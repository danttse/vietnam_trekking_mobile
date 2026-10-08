import '../../../core/utils/badge_icon_helper.dart';
import '../../../l10n/app_localizations.dart';
import '../../profile/data/models/profile_model.dart';
import '../data/models/journey_model.dart';
import '../data/models/milestone_model.dart';
import 'package:flutter/material.dart';

class CheckinSuccessViewModel extends ChangeNotifier {
  final MilestoneModel? milestone;
  final JourneyModel? journey;
  final List<AchievementModel>? _customAchievements;

  final int _visitedProvinces = 14;
  final int _totalProvinces = 34;

  CheckinSuccessViewModel({
    this.milestone,
    this.journey,
    List<AchievementModel>? achievements,
  }) : _customAchievements = achievements;

  int get countAchieve => _customAchievements?.length ?? 1;
  String get countAchieveText => '+$countAchieve';

  int get visitedProvinces => _visitedProvinces;
  int get totalProvinces => _totalProvinces;
  String get conqueredProvincesText => '$_visitedProvinces / $_totalProvinces';
  String get maxElevationText {
    double alt = 0;
    if (milestone != null && milestone!.altitude > 0) {
      alt = milestone!.altitude;
    } else if (journey != null && journey!.route.maxElevation > 0) {
      alt = journey!.route.maxElevation;
    }
    if (alt <= 0) return '--';
    final formatted = alt.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    return '${formatted}m';
  }
  String get destinationName {
    if (milestone != null && milestone!.name.trim().isNotEmpty) {
      return milestone!.name.trim();
    }
    if (journey != null && journey!.route.name.trim().isNotEmpty) {
      return journey!.route.name.trim();
    }
    return journey?.name ?? '';
  }
  List<AchievementModel> get achievementsEarned {
    return _customAchievements ?? const [];
  }

  List<AchievementModel> getAchievements(AppLocalizations l10n) {
    final custom = _customAchievements;
    if (custom != null && custom.isNotEmpty) {
      return custom;
    }

    final name = destinationName.isNotEmpty ? destinationName : 'Checkpoint';
    final double alt = milestone?.altitude ?? (journey?.route.maxElevation ?? 0);

    final title = l10n.milestoneConquerBadgeTitle(name);
    final description = alt > 0
        ? l10n.milestoneConquerBadgeDesc(name, alt.toInt().toString())
        : l10n.milestoneConquerBadgeDescSimple(name);

    final icon = _resolveMilestoneIcon(name, alt);

    return [
      AchievementModel(
        id: 'ach_${milestone?.id ?? DateTime.now().millisecondsSinceEpoch}',
        title: title,
        description: description,
        icon: icon,
        isUnlocked: true,
      ),
    ];
  }

  IconData _resolveMilestoneIcon(String name, double altitude) {
    return BadgeIconHelper.resolve(name, altitude);
  }
}
