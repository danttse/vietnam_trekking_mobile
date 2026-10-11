import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/database/daos/journey_dao.dart';
import '../../../../core/database/daos/marker_dao.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/database/models/local_journey_marker.dart';
import '../../../../core/database/models/local_marker_media.dart';
import '../../../../core/network/api_error_handler.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/auth_event_bus.dart';
import '../../../../core/services/token_storage.dart';
import '../../../../core/services/offline_store.dart';
import '../../../../core/services/trekking_catalog_service.dart';
import '../datasources/journey_remote_datasource.dart';
import '../models/contribution_model.dart';
import '../models/journey_model.dart' hide JourneyStatistics;
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
  late final TrekkingCatalogService _catalog;
  late final JourneyDao _journeyDao;
  late final MarkerDao _markerDao;

  JourneyRepository({
    TokenStorage? tokenStorage,
    AuthEventBus? eventBus,
    DatabaseHelper? dbHelper,
  }) {
    final storage = tokenStorage ?? SecureTokenStorage();
    final bus = eventBus ?? AuthEventBus();
    // Trekking-service dùng port 3003 — dùng createTrekkingDio
    final dio = DioClient.createTrekkingDio(
      tokenStorage: storage,
      eventBus: bus,
    );
    _remote = JourneyRemoteDataSource(dio);
    final offline = tokenStorage == null && dbHelper == null
        ? OfflineStore.instance
        : OfflineStore(
            databaseHelper: dbHelper,
            ownerProvider: () async =>
                OfflineStore.ownerFromToken(await storage.getAccessToken()),
          );
    _catalog = TrekkingCatalogService(
      client: dio,
      checkinClient: DioClient.createCheckinDio(
        tokenStorage: storage,
        eventBus: bus,
      ),
      store: offline,
    );

    final db = dbHelper ?? DatabaseHelper.instance;
    _journeyDao = JourneyDao(dbHelper: db);
    _markerDao = MarkerDao(dbHelper: db);
  }

  // ── JOURNEYS ──────────────────────────────────────────────────────────────

  Future<List<JourneyModel>> getJourneys({String? status}) async {
    final journeys = await _catalog.getJourneys();
    return status == null
        ? journeys
        : journeys
              .where((j) => j.status.name.toUpperCase() == status.toUpperCase())
              .toList();
  }

  Future<JourneyStatistics?> getStatistics() async {
    try {
      return await _remote.getStatistics();
    } on DioException catch (e) {
      debugPrint(
        '[JourneyRepo] getStatistics offline: ${ApiErrorHandler.handle(e)}',
      );
      return null;
    }
  }

  Future<JourneyModel?> getJourneyById(String id) async {
    try {
      return await _catalog.getJourney(id);
    } on StateError {
      await _catalog.getJourneys();
      return _catalog.getJourney(id);
    }
  }

  Future<JourneyModel> createJourney({
    required String trekkingPlaceId,
    required String trekkingRouteId,
    required String name,
    String? provinceId,
    DateTime? plannedStartAt,
    DateTime? plannedEndAt,
    int? memberCount = 1,
    String? notes,
    bool enableCheckin = true,
    String userId = 'local_user',
  }) async {
    final route = await _catalog.getRoute(trekkingRouteId);
    return _catalog.createJourney({
      'clientJourneyId': _newUuid(),
      'trekkingPlaceId': trekkingPlaceId,
      'trekkingRouteId': trekkingRouteId,
      'name': name,
      'participantCount': memberCount ?? 1,
      if (notes != null) 'note': notes,
      if (plannedStartAt != null)
        'plannedStartAt': plannedStartAt.toUtc().toIso8601String(),
      if (plannedEndAt != null)
        'plannedEndAt': plannedEndAt.toUtc().toIso8601String(),
    }, route);
  }

  Future<JourneyModel> _transition(
    String id,
    String action, {
    Map<String, dynamic> body = const {},
  }) async {
    await _catalog.transitionJourney(id, action, body: body);
    return _catalog.getJourney(id);
  }

  Future<JourneyModel> startJourney(String id) => _transition(id, 'start');
  Future<JourneyModel> pauseJourney(String id) => _transition(id, 'pause');
  Future<JourneyModel> resumeJourney(String id) => _transition(id, 'resume');
  Future<JourneyModel> cancelJourney(String id) => _transition(id, 'cancel');
  Future<JourneyModel> completeJourney(
    String id, {
    String? encodedPolyline,
    double? distanceMeters,
    int? durationSeconds,
    double? elevationGain,
    double? maxAltitude,
    double? averageSpeed,
  }) => _transition(
    id,
    'complete',
    body: {
      'completedAt': DateTime.now().toUtc().toIso8601String(),
      'statistics': {
        if (distanceMeters != null) 'distanceMeters': distanceMeters,
        if (durationSeconds != null) 'durationSeconds': durationSeconds,
        if (elevationGain != null) 'elevationGain': elevationGain,
        if (maxAltitude != null) 'maxAltitude': maxAltitude,
        if (averageSpeed != null) 'averageSpeed': averageSpeed,
      },
      if (encodedPolyline != null)
        'track': {'encodedPolyline': encodedPolyline},
    },
  );

  // ── ROUTES ────────────────────────────────────────────────────────────────

  Future<RouteModel?> getRoute(String routeId) async {
    final json = Map<String, dynamic>.from(
      await _catalog.getCatalog('/routes/$routeId') as Map,
    );
    final place = await _catalog.getPlace(json['trekkingPlaceId'].toString());
    return RouteModel.fromJson({
      ...json,
      'placeName': place['name'],
      'placeAddress': place['address'],
      'placeImageUrl': (place['images'] as List?)?.firstOrNull,
    });
  }

  Future<List<MilestoneModel>> getMilestones(String routeId) async =>
      (await _catalog.getMilestones(routeId))
          .map(MilestoneModel.fromJson)
          .toList();

  Future<OfflinePackageInfo?> getOfflinePackage(String routeId) async {
    try {
      return await _remote.getOfflinePackage(routeId);
    } on DioException catch (e) {
      debugPrint(
        '[JourneyRepo] getOfflinePackage: ${ApiErrorHandler.handle(e)}',
      );
      return null;
    }
  }

  // ── MARKERS ───────────────────────────────────────────────────────────────

  Future<String> resolveLocalJourneyId(String id) async {
    try {
      return await _catalog.offline.localJourneyId(id);
    } on StateError {
      await _catalog.getJourneys();
      return _catalog.offline.localJourneyId(id);
    }
  }

  Future<List<MarkerModel>> getMarkers(String localJourneyId) async {
    localJourneyId = await resolveLocalJourneyId(localJourneyId);
    final local = await _markerDao.getMarkersByJourney(localJourneyId);

    try {
      final localJ = await _journeyDao.getJourney(localJourneyId);
      final serverId = localJ?.serverJourneyId;
      if (serverId != null) {
        final serverMarkers = await _remote.getMarkers(serverId);
        for (final sm in serverMarkers) {
          // sm.serverMarkerId = journeyMarkerId từ backend
          final serverMarkerId = sm.serverMarkerId ?? sm.markerId;
          final existing = local
              .where((l) => l.serverMarkerId == serverMarkerId)
              .firstOrNull;
          if ((existing == null || existing.syncStatus == 'SYNCED') &&
              serverMarkerId.isNotEmpty) {
            final localId = existing?.localMarkerId ?? _newUuid();
            await _markerDao.insertMarker(
              LocalJourneyMarker(
                localMarkerId: localId,
                serverMarkerId: serverMarkerId,
                localJourneyId: localJourneyId,
                userId: localJ!.userId,
                name: sm.name,
                type: sm.type,
                note: sm.note,
                latitude: sm.latitude,
                longitude: sm.longitude,
                altitude: sm.altitude,
                markedAt: sm.markedAt,
                syncStatus: 'SYNCED',
                createdAt: sm.markedAt,
              ),
            );
            final cachedMedia = await _markerDao.getMediaByMarker(localId);
            for (final file in cachedMedia) {
              if (file.remoteUrl != null &&
                  !sm.mediaRemoteUrls.contains(file.remoteUrl)) {
                await _markerDao.deleteMedia(file.localMarkerMediaId);
              }
            }
            for (var i = 0; i < sm.mediaRemoteUrls.length; i++) {
              if (cachedMedia.any(
                (file) => file.remoteUrl == sm.mediaRemoteUrls[i],
              ))
                continue;
              await _markerDao.insertMedia(
                LocalMarkerMedia(
                  localMarkerMediaId: 'remote-$serverMarkerId-$i',
                  localMarkerId: localId,
                  localPath: '',
                  remoteUrl: sm.mediaRemoteUrls[i],
                  uploadStatus: 'UPLOADED',
                  createdAt: sm.markedAt,
                ),
              );
            }
          }
        }
      }
    } on DioException catch (e) {
      if (!OfflineStore.canUseCache(e)) rethrow;
    }

    final refreshed = await _markerDao.getMarkersByJourney(localJourneyId);
    return Future.wait(
      refreshed.where((m) => m.syncStatus != 'PENDING_DELETE').map((
        marker,
      ) async {
        final media = await _markerDao.getMediaByMarker(marker.localMarkerId);
        return _localMarkerToModel(
          marker,
          mediaLocalPaths: media
              .map((m) => m.localPath)
              .where((p) => p.isNotEmpty)
              .toList(),
          mediaRemoteUrls: media
              .where((m) => m.localPath.isEmpty)
              .map((m) => m.remoteUrl)
              .whereType<String>()
              .toList(),
        );
      }),
    );
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
    bool syncImmediately = true,
  }) async {
    final localMarkerId = _newUuid();
    localJourneyId = await resolveLocalJourneyId(localJourneyId);
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
    final media = <Map<String, Object?>>[];
    for (final path in mediaLocalPaths) {
      media.add(
        LocalMarkerMedia(
          localMarkerMediaId: _newUuid(),
          localMarkerId: localMarkerId,
          type: 'IMAGE',
          localPath: path,
          uploadStatus: 'LOCAL',
          createdAt: now,
        ).toMap(),
      );
    }
    await _catalog.offline.createMarker(marker.toMap(), media);
    if (syncImmediately) await _catalog.syncPending();
    final saved = await _markerDao.getMarker(localMarkerId);
    return _localMarkerToModel(saved!, mediaLocalPaths: mediaLocalPaths);
  }

  Future<void> updateMarker(
    String localMarkerId, {
    String? name,
    String? type,
    String? note,
    List<String>? mediaLocalPaths,
    List<String>? mediaRemoteUrls,
    bool syncImmediately = true,
  }) async {
    await _catalog.offline.changeMarker(
      localMarkerId,
      mediaLocalPaths: mediaLocalPaths,
      mediaRemoteUrls: mediaRemoteUrls,
      values: {
        if (name != null) 'name': name,
        if (type != null) 'type': type,
        if (note != null) 'note': note,
      },
    );
    if (syncImmediately) await _catalog.syncPending();
  }

  Future<void> deleteMarker(String localMarkerId) async {
    await _catalog.offline.changeMarker(localMarkerId, delete: true);
    await _catalog.syncPending();
  }

  Future<MarkerModel?> getLocalMarker(String id) async {
    final marker = await _markerDao.getMarker(id);
    if (marker == null ||
        marker.userId != await _catalog.offline.requireOwner())
      return null;
    final media = await _markerDao.getMediaByMarker(id);
    return _localMarkerToModel(
      marker,
      mediaLocalPaths: media
          .map((m) => m.localPath)
          .where((p) => p.isNotEmpty)
          .toList(),
      mediaRemoteUrls: media
          .where((m) => m.localPath.isEmpty)
          .map((m) => m.remoteUrl)
          .whereType<String>()
          .toList(),
    );
  }

  // ── REVIEWS ───────────────────────────────────────────────────────────────

  Future<List<ReviewModel>> getReviews(
    String placeId, {
    int page = 1,
    int limit = 20,
  }) async {
    return _remote.getReviews(placeId, page: page, limit: limit);
  }

  Future<Map<String, dynamic>> getReviewEligibility(String placeId) =>
      _remote.getReviewEligibility(placeId);

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
    return _submitContribution('ROUTE_SUBMISSION', request.toJson(), userId);
  }

  Future<ContributionModel> submitPlaceContribution(
    SubmitPlaceContributionRequest request, {
    required String userId,
  }) async {
    return _submitContribution('PLACE_SUGGESTION', request.toJson(), userId);
  }

  Future<ContributionModel> _submitContribution(
    String type,
    Map<String, dynamic> body,
    String userId,
  ) async {
    if (await _catalog.offline.requireOwner() != userId)
      throw StateError('Tài khoản của đóng góp không khớp.');
    final id = await _catalog.offline.submitContribution(type, body);
    await _catalog.syncPending();
    final error = await _catalog.offline.operationError(id);
    if (error != null) throw StateError(error);
    return ContributionModel.fromJson(
      (await _catalog.offline.contribution(id))!,
    );
  }

  Future<MyContributionsResponse> getMyContributions({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final owner = await _catalog.offline.requireOwner();
    final resource = '/contributions/me?${status ?? ''}&$page&$limit';
    Map<String, dynamic> data;
    try {
      final response = await _catalog.dio.get(
        '/contributions/me',
        queryParameters: {
          if (status != null) 'status': status,
          'page': page,
          'limit': limit,
        },
      );
      data = Map<String, dynamic>.from(response.data['data'] as Map);
      await _catalog.offline.cache(resource, data, owner: owner);
    } on DioException catch (e) {
      if (!OfflineStore.canUseCache(e)) rethrow;
      final cached = await _catalog.offline.read(resource, owner: owner);
      data = cached is Map
          ? Map<String, dynamic>.from(cached)
          : {
              'routes': {'items': [], 'total': 0},
              'places': {'items': [], 'total': 0},
            };
    }
    if (page == 1) {
      final rows = await (await _catalog.offline.databaseHelper.database).query(
        'local_contributions',
        where: "userId = ? AND syncStatus != 'SYNCED'",
        whereArgs: [owner],
      );
      for (final row in rows) {
        if (status != null && status != row['serverStatus']) continue;
        final key = row['type'] == 'ROUTE_SUBMISSION' ? 'routes' : 'places';
        final group = Map<String, dynamic>.from(data[key] as Map);
        group['items'] = [
          await _catalog.offline.contribution(
            row['localContributionId'] as String,
          ),
          ...(group['items'] as List),
        ];
        group['total'] = (group['total'] as num).toInt() + 1;
        data[key] = group;
      }
    }
    return MyContributionsResponse.fromJson(data);
  }

  Future<ContributionModel> getMyContributionById(String id) async {
    final local = await _catalog.offline.contribution(id);
    if (local != null && local['offlineSyncStatus'] != 'SYNCED')
      return ContributionModel.fromJson(local);
    final owner = await _catalog.offline.requireOwner();
    final resource = '/contributions/me/$id';
    try {
      final response = await _catalog.dio.get(resource);
      final data = Map<String, dynamic>.from(response.data['data'] as Map);
      await _catalog.offline.cache(resource, data, owner: owner);
      return ContributionModel.fromJson(data);
    } on DioException catch (e) {
      if (!OfflineStore.canUseCache(e)) rethrow;
      final cached =
          await _catalog.offline.read(resource, owner: owner) ?? local;
      if (cached == null) rethrow;
      return ContributionModel.fromJson(
        Map<String, dynamic>.from(cached as Map),
      );
    }
  }

  // ── PRIVATE HELPERS ───────────────────────────────────────────────────────

  MarkerModel _localMarkerToModel(
    LocalJourneyMarker m, {
    List<String> mediaLocalPaths = const [],
    List<String> mediaRemoteUrls = const [],
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
      mediaRemoteUrls: mediaRemoteUrls,
    );
  }
}
