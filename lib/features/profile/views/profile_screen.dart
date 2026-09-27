import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../view_models/profile_viewmodel.dart';
import '../widgets/profile_widgets.dart';
import 'profile_setting_screen.dart';
import '../../../core/widgets/app_bar/app_top_bar.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;
  final ValueChanged<int>? onTabChanged;

  const ProfileScreen({
    super.key,
    this.onBackToHome,
    this.onTabChanged,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileViewModel _viewModel = ProfileViewModel();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            final l10n = AppLocalizations.of(context)!;
            final profile = _viewModel.profile;
            return Column(children: [
            AppTopBar(
              title: l10n.profileTitle,
              icon: Icons.settings_outlined,
              onClickIcon: () {
              Navigator.push(context,
                MaterialPageRoute(
                  builder: (context) => const ProfileSettingScreen(),
                ),
              );
              },
            ),
            Expanded(child: 
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 18),
                  ProfileHeaderCard(
                    name: profile.name,
                    isPro: profile.isPro,
                    memberSince: l10n.memberSince(profile.memberSince),
                    bio: profile.bio,
                    avatarUrl: profile.avatarUrl,
                  ),
                  const SizedBox(height: 20),

                  // Province Progress Bar
                  ProfileProvinceProgressBar(
                    title: l10n.profileProvinceMapTitle,
                    current: profile.visitedProvinces,
                    total: profile.totalProvinces,
                    unit: l10n.profileProvinceUnit,
                  ),
                  const SizedBox(height: 20),

                  // 2x2 Stats Grid
                  Row(
                    children: [
                      Expanded(
                        child: ProfileStatCard(
                          value: '${profile.totalDistanceKm} km',
                          label: l10n.profileStatTotalDistance,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ProfileStatCard(
                          value: '${profile.visitedProvinces}',
                          label: l10n.profileStatVisitedProvinces,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ProfileStatCard(
                          value: '${profile.completedTrips}',
                          label: l10n.profileStatCompletedTrips,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ProfileStatCard(
                          value: '${profile.totalDays} ngày',
                          label: l10n.profileStatTotalDays,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Title: DANH HIỆU CỦA BẠN
                  Text(
                    l10n.profileAchievementsTitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // List of achievements
                  ...profile.achievements.map((achievement) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ProfileAchievementCard(
                        title: achievement.title,
                        description: achievement.description,
                        icon: achievement.icon,
                        isUnlocked: achievement.isUnlocked,
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                ],
              ),
            ))
            ]);
          },
        ),
      ),
    );
  }
}
