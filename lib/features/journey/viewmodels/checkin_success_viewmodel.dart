import '../../../core/services/user_api_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../profile/data/models/profile_model.dart';
import '../data/models/journey_model.dart';
import '../data/models/milestone_model.dart';

import 'package:flutter/material.dart';

class CheckinSuccessViewModel extends ChangeNotifier {
  final MilestoneModel? milestone;
  final JourneyModel? journey;
  final List<AchievementModel>? _customAchievements;

  int _visitedProvinces = 0;
  bool _disposed = false;
  final int _totalProvinces = 34;

  CheckinSuccessViewModel({
    this.milestone,
    this.journey,
    List<AchievementModel>? achievements,
  }) : _customAchievements = achievements {
    _loadSummary();
  }

  int get countAchieve => _customAchievements?.length ?? 0;
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

  List<AchievementModel> getAchievements(AppLocalizations l10n) =>
      achievementsEarned;

  Future<void> _loadSummary() async {
    try {
      final data = await UserApiService().getProvinceVisits();
      if (_disposed) return;
      _visitedProvinces =
          ((data['summary'] as Map?)?['visitedCount'] as num? ?? 0).toInt();
      notifyListeners();
    } catch (_) {
      /* No invented awards when server statistics are unavailable. */
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
