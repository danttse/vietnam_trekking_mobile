/// Trạng thái của journey
enum JourneyStatus {
  planned,
  active,
  paused,
  completed,
  cancelled;

  static JourneyStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'PLANNED':
        return JourneyStatus.planned;
      case 'ACTIVE':
        return JourneyStatus.active;
      case 'PAUSED':
        return JourneyStatus.paused;
      case 'COMPLETED':
        return JourneyStatus.completed;
      case 'CANCELLED':
        return JourneyStatus.cancelled;
      default:
        return JourneyStatus.planned;
    }
  }

  String toDbString() {
    return name.toUpperCase();
  }
}

/// Trạng thái sync
enum SyncStatus {
  pending,
  synced,
  failed;

  static SyncStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'PENDING':
        return SyncStatus.pending;
      case 'SYNCED':
        return SyncStatus.synced;
      case 'FAILED':
        return SyncStatus.failed;
      default:
        return SyncStatus.pending;
    }
  }

  String toDbString() {
    return name.toUpperCase();
  }
}

class LocalJourney {
  final String localJourneyId;
  final String? serverJourneyId;
  final String userId;
  final String trekkingPlaceId;
  final String trekkingRouteId;
  final String? provinceId;
  final String name;
  final String status;
  final DateTime? plannedStartAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final double distanceMeters;
  final int durationSeconds;
  final double elevationGain;
  final double? maxAltitude;
  final int checkinCount;
  final int markerCount;
  final String syncStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const LocalJourney({
    required this.localJourneyId,
    this.serverJourneyId,
    required this.userId,
    required this.trekkingPlaceId,
    required this.trekkingRouteId,
    this.provinceId,
    required this.name,
    this.status = 'PLANNED',
    this.plannedStartAt,
    this.startedAt,
    this.completedAt,
    this.distanceMeters = 0.0,
    this.durationSeconds = 0,
    this.elevationGain = 0.0,
    this.maxAltitude,
    this.checkinCount = 0,
    this.markerCount = 0,
    this.syncStatus = 'PENDING',
    this.createdAt,
    this.updatedAt,
  });

  factory LocalJourney.fromMap(Map<String, dynamic> map) {
    return LocalJourney(
      localJourneyId: map['localJourneyId'] as String,
      serverJourneyId: map['serverJourneyId'] as String?,
      userId: map['userId'] as String,
      trekkingPlaceId: map['trekkingPlaceId'] as String,
      trekkingRouteId: map['trekkingRouteId'] as String,
      provinceId: map['provinceId'] as String?,
      name: map['name'] as String,
      status: map['status'] as String? ?? 'PLANNED',
      plannedStartAt: map['plannedStartAt'] != null
          ? DateTime.parse(map['plannedStartAt'] as String)
          : null,
      startedAt: map['startedAt'] != null
          ? DateTime.parse(map['startedAt'] as String)
          : null,
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'] as String)
          : null,
      distanceMeters: (map['distanceMeters'] as num?)?.toDouble() ?? 0.0,
      durationSeconds: map['durationSeconds'] as int? ?? 0,
      elevationGain: (map['elevationGain'] as num?)?.toDouble() ?? 0.0,
      maxAltitude: (map['maxAltitude'] as num?)?.toDouble(),
      checkinCount: map['checkinCount'] as int? ?? 0,
      markerCount: map['markerCount'] as int? ?? 0,
      syncStatus: map['syncStatus'] as String? ?? 'PENDING',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'localJourneyId': localJourneyId,
      'serverJourneyId': serverJourneyId,
      'userId': userId,
      'trekkingPlaceId': trekkingPlaceId,
      'trekkingRouteId': trekkingRouteId,
      'provinceId': provinceId,
      'name': name,
      'status': status,
      'plannedStartAt': plannedStartAt?.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'distanceMeters': distanceMeters,
      'durationSeconds': durationSeconds,
      'elevationGain': elevationGain,
      'maxAltitude': maxAltitude,
      'checkinCount': checkinCount,
      'markerCount': markerCount,
      'syncStatus': syncStatus,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  LocalJourney copyWith({
    String? localJourneyId,
    String? serverJourneyId,
    String? userId,
    String? trekkingPlaceId,
    String? trekkingRouteId,
    String? provinceId,
    String? name,
    String? status,
    DateTime? plannedStartAt,
    DateTime? startedAt,
    DateTime? completedAt,
    double? distanceMeters,
    int? durationSeconds,
    double? elevationGain,
    double? maxAltitude,
    int? checkinCount,
    int? markerCount,
    String? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LocalJourney(
      localJourneyId: localJourneyId ?? this.localJourneyId,
      serverJourneyId: serverJourneyId ?? this.serverJourneyId,
      userId: userId ?? this.userId,
      trekkingPlaceId: trekkingPlaceId ?? this.trekkingPlaceId,
      trekkingRouteId: trekkingRouteId ?? this.trekkingRouteId,
      provinceId: provinceId ?? this.provinceId,
      name: name ?? this.name,
      status: status ?? this.status,
      plannedStartAt: plannedStartAt ?? this.plannedStartAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      elevationGain: elevationGain ?? this.elevationGain,
      maxAltitude: maxAltitude ?? this.maxAltitude,
      checkinCount: checkinCount ?? this.checkinCount,
      markerCount: markerCount ?? this.markerCount,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
