/// Model Route (cung đường) trả về từ API.
class RouteModel {
  final String routeId;
  final String trekkingPlaceId;
  final String name;
  final String? description;
  final String? difficulty;
  final double? distanceMeters;
  final int? estimatedDurationMinutes;
  final int? elevationGain;
  final int? maxElevation;
  final double? startLatitude;
  final double? startLongitude;
  final double? endLatitude;
  final double? endLongitude;
  final String? encodedPolyline;
  final int? mapVersion;
  final String? imageUrl;

  // Denormalized place info
  final String? placeName;
  final String? placeAddress;

  const RouteModel({
    required this.routeId,
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
    this.imageUrl,
    this.placeName,
    this.placeAddress,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      routeId: json['routeId'] as String? ??
          json['trekkingRouteId'] as String? ??
          json['id'] as String,
      trekkingPlaceId: json['trekkingPlaceId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      difficulty: json['difficulty'] as String?,
      distanceMeters: (json['distanceMeters'] as num?)?.toDouble(),
      estimatedDurationMinutes:
          json['estimatedDurationMinutes'] as int?,
      elevationGain: json['elevationGain'] as int?,
      maxElevation: json['maxElevation'] as int?,
      startLatitude: (json['startLatitude'] as num?)?.toDouble(),
      startLongitude: (json['startLongitude'] as num?)?.toDouble(),
      endLatitude: (json['endLatitude'] as num?)?.toDouble(),
      endLongitude: (json['endLongitude'] as num?)?.toDouble(),
      encodedPolyline: json['encodedPolyline'] as String?,
      mapVersion: json['mapVersion'] as int?,
      imageUrl: json['imageUrl'] as String?,
      placeName: json['placeName'] as String?,
      placeAddress: json['placeAddress'] as String?,
    );
  }

  /// Difficulty label tiếng Việt
  String get difficultyLabel {
    switch ((difficulty ?? '').toUpperCase()) {
      case 'EASY':
        return 'Dễ';
      case 'MEDIUM':
        return 'Trung bình';
      case 'HARD':
        return 'Khó';
      case 'EXPERT':
        return 'Chuyên gia';
      default:
        return difficulty ?? 'Không rõ';
    }
  }

  /// Difficulty level number (for badge display)
  int get difficultyLevel {
    switch ((difficulty ?? '').toUpperCase()) {
      case 'EASY':
        return 1;
      case 'MEDIUM':
        return 2;
      case 'HARD':
        return 3;
      case 'EXPERT':
        return 4;
      default:
        return 0;
    }
  }

  String get distanceLabel {
    if (distanceMeters == null) return '--';
    final km = distanceMeters! / 1000;
    return '${km.toStringAsFixed(1)} km';
  }

  String get durationLabel {
    if (estimatedDurationMinutes == null) return '--';
    final days = estimatedDurationMinutes! ~/ (60 * 24);
    if (days >= 1) return '$days - ${days + 1} ngày';
    final hours = estimatedDurationMinutes! ~/ 60;
    return '$hours giờ';
  }
}

/// Model offline map package info trả về từ API.
///
/// Backend `/routes/:routeId/offline-package` trả:
/// {
///   "place": {...},
///   "route": {...},
///   "milestones": [...],
///   "mapManifest": {
///     "available": true, "version": 3, "sizeBytes": 48000000,
///     "downloadUrl": "...", "checksum": "sha256:...",
///     "minZoom": 10, "maxZoom": 16,
///     "bounds": { "minLatitude": ..., ... }
///   }
/// }
class OfflinePackageInfo {
  final String routeId;
  final String mapName;
  final String downloadUrl;
  final int sizeBytes;
  final int mapVersion;
  final String checksum;
  final int minZoom;
  final int maxZoom;
  final int waypointCount;
  final bool supportsTrail;
  final bool available;

  const OfflinePackageInfo({
    required this.routeId,
    required this.mapName,
    required this.downloadUrl,
    required this.sizeBytes,
    required this.mapVersion,
    required this.checksum,
    required this.minZoom,
    required this.maxZoom,
    this.waypointCount = 0,
    this.supportsTrail = false,
    this.available = true,
  });

  /// Parse từ response của GET /routes/:routeId/offline-package
  /// Response có dạng: { place, route, milestones, mapManifest }
  factory OfflinePackageInfo.fromJson(Map<String, dynamic> json) {
    // Backend đặt map info trong "mapManifest", nhưng routeId ở "route.trekkingRouteId"
    final manifest = json['mapManifest'] as Map<String, dynamic>? ?? json;
    final route = json['route'] as Map<String, dynamic>?;

    // Lấy checksum — có thể là "sha256:abc..." → cần strip prefix khi verify
    final rawChecksum = manifest['checksum'] as String? ?? '';

    return OfflinePackageInfo(
      routeId: route?['trekkingRouteId'] as String? ??
          json['routeId'] as String? ?? '',
      mapName: route?['name'] as String? ??
          json['mapName'] as String? ?? '',
      downloadUrl: manifest['downloadUrl'] as String? ??
          json['downloadUrl'] as String? ?? '',
      sizeBytes: manifest['sizeBytes'] as int? ??
          json['sizeBytes'] as int? ?? 0,
      mapVersion: manifest['version'] as int? ??
          manifest['mapVersion'] as int? ??
          json['mapVersion'] as int? ?? 1,
      checksum: rawChecksum,
      minZoom: manifest['minZoom'] as int? ??
          json['minZoom'] as int? ?? 12,
      maxZoom: manifest['maxZoom'] as int? ??
          json['maxZoom'] as int? ?? 17,
      waypointCount: json['waypointCount'] as int? ?? 0,
      supportsTrail: json['supportsTrail'] as bool? ?? false,
      available: manifest['available'] as bool? ?? true,
    );
  }

  String get sizeMb => '${(sizeBytes / (1024 * 1024)).toStringAsFixed(0)} MB';
  String get zoomLabel => '$minZoom – $maxZoom (Chi tiết)';

  /// SHA256 hash thuần (bỏ prefix "sha256:" nếu có), dùng để so sánh với crypto.sha256
  String get checksumHash {
    if (checksum.startsWith('sha256:')) {
      return checksum.substring('sha256:'.length);
    }
    return checksum;
  }
}
