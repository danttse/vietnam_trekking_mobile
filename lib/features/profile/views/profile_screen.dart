import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../view_models/profile_viewmodel.dart';
import '../widgets/profile_widgets.dart';
import 'profile_setting_screen.dart';

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

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top App Bar: Title "Hồ Sơ" + Settings Icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          if (Navigator.canPop(context)) ...[
                            IconButton(
                              icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                              onPressed: () => Navigator.pop(context),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            l10n.profileTitle,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                      // Settings button in circular container
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileSettingScreen(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.settings_outlined,
                            size: 20,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Profile Header (Avatar, Name, PRO, Member Since, Bio)
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
            );
          },
        ),
      ),
    );
  }
}
