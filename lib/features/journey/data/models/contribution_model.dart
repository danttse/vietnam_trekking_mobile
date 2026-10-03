/// Model Contribution (đóng góp cung đường / địa điểm mới) trả về từ API.
///
/// Backend có 2 loại:
/// - Route Submission: POST /contributions/routes
/// - Place Suggestion: POST /contributions/places
///
/// Trạng thái: DRAFT → PENDING_REVIEW → (APPROVED | REJECTED | NEEDS_REVISION)
class ContributionModel {
  final String contributionId;
  final String? userId;
  final String type; // ROUTE_SUBMISSION | PLACE_SUGGESTION
  final String status; // DRAFT | PENDING_REVIEW | NEEDS_REVISION | APPROVED | REJECTED | CANCELLED
  final String? sourceJourneyId;
  final String? proposedName;
  final String? description;
  final String? encodedPolyline;
  final Map<String, dynamic>? statistics;
  final List<String> images;
  final String? adminNote;
  final String? resultingRouteId;
  final String? resultingPlaceId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ContributionModel({
    required this.contributionId,
    this.userId,
    required this.type,
    required this.status,
    this.sourceJourneyId,
    this.proposedName,
    this.description,
    this.encodedPolyline,
    this.statistics,
    this.images = const [],
    this.adminNote,
    this.resultingRouteId,
    this.resultingPlaceId,
    this.createdAt,
    this.updatedAt,
  });

  factory ContributionModel.fromJson(Map<String, dynamic> json) {
    return ContributionModel(
      contributionId: json['routeSubmissionId'] as String? ??
          json['placeSuggestionId'] as String? ??
          json['contributionId'] as String? ??
          json['id'] as String? ??
          '',
      userId: json['userId'] as String?,
      type: json['type'] as String? ??
          (json.containsKey('routeSubmissionId')
              ? 'ROUTE_SUBMISSION'
              : 'PLACE_SUGGESTION'),
      status: json['status'] as String? ?? 'PENDING_REVIEW',
      sourceJourneyId: json['sourceJourneyId'] as String?,
      proposedName: json['proposedName'] as String?,
      description: json['description'] as String?,
      encodedPolyline: json['encodedPolyline'] as String?,
      statistics: json['statistics'] as Map<String, dynamic>?,
      images: (json['images'] as List<dynamic>?)?.cast<String>() ?? [],
      adminNote: json['adminNote'] as String?,
      resultingRouteId: json['resultingRouteId'] as String?,
      resultingPlaceId: json['resultingPlaceId'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  String get statusLabel {
    switch (status.toUpperCase()) {
      case 'DRAFT':
        return 'Nháp';
      case 'PENDING_REVIEW':
        return 'Chờ xét duyệt';
      case 'NEEDS_REVISION':
        return 'Cần chỉnh sửa';
      case 'APPROVED':
        return 'Đã duyệt';
      case 'REJECTED':
        return 'Bị từ chối';
      case 'CANCELLED':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  String get typeLabel {
    switch (type.toUpperCase()) {
      case 'ROUTE_SUBMISSION':
        return 'Cung đường';
      case 'PLACE_SUGGESTION':
        return 'Địa điểm mới';
      default:
        return type;
    }
  }
}

// ── Request: Route Contribution ────────────────────────────────────────────

class SubmitRouteContributionRequest {
  /// sourceJourneyId phải là serverJourneyId từ Journey đã COMPLETED
  final String sourceJourneyId;
  final String? trekkingPlaceId;
  final String? proposedName;
  final String? description;
  final String? notes;
  final String? encodedPolyline;
  final Map<String, dynamic>? statistics;
  final List<String> images;
  final List<String> markerIds; // serverMarkerId list để share
  final String? clientOperationId; // idempotency key

  const SubmitRouteContributionRequest({
    required this.sourceJourneyId,
    this.trekkingPlaceId,
    this.proposedName,
    this.description,
    this.notes,
    this.encodedPolyline,
    this.statistics,
    this.images = const [],
    this.markerIds = const [],
    this.clientOperationId,
  });

  Map<String, dynamic> toJson() => {
        'sourceJourneyId': sourceJourneyId,
        if (trekkingPlaceId != null) 'trekkingPlaceId': trekkingPlaceId,
        if (proposedName != null) 'proposedName': proposedName,
        if (description != null) 'description': description,
        if (notes != null) 'notes': notes,
        if (encodedPolyline != null) 'encodedPolyline': encodedPolyline,
        if (statistics != null) 'statistics': statistics,
        if (images.isNotEmpty) 'images': images,
        if (markerIds.isNotEmpty) 'markerIds': markerIds,
        if (clientOperationId != null) 'clientOperationId': clientOperationId,
      };
}

// ── Request: Place Contribution ────────────────────────────────────────────

class SubmitPlaceContributionRequest {
  final String provinceId;
  final String proposedName;
  final String? address;
  final double latitude;
  final double longitude;
  final String? description;
  final String? difficulty; // EASY | MODERATE | HARD | EXPERT
  final List<String> tags;
  final List<String> images;
  final String? clientOperationId; // idempotency key

  const SubmitPlaceContributionRequest({
    required this.provinceId,
    required this.proposedName,
    this.address,
    required this.latitude,
    required this.longitude,
    this.description,
    this.difficulty,
    this.tags = const [],
    this.images = const [],
    this.clientOperationId,
  });

  Map<String, dynamic> toJson() => {
        'provinceId': provinceId,
        'proposedName': proposedName,
        if (address != null) 'address': address,
        // Backend nhận GeoJSON Point: [lng, lat]
        'location': {
          'type': 'Point',
          'coordinates': [longitude, latitude],
        },
        if (description != null) 'description': description,
        if (difficulty != null) 'difficulty': difficulty,
        if (tags.isNotEmpty) 'tags': tags,
        if (images.isNotEmpty) 'images': images,
        if (clientOperationId != null) 'clientOperationId': clientOperationId,
      };
}

// ── Response: My Contributions ─────────────────────────────────────────────

class MyContributionsResponse {
  final List<ContributionModel> routes;
  final int routesTotal;
  final List<ContributionModel> places;
  final int placesTotal;

  const MyContributionsResponse({
    required this.routes,
    required this.routesTotal,
    required this.places,
    required this.placesTotal,
  });

  factory MyContributionsResponse.fromJson(Map<String, dynamic> json) {
    final routesData = json['routes'] as Map<String, dynamic>? ?? {};
    final placesData = json['places'] as Map<String, dynamic>? ?? {};

    final routeItems = (routesData['items'] as List<dynamic>?) ?? [];
    final placeItems = (placesData['items'] as List<dynamic>?) ?? [];

    return MyContributionsResponse(
      routes: routeItems
          .cast<Map<String, dynamic>>()
          .map(ContributionModel.fromJson)
          .toList(),
      routesTotal: routesData['total'] as int? ?? routeItems.length,
      places: placeItems
          .cast<Map<String, dynamic>>()
          .map(ContributionModel.fromJson)
          .toList(),
      placesTotal: placesData['total'] as int? ?? placeItems.length,
    );
  }

  List<ContributionModel> get all => [...routes, ...places];
  int get totalCount => routesTotal + placesTotal;
}
