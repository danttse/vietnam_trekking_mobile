/// Model Milestone (điểm kiểm soát) trả về từ API.
class MilestoneModel {
  final String milestoneId;
  final String trekkingRouteId;
  final String name;
  final String? description;
  final String type; // START | CHECKPOINT | VIEWPOINT | REST_POINT | WATER_POINT | CAMP | SUMMIT | FINISH
  final int sequenceNumber;
  final double latitude;
  final double longitude;
  final double? altitude;
  final double checkinRadiusMeters;
  final bool required;
  final String? imageUrl;

  // Runtime state — không từ API, tính toán local
  final bool isCheckedIn;
  final bool isCurrentLocation; // user đang ở đây

  const MilestoneModel({
    required this.milestoneId,
    required this.trekkingRouteId,
    required this.name,
    this.description,
    required this.type,
    required this.sequenceNumber,
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.checkinRadiusMeters = 500,
    this.required = true,
    this.imageUrl,
    this.isCheckedIn = false,
    this.isCurrentLocation = false,
  });

  factory MilestoneModel.fromJson(Map<String, dynamic> json) {
    // Backend trả location dạng GeoJSON Point: { "type": "Point", "coordinates": [lng, lat] }
    // Cũng hỗ trợ flat fields latitude/longitude cho backward compat.
    double lat;
    double lng;
    final location = json['location'] as Map<String, dynamic>?;
    if (location != null) {
      final coords = location['coordinates'] as List<dynamic>;
      // GeoJSON convention: [longitude, latitude]
      lng = (coords[0] as num).toDouble();
      lat = (coords[1] as num).toDouble();
    } else {
      lat = (json['latitude'] as num).toDouble();
      lng = (json['longitude'] as num).toDouble();
    }

    return MilestoneModel(
      milestoneId: json['milestoneId'] as String? ??
          json['id'] as String,
      trekkingRouteId: json['trekkingRouteId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      type: json['type'] as String? ?? 'CHECKPOINT',
      // Backend dùng "sequence", frontend dùng "sequenceNumber"
      sequenceNumber: json['sequence'] as int? ??
          json['sequenceNumber'] as int? ?? 0,
      latitude: lat,
      longitude: lng,
      altitude: (json['altitude'] as num?)?.toDouble(),
      checkinRadiusMeters:
          (json['checkinRadiusMeters'] as num?)?.toDouble() ?? 50,
      required: json['required'] as bool? ?? true,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  MilestoneModel copyWith({
    bool? isCheckedIn,
    bool? isCurrentLocation,
  }) {
    return MilestoneModel(
      milestoneId: milestoneId,
      trekkingRouteId: trekkingRouteId,
      name: name,
      description: description,
      type: type,
      sequenceNumber: sequenceNumber,
      latitude: latitude,
      longitude: longitude,
      altitude: altitude,
      checkinRadiusMeters: checkinRadiusMeters,
      required: required,
      imageUrl: imageUrl,
      isCheckedIn: isCheckedIn ?? this.isCheckedIn,
      isCurrentLocation: isCurrentLocation ?? this.isCurrentLocation,
    );
  }

  String get altitudeLabel {
    if (altitude == null) return '';
    return 'Độ cao ${altitude!.toInt()}m';
  }

  String get typeLabel {
    switch (type.toUpperCase()) {
      case 'START':
        return 'Điểm xuất phát';
      case 'FINISH':
        return 'Điểm kết thúc';
      case 'CHECKPOINT':
        return 'Điểm kiểm soát';
      case 'VIEWPOINT':
        return 'Điểm ngắm cảnh';
      case 'REST_POINT':
        return 'Điểm nghỉ chân';
      case 'WATER_POINT':
        return 'Nguồn nước';
      case 'CAMP':
        return 'Điểm cắm trại';
      case 'SUMMIT':
        return 'Đỉnh núi';
      default:
        return 'Điểm kiểm soát';
    }
  }
}
