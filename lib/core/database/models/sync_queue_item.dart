/// Loại entity trong sync queue
enum SyncEntityType {
  journey,
  checkin,
  provinceVisit,
  routeSubmission,
  placeSuggestion,
  journeyMarker,
  markerMedia;

  static SyncEntityType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'JOURNEY':
        return SyncEntityType.journey;
      case 'CHECKIN':
        return SyncEntityType.checkin;
      case 'PROVINCE_VISIT':
        return SyncEntityType.provinceVisit;
      case 'ROUTE_SUBMISSION':
        return SyncEntityType.routeSubmission;
      case 'PLACE_SUGGESTION':
        return SyncEntityType.placeSuggestion;
      case 'JOURNEY_MARKER':
        return SyncEntityType.journeyMarker;
      case 'MARKER_MEDIA':
        return SyncEntityType.markerMedia;
      default:
        return SyncEntityType.journey;
    }
  }

  String toDbString() {
    switch (this) {
      case SyncEntityType.journey:
        return 'JOURNEY';
      case SyncEntityType.checkin:
        return 'CHECKIN';
      case SyncEntityType.provinceVisit:
        return 'PROVINCE_VISIT';
      case SyncEntityType.routeSubmission:
        return 'ROUTE_SUBMISSION';
      case SyncEntityType.placeSuggestion:
        return 'PLACE_SUGGESTION';
      case SyncEntityType.journeyMarker:
        return 'JOURNEY_MARKER';
      case SyncEntityType.markerMedia:
        return 'MARKER_MEDIA';
    }
  }
}

/// Loại operation trong sync queue
enum SyncOperation {
  create,
  update,
  delete;

  static SyncOperation fromString(String value) {
    switch (value.toUpperCase()) {
      case 'CREATE':
        return SyncOperation.create;
      case 'UPDATE':
        return SyncOperation.update;
      case 'DELETE':
        return SyncOperation.delete;
      default:
        return SyncOperation.create;
    }
  }

  String toDbString() {
    return name.toUpperCase();
  }
}

/// Trạng thái item trong sync queue
enum SyncQueueStatus {
  pending,
  processing,
  failed;

  static SyncQueueStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'PENDING':
        return SyncQueueStatus.pending;
      case 'PROCESSING':
        return SyncQueueStatus.processing;
      case 'FAILED':
        return SyncQueueStatus.failed;
      default:
        return SyncQueueStatus.pending;
    }
  }

  String toDbString() {
    return name.toUpperCase();
  }
}

/// Mức ưu tiên trong sync queue
enum SyncPriority {
  immediate,
  normal,
  offPeak,
  bulk;

  static SyncPriority fromString(String value) {
    switch (value.toUpperCase()) {
      case 'IMMEDIATE':
        return SyncPriority.immediate;
      case 'NORMAL':
        return SyncPriority.normal;
      case 'OFF_PEAK':
        return SyncPriority.offPeak;
      case 'BULK':
        return SyncPriority.bulk;
      default:
        return SyncPriority.normal;
    }
  }

  String toDbString() {
    switch (this) {
      case SyncPriority.immediate:
        return 'IMMEDIATE';
      case SyncPriority.normal:
        return 'NORMAL';
      case SyncPriority.offPeak:
        return 'OFF_PEAK';
      case SyncPriority.bulk:
        return 'BULK';
    }
  }
}

class SyncQueueItem {
  final int? syncQueueId; // Auto-increment
  final String entityType;
  final String entityId;
  final String operation;
  final String? payload;
  final String status;
  final int retryCount;
  final String idempotencyKey;
  final String priority;
  final DateTime? nextRetryAt;
  final DateTime? scheduledAfter;
  final int? payloadSizeBytes;
  final DateTime createdAt;
  final DateTime? lastAttemptAt;
  final String? lastError;

  const SyncQueueItem({
    this.syncQueueId,
    required this.entityType,
    required this.entityId,
    required this.operation,
    this.payload,
    this.status = 'PENDING',
    this.retryCount = 0,
    required this.idempotencyKey,
    this.priority = 'NORMAL',
    this.nextRetryAt,
    this.scheduledAfter,
    this.payloadSizeBytes,
    required this.createdAt,
    this.lastAttemptAt,
    this.lastError,
  });

  factory SyncQueueItem.fromMap(Map<String, dynamic> map) {
    return SyncQueueItem(
      syncQueueId: map['syncQueueId'] as int?,
      entityType: map['entityType'] as String,
      entityId: map['entityId'] as String,
      operation: map['operation'] as String,
      payload: map['payload'] as String?,
      status: map['status'] as String? ?? 'PENDING',
      retryCount: map['retryCount'] as int? ?? 0,
      idempotencyKey: map['idempotencyKey'] as String,
      priority: map['priority'] as String? ?? 'NORMAL',
      nextRetryAt: map['nextRetryAt'] != null
          ? DateTime.parse(map['nextRetryAt'] as String)
          : null,
      scheduledAfter: map['scheduledAfter'] != null
          ? DateTime.parse(map['scheduledAfter'] as String)
          : null,
      payloadSizeBytes: map['payloadSizeBytes'] as int?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastAttemptAt: map['lastAttemptAt'] != null
          ? DateTime.parse(map['lastAttemptAt'] as String)
          : null,
      lastError: map['lastError'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (syncQueueId != null) 'syncQueueId': syncQueueId,
      'entityType': entityType,
      'entityId': entityId,
      'operation': operation,
      'payload': payload,
      'status': status,
      'retryCount': retryCount,
      'idempotencyKey': idempotencyKey,
      'priority': priority,
      'nextRetryAt': nextRetryAt?.toIso8601String(),
      'scheduledAfter': scheduledAfter?.toIso8601String(),
      'payloadSizeBytes': payloadSizeBytes,
      'createdAt': createdAt.toIso8601String(),
      'lastAttemptAt': lastAttemptAt?.toIso8601String(),
      'lastError': lastError,
    };
  }

  SyncQueueItem copyWith({
    int? syncQueueId,
    String? entityType,
    String? entityId,
    String? operation,
    String? payload,
    String? status,
    int? retryCount,
    String? idempotencyKey,
    String? priority,
    DateTime? nextRetryAt,
    DateTime? scheduledAfter,
    int? payloadSizeBytes,
    DateTime? createdAt,
    DateTime? lastAttemptAt,
    String? lastError,
  }) {
    return SyncQueueItem(
      syncQueueId: syncQueueId ?? this.syncQueueId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      priority: priority ?? this.priority,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
      scheduledAfter: scheduledAfter ?? this.scheduledAfter,
      payloadSizeBytes: payloadSizeBytes ?? this.payloadSizeBytes,
      createdAt: createdAt ?? this.createdAt,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      lastError: lastError ?? this.lastError,
    );
  }
}
