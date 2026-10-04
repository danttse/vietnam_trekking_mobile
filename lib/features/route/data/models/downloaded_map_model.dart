class DownloadedMapModel {
  final String mapId;
  final String trekkingPlaceId;
  final String trekkingRouteId;
  final String mapName;
  final String localPath;
  final int mapVersion;
  final int sizeBytes;
  final int minZoom;
  final int maxZoom;
  final double minLatitude;
  final double minLongitude;
  final double maxLatitude;
  final double maxLongitude;
  final String checksum;
  final DateTime? downloadedAt;
  final DateTime? lastUsedAt;
  final String status;
  final int waypointCount;
  final bool hasTrailSupport;

  const DownloadedMapModel({
    required this.mapId,
    required this.trekkingPlaceId,
    required this.trekkingRouteId,
    required this.mapName,
    this.localPath = '',
    this.mapVersion = 1,
    this.sizeBytes = 44040192, // ~42 MB
    this.minZoom = 12,
    this.maxZoom = 17,
    this.minLatitude = 0.0,
    this.minLongitude = 0.0,
    this.maxLatitude = 0.0,
    this.maxLongitude = 0.0,
    this.checksum = '',
    this.downloadedAt,
    this.lastUsedAt,
    this.status = 'READY',
    this.waypointCount = 28,
    this.hasTrailSupport = true,
  });

  String get sizeMBText {
    final mb = sizeBytes / (1024 * 1024);
    return '${mb.toStringAsFixed(0)} MB';
  }

  String get zoomRangeText => '$minZoom – $maxZoom';
}
