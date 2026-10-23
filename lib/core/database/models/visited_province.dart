class VisitedProvince {
  final String ownerId;
  final String provinceId;
  final String name;
  final DateTime? firstVisitedAt;
  final DateTime? lastVisitedAt;
  final int visitCount;
  final String? source;
  final String syncStatus;
  final DateTime? updatedAt;

  const VisitedProvince({
    this.ownerId = '',
    required this.provinceId,
    required this.name,
    this.firstVisitedAt,
    this.lastVisitedAt,
    this.visitCount = 1,
    this.source,
    this.syncStatus = 'SYNCED',
    this.updatedAt,
  });

  factory VisitedProvince.fromMap(Map<String, dynamic> map) {
    return VisitedProvince(
      ownerId: map['ownerId'] as String? ?? '',
      provinceId: map['provinceId'] as String,
      name: map['name'] as String,
      firstVisitedAt: map['firstVisitedAt'] != null
          ? DateTime.parse(map['firstVisitedAt'] as String)
          : null,
      lastVisitedAt: map['lastVisitedAt'] != null
          ? DateTime.parse(map['lastVisitedAt'] as String)
          : null,
      visitCount: map['visitCount'] as int? ?? 1,
      source: map['source'] as String?,
      syncStatus: map['syncStatus'] as String? ?? 'SYNCED',
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'provinceId': provinceId,
      'name': name,
      'firstVisitedAt': firstVisitedAt?.toIso8601String(),
      'lastVisitedAt': lastVisitedAt?.toIso8601String(),
      'visitCount': visitCount,
      'source': source,
      'syncStatus': syncStatus,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  VisitedProvince copyWith({
    String? ownerId,
    String? provinceId,
    String? name,
    DateTime? firstVisitedAt,
    DateTime? lastVisitedAt,
    int? visitCount,
    String? source,
    String? syncStatus,
    DateTime? updatedAt,
  }) {
    return VisitedProvince(
      ownerId: ownerId ?? this.ownerId,
      provinceId: provinceId ?? this.provinceId,
      name: name ?? this.name,
      firstVisitedAt: firstVisitedAt ?? this.firstVisitedAt,
      lastVisitedAt: lastVisitedAt ?? this.lastVisitedAt,
      visitCount: visitCount ?? this.visitCount,
      source: source ?? this.source,
      syncStatus: syncStatus ?? this.syncStatus,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
