/// Model Journey Marker trả về từ API / tạo local.
class MarkerModel {
  final String markerId; // localMarkerId hoặc serverMarkerId
  final String? serverMarkerId;
  final String localJourneyId;
  final String name;
  final String type; // VIEWPOINT|REST_POINT|WATER_POINT|CAMP|DANGER|INTERSECTION|SUMMIT|LANDMARK|PHOTO_SPOT|OTHER
  final String? note;
  final double latitude;
  final double longitude;
  final double? altitude;
  final DateTime markedAt;
  final String syncStatus; // LOCAL_ONLY | PENDING_SYNC | SYNCED | FAILED
  final List<String> mediaLocalPaths;
  final List<String> mediaRemoteUrls;

  const MarkerModel({
    required this.markerId,
    this.serverMarkerId,
    required this.localJourneyId,
    required this.name,
    required this.type,
    this.note,
    required this.latitude,
    required this.longitude,
    this.altitude,
    required this.markedAt,
    this.syncStatus = 'LOCAL_ONLY',
    this.mediaLocalPaths = const [],
    this.mediaRemoteUrls = const [],
  });

  factory MarkerModel.fromJson(Map<String, dynamic> json) {
    // Backend trả location dạng GeoJSON Point: { "type": "Point", "coordinates": [lng, lat] }
    double lat;
    double lng;
    final location = json['location'] as Map<String, dynamic>?;
    if (location != null) {
      final coords = location['coordinates'] as List<dynamic>;
      lng = (coords[0] as num).toDouble();
      lat = (coords[1] as num).toDouble();
    } else {
      lat = (json['latitude'] as num).toDouble();
      lng = (json['longitude'] as num).toDouble();
    }

    return MarkerModel(
      // Backend trả "journeyMarkerId", fallback về "markerId" / "id" / "localMarkerId"
      markerId: json['journeyMarkerId'] as String? ??
          json['markerId'] as String? ??
          json['id'] as String? ??
          json['localMarkerId'] as String? ??
          '',
      serverMarkerId: json['journeyMarkerId'] as String? ??
          json['serverMarkerId'] as String?,
      localJourneyId: json['localJourneyId'] as String? ??
          json['journeyId'] as String? ??
          '',
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? 'OTHER',
      note: json['note'] as String?,
      latitude: lat,
      longitude: lng,
      altitude: (json['altitude'] as num?)?.toDouble(),
      markedAt: json['markedAt'] != null
          ? DateTime.tryParse(json['markedAt'] as String) ??
              DateTime.now()
          : DateTime.now(),
      syncStatus: json['syncStatus'] as String? ?? 'LOCAL_ONLY',
      mediaLocalPaths: (json['mediaLocalPaths'] as List<dynamic>?)
              ?.cast<String>() ??
          [],
      // Backend trả "images" (list of URLs)
      mediaRemoteUrls: (json['images'] as List<dynamic>?)
              ?.cast<String>() ??
          (json['mediaRemoteUrls'] as List<dynamic>?)
              ?.cast<String>() ??
          [],
    );
  }

  /// Chuyển sang body API tạo marker mới.
  /// Backend nhận location dạng GeoJSON Point với [lng, lat].
  Map<String, dynamic> toCreateJson({String? clientMarkerId}) => {
        'name': name,
        'type': type,
        if (note != null && note!.isNotEmpty) 'note': note,
        'location': {
          'type': 'Point',
          'coordinates': [longitude, latitude], // GeoJSON: [lng, lat]
        },
        if (altitude != null) 'altitude': altitude,
        'markedAt': markedAt.toIso8601String(),
        if (clientMarkerId != null) 'clientMarkerId': clientMarkerId,
      };

  String get typeLabel {
    switch (type.toUpperCase()) {
      case 'VIEWPOINT':
        return 'Điểm ngắm cảnh';
      case 'REST_POINT':
        return 'Điểm nghỉ chân';
      case 'WATER_POINT':
        return 'Nguồn nước';
      case 'CAMP':
        return 'Điểm cắm trại';
      case 'DANGER':
        return 'Khu vực nguy hiểm';
      case 'INTERSECTION':
        return 'Ngã rẽ';
      case 'SUMMIT':
        return 'Đỉnh núi';
      case 'LANDMARK':
        return 'Cột mốc';
      case 'PHOTO_SPOT':
        return 'Điểm chụp ảnh';
      default:
        return 'Khác';
    }
  }

  bool get isSynced => syncStatus == 'SYNCED';
  bool get isPendingSync =>
      syncStatus == 'LOCAL_ONLY' || syncStatus == 'PENDING_SYNC';
}
