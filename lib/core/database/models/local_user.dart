/// Model lưu thông tin user local + cached gamification profile.
class LocalUser {
  final String userId;
  final String? displayName;
  final String? avatarUrl;
  final String? email;

  // Cached gamification profile
  final String? currentRankCode;
  final String? currentRankName;
  final int? currentRankLevel;
  final int totalXp;
  final String? nextRankCode;
  final int? nextRankXp;
  final DateTime? rankUpdatedAt;

  final DateTime? cachedAt;
  final DateTime? updatedAt;

  const LocalUser({
    required this.userId,
    this.displayName,
    this.avatarUrl,
    this.email,
    this.currentRankCode,
    this.currentRankName,
    this.currentRankLevel,
    this.totalXp = 0,
    this.nextRankCode,
    this.nextRankXp,
    this.rankUpdatedAt,
    this.cachedAt,
    this.updatedAt,
  });

  factory LocalUser.fromMap(Map<String, dynamic> map) {
    return LocalUser(
      userId: map['userId'] as String,
      displayName: map['displayName'] as String?,
      avatarUrl: map['avatarUrl'] as String?,
      email: map['email'] as String?,
      currentRankCode: map['currentRankCode'] as String?,
      currentRankName: map['currentRankName'] as String?,
      currentRankLevel: map['currentRankLevel'] as int?,
      totalXp: (map['totalXp'] as int?) ?? 0,
      nextRankCode: map['nextRankCode'] as String?,
      nextRankXp: map['nextRankXp'] as int?,
      rankUpdatedAt: map['rankUpdatedAt'] != null
          ? DateTime.parse(map['rankUpdatedAt'] as String)
          : null,
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
      'userId': userId,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'email': email,
      'currentRankCode': currentRankCode,
      'currentRankName': currentRankName,
      'currentRankLevel': currentRankLevel,
      'totalXp': totalXp,
      'nextRankCode': nextRankCode,
      'nextRankXp': nextRankXp,
      'rankUpdatedAt': rankUpdatedAt?.toIso8601String(),
      'cachedAt': cachedAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  LocalUser copyWith({
    String? userId,
    String? displayName,
    String? avatarUrl,
    String? email,
    String? currentRankCode,
    String? currentRankName,
    int? currentRankLevel,
    int? totalXp,
    String? nextRankCode,
    int? nextRankXp,
    DateTime? rankUpdatedAt,
    DateTime? cachedAt,
    DateTime? updatedAt,
  }) {
    return LocalUser(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      email: email ?? this.email,
      currentRankCode: currentRankCode ?? this.currentRankCode,
      currentRankName: currentRankName ?? this.currentRankName,
      currentRankLevel: currentRankLevel ?? this.currentRankLevel,
      totalXp: totalXp ?? this.totalXp,
      nextRankCode: nextRankCode ?? this.nextRankCode,
      nextRankXp: nextRankXp ?? this.nextRankXp,
      rankUpdatedAt: rankUpdatedAt ?? this.rankUpdatedAt,
      cachedAt: cachedAt ?? this.cachedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
