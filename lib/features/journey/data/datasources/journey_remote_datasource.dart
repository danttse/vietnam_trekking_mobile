import 'package:dio/dio.dart';

import '../models/journey_model.dart';
import '../models/route_model.dart';
import '../models/milestone_model.dart';
import '../models/marker_model.dart';
import '../models/review_model.dart';
import '../models/contribution_model.dart';

/// Remote datasource — tất cả HTTP calls cho trekking module.
/// Base URL trỏ đến /api/v1 (từ DioClient).
class JourneyRemoteDataSource {
  final Dio _dio;

  const JourneyRemoteDataSource(this._dio);

  // ── JOURNEYS ──────────────────────────────────────────────────────────────

  Future<List<JourneyModel>> getJourneys({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final resp = await _dio.get(
      '/journeys',
      queryParameters: {
        if (status != null) 'status': status,
        'page': page,
        'limit': limit,
      },
    );
    final data = _unwrapList(resp.data);
    return data.map((e) => JourneyModel.fromJson(e)).toList();
  }

  Future<JourneyStatistics> getStatistics() async {
    final resp = await _dio.get('/journeys/statistics');
    return JourneyStatistics.fromJson(_unwrap(resp.data));
  }

  Future<JourneyModel> getJourneyById(String journeyId) async {
    final resp = await _dio.get('/journeys/$journeyId');
    return JourneyModel.fromJson(_unwrap(resp.data));
  }

  /// POST /journeys
  /// Body: trekkingPlaceId, trekkingRouteId, name, clientJourneyId, ...
  /// Header: Idempotency-Key (chống duplicate khi offline retry)
  Future<JourneyModel> createJourney(
    Map<String, dynamic> body, {
    String? idempotencyKey,
  }) async {
    final resp = await _dio.post(
      '/journeys',
      data: body,
      options: idempotencyKey != null
          ? Options(headers: {'Idempotency-Key': idempotencyKey})
          : null,
    );
    return JourneyModel.fromJson(_unwrap(resp.data));
  }

  /// POST /journeys/:id/start
  /// Body: { "startedAt": "ISO8601" } (optional)
  Future<JourneyModel> startJourney(
    String journeyId, {
    DateTime? startedAt,
  }) async {
    final resp = await _dio.post(
      '/journeys/$journeyId/start',
      data: startedAt != null ? {'startedAt': startedAt.toIso8601String()} : {},
    );
    return JourneyModel.fromJson(_unwrap(resp.data));
  }

  Future<JourneyModel> pauseJourney(String journeyId) async {
    final resp = await _dio.post('/journeys/$journeyId/pause');
    return JourneyModel.fromJson(_unwrap(resp.data));
  }

  Future<JourneyModel> resumeJourney(String journeyId) async {
    final resp = await _dio.post('/journeys/$journeyId/resume');
    return JourneyModel.fromJson(_unwrap(resp.data));
  }

  /// POST /journeys/:id/complete
  /// Body: { "completedAt", "statistics": { distanceMeters, durationSeconds, elevationGain, maxAltitude, averageSpeed }, "track": { "encodedPolyline" } }
  /// Header: Idempotency-Key (khuyến nghị cho offline retry)
  Future<JourneyModel> completeJourney(
    String journeyId, {
    DateTime? completedAt,
    String? encodedPolyline,
    double? distanceMeters,
    int? durationSeconds,
    double? elevationGain,
    double? maxAltitude,
    double? averageSpeed,
    String? idempotencyKey,
  }) async {
    final Map<String, dynamic> body = {
      if (completedAt != null) 'completedAt': completedAt.toIso8601String(),
      // Backend nhận statistics nested
      'statistics': {
        if (distanceMeters != null) 'distanceMeters': distanceMeters,
        if (durationSeconds != null) 'durationSeconds': durationSeconds,
        if (elevationGain != null) 'elevationGain': elevationGain,
        if (maxAltitude != null) 'maxAltitude': maxAltitude,
        if (averageSpeed != null) 'averageSpeed': averageSpeed,
      },
      // Backend nhận track nested
      if (encodedPolyline != null)
        'track': {'encodedPolyline': encodedPolyline},
    };

    final resp = await _dio.post(
      '/journeys/$journeyId/complete',
      data: body,
      options: idempotencyKey != null
          ? Options(headers: {'Idempotency-Key': idempotencyKey})
          : null,
    );
    return JourneyModel.fromJson(_unwrap(resp.data));
  }

  Future<JourneyModel> cancelJourney(String journeyId) async {
    final resp = await _dio.post('/journeys/$journeyId/cancel');
    return JourneyModel.fromJson(_unwrap(resp.data));
  }

  // ── ROUTES ────────────────────────────────────────────────────────────────

  Future<RouteModel> getRoute(String routeId) async {
    final resp = await _dio.get('/routes/$routeId');
    return RouteModel.fromJson(_unwrap(resp.data));
  }

  Future<List<MilestoneModel>> getMilestones(String routeId) async {
    final resp = await _dio.get('/routes/$routeId/milestones');
    final data = _unwrapList(resp.data);
    return data.map((e) => MilestoneModel.fromJson(e)).toList();
  }

  Future<OfflinePackageInfo> getOfflinePackage(String routeId) async {
    final resp = await _dio.get('/routes/$routeId/offline-package');
    return OfflinePackageInfo.fromJson(_unwrap(resp.data));
  }

  Future<OfflinePackageCheckResult> checkOfflinePackage(
    String routeId,
    int currentVersion,
  ) async {
    final resp = await _dio.get(
      '/routes/$routeId/offline-package/check',
      queryParameters: {'version': currentVersion},
    );
    return OfflinePackageCheckResult.fromJson(_unwrap(resp.data));
  }

  // ── MARKERS ───────────────────────────────────────────────────────────────

  Future<List<MarkerModel>> getMarkers(String journeyId) async {
    final resp = await _dio.get('/journeys/$journeyId/markers');
    final data = _unwrapList(resp.data);
    return data.map((e) => MarkerModel.fromJson(e)).toList();
  }

  /// POST /journeys/:id/markers
  /// Body: { name, type, location (GeoJSON Point), markedAt, clientMarkerId, ... }
  Future<MarkerModel> createMarker(
    String journeyId,
    Map<String, dynamic> body, {
    String? clientMarkerId,
  }) async {
    // Đảm bảo location được gửi theo GeoJSON nếu body có lat/lng flat
    final enrichedBody = _enrichMarkerBody(
      body,
      clientMarkerId: clientMarkerId,
    );
    final resp = await _dio.post(
      '/journeys/$journeyId/markers',
      data: enrichedBody,
      options: clientMarkerId != null
          ? Options(headers: {'Idempotency-Key': clientMarkerId})
          : null,
    );
    return MarkerModel.fromJson(_unwrap(resp.data));
  }

  Future<MarkerModel> updateMarker(
    String journeyId,
    String markerId,
    Map<String, dynamic> body,
  ) async {
    final resp = await _dio.put(
      '/journeys/$journeyId/markers/$markerId',
      data: body,
    );
    return MarkerModel.fromJson(_unwrap(resp.data));
  }

  Future<void> deleteMarker(String journeyId, String markerId) async {
    await _dio.delete('/journeys/$journeyId/markers/$markerId');
  }

  // ── PLACES ────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getPlace(String placeId) async {
    final resp = await _dio.get('/places/$placeId');
    return _unwrap(resp.data);
  }

  Future<List<Map<String, dynamic>>> getRoutesByPlace(String placeId) async {
    final resp = await _dio.get('/places/$placeId/routes');
    return _unwrapList(resp.data);
  }

  // ── REVIEWS ───────────────────────────────────────────────────────────────

  Future<List<ReviewModel>> getReviews(
    String placeId, {
    int page = 1,
    int limit = 20,
  }) async {
    final resp = await _dio.get(
      '/places/$placeId/reviews',
      queryParameters: {'page': page, 'limit': limit},
    );
    final data = _unwrapList(resp.data);
    return data.map((e) => ReviewModel.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> getReviewEligibility(String placeId) async {
    final resp = await _dio.get('/places/$placeId/reviews/eligibility');
    return Map<String, dynamic>.from(_unwrap(resp.data));
  }

  Future<ReviewModel?> getMyReview(String placeId) async {
    final resp = await _dio.get('/places/$placeId/reviews/me');
    final raw = resp.data;
    // Trả null nếu chưa có review
    if (raw is Map<String, dynamic>) {
      final data = raw['data'];
      if (data == null) return null;
      return ReviewModel.fromJson(data as Map<String, dynamic>);
    }
    return null;
  }

  Future<ReviewModel> createReview(
    String placeId,
    CreateReviewRequest request,
  ) async {
    final resp = await _dio.post(
      '/places/$placeId/reviews',
      data: request.toJson(),
    );
    return ReviewModel.fromJson(_unwrap(resp.data));
  }

  Future<ReviewModel> updateReview(
    String placeId,
    String reviewId,
    CreateReviewRequest request,
  ) async {
    final resp = await _dio.put(
      '/places/$placeId/reviews/$reviewId',
      data: request.toJson(),
    );
    return ReviewModel.fromJson(_unwrap(resp.data));
  }

  Future<void> deleteReview(String placeId, String reviewId) async {
    await _dio.delete('/places/$placeId/reviews/$reviewId');
  }

  // ── CONTRIBUTIONS ─────────────────────────────────────────────────────────

  /// POST /contributions/routes
  /// sourceJourneyId phải là serverJourneyId (từ Journey đã COMPLETED)
  Future<ContributionModel> submitRouteContribution(
    SubmitRouteContributionRequest request,
  ) async {
    final resp = await _dio.post(
      '/contributions/routes',
      data: request.toJson(),
    );
    return ContributionModel.fromJson(_unwrap(resp.data));
  }

  /// POST /contributions/places
  Future<ContributionModel> submitPlaceContribution(
    SubmitPlaceContributionRequest request,
  ) async {
    final resp = await _dio.post(
      '/contributions/places',
      data: request.toJson(),
    );
    return ContributionModel.fromJson(_unwrap(resp.data));
  }

  /// GET /contributions/me  (route mounted at /contributions/me per contribution.routes.js)
  Future<MyContributionsResponse> getMyContributions({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final resp = await _dio.get(
      '/contributions/me',
      queryParameters: {
        if (status != null) 'status': status,
        'page': page,
        'limit': limit,
      },
    );
    return MyContributionsResponse.fromJson(_unwrap(resp.data));
  }

  Future<ContributionModel> getMyContributionById(String id) async {
    final resp = await _dio.get('/contributions/me/$id');
    return ContributionModel.fromJson(_unwrap(resp.data));
  }

  // ── HELPERS ───────────────────────────────────────────────────────────────

  /// Chuyển body marker từ flat (lat/lng) sang GeoJSON Point nếu cần.
  Map<String, dynamic> _enrichMarkerBody(
    Map<String, dynamic> body, {
    String? clientMarkerId,
  }) {
    final result = Map<String, dynamic>.from(body);

    // Nếu body có lat/lng flat → convert sang GeoJSON location
    if (!result.containsKey('location') &&
        result.containsKey('latitude') &&
        result.containsKey('longitude')) {
      final lat = result.remove('latitude') as num;
      final lng = result.remove('longitude') as num;
      result['location'] = {
        'type': 'Point',
        'coordinates': [lng.toDouble(), lat.toDouble()], // GeoJSON: [lng, lat]
      };
    }

    if (clientMarkerId != null && !result.containsKey('clientMarkerId')) {
      result['clientMarkerId'] = clientMarkerId;
    }

    return result;
  }

  Map<String, dynamic> _unwrap(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      if (responseData.containsKey('data') &&
          responseData['data'] is Map<String, dynamic>) {
        return responseData['data'] as Map<String, dynamic>;
      }
      return responseData;
    }
    throw StateError('Unexpected response format: $responseData');
  }

  List<Map<String, dynamic>> _unwrapList(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      final inner = responseData['data'];
      if (inner is List) {
        return inner.cast<Map<String, dynamic>>();
      }
      // paginated: { data: { items: [...] } }
      if (inner is Map<String, dynamic>) {
        final items = inner['items'] ?? inner['journeys'] ?? inner['data'];
        if (items is List) return items.cast<Map<String, dynamic>>();
      }
    }
    if (responseData is List) {
      return responseData.cast<Map<String, dynamic>>();
    }
    return [];
  }
}

// ── Supporting response models ─────────────────────────────────────────────

class JourneyStatistics {
  final int totalJourneys;
  final double totalDistanceMeters;
  final double totalElevationGain;
  final int totalDurationSeconds;

  const JourneyStatistics({
    required this.totalJourneys,
    required this.totalDistanceMeters,
    required this.totalElevationGain,
    required this.totalDurationSeconds,
  });

  factory JourneyStatistics.fromJson(
    Map<String, dynamic> json,
  ) => JourneyStatistics(
    totalJourneys: json['totalJourneys'] as int? ?? 0,
    totalDistanceMeters: (json['totalDistanceMeters'] as num?)?.toDouble() ?? 0,
    totalElevationGain: (json['totalElevationGain'] as num?)?.toDouble() ?? 0,
    totalDurationSeconds: json['totalDurationSeconds'] as int? ?? 0,
  );

  double get totalDistanceKm => totalDistanceMeters / 1000;
}

class OfflinePackageCheckResult {
  final bool hasUpdate;
  final int serverVersion;
  final bool available;
  final String checksum;

  const OfflinePackageCheckResult({
    required this.hasUpdate,
    required this.serverVersion,
    required this.available,
    required this.checksum,
  });

  factory OfflinePackageCheckResult.fromJson(Map<String, dynamic> json) =>
      OfflinePackageCheckResult(
        hasUpdate: json['hasUpdate'] as bool? ?? false,
        serverVersion: json['serverVersion'] as int? ?? 0,
        available: json['available'] as bool? ?? false,
        checksum: json['checksum'] as String? ?? '',
      );
}
