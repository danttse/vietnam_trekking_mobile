class DownloadedMap {
  final String mapId;
  final String scope; // 'PLACE' | 'ROUTE'
  final String? trekkingPlaceId;
  final String? trekkingRouteId;
  final String mapName;
  final String localPath;
  final int? mapVersion;
  final int? sizeBytes;
  final int waypointCount;
  final int? minZoom;
  final int? maxZoom;
  final double? minLatitude;
  final double? minLongitude;
  final double? maxLatitude;
  final double? maxLongitude;
  final String? checksum;
  final DateTime? downloadedAt;
  final DateTime? lastUsedAt;
  final String status;

  const DownloadedMap({
    required this.mapId,
    this.scope = 'ROUTE',
    this.trekkingPlaceId,
    this.trekkingRouteId,
    required this.mapName,
    required this.localPath,
    this.mapVersion,
    this.sizeBytes,
    this.waypointCount = 0,
    this.minZoom,
    this.maxZoom,
    this.minLatitude,
    this.minLongitude,
    this.maxLatitude,
    this.maxLongitude,
    this.checksum,
    this.downloadedAt,
    this.lastUsedAt,
    this.status = 'READY',
  });

  factory DownloadedMap.fromMap(Map<String, dynamic> map) {
    return DownloadedMap(
      mapId: map['mapId'] as String,
      scope: map['scope'] as String? ?? 'ROUTE',
      trekkingPlaceId: map['trekkingPlaceId'] as String?,
      trekkingRouteId: map['trekkingRouteId'] as String?,
      mapName: map['mapName'] as String,
      localPath: map['localPath'] as String,
      mapVersion: map['mapVersion'] as int?,
      sizeBytes: map['sizeBytes'] as int?,
      waypointCount: map['waypointCount'] as int? ?? 0,
      minZoom: map['minZoom'] as int?,
      maxZoom: map['maxZoom'] as int?,
      minLatitude: (map['minLatitude'] as num?)?.toDouble(),
      minLongitude: (map['minLongitude'] as num?)?.toDouble(),
      maxLatitude: (map['maxLatitude'] as num?)?.toDouble(),
      maxLongitude: (map['maxLongitude'] as num?)?.toDouble(),
      checksum: map['checksum'] as String?,
      downloadedAt: map['downloadedAt'] != null
          ? DateTime.parse(map['downloadedAt'] as String)
          : null,
      lastUsedAt: map['lastUsedAt'] != null
          ? DateTime.parse(map['lastUsedAt'] as String)
          : null,
      status: map['status'] as String? ?? 'READY',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mapId': mapId,
      'scope': scope,
      'trekkingPlaceId': trekkingPlaceId,
      'trekkingRouteId': trekkingRouteId,
      'mapName': mapName,
      'localPath': localPath,
      'mapVersion': mapVersion,
      'sizeBytes': sizeBytes,
      'waypointCount': waypointCount,
      'minZoom': minZoom,
      'maxZoom': maxZoom,
      'minLatitude': minLatitude,
      'minLongitude': minLongitude,
      'maxLatitude': maxLatitude,
      'maxLongitude': maxLongitude,
      'checksum': checksum,
      'downloadedAt': downloadedAt?.toIso8601String(),
      'lastUsedAt': lastUsedAt?.toIso8601String(),
      'status': status,
    };
  }

  DownloadedMap copyWith({
    String? mapId,
    String? scope,
    String? trekkingPlaceId,
    String? trekkingRouteId,
    String? mapName,
    String? localPath,
    int? mapVersion,
    int? sizeBytes,
    int? waypointCount,
    int? minZoom,
    int? maxZoom,
    double? minLatitude,
    double? minLongitude,
    double? maxLatitude,
    double? maxLongitude,
    String? checksum,
    DateTime? downloadedAt,
    DateTime? lastUsedAt,
    String? status,
  }) {
    return DownloadedMap(
      mapId: mapId ?? this.mapId,
      scope: scope ?? this.scope,
      trekkingPlaceId: trekkingPlaceId ?? this.trekkingPlaceId,
      trekkingRouteId: trekkingRouteId ?? this.trekkingRouteId,
      mapName: mapName ?? this.mapName,
      localPath: localPath ?? this.localPath,
      mapVersion: mapVersion ?? this.mapVersion,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      waypointCount: waypointCount ?? this.waypointCount,
      minZoom: minZoom ?? this.minZoom,
      maxZoom: maxZoom ?? this.maxZoom,
      minLatitude: minLatitude ?? this.minLatitude,
      minLongitude: minLongitude ?? this.minLongitude,
      maxLatitude: maxLatitude ?? this.maxLatitude,
      maxLongitude: maxLongitude ?? this.maxLongitude,
      checksum: checksum ?? this.checksum,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      status: status ?? this.status,
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // COMPUTED GETTERS
  // ══════════════════════════════════════════════════════════════════════════

  /// Zoom range text (e.g., "10-15")
  String get zoomRangeText {
    if (minZoom != null && maxZoom != null) {
      return '$minZoom-$maxZoom';
    }
    return 'N/A';
  }

  /// Size in MB text (e.g., "12.5 MB")
  String get sizeMBText {
    if (sizeBytes != null && sizeBytes! > 0) {
      final mb = sizeBytes! / (1024 * 1024);
      return '${mb.toStringAsFixed(1)} MB';
    }
    return 'N/A';
  }

  /// Check if map has trail support (has waypoints)
  bool get hasTrailSupport {
    return waypointCount > 0;
  }

  /// Check if map is ready to use
  bool get isReady {
    return status == 'READY';
  }

  /// Check if map is downloading
  bool get isDownloading {
    return status == 'DOWNLOADING';
  }

  /// Check if map has error
  bool get hasError {
    return status == 'ERROR';
  }
}
