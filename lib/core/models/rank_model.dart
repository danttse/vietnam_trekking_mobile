class RankInfo {
  static const icons = {
    'NEWBIE': '🌱',
    'HIKER': '🥾',
    'EXPLORER': '🧭',
    'TREKKER': '🏔️',
    'PATHFINDER': '🗺️',
    'MOUNTAINEER': '⛰️',
    'ADVENTURER': '🌋',
    'ELITE_TREKKER': '🦅',
    'TREK_MASTER': '👑',
    'TREK_LEGEND': '🌟',
  };
  String get emoji => icons[code] ?? '🏅';
  final String code;
  final String name;
  final int level;
  final String? iconUrl;

  const RankInfo({
    required this.code,
    required this.name,
    required this.level,
    this.iconUrl,
  });

  factory RankInfo.fromJson(Map<String, dynamic> json) => RankInfo(
    code: json['code'] as String,
    name: json['name'] as String,
    level: (json['level'] as num).toInt(),
    iconUrl: json['iconUrl'] as String?,
  );
}

class RankDefinition extends RankInfo {
  final String? description;
  final Map<String, num> requirements;

  const RankDefinition({
    required super.code,
    required super.name,
    required super.level,
    super.iconUrl,
    this.description,
    required this.requirements,
  });

  factory RankDefinition.fromJson(Map<String, dynamic> json) {
    final requirements = json['requirements'] as Map;
    return RankDefinition(
      code: json['code'] as String,
      name: json['name'] as String,
      level: (json['level'] as num).toInt(),
      iconUrl: json['iconUrl'] as String?,
      description: json['description'] as String?,
      requirements: {
        'xp': json['minXp'] as num,
        for (final key in [
          'completedJourneys',
          'visitedProvinces',
          'badges',
          'distanceMeters',
          'approvedContributions',
        ])
          key: requirements[key] as num? ?? 0,
      },
    );
  }
}

class UserRankProfile {
  final RankInfo rank;
  final num totalXp;
  final RankInfo? nextRank;

  const UserRankProfile({
    required this.rank,
    required this.totalXp,
    this.nextRank,
  });

  factory UserRankProfile.fromJson(Map<String, dynamic> json) =>
      UserRankProfile(
        rank: RankInfo.fromJson(Map<String, dynamic>.from(json['rank'] as Map)),
        totalXp: json['totalXp'] as num,
        nextRank: json['nextRank'] == null
            ? null
            : RankInfo.fromJson(
                Map<String, dynamic>.from(json['nextRank'] as Map),
              ),
      );
}

class RankRequirementProgress {
  final num current;
  final num required;
  final bool completed;

  const RankRequirementProgress({
    required this.current,
    required this.required,
    required this.completed,
  });

  factory RankRequirementProgress.fromJson(Map json) => RankRequirementProgress(
    current: json['current'] as num,
    required: json['required'] as num,
    completed: json['completed'] as bool,
  );
}

class RankProgress {
  final RankInfo currentRank;
  final RankInfo? nextRank;
  final Map<String, RankRequirementProgress> requirements;
  final num overallProgressPercent;

  const RankProgress({
    required this.currentRank,
    this.nextRank,
    required this.requirements,
    required this.overallProgressPercent,
  });

  double get fraction =>
      (overallProgressPercent / 100).clamp(0.0, 1.0).toDouble();

  factory RankProgress.fromJson(Map<String, dynamic> json) => RankProgress(
    currentRank: RankInfo.fromJson(
      Map<String, dynamic>.from(json['currentRank'] as Map),
    ),
    nextRank: json['nextRank'] == null
        ? null
        : RankInfo.fromJson(Map<String, dynamic>.from(json['nextRank'] as Map)),
    requirements: (json['requirements'] as Map).map(
      (key, value) => MapEntry(
        key as String,
        RankRequirementProgress.fromJson(value as Map),
      ),
    ),
    overallProgressPercent: json['overallProgressPercent'] as num,
  );
}
