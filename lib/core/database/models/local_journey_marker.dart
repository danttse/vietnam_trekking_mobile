/// Loại marker do user tạo
enum MarkerType {
  viewpoint,
  restPoint,
  waterPoint,
  camp,
  danger,
  intersection,
  summit,
  landmark,
  photoSpot,
  other;

  static MarkerType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'VIEWPOINT':
        return MarkerType.viewpoint;
      case 'REST_POINT':
        return MarkerType.restPoint;
      case 'WATER_POINT':
        return MarkerType.waterPoint;
      case 'CAMP':
        return MarkerType.camp;
      case 'DANGER':
        return MarkerType.danger;
      case 'INTERSECTION':
        return MarkerType.intersection;
      case 'SUMMIT':
        return MarkerType.summit;
      case 'LANDMARK':
        return MarkerType.landmark;
      case 'PHOTO_SPOT':
        return MarkerType.photoSpot;
      default:
        return MarkerType.other;
    }
  }

  String toDbString() {
    switch (this) {
      case MarkerType.viewpoint:
        return 'VIEWPOINT';
      case MarkerType.restPoint:
        return 'REST_POINT';
      case MarkerType.waterPoint:
        return 'WATER_POINT';
      case MarkerType.camp:
        return 'CAMP';
      case MarkerType.danger:
        return 'DANGER';
      case MarkerType.intersection:
        return 'INTERSECTION';
      case MarkerType.summit:
        return 'SUMMIT';
      case MarkerType.landmark:
        return 'LANDMARK';
      case MarkerType.photoSpot:
        return 'PHOTO_SPOT';
      case MarkerType.other:
        return 'OTHER';
    }
  }

  /// Tên hiển thị tiếng Việt
  String get displayName {
    switch (this) {
      case MarkerType.viewpoint:
        return 'Điểm ngắm cảnh';
      case MarkerType.restPoint:
        return 'Điểm nghỉ chân';
      case MarkerType.waterPoint:
        return 'Nguồn nước';
      case MarkerType.camp:
        return 'Điểm cắm trại';
      case MarkerType.danger:
        return 'Khu vực nguy hiểm';
      case MarkerType.intersection:
        return 'Ngã rẽ';
      case MarkerType.summit:
        return 'Đỉnh núi';
      case MarkerType.landmark:
        return 'Cột mốc';
      case MarkerType.photoSpot:
        return 'Điểm chụp ảnh';
      case MarkerType.other:
        return 'Khác';
    }
  }
}

/// Trạng thái sync của marker
enum MarkerSyncStatus {
  localOnly,
  pendingSync,
  synced,
  failed;

  static MarkerSyncStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'LOCAL_ONLY':
        return MarkerSyncStatus.localOnly;
      case 'PENDING_SYNC':
        return MarkerSyncStatus.pendingSync;
      case 'SYNCED':
        return MarkerSyncStatus.synced;
      case 'FAILED':
        return MarkerSyncStatus.failed;
      default:
        return MarkerSyncStatus.localOnly;
    }
  }

  String toDbString() {
    switch (this) {
      case MarkerSyncStatus.localOnly:
        return 'LOCAL_ONLY';
      case MarkerSyncStatus.pendingSync:
        return 'PENDING_SYNC';
      case MarkerSyncStatus.synced:
        return 'SYNCED';
      case MarkerSyncStatus.failed:
        return 'FAILED';
    }
  }
}

class LocalJourneyMarker {
  final String localMarkerId;
  final String? serverMarkerId;
  final String localJourneyId;
  final String userId;
  final String name;
  final String type;
  final String? note;
  final double latitude;
  final double longitude;
  final double? altitude;
  final double? accuracyMeters;
  final DateTime markedAt;
  final String syncStatus;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const LocalJourneyMarker({
    required this.localMarkerId,
    this.serverMarkerId,
    required this.localJourneyId,
    required this.userId,
    required this.name,
    this.type = 'OTHER',
    this.note,
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.accuracyMeters,
    required this.markedAt,
    this.syncStatus = 'LOCAL_ONLY',
    required this.createdAt,
    this.updatedAt,
  });

  factory LocalJourneyMarker.fromMap(Map<String, dynamic> map) {
    return LocalJourneyMarker(
      localMarkerId: map['localMarkerId'] as String,
      serverMarkerId: map['serverMarkerId'] as String?,
      localJourneyId: map['localJourneyId'] as String,
      userId: map['userId'] as String,
      name: map['name'] as String,
      type: map['type'] as String? ?? 'OTHER',
      note: map['note'] as String?,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      altitude: (map['altitude'] as num?)?.toDouble(),
      accuracyMeters: (map['accuracyMeters'] as num?)?.toDouble(),
      markedAt: DateTime.parse(map['markedAt'] as String),
      syncStatus: map['syncStatus'] as String? ?? 'LOCAL_ONLY',
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'localMarkerId': localMarkerId,
      'serverMarkerId': serverMarkerId,
      'localJourneyId': localJourneyId,
      'userId': userId,
      'name': name,
      'type': type,
      'note': note,
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'accuracyMeters': accuracyMeters,
      'markedAt': markedAt.toIso8601String(),
      'syncStatus': syncStatus,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  LocalJourneyMarker copyWith({
    String? localMarkerId,
    String? serverMarkerId,
    String? localJourneyId,
    String? userId,
    String? name,
    String? type,
    String? note,
    double? latitude,
    double? longitude,
    double? altitude,
    double? accuracyMeters,
    DateTime? markedAt,
    String? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LocalJourneyMarker(
      localMarkerId: localMarkerId ?? this.localMarkerId,
      serverMarkerId: serverMarkerId ?? this.serverMarkerId,
      localJourneyId: localJourneyId ?? this.localJourneyId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      note: note ?? this.note,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      accuracyMeters: accuracyMeters ?? this.accuracyMeters,
      markedAt: markedAt ?? this.markedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
