enum RouteDifficulty {
  easy,
  moderate,
  hard,
  extreme,
}

class GeoPoint {
  final double latitude;
  final double longitude;

  const GeoPoint({
    required this.latitude,
    required this.longitude,
  });
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
  final String? province;

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
    this.province,
  });

  double get distanceKm => distanceMeters / 1000.0;
}
