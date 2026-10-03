import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/database/daos/cache_dao.dart';
import '../../../../core/database/daos/journey_dao.dart';
import '../../../../core/database/daos/marker_dao.dart';
import '../../../../core/database/daos/sync_dao.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/database/models/cached_milestone.dart';
import '../../../../core/database/models/cached_route.dart';
import '../../../../core/database/models/local_journey.dart';
import '../../../../core/database/models/local_journey_marker.dart';
import '../../../../core/database/models/local_marker_media.dart';
import '../../../../core/database/models/local_contribution.dart';
import '../../../../core/database/models/sync_queue_item.dart';
import '../../../../core/network/api_error_handler.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/auth_event_bus.dart';
import '../../../../core/services/token_storage.dart';
import '../datasources/journey_remote_datasource.dart';
import '../models/contribution_model.dart';
import '../models/journey_model.dart';
import '../models/marker_model.dart';
import '../models/milestone_model.dart';
import '../models/review_model.dart';
import '../models/route_model.dart';

/// Simple non-RFC UUID — unique enough for local IDs
String _newUuid() {
  final now = DateTime.now().microsecondsSinceEpoch;
  return '${now.toRadixString(16)}-${Object().hashCode.toRadixString(16)}';
}

/// Repository duy nhất cho toàn bộ Journey module.
///
/// Chiến lược offline-first:
///   Online  → gọi remote → upsert SQLite cache
///   Offline → đọc SQLite → enqueue sync_queue
class JourneyRepository {
  late final JourneyRemoteDataSource _remote;
  late final JourneyDao _journeyDao;
  late final MarkerDao _markerDao;
  late final CacheDao _cacheDao;
  late final SyncDao _syncDao;

  JourneyRepository({
    TokenStorage? tokenStorage,
    AuthEventBus? eventBus,
    DatabaseHelper? dbHelper,
  }) {
    final storage = tokenStorage ?? SecureTokenStorage();
    final bus = eventBus ?? AuthEventBus();
    // Trekking-service dùng port 3003 — dùng createTrekkingDio
    final dio = DioClient.createTrekkingDio(tokenStorage: storage, eventBus: bus);
    _remote = JourneyRemoteDataSource(dio);

    final db = dbHelper ?? DatabaseHelper.instance;
    _journeyDao = JourneyDao(dbHelper: db);
    _markerDao = MarkerDao(dbHelper: db);
    _cacheDao = CacheDao(dbHelper: db);
    _syncDao = SyncDao(dbHelper: db);
  }

  // ── JOURNEYS ──────────────────────────────────────────────────────────────

  Future<List<JourneyModel>> getJourneys({String? status}) async {
    try {
      final list = await _remote.getJourneys(status: status);
      for (final j in list) {
        await _upsertJourneyLocal(j);
      }
      return list;
    } on DioException catch (e) {
      debugPrint('[JourneyRepo] getJourneys offline: ${ApiErrorHandler.handle(e)}');
      return _getLocalJourneys(status: status);
    }
  }

  Future<JourneyStatistics?> getStatistics() async {
    try {
      return await _remote.getStatistics();
    } on DioException catch (e) {
      debugPrint('[JourneyRepo] getStatistics offline: ${ApiErrorHandler.handle(e)}');
      return null;
    }
  }

  Future<JourneyModel?> getJourneyById(String localOrServerId) async {
    try {
      final serverJourney = await _remote.getJourneyById(localOrServerId);
      await _upsertJourneyLocal(serverJourney);
      return serverJourney;
    } on DioException {
      // Tìm local theo localJourneyId trước
      final byLocal = await _journeyDao.getJourney(localOrServerId);
      if (byLocal != null) return _localToModel(byLocal);

      // Tìm theo serverJourneyId
      final allLocal = await _journeyDao.getJourneysByUser('');
      final match = allLocal
          .where((j) => j.serverJourneyId == localOrServerId)
          .firstOrNull;
      return match != null ? _localToModel(match) : null;
    }
  }

  /// Tạo journey — offline-first:
  /// 1. Insert local với clientJourneyId = localUUID
  /// 2. POST API với Idempotency-Key = clientJourneyId
  /// 3. Online: markSynced(localId, serverJourneyId)
  /// 4. Offline: enqueue sync_queue
  Future<JourneyModel> createJourney({
    required String trekkingPlaceId,
    required String trekkingRouteId,
    required String name,
    String? provinceId,
    DateTime? plannedStartAt,
    DateTime? plannedEndAt,
    int? memberCount,
    String? notes,
    bool enableCheckin = true,
    String userId = 'local_user',
  }) async {
    final localId = _newUuid();
    final now = DateTime.now();

    final localJourney = LocalJourney(
      localJourneyId: localId,
      serverJourneyId: null,
      userId: userId,
      trekkingPlaceId: trekkingPlaceId,
      trekkingRouteId: trekkingRouteId,
      provinceId: provinceId,
      name: name,
      status: 'PLANNED',
      plannedStartAt: plannedStartAt,
      syncStatus: 'PENDING',
      createdAt: now,
      updatedAt: now,
    );
    await _journeyDao.insertJourney(localJourney);

    // Body theo contract backend — gửi clientJourneyId để idempotency
    final body = <String, dynamic>{
      'trekkingPlaceId': trekkingPlaceId,
      'trekkingRouteId': trekkingRouteId,
      'name': name,
      // clientJourneyId = localId → server dùng làm idempotency key
      'clientJourneyId': localId,
      if (provinceId != null) 'provinceId': provinceId,
      if (plannedStartAt != null)
        'plannedStartAt': plannedStartAt.toIso8601String(),
      if (plannedEndAt != null) 'plannedEndAt': plannedEndAt.toIso8601String(),
      // Backend dùng "participantCount", không phải "memberCount"
      if (memberCount != null) 'participantCount': memberCount,
      if (notes != null && notes.isNotEmpty) 'note': notes,
    };

    try {
      // Idempotency-Key header = clientJourneyId để chống duplicate retry
      final serverJourney =
          await _remote.createJourney(body, idempotencyKey: localId);
      await _journeyDao.markSynced(localId, serverJourney.journeyId);
      // Upsert với serverJourneyId đầy đủ
      await _upsertJourneyLocal(serverJourney);
      return serverJourney;
    } on DioException catch (e) {
      debugPrint('[JourneyRepo] createJourney offline: ${ApiErrorHandler.handle(e)}');
      await _enqueueSyncCreate('JOURNEY', localId, body);
      return _localToModel(localJourney);
    }
  }

  Future<JourneyModel> startJourney(String localJourneyId) async {
    final startedAt = DateTime.now();
    await _updateJourneyStatusLocal(localJourneyId, 'ACTIVE', startedAt: startedAt);
    return _remoteStatusAction(localJourneyId, 'start',
        body: {'startedAt': startedAt.toIso8601String()});
  }

  Future<JourneyModel> pauseJourney(String localJourneyId) async {
    await _updateJourneyStatusLocal(localJourneyId, 'PAUSED');
    return _remoteStatusAction(localJourneyId, 'pause');
  }

  Future<JourneyModel> resumeJourney(String localJourneyId) async {
    await _updateJourneyStatusLocal(localJourneyId, 'ACTIVE');
    return _remoteStatusAction(localJourneyId, 'resume');
  }

  /// Complete journey — gửi statistics + encodedPolyline.
  /// Body theo contract backend: { completedAt, statistics: {...}, track: { encodedPolyline } }
  Future<JourneyModel> completeJourney(
    String localJourneyId, {
    String? encodedPolyline,
    double? distanceMeters,
    int? durationSeconds,
    double? elevationGain,
    double? maxAltitude,
    double? averageSpeed,
  }) async {
    final completedAt = DateTime.now();
    await _updateJourneyStatusLocal(localJourneyId, 'COMPLETED',
        completedAt: completedAt);

    try {
      final local = await _journeyDao.getJourney(localJourneyId);
      final serverId = local?.serverJourneyId;
      if (serverId == null) throw StateError('no server id');

      // Idempotency key cho complete — chống duplicate retry offline
      final idempotencyKey = 'COMPLETE_$localJourneyId';

      return await _remote.completeJourney(
        serverId,
        completedAt: completedAt,
        encodedPolyline: encodedPolyline,
        distanceMeters: distanceMeters,
        durationSeconds: durationSeconds,
        elevationGain: elevationGain,
        maxAltitude: maxAltitude,
        averageSpeed: averageSpeed,
        idempotencyKey: idempotencyKey,
      );
    } on Exception catch (e) {
      debugPrint('[JourneyRepo] completeJourney error: $e');
      final local = await _journeyDao.getJourney(localJourneyId);
      return _localToModel(local!);
    }
  }

  Future<JourneyModel> cancelJourney(String localJourneyId) async {
    await _updateJourneyStatusLocal(localJourneyId, 'CANCELLED');
    return _remoteStatusAction(localJourneyId, 'cancel');
  }

  // ── ROUTES ────────────────────────────────────────────────────────────────

  Future<RouteModel?> getRoute(String routeId) async {
    try {
      final route = await _remote.getRoute(routeId);
      await _cacheDao.upsertRoute(CachedRoute(
        trekkingRouteId: route.routeId,
        trekkingPlaceId: route.trekkingPlaceId,
        name: route.name,
        description: route.description,
        difficulty: route.difficulty,
        distanceMeters: route.distanceMeters?.toInt(),
        estimatedDurationMinutes: route.estimatedDurationMinutes,
        elevationGain: route.elevationGain,
        maxElevation: route.maxElevation,
        startLatitude: route.startLatitude,
        startLongitude: route.startLongitude,
        endLatitude: route.endLatitude,
        endLongitude: route.endLongitude,
        encodedPolyline: route.encodedPolyline,
        mapVersion: route.mapVersion,
        cachedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      return route;
    } on DioException {
      final cached = await _cacheDao.getRoute(routeId);
      if (cached == null) return null;
      return RouteModel(
        routeId: cached.trekkingRouteId,
        trekkingPlaceId: cached.trekkingPlaceId,
        name: cached.name,
        description: cached.description,
        difficulty: cached.difficulty,
        distanceMeters: cached.distanceMeters?.toDouble(),
        estimatedDurationMinutes: cached.estimatedDurationMinutes,
        elevationGain: cached.elevationGain,
        maxElevation: cached.maxElevation,
        startLatitude: cached.startLatitude,
        startLongitude: cached.startLongitude,
        endLatitude: cached.endLatitude,
        endLongitude: cached.endLongitude,
        encodedPolyline: cached.encodedPolyline,
        mapVersion: cached.mapVersion,
      );
    }
  }

  Future<List<MilestoneModel>> getMilestones(String routeId) async {
    try {
      final milestones = await _remote.getMilestones(routeId);
      for (final m in milestones) {
        await _cacheDao.upsertMilestone(CachedMilestone(
          milestoneId: m.milestoneId,
          trekkingRouteId: m.trekkingRouteId,
          name: m.name,
          description: m.description,
          type: m.type,
          sequenceNumber: m.sequenceNumber,
          latitude: m.latitude,
          longitude: m.longitude,
          altitude: m.altitude,
          checkinRadiusMeters: m.checkinRadiusMeters,
          required: m.required,
          imageUrl: m.imageUrl,
          cachedAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
      }
      return milestones;
    } on DioException {
      final cached = await _cacheDao.getMilestonesByRoute(routeId);
      return cached
          .map((c) => MilestoneModel(
                milestoneId: c.milestoneId,
                trekkingRouteId: c.trekkingRouteId,
                name: c.name,
                description: c.description,
                type: c.type,
                sequenceNumber: c.sequenceNumber,
                latitude: c.latitude,
                longitude: c.longitude,
                altitude: c.altitude,
                checkinRadiusMeters: c.checkinRadiusMeters,
                required: c.required,
                imageUrl: c.imageUrl,
              ))
          .toList();
    }
  }

  Future<OfflinePackageInfo?> getOfflinePackage(String routeId) async {
    try {
      return await _remote.getOfflinePackage(routeId);
    } on DioException catch (e) {
      debugPrint('[JourneyRepo] getOfflinePackage: ${ApiErrorHandler.handle(e)}');
      return null;
    }
  }

  // ── MARKERS ───────────────────────────────────────────────────────────────

  Future<List<MarkerModel>> getMarkers(String localJourneyId) async {
    final local = await _markerDao.getMarkersByJourney(localJourneyId);
    final models = local.map(_localMarkerToModel).toList();

    try {
      final localJ = await _journeyDao.getJourney(localJourneyId);
      final serverId = localJ?.serverJourneyId;
      if (serverId != null) {
        final serverMarkers = await _remote.getMarkers(serverId);
        for (final sm in serverMarkers) {
          // sm.serverMarkerId = journeyMarkerId từ backend
          final serverMarkerId = sm.serverMarkerId ?? sm.markerId;
          final hasLocal =
              local.any((l) => l.serverMarkerId == serverMarkerId);
          if (!hasLocal && serverMarkerId.isNotEmpty) {
            await _markerDao.insertMarker(LocalJourneyMarker(
              localMarkerId: _newUuid(),
              serverMarkerId: serverMarkerId,
              localJourneyId: localJourneyId,
              userId: sm.localJourneyId, // placeholder
              name: sm.name,
              type: sm.type,
              note: sm.note,
              latitude: sm.latitude,
              longitude: sm.longitude,
              altitude: sm.altitude,
              markedAt: sm.markedAt,
              syncStatus: 'SYNCED',
              createdAt: sm.markedAt,
            ));
          }
        }
      }
    } on DioException {/* offline — dùng local */}

    return models;
  }

  /// Tạo marker — lưu local NGAY, sau đó sync lên server.
  /// Dùng clientMarkerId = localMarkerId làm idempotency key.
  Future<MarkerModel> createMarker({
    required String localJourneyId,
    required String userId,
    required String name,
    required String type,
    required double latitude,
    required double longitude,
    double? altitude,
    double? accuracy,
    String? note,
    List<String> mediaLocalPaths = const [],
  }) async {
    final localMarkerId = _newUuid();
    final now = DateTime.now();

    final marker = LocalJourneyMarker(
      localMarkerId: localMarkerId,
      localJourneyId: localJourneyId,
      userId: userId,
      name: name,
      type: type,
      note: note,
      latitude: latitude,
      longitude: longitude,
      altitude: altitude,
      accuracyMeters: accuracy,
      markedAt: now,
      syncStatus: 'LOCAL_ONLY',
      createdAt: now,
    );
    await _markerDao.insertMarker(marker);

    for (final path in mediaLocalPaths) {
      await _markerDao.insertMedia(LocalMarkerMedia(
        localMarkerMediaId: _newUuid(),
        localMarkerId: localMarkerId,
        type: 'IMAGE',
        localPath: path,
        uploadStatus: 'LOCAL',
        createdAt: now,
      ));
    }

    try {
      final localJ = await _journeyDao.getJourney(localJourneyId);
      final serverId = localJ?.serverJourneyId;
      if (serverId != null) {
        // Body theo backend contract — location GeoJSON, clientMarkerId
        final serverMarker = await _remote.createMarker(
          serverId,
          {
            'name': name,
            'type': type,
            'location': {
              'type': 'Point',
              'coordinates': [longitude, latitude], // GeoJSON: [lng, lat]
            },
            if (altitude != null) 'altitude': altitude,
            if (accuracy != null) 'accuracyMeters': accuracy,
            if (note != null && note.isNotEmpty) 'note': note,
            'markedAt': now.toIso8601String(),
          },
          clientMarkerId: localMarkerId,
        );
        final serverMarkerId =
            serverMarker.serverMarkerId ?? serverMarker.markerId;
        await _markerDao.markMarkerSynced(localMarkerId, serverMarkerId);
        return _localMarkerToModel(
          marker.copyWith(syncStatus: 'SYNCED'),
          mediaLocalPaths: mediaLocalPaths,
        );
      }
    } on Exception catch (e) {
      debugPrint('[JourneyRepo] createMarker offline: $e');
    }

    // Offline → enqueue
    await _enqueueSyncCreate('JOURNEY_MARKER', localMarkerId, {
      'localMarkerId': localMarkerId,
      'localJourneyId': localJourneyId,
      'name': name,
      'type': type,
      'latitude': latitude,
      'longitude': longitude,
      if (altitude != null) 'altitude': altitude,
      if (note != null) 'note': note,
      'markedAt': now.toIso8601String(),
    });

    return _localMarkerToModel(marker, mediaLocalPaths: mediaLocalPaths);
  }

  Future<void> updateMarker(
    String localMarkerId, {
    String? name,
    String? type,
    String? note,
  }) async {
    final marker = await _markerDao.getMarker(localMarkerId);
    if (marker == null) return;
    final updated = marker.copyWith(
      name: name,
      type: type,
      note: note,
      updatedAt: DateTime.now(),
    );
    await _markerDao.updateMarker(updated);
    try {
      if (marker.serverMarkerId != null) {
        final localJ = await _journeyDao.getJourney(marker.localJourneyId);
        if (localJ?.serverJourneyId != null) {
          await _remote.updateMarker(
            localJ!.serverJourneyId!,
            marker.serverMarkerId!,
            {
              if (name != null) 'name': name,
              if (type != null) 'type': type,
              if (note != null) 'note': note,
            },
          );
        }
      }
    } on Exception catch (e) {
      debugPrint('[JourneyRepo] updateMarker offline: $e');
    }
  }

  Future<void> deleteMarker(String localMarkerId) async {
    final marker = await _markerDao.getMarker(localMarkerId);
    await _markerDao.deleteMarker(localMarkerId);
    try {
      if (marker?.serverMarkerId != null) {
        final localJ =
            await _journeyDao.getJourney(marker!.localJourneyId);
        if (localJ?.serverJourneyId != null) {
          await _remote.deleteMarker(
            localJ!.serverJourneyId!,
            marker.serverMarkerId!,
          );
        }
      }
    } on Exception catch (e) {
      debugPrint('[JourneyRepo] deleteMarker offline: $e');
    }
  }

  // ── REVIEWS ───────────────────────────────────────────────────────────────

  Future<List<ReviewModel>> getReviews(
    String placeId, {
    int page = 1,
    int limit = 20,
  }) async {
    return _remote.getReviews(placeId, page: page, limit: limit);
  }

  Future<ReviewModel?> getMyReview(String placeId) async {
    return _remote.getMyReview(placeId);
  }

  Future<ReviewModel> createReview(
    String placeId,
    CreateReviewRequest request,
  ) async {
    return _remote.createReview(placeId, request);
  }

  Future<ReviewModel> updateReview(
    String placeId,
    String reviewId,
    CreateReviewRequest request,
  ) async {
    return _remote.updateReview(placeId, reviewId, request);
  }

  Future<void> deleteReview(String placeId, String reviewId) async {
    return _remote.deleteReview(placeId, reviewId);
  }

  // ── CONTRIBUTIONS ─────────────────────────────────────────────────────────

  /// Submit route contribution — lưu local TRƯỚC, sync sau nếu offline.
  Future<ContributionModel> submitRouteContribution(
    SubmitRouteContributionRequest request, {
    required String userId,
  }) async {
    final localId = _newUuid();
    final now = DateTime.now();

    // Lưu local contribution record
    await _syncDao.insertContribution(LocalContribution(
      localContributionId: localId,
      userId: userId,
      type: 'ROUTE_SUBMISSION',
      sourceLocalJourneyId: null, // không cần, đã có serverJourneyId
      sourceServerJourneyId: request.sourceJourneyId,
      payload: jsonEncode(request.toJson()),
      serverStatus: 'DRAFT',
      syncStatus: 'PENDING',
      createdAt: now,
      updatedAt: now,
    ));

    try {
      final result = await _remote.submitRouteContribution(request);
      await _syncDao.updateContributionServerStatus(
        localId,
        serverContributionId: result.contributionId,
        serverStatus: result.status,
      );
      return result;
    } on DioException catch (e) {
      debugPrint('[JourneyRepo] submitRoute offline: ${ApiErrorHandler.handle(e)}');
      // Enqueue để retry khi có mạng
      await _enqueueSyncCreate('ROUTE_SUBMISSION', localId,
          request.toJson());
      // Trả về model local tạm thời
      return ContributionModel(
        contributionId: localId,
        userId: userId,
        type: 'ROUTE_SUBMISSION',
        status: 'DRAFT',
        sourceJourneyId: request.sourceJourneyId,
        proposedName: request.proposedName,
      );
    }
  }

  Future<ContributionModel> submitPlaceContribution(
    SubmitPlaceContributionRequest request, {
    required String userId,
  }) async {
    return _remote.submitPlaceContribution(request);
  }

  Future<MyContributionsResponse> getMyContributions({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    return _remote.getMyContributions(
        status: status, page: page, limit: limit);
  }

  Future<ContributionModel> getMyContributionById(String id) async {
    return _remote.getMyContributionById(id);
  }

  // ── PRIVATE HELPERS ───────────────────────────────────────────────────────

  Future<void> _updateJourneyStatusLocal(
    String localJourneyId,
    String status, {
    DateTime? startedAt,
    DateTime? completedAt,
  }) async {
    final j = await _journeyDao.getJourney(localJourneyId);
    if (j == null) return;
    await _journeyDao.updateJourney(j.copyWith(
      status: status,
      startedAt: startedAt ?? j.startedAt,
      completedAt: completedAt ?? j.completedAt,
      updatedAt: DateTime.now(),
    ));
  }

  Future<JourneyModel> _remoteStatusAction(
    String localJourneyId,
    String action, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final local = await _journeyDao.getJourney(localJourneyId);
      final serverId = local?.serverJourneyId;
      if (serverId == null) throw StateError('no server id');
      switch (action) {
        case 'start':
          return await _remote.startJourney(serverId,
              startedAt: body?['startedAt'] != null
                  ? DateTime.tryParse(body!['startedAt'] as String)
                  : null);
        case 'pause':
          return await _remote.pauseJourney(serverId);
        case 'resume':
          return await _remote.resumeJourney(serverId);
        case 'cancel':
          return await _remote.cancelJourney(serverId);
        default:
          throw ArgumentError('Unknown action: $action');
      }
    } on Exception catch (e) {
      debugPrint('[JourneyRepo] _remoteStatusAction $action offline: $e');
      final local = await _journeyDao.getJourney(localJourneyId);
      return _localToModel(local!);
    }
  }

  /// Upsert journey vào local DB — tìm record theo serverJourneyId HOẶC clientJourneyId.
  Future<void> _upsertJourneyLocal(JourneyModel j) async {
    final now = DateTime.now();

    // 1. Tìm theo serverJourneyId
    var existing = await _findLocalByServerId(j.journeyId);

    // 2. Tìm theo clientJourneyId (backend echo về trong response)
    if (existing == null && j.clientJourneyId != null) {
      existing = await _journeyDao.getJourney(j.clientJourneyId!);
    }

    if (existing != null) {
      await _journeyDao.updateJourney(existing.copyWith(
        serverJourneyId: j.journeyId,
        status: j.status,
        startedAt: j.startedAt ?? existing.startedAt,
        completedAt: j.completedAt ?? existing.completedAt,
        distanceMeters: j.distanceMeters,
        durationSeconds: j.durationSeconds,
        elevationGain: j.elevationGain,
        maxAltitude: j.maxAltitude,
        checkinCount: j.checkinCount,
        markerCount: j.markerCount,
        syncStatus: 'SYNCED',
        updatedAt: now,
      ));
    } else {
      await _journeyDao.insertJourney(LocalJourney(
        localJourneyId: j.clientJourneyId ?? _newUuid(),
        serverJourneyId: j.journeyId,
        userId: j.userId,
        trekkingPlaceId: j.trekkingPlaceId,
        trekkingRouteId: j.trekkingRouteId,
        provinceId: j.provinceId,
        name: j.name,
        status: j.status,
        plannedStartAt: j.plannedStartAt,
        startedAt: j.startedAt,
        completedAt: j.completedAt,
        distanceMeters: j.distanceMeters,
        durationSeconds: j.durationSeconds,
        elevationGain: j.elevationGain,
        maxAltitude: j.maxAltitude,
        checkinCount: j.checkinCount,
        markerCount: j.markerCount,
        syncStatus: 'SYNCED',
        createdAt: j.createdAt ?? now,
        updatedAt: j.updatedAt ?? now,
      ));
    }
  }

  Future<LocalJourney?> _findLocalByServerId(String serverJourneyId) async {
    final db = DatabaseHelper.instance;
    final database = await db.database;
    final rows = await database.query(
      'local_journeys',
      where: 'serverJourneyId = ?',
      whereArgs: [serverJourneyId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return LocalJourney.fromMap(rows.first);
  }

  Future<List<JourneyModel>> _getLocalJourneys({String? status}) async {
    final locals = status != null
        ? await _journeyDao.getJourneysByStatus(status)
        : await _journeyDao.getJourneysByUser('local_user');
    return locals.map(_localToModel).toList();
  }

  JourneyModel _localToModel(LocalJourney l) {
    return JourneyModel(
      journeyId: l.serverJourneyId ?? l.localJourneyId,
      userId: l.userId,
      trekkingPlaceId: l.trekkingPlaceId,
      trekkingRouteId: l.trekkingRouteId,
      provinceId: l.provinceId,
      name: l.name,
      status: l.status,
      plannedStartAt: l.plannedStartAt,
      startedAt: l.startedAt,
      completedAt: l.completedAt,
      distanceMeters: l.distanceMeters,
      durationSeconds: l.durationSeconds,
      elevationGain: l.elevationGain,
      maxAltitude: l.maxAltitude,
      checkinCount: l.checkinCount,
      markerCount: l.markerCount,
      createdAt: l.createdAt,
      updatedAt: l.updatedAt,
    );
  }

  MarkerModel _localMarkerToModel(
    LocalJourneyMarker m, {
    List<String> mediaLocalPaths = const [],
  }) {
    return MarkerModel(
      markerId: m.localMarkerId,
      serverMarkerId: m.serverMarkerId,
      localJourneyId: m.localJourneyId,
      name: m.name,
      type: m.type,
      note: m.note,
      latitude: m.latitude,
      longitude: m.longitude,
      altitude: m.altitude,
      markedAt: m.markedAt,
      syncStatus: m.syncStatus,
      mediaLocalPaths: mediaLocalPaths,
    );
  }

  Future<void> _enqueueSyncCreate(
    String entityType,
    String entityId,
    Map<String, dynamic> payload,
  ) async {
    final key = '${entityType}_${entityId}_CREATE';
    await _syncDao.enqueue(SyncQueueItem(
      entityType: entityType,
      entityId: entityId,
      operation: 'CREATE',
      payload: jsonEncode(payload),
      status: 'PENDING',
      idempotencyKey: key,
      priority: 'NORMAL',
      createdAt: DateTime.now(),
    ));
  }
}
