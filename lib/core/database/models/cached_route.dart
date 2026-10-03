class CachedRoute {
  final String trekkingRouteId;
  final String trekkingPlaceId;
  final String name;
  final String? description;
  final String? difficulty;
  final int? distanceMeters;
  final int? estimatedDurationMinutes;
  final int? elevationGain;
  final int? maxElevation;
  final double? startLatitude;
  final double? startLongitude;
  final double? endLatitude;
  final double? endLongitude;
  final String? encodedPolyline;
  final int? mapVersion;
  final DateTime? cachedAt;
  final DateTime? updatedAt;

  const CachedRoute({
    required this.trekkingRouteId,
    required this.trekkingPlaceId,
    required this.name,
    this.description,
    this.difficulty,
    this.distanceMeters,
    this.estimatedDurationMinutes,
    this.elevationGain,
    this.maxElevation,
    this.startLatitude,
    this.startLongitude,
    this.endLatitude,
    this.endLongitude,
    this.encodedPolyline,
    this.mapVersion,
    this.cachedAt,
    this.updatedAt,
  });

  factory CachedRoute.fromMap(Map<String, dynamic> map) {
    return CachedRoute(
      trekkingRouteId: map['trekkingRouteId'] as String,
      trekkingPlaceId: map['trekkingPlaceId'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      difficulty: map['difficulty'] as String?,
      distanceMeters: map['distanceMeters'] as int?,
      estimatedDurationMinutes: map['estimatedDurationMinutes'] as int?,
      elevationGain: map['elevationGain'] as int?,
      maxElevation: map['maxElevation'] as int?,
      startLatitude: map['startLatitude'] as double?,
      startLongitude: map['startLongitude'] as double?,
      endLatitude: map['endLatitude'] as double?,
      endLongitude: map['endLongitude'] as double?,
      encodedPolyline: map['encodedPolyline'] as String?,
      mapVersion: map['mapVersion'] as int?,
      cachedAt: map['cachedAt'] != null
          ? DateTime.parse(map['cachedAt'] as String)
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'trekkingRouteId': trekkingRouteId,
      'trekkingPlaceId': trekkingPlaceId,
      'name': name,
      'description': description,
      'difficulty': difficulty,
      'distanceMeters': distanceMeters,
      'estimatedDurationMinutes': estimatedDurationMinutes,
      'elevationGain': elevationGain,
      'maxElevation': maxElevation,
      'startLatitude': startLatitude,
      'startLongitude': startLongitude,
      'endLatitude': endLatitude,
      'endLongitude': endLongitude,
      'encodedPolyline': encodedPolyline,
      'mapVersion': mapVersion,
      'cachedAt': cachedAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
