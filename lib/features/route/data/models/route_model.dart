enum RouteDifficulty { easy, moderate, hard, extreme }

class GeoPoint {
  final double latitude;
  final double longitude;

  const GeoPoint({required this.latitude, required this.longitude});
}

class RouteModel {
  final String routeId;
  final String trekkingPlaceId;
  final String name;
  final String? description;
  final RouteDifficulty difficulty;
  final double distanceMeters;
  final Duration estimatedDuration;
  final double elevationGain;
  final double maxElevation;
  final GeoPoint startPoint;
  final GeoPoint endPoint;
  final String encodedPolyline;
  final int mapVersion;
  final String? imageUrl;
  final String? mapImageUrl;
  final String? province;
  final String? placeName;
  final String? status;
  final List<GeoPoint> path;

  const RouteModel({
    required this.routeId,
    required this.trekkingPlaceId,
    required this.name,
    this.description,
    required this.difficulty,
    required this.distanceMeters,
    required this.estimatedDuration,
    required this.elevationGain,
    required this.maxElevation,
    required this.startPoint,
    required this.endPoint,
    required this.encodedPolyline,
    required this.mapVersion,
    this.imageUrl,
    this.mapImageUrl,
    this.province,
    this.placeName,
    this.status,
    this.path = const [],
  });

  double get distanceKm => distanceMeters / 1000.0;

  factory RouteModel.fromJson(
    Map<String, dynamic> json, {
    Map<String, dynamic> place = const {},
  }) {
    GeoPoint point(dynamic value) {
      final coords = value is Map ? value['coordinates'] : null;
      return GeoPoint(
        latitude: coords is List && coords.length >= 2
            ? (coords[1] as num).toDouble()
            : 0,
        longitude: coords is List && coords.length >= 2
            ? (coords[0] as num).toDouble()
            : 0,
      );
    }

    final path = (json['path'] as Map?)?['coordinates'];
    final startCoordinates = (json['startLocation'] as Map?)?['coordinates'];
    final endCoordinates = (json['endLocation'] as Map?)?['coordinates'];
    final start = startCoordinates is List && startCoordinates.length >= 2
        ? json['startLocation']
        : path is List && path.isNotEmpty
        ? {'coordinates': path.first}
        : place['location'];
    final end = endCoordinates is List && endCoordinates.length >= 2
        ? json['endLocation']
        : path is List && path.isNotEmpty
        ? {'coordinates': path.last}
        : place['location'];
    return RouteModel(
      routeId:
          (json['trekkingRouteId'] ??
                  json['routeId'] ??
                  json['_id'] ??
                  json['id'] ??
                  '')
              .toString(),
      trekkingPlaceId: (json['trekkingPlaceId'] ?? '').toString(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      difficulty: switch (json['difficulty']) {
        'EASY' => RouteDifficulty.easy,
        'MODERATE' => RouteDifficulty.moderate,
        'EXPERT' => RouteDifficulty.extreme,
        _ => RouteDifficulty.hard,
      },
      distanceMeters: (json['distanceMeters'] as num? ?? 0).toDouble(),
      estimatedDuration: Duration(
        minutes: (json['estimatedDurationMinutes'] as num? ?? 0).toInt(),
      ),
      elevationGain: (json['elevationGain'] as num? ?? 0).toDouble(),
      maxElevation: (json['maxElevation'] as num? ?? 0).toDouble(),
      startPoint: point(start),
      endPoint: point(end),
      encodedPolyline: json['encodedPolyline'] as String? ?? '',
      mapVersion:
          (((place['offlineMap'] as Map?)?['version'] ??
                          (json['offlineMap'] as Map?)?['version'])
                      as num? ??
                  0)
              .toInt(),
      imageUrl: json['imageUrl'] as String?,
      mapImageUrl: json['imageUrl'] as String?,
      placeName: place['name'] as String?,
      status: json['status'] as String?,
      path: path is List
          ? path
                .whereType<List>()
                .where((c) => c.length >= 2 && c[0] is num && c[1] is num)
                .map(
                  (c) => GeoPoint(
                    latitude: (c[1] as num).toDouble(),
                    longitude: (c[0] as num).toDouble(),
                  ),
                )
                .toList()
          : const [],
      province: (place['address'] ?? place['provinceId'] ?? json['province'])
          ?.toString(),
    );
  }
}
