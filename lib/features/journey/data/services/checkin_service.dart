import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/database/daos/checkin_dao.dart';
import '../../../../core/database/daos/journey_dao.dart';
import '../../../../core/database/daos/sync_dao.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/database/models/offline_checkin.dart';
import '../../../../core/database/models/sync_queue_item.dart';
import '../../../../core/network/api_error_handler.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/auth_event_bus.dart';
import '../../../../core/services/token_storage.dart';

/// Kết quả check-in thành công
class CheckinResult {
  final String serverCheckinId;
  final String milestoneType;
  final bool qualifiesPlaceVisit;
  final String verificationStatus; // VERIFIED | PENDING_VERIFICATION
  final Map<String, dynamic> raw;

  const CheckinResult({
    required this.serverCheckinId,
    required this.milestoneType,
    this.qualifiesPlaceVisit = false,
    this.verificationStatus = 'VERIFIED',
    this.raw = const {},
  });
}

/// Service xử lý check-in GPS cho milestone trekking.
///
/// Flow:
///   Online  → POST /checkins → lưu local SYNCED
///   Offline → lưu local PENDING → enqueue sync_queue → sync khi có mạng
///
/// Service gọi **checkin-service** (port 3002) trực tiếp, không qua trekking-service.
class CheckinService {
  final Dio _dio;
  final CheckinDao _checkinDao;
  final JourneyDao _journeyDao;
  final SyncDao _syncDao;

  CheckinService({
    TokenStorage? tokenStorage,
    AuthEventBus? eventBus,
    DatabaseHelper? dbHelper,
  })  : _dio = DioClient.createCheckinDio(
          tokenStorage: tokenStorage ?? SecureTokenStorage(),
          eventBus: eventBus ?? AuthEventBus(),
        ),
        _checkinDao = CheckinDao(dbHelper: dbHelper ?? DatabaseHelper.instance),
        _journeyDao = JourneyDao(dbHelper: dbHelper ?? DatabaseHelper.instance),
        _syncDao = SyncDao(dbHelper: dbHelper ?? DatabaseHelper.instance);

  /// Thực hiện check-in online tại milestone.
  ///
  /// - [localJourneyId]: localJourneyId trong SQLite (dùng để lấy serverJourneyId)
  /// - [milestoneId]: server milestoneId
  /// - [latitude], [longitude]: tọa độ GPS hiện tại của user
  /// - [accuracyMeters]: độ chính xác GPS
  /// - [distanceToTarget]: khoảng cách đến milestone (m)
  /// - [userId]: userId từ token storage (không hard-code)
  ///
  /// Returns [CheckinResult] khi thành công, ném Exception khi thất bại.
  Future<CheckinResult> performCheckin({
    required String localJourneyId,
    required String milestoneId,
    required double latitude,
    required double longitude,
    required double accuracyMeters,
    required double distanceToTarget,
    required String userId,
  }) async {
    // Lấy serverJourneyId
    final localJourney = await _journeyDao.getJourney(localJourneyId);
    final serverJourneyId = localJourney?.serverJourneyId;

    if (serverJourneyId == null) {
      // Journey chưa sync lên server → lưu offline, sẽ sync sau
      await _saveOfflineCheckin(
        localJourneyId: localJourneyId,
        milestoneId: milestoneId,
        latitude: latitude,
        longitude: longitude,
        accuracyMeters: accuracyMeters,
        distanceToTarget: distanceToTarget,
        userId: userId,
      );
      throw Exception(
        'Hành trình chưa đồng bộ với server. Check-in đã lưu offline và sẽ gửi khi có mạng.',
      );
    }

    final now = DateTime.now();
    final localCheckinId = _newUuid();

    try {
      // POST /api/v1/checkins
      final resp = await _dio.post(
        '/checkins',
        data: {
          'journeyId': serverJourneyId,
          'milestoneId': milestoneId,
          'latitude': latitude,
          'longitude': longitude,
          'accuracyMeters': accuracyMeters,
          'checkedAt': now.toIso8601String(),
        },
      );

      final data = _extractData(resp.data);
      final serverCheckinId = data['milestoneCheckinId'] as String? ??
          data['checkinId'] as String? ??
          localCheckinId;

      // Lưu local SYNCED
      await _checkinDao.insertCheckin(OfflineCheckin(
        localCheckinId: localCheckinId,
        serverCheckinId: serverCheckinId,
        localJourneyId: localJourneyId,
        milestoneId: milestoneId,
        userId: userId,
        latitude: latitude,
        longitude: longitude,
        accuracyMeters: accuracyMeters,
        distanceToTargetMeters: distanceToTarget,
        verificationStatus: data['verification']?['status'] as String? ??
            'VERIFIED',
        checkedAt: now,
        syncStatus: 'SYNCED',
        createdAt: now,
      ));

      return CheckinResult(
        serverCheckinId: serverCheckinId,
        milestoneType: data['milestoneType'] as String? ?? 'CHECKPOINT',
        qualifiesPlaceVisit: data['qualifiesPlaceVisit'] as bool? ?? false,
        verificationStatus: data['verification']?['status'] as String? ??
            'VERIFIED',
        raw: data,
      );
    } on DioException catch (e) {
      // Phân tích lỗi để quyết định có save offline không
      final statusCode = e.response?.statusCode;

      // 422 CHECKIN_OUT_OF_RADIUS / GPS_ACCURACY_TOO_LOW → không lưu offline
      if (statusCode == 422 || statusCode == 409) {
        final msg = ApiErrorHandler.handle(e);
        throw Exception(msg);
      }

      // Lỗi mạng / server 500-503 → lưu offline, retry sau
      if (kDebugMode) {
        debugPrint('[CheckinService] Network error, saving offline: $e');
      }
      await _saveOfflineCheckin(
        localJourneyId: localJourneyId,
        milestoneId: milestoneId,
        latitude: latitude,
        longitude: longitude,
        accuracyMeters: accuracyMeters,
        distanceToTarget: distanceToTarget,
        userId: userId,
        localCheckinId: localCheckinId,
        checkedAt: now,
      );
      throw Exception(
        'Không có mạng. Check-in đã lưu offline và sẽ được gửi khi có kết nối.',
      );
    }
  }

  /// Đồng bộ tất cả offline checkins lên checkin-service.
  /// Dùng batch endpoint POST /checkins/sync để tránh nhiều request.
  Future<int> syncOfflineCheckins() async {
    final pending = await _checkinDao.getPendingSyncCheckins();
    if (pending.isEmpty) return 0;

    // Lấy serverJourneyId cho từng checkin
    final items = <Map<String, dynamic>>[];
    for (final c in pending) {
      final localJ = await _journeyDao.getJourney(c.localJourneyId);
      final serverJourneyId = localJ?.serverJourneyId;
      if (serverJourneyId == null) continue; // journey vẫn chưa sync

      items.add({
        'clientCheckinId': c.localCheckinId,
        'journeyId': serverJourneyId,
        'milestoneId': c.milestoneId,
        'latitude': c.latitude,
        'longitude': c.longitude,
        'accuracyMeters': c.accuracyMeters ?? 0,
        'checkedAt': c.checkedAt.toIso8601String(),
      });
    }
    if (items.isEmpty) return 0;

    try {
      final resp = await _dio.post('/checkins/sync', data: {'items': items});
      final data = _extractData(resp.data);
      final results = (data['results'] as List<dynamic>?) ?? [];

      int synced = 0;
      for (final r in results.cast<Map<String, dynamic>>()) {
        final clientId = r['clientCheckinId'] as String?;
        final serverCheckinId = r['serverCheckinId'] as String?;
        final status = r['status'] as String? ?? 'FAILED';

        if (clientId == null) continue;
        if (status != 'FAILED' && serverCheckinId != null) {
          await _checkinDao.markCheckinSynced(clientId, serverCheckinId);
          synced++;
        }
        // status == 'FAILED' → để lại pending hoặc mark failed
      }
      return synced;
    } on DioException catch (e) {
      if (kDebugMode) debugPrint('[CheckinService] syncOfflineCheckins error: $e');
      return 0;
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<void> _saveOfflineCheckin({
    required String localJourneyId,
    required String milestoneId,
    required double latitude,
    required double longitude,
    required double accuracyMeters,
    required double distanceToTarget,
    required String userId,
    String? localCheckinId,
    DateTime? checkedAt,
  }) async {
    final id = localCheckinId ?? _newUuid();
    final now = checkedAt ?? DateTime.now();

    await _checkinDao.insertCheckin(OfflineCheckin(
      localCheckinId: id,
      localJourneyId: localJourneyId,
      milestoneId: milestoneId,
      userId: userId,
      latitude: latitude,
      longitude: longitude,
      accuracyMeters: accuracyMeters,
      distanceToTargetMeters: distanceToTarget,
      checkedAt: now,
      syncStatus: 'PENDING',
      createdAt: now,
    ));

    // Enqueue trong sync_queue với priority IMMEDIATE
    await _syncDao.enqueue(SyncQueueItem(
      entityType: 'CHECKIN',
      entityId: id,
      operation: 'CREATE',
      payload: jsonEncode({
        'localCheckinId': id,
        'localJourneyId': localJourneyId,
        'milestoneId': milestoneId,
        'latitude': latitude,
        'longitude': longitude,
        'accuracyMeters': accuracyMeters,
        'checkedAt': now.toIso8601String(),
      }),
      status: 'PENDING',
      idempotencyKey: 'CHECKIN_${id}_CREATE',
      priority: 'IMMEDIATE',
      createdAt: now,
    ));
  }

  Map<String, dynamic> _extractData(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      final data = responseData['data'];
      if (data is Map<String, dynamic>) return data;
      return responseData;
    }
    return {};
  }

  String _newUuid() {
    final now = DateTime.now().microsecondsSinceEpoch;
    return '${now.toRadixString(16)}-${Object().hashCode.toRadixString(16)}';
  }
}
