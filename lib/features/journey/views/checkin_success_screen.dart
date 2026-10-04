import 'package:flutter/material.dart';
import '../../../core/widgets/buttons/btn_login_style.dart';
import '../../../core/widgets/buttons/btn_outline_style.dart';
import '../../../core/widgets/cards/profile_achievement_card.dart';
import '../../../core/widgets/cards/profile_stat_card.dart';
import '../../../l10n/app_localizations.dart';
import '../../profile/data/models/profile_model.dart';
import '../data/models/journey_model.dart';
import '../data/models/milestone_model.dart';
import '../viewmodels/checkin_success_viewmodel.dart';
import 'rate_milestone_screen.dart';

class CheckinSuccessScreen extends StatefulWidget {
  final MilestoneModel? milestone;
  final JourneyModel? journey;
  final List<AchievementModel>? achievements;

  const CheckinSuccessScreen({
    super.key,
    this.milestone,
    this.journey,
    this.achievements,
  });

  @override
  State<CheckinSuccessScreen> createState() => _CheckinSuccessScreenState();
}

class _CheckinSuccessScreenState extends State<CheckinSuccessScreen> {
  late final CheckinSuccessViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = CheckinSuccessViewModel(
      milestone: widget.milestone,
      journey: widget.journey,
      achievements: widget.achievements,
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.surfaceContainerHighest,
                        border: Border.all(
                          color: colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.terrain,
                          size: 54,
                          color: Color(0xFF6ECB8E),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.checkinCongratulation,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.checkinSuccessTitle,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      l10n.checkinSuccessMessage(_viewModel.destinationName),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      l10n.achievementsEarnedTitle,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._viewModel.getAchievements(l10n).map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ProfileAchievementCard(
                        title: item.title,
                        description: item.description,
                        icon: item.icon,
                        isUnlocked: item.isUnlocked,
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ProfileStatCard(
                          value: _viewModel.countAchieveText,
                          label: l10n.statNewBadge,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ProfileStatCard(
                          value: _viewModel.maxElevationText,
                          label: l10n.statMaxElevation,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ProfileStatCard(
                          value: _viewModel.conqueredProvincesText,
                          label: l10n.statConqueredProvinces,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: BtnLoginPrimary(
                      text: l10n.continueJourneyButton,
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: BtnOutlineStyle(
                      text: l10n.ratePlaceButton,
                      icon: Icon(
                        Icons.star_outline,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RateMilestoneScreen(
                              milestone: widget.milestone,
                              journey: widget.journey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: BtnOutlineStyle(
                      text: l10n.shareAchievementButton,
                      icon: const SizedBox.shrink(),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.featureComingSoon(l10n.shareAchievementButton)),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
