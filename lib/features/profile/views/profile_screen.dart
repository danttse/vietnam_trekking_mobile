import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vietnam_trekking_mobile/features/profile/views/edit_bio_screen.dart';

import '../../../l10n/app_localizations.dart';
import '../view_models/profile_viewmodel.dart';
import '../widgets/profile_widgets.dart';
import '../widgets/rank_widgets.dart';
import 'rank_detail_screen.dart';
import 'xp_history_screen.dart';
import 'profile_setting_screen.dart';
import 'badge_detail_screen.dart';
import '../../../core/widgets/app_bar/app_top_bar.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;
  final ValueChanged<int>? onTabChanged;

  const ProfileScreen({super.key, this.onBackToHome, this.onTabChanged});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ProfileViewModel>().ensureLoaded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    // watch -> tự rebuild khi ProfileViewModel gọi notifyListeners()
    final viewModel = context.watch<ProfileViewModel>();
    final profile = viewModel.profile;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            if (viewModel.isLoading) const LinearProgressIndicator(),
            if (viewModel.error != null)
              ListTile(
                title: Text(viewModel.error!),
                trailing: TextButton(
                  onPressed: viewModel.load,
                  child: const Text('Thử lại'),
                ),
              ),
            AppTopBar(
              title: l10n.profileTitle,
              icon: Icons.settings_outlined,
              onClickIcon: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileSettingScreen(),
                  ),
                );
              },
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: viewModel.load,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
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
                        rankLabel: viewModel.rankProfile == null
                            ? null
                            : '${viewModel.rankProfile!.rank.name} · ${l10n.rankLevel(viewModel.rankProfile!.rank.level)}',
                        isEdit: true,
                        actionEdit: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditBioScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      ProfileProvinceProgressBar(
                        title: l10n.profileProvinceMapTitle,
                        current: profile.visitedProvinces,
                        total: profile.totalProvinces,
                        unit: l10n.profileProvinceUnit,
                      ),
                      const SizedBox(height: 20),

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

                      Text(
                        l10n.rankSectionTitle,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      RankSummaryCard(
                        profile: viewModel.rankProfile,
                        progress: viewModel.rankProgress,
                        isLoading: viewModel.isRankLoading,
                        error: viewModel.rankError,
                        onRetry: viewModel.loadRank,
                        onViewDetails: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RankDetailScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.history_rounded),
                        label: Text(l10n.xpHistoryTitle),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const XpHistoryScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

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

                      ...profile.achievements.map((achievement) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: ProfileAchievementCard(
                            title: achievement.title,
                            description: achievement.description,
                            icon: achievement.icon,
                            isUnlocked: achievement.isUnlocked,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BadgeDetailScreen(
                                    badge: achievement,
                                    allBadges: profile.achievements,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
