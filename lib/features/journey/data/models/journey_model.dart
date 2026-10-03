/// Model Journey trả về từ API server.
class JourneyModel {
  final String journeyId;
  final String userId;
  final String trekkingPlaceId;
  final String trekkingRouteId;
  final String? provinceId;
  final String name;
  final String status; // PLANNED | ACTIVE | PAUSED | COMPLETED | CANCELLED
  final DateTime? plannedStartAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final double distanceMeters;
  final int durationSeconds;
  final double elevationGain;
  final double? maxAltitude;
  final int checkinCount;
  final int markerCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Denormalized từ route/place để hiển thị trong list
  final String? placeName;
  final String? placeAddress;
  final String? routeName;
  final String? placeImageUrl;
  final double? routeDistanceMeters;
  final int? totalMilestones;
  final int? memberCount;
  // clientJourneyId — backend echo về, dùng để map offline↔server
  final String? clientJourneyId;

  const JourneyModel({
    required this.journeyId,
    required this.userId,
    required this.trekkingPlaceId,
    required this.trekkingRouteId,
    this.provinceId,
    required this.name,
    required this.status,
    this.plannedStartAt,
    this.startedAt,
    this.completedAt,
    this.distanceMeters = 0,
    this.durationSeconds = 0,
    this.elevationGain = 0,
    this.maxAltitude,
    this.checkinCount = 0,
    this.markerCount = 0,
    this.createdAt,
    this.updatedAt,
    this.placeName,
    this.placeAddress,
    this.routeName,
    this.placeImageUrl,
    this.routeDistanceMeters,
    this.totalMilestones,
    this.memberCount,
    this.clientJourneyId,
  });

  factory JourneyModel.fromJson(Map<String, dynamic> json) {
    // Backend lồng thống kê trong sub-object "statistics"
    final stats = json['statistics'] as Map<String, dynamic>? ?? {};

    return JourneyModel(
      journeyId: json['journeyId'] as String? ?? json['id'] as String,
      userId: json['userId'] as String? ?? '',
      trekkingPlaceId: json['trekkingPlaceId'] as String? ?? '',
      trekkingRouteId: json['trekkingRouteId'] as String? ?? '',
      provinceId: json['provinceId'] as String?,
      name: json['name'] as String? ?? '',
      status: json['status'] as String? ?? 'PLANNED',
      plannedStartAt: json['plannedStartAt'] != null
          ? DateTime.tryParse(json['plannedStartAt'] as String)
          : null,
      startedAt: json['startedAt'] != null
          ? DateTime.tryParse(json['startedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'] as String)
          : null,
      // Thống kê lấy từ sub-object "statistics" hoặc flat (offline fallback)
      distanceMeters: (stats['distanceMeters'] as num?)?.toDouble() ??
          (json['distanceMeters'] as num?)?.toDouble() ?? 0,
      durationSeconds: stats['durationSeconds'] as int? ??
          json['durationSeconds'] as int? ?? 0,
      elevationGain: (stats['elevationGain'] as num?)?.toDouble() ??
          (json['elevationGain'] as num?)?.toDouble() ?? 0,
      maxAltitude: (stats['maxAltitude'] as num?)?.toDouble() ??
          (json['maxAltitude'] as num?)?.toDouble(),
      checkinCount: json['checkinCount'] as int? ?? 0,
      markerCount: json['markerCount'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
      placeName: json['placeName'] as String?,
      placeAddress: json['placeAddress'] as String?,
      routeName: json['routeName'] as String?,
      placeImageUrl: json['placeImageUrl'] as String?,
      routeDistanceMeters:
          (json['routeDistanceMeters'] as num?)?.toDouble(),
      totalMilestones: json['totalMilestones'] as int?,
      // Backend dùng "participantCount", frontend dùng "memberCount"
      memberCount: json['participantCount'] as int? ??
          json['memberCount'] as int?,
      // Backend echo lại clientJourneyId khi tạo journey
      clientJourneyId: json['clientJourneyId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'journeyId': journeyId,
        'userId': userId,
        'trekkingPlaceId': trekkingPlaceId,
        'trekkingRouteId': trekkingRouteId,
        if (provinceId != null) 'provinceId': provinceId,
        'name': name,
        'status': status,
        if (plannedStartAt != null)
          'plannedStartAt': plannedStartAt!.toIso8601String(),
        if (startedAt != null) 'startedAt': startedAt!.toIso8601String(),
        if (completedAt != null)
          'completedAt': completedAt!.toIso8601String(),
        'distanceMeters': distanceMeters,
        'durationSeconds': durationSeconds,
        'elevationGain': elevationGain,
        if (maxAltitude != null) 'maxAltitude': maxAltitude,
        'checkinCount': checkinCount,
        'markerCount': markerCount,
      };
}
