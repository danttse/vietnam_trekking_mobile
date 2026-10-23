/// Trạng thái xác minh check-in
enum CheckinVerificationStatus {
  verified,
  rejected,
  pendingVerification;

  static CheckinVerificationStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'VERIFIED':
        return CheckinVerificationStatus.verified;
      case 'REJECTED':
        return CheckinVerificationStatus.rejected;
      case 'PENDING_VERIFICATION':
        return CheckinVerificationStatus.pendingVerification;
      default:
        return CheckinVerificationStatus.pendingVerification;
    }
  }

  String toDbString() {
    switch (this) {
      case CheckinVerificationStatus.verified:
        return 'VERIFIED';
      case CheckinVerificationStatus.rejected:
        return 'REJECTED';
      case CheckinVerificationStatus.pendingVerification:
        return 'PENDING_VERIFICATION';
    }
  }
}

class OfflineCheckin {
  final String localCheckinId;
  final String? serverCheckinId;
  final String localJourneyId;
  final String milestoneId;
  final String userId;
  final double latitude;
  final double longitude;
  final double? accuracyMeters;
  final double? distanceToTargetMeters;
  final String? verificationStatus;
  final DateTime checkedAt;
  final String syncStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const OfflineCheckin({
    required this.localCheckinId,
    this.serverCheckinId,
    required this.localJourneyId,
    required this.milestoneId,
    required this.userId,
    required this.latitude,
    required this.longitude,
    this.accuracyMeters,
    this.distanceToTargetMeters,
    this.verificationStatus,
    required this.checkedAt,
    this.syncStatus = 'PENDING',
    this.createdAt,
    this.updatedAt,
  });

  factory OfflineCheckin.fromMap(Map<String, dynamic> map) {
    return OfflineCheckin(
      localCheckinId: map['localCheckinId'] as String,
      serverCheckinId: map['serverCheckinId'] as String?,
      localJourneyId: map['localJourneyId'] as String,
      milestoneId: map['milestoneId'] as String,
      userId: map['userId'] as String,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      accuracyMeters: (map['accuracyMeters'] as num?)?.toDouble(),
      distanceToTargetMeters:
          (map['distanceToTargetMeters'] as num?)?.toDouble(),
      verificationStatus: map['verificationStatus'] as String?,
      checkedAt: DateTime.parse(map['checkedAt'] as String),
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
      'localCheckinId': localCheckinId,
      'serverCheckinId': serverCheckinId,
      'localJourneyId': localJourneyId,
      'milestoneId': milestoneId,
      'userId': userId,
      'latitude': latitude,
      'longitude': longitude,
      'accuracyMeters': accuracyMeters,
      'distanceToTargetMeters': distanceToTargetMeters,
      'verificationStatus': verificationStatus,
      'checkedAt': checkedAt.toIso8601String(),
      'syncStatus': syncStatus,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  OfflineCheckin copyWith({
    String? localCheckinId,
    String? serverCheckinId,
    String? localJourneyId,
    String? milestoneId,
    String? userId,
    double? latitude,
    double? longitude,
    double? accuracyMeters,
    double? distanceToTargetMeters,
    String? verificationStatus,
    DateTime? checkedAt,
    String? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OfflineCheckin(
      localCheckinId: localCheckinId ?? this.localCheckinId,
      serverCheckinId: serverCheckinId ?? this.serverCheckinId,
      localJourneyId: localJourneyId ?? this.localJourneyId,
      milestoneId: milestoneId ?? this.milestoneId,
      userId: userId ?? this.userId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracyMeters: accuracyMeters ?? this.accuracyMeters,
      distanceToTargetMeters:
          distanceToTargetMeters ?? this.distanceToTargetMeters,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      checkedAt: checkedAt ?? this.checkedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
