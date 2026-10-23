/// Loại contribution
enum ContributionType {
  routeSubmission,
  placeSuggestion;

  static ContributionType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'ROUTE_SUBMISSION':
        return ContributionType.routeSubmission;
      case 'PLACE_SUGGESTION':
        return ContributionType.placeSuggestion;
      default:
        return ContributionType.routeSubmission;
    }
  }

  String toDbString() {
    switch (this) {
      case ContributionType.routeSubmission:
        return 'ROUTE_SUBMISSION';
      case ContributionType.placeSuggestion:
        return 'PLACE_SUGGESTION';
    }
  }
}

/// Trạng thái trên server của contribution
enum ContributionServerStatus {
  draft,
  pendingReview,
  needsRevision,
  approved,
  rejected,
  cancelled;

  static ContributionServerStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'DRAFT':
        return ContributionServerStatus.draft;
      case 'PENDING_REVIEW':
        return ContributionServerStatus.pendingReview;
      case 'NEEDS_REVISION':
        return ContributionServerStatus.needsRevision;
      case 'APPROVED':
        return ContributionServerStatus.approved;
      case 'REJECTED':
        return ContributionServerStatus.rejected;
      case 'CANCELLED':
        return ContributionServerStatus.cancelled;
      default:
        return ContributionServerStatus.draft;
    }
  }

  String toDbString() {
    switch (this) {
      case ContributionServerStatus.draft:
        return 'DRAFT';
      case ContributionServerStatus.pendingReview:
        return 'PENDING_REVIEW';
      case ContributionServerStatus.needsRevision:
        return 'NEEDS_REVISION';
      case ContributionServerStatus.approved:
        return 'APPROVED';
      case ContributionServerStatus.rejected:
        return 'REJECTED';
      case ContributionServerStatus.cancelled:
        return 'CANCELLED';
    }
  }
}

/// Trạng thái sync của contribution
enum ContributionSyncStatus {
  pending,
  processing,
  synced,
  failed,
  deferred;

  static ContributionSyncStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'PENDING':
        return ContributionSyncStatus.pending;
      case 'PROCESSING':
        return ContributionSyncStatus.processing;
      case 'SYNCED':
        return ContributionSyncStatus.synced;
      case 'FAILED':
        return ContributionSyncStatus.failed;
      case 'DEFERRED':
        return ContributionSyncStatus.deferred;
      default:
        return ContributionSyncStatus.pending;
    }
  }

  String toDbString() {
    return name.toUpperCase();
  }
}

class LocalContribution {
  final String localContributionId;
  final String? serverContributionId;
  final String userId;
  final String type;
  final String? sourceLocalJourneyId;
  final String? sourceServerJourneyId;
  final String payload;
  final String serverStatus;
  final String syncStatus;
  final String? adminNote;
  final String? resultingEntityId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastSyncedAt;

  const LocalContribution({
    required this.localContributionId,
    this.serverContributionId,
    required this.userId,
    required this.type,
    this.sourceLocalJourneyId,
    this.sourceServerJourneyId,
    required this.payload,
    this.serverStatus = 'DRAFT',
    this.syncStatus = 'PENDING',
    this.adminNote,
    this.resultingEntityId,
    this.createdAt,
    this.updatedAt,
    this.lastSyncedAt,
  });

  factory LocalContribution.fromMap(Map<String, dynamic> map) {
    return LocalContribution(
      localContributionId: map['localContributionId'] as String,
      serverContributionId: map['serverContributionId'] as String?,
      userId: map['userId'] as String,
      type: map['type'] as String,
      sourceLocalJourneyId: map['sourceLocalJourneyId'] as String?,
      sourceServerJourneyId: map['sourceServerJourneyId'] as String?,
      payload: map['payload'] as String,
      serverStatus: map['serverStatus'] as String? ?? 'DRAFT',
      syncStatus: map['syncStatus'] as String? ?? 'PENDING',
      adminNote: map['adminNote'] as String?,
      resultingEntityId: map['resultingEntityId'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
      lastSyncedAt: map['lastSyncedAt'] != null
          ? DateTime.parse(map['lastSyncedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'localContributionId': localContributionId,
      'serverContributionId': serverContributionId,
      'userId': userId,
      'type': type,
      'sourceLocalJourneyId': sourceLocalJourneyId,
      'sourceServerJourneyId': sourceServerJourneyId,
      'payload': payload,
      'serverStatus': serverStatus,
      'syncStatus': syncStatus,
      'adminNote': adminNote,
      'resultingEntityId': resultingEntityId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
    };
  }

  LocalContribution copyWith({
    String? localContributionId,
    String? serverContributionId,
    String? userId,
    String? type,
    String? sourceLocalJourneyId,
    String? sourceServerJourneyId,
    String? payload,
    String? serverStatus,
    String? syncStatus,
    String? adminNote,
    String? resultingEntityId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncedAt,
  }) {
    return LocalContribution(
      localContributionId: localContributionId ?? this.localContributionId,
      serverContributionId: serverContributionId ?? this.serverContributionId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      sourceLocalJourneyId: sourceLocalJourneyId ?? this.sourceLocalJourneyId,
      sourceServerJourneyId:
          sourceServerJourneyId ?? this.sourceServerJourneyId,
      payload: payload ?? this.payload,
      serverStatus: serverStatus ?? this.serverStatus,
      syncStatus: syncStatus ?? this.syncStatus,
      adminNote: adminNote ?? this.adminNote,
      resultingEntityId: resultingEntityId ?? this.resultingEntityId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}
