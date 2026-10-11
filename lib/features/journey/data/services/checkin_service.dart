import '../../../../core/database/database_helper.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/auth_event_bus.dart';
import '../../../../core/services/token_storage.dart';
import '../../../../core/services/offline_store.dart';
import '../../../../core/services/trekking_catalog_service.dart';

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
  late final TrekkingCatalogService _catalog;
  CheckinService({
    TokenStorage? tokenStorage,
    AuthEventBus? eventBus,
    DatabaseHelper? dbHelper,
  }) {
    final storage = tokenStorage ?? const SecureTokenStorage();
    final bus = eventBus ?? AuthEventBus();
    final offline = tokenStorage == null && dbHelper == null
        ? OfflineStore.instance
        : OfflineStore(
            databaseHelper: dbHelper,
            ownerProvider: () async =>
                OfflineStore.ownerFromToken(await storage.getAccessToken()),
          );
    _catalog = TrekkingCatalogService(
      store: offline,
      client: DioClient.createTrekkingDio(tokenStorage: storage, eventBus: bus),
      checkinClient: DioClient.createCheckinDio(
        tokenStorage: storage,
        eventBus: bus,
      ),
    );
  }
  Future<CheckinResult> performCheckin({
    required String localJourneyId,
    required String milestoneId,
    required double latitude,
    required double longitude,
    required double accuracyMeters,
    required double distanceToTarget,
    required String userId,
  }) async {
    final data = await _catalog.checkIn(localJourneyId, {
      'milestoneId': milestoneId,
      'latitude': latitude,
      'longitude': longitude,
      'accuracyMeters': accuracyMeters,
      'checkedAt': DateTime.now().toUtc().toIso8601String(),
    });
    final verification =
        data['verification']?['status']?.toString() ?? 'PENDING';
    return CheckinResult(
      serverCheckinId: data['checkinId']?.toString() ?? '',
      milestoneType: data['milestoneType'] ?? 'CHECKPOINT',
      qualifiesPlaceVisit: data['qualifiesPlaceVisit'] == true,
      verificationStatus: verification,
      raw: data,
    );
  }

  Future<int> syncOfflineCheckins() async {
    final db = await _catalog.offline.databaseHelper.database;
    final owner = await _catalog.offline.requireOwner();
    final before = await db.query(
      'offline_checkins',
      where: "userId = ? AND syncStatus = 'PENDING'",
      whereArgs: [owner],
    );
    await _catalog.syncPending();
    final after = await db.query(
      'offline_checkins',
      where: "userId = ? AND syncStatus = 'PENDING'",
      whereArgs: [owner],
    );
    final remaining = after.map((c) => c['localCheckinId']).toSet();
    final synced = await db.query(
      'offline_checkins',
      where: "userId = ? AND syncStatus = 'SYNCED'",
      whereArgs: [owner],
    );
    final syncedIds = synced.map((c) => c['localCheckinId']).toSet();
    return before
        .where(
          (c) =>
              !remaining.contains(c['localCheckinId']) &&
              syncedIds.contains(c['localCheckinId']),
        )
        .length;
  }
}
