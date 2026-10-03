/// Milestone type values
enum MilestoneType {
  start,
  checkpoint,
  viewpoint,
  restPoint,
  waterPoint,
  camp,
  summit,
  finish;

  static MilestoneType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'START':
        return MilestoneType.start;
      case 'CHECKPOINT':
        return MilestoneType.checkpoint;
      case 'VIEWPOINT':
        return MilestoneType.viewpoint;
      case 'REST_POINT':
        return MilestoneType.restPoint;
      case 'WATER_POINT':
        return MilestoneType.waterPoint;
      case 'CAMP':
        return MilestoneType.camp;
      case 'SUMMIT':
        return MilestoneType.summit;
      case 'FINISH':
        return MilestoneType.finish;
      default:
        return MilestoneType.checkpoint;
    }
  }

  String toDbString() {
    switch (this) {
      case MilestoneType.start:
        return 'START';
      case MilestoneType.checkpoint:
        return 'CHECKPOINT';
      case MilestoneType.viewpoint:
        return 'VIEWPOINT';
      case MilestoneType.restPoint:
        return 'REST_POINT';
      case MilestoneType.waterPoint:
        return 'WATER_POINT';
      case MilestoneType.camp:
        return 'CAMP';
      case MilestoneType.summit:
        return 'SUMMIT';
      case MilestoneType.finish:
        return 'FINISH';
    }
  }
}

class CachedMilestone {
  final String milestoneId;
  final String trekkingRouteId;
  final String name;
  final String? description;
  final String type;
  final int sequenceNumber;
  final double latitude;
  final double longitude;
  final double? altitude;
  final double checkinRadiusMeters;
  final bool required;
  final String? imageUrl;
  final DateTime? cachedAt;
  final DateTime? updatedAt;

  const CachedMilestone({
    required this.milestoneId,
    required this.trekkingRouteId,
    required this.name,
    this.description,
    required this.type,
    required this.sequenceNumber,
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.checkinRadiusMeters = 50.0,
    this.required = true,
    this.imageUrl,
    this.cachedAt,
    this.updatedAt,
  });

  factory CachedMilestone.fromMap(Map<String, dynamic> map) {
    return CachedMilestone(
      milestoneId: map['milestoneId'] as String,
      trekkingRouteId: map['trekkingRouteId'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      type: map['type'] as String,
      sequenceNumber: map['sequenceNumber'] as int,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      altitude: map['altitude'] as double?,
      checkinRadiusMeters: (map['checkinRadiusMeters'] as num?)?.toDouble() ?? 50.0,
      required: (map['required'] as int? ?? 1) == 1,
      imageUrl: map['imageUrl'] as String?,
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
      'milestoneId': milestoneId,
      'trekkingRouteId': trekkingRouteId,
      'name': name,
      'description': description,
      'type': type,
      'sequenceNumber': sequenceNumber,
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'checkinRadiusMeters': checkinRadiusMeters,
      'required': required ? 1 : 0,
      'imageUrl': imageUrl,
      'cachedAt': cachedAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
