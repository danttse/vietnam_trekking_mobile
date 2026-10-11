import 'package:flutter/material.dart';
import 'package:vietnam_trekking_mobile/core/widgets/cards/card_home_stats.dart';
import 'package:vietnam_trekking_mobile/features/promote/widgets/promote_slide_scaffold.dart';
import 'package:vietnam_trekking_mobile/l10n/app_localizations.dart';

class PromoteStatsSlide extends StatelessWidget {
  const PromoteStatsSlide({super.key});

  Widget _buildAchievementBadgeCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: colorScheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return PromoteSlideScaffold(
      title: l10n.promoteStatsTitle,
      description: l10n.promoteStatsDesc,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 160,
              child: Row(
                children: [
                  Expanded(
                    flex: 11,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/images/vietnam_network.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: colorScheme.surfaceContainerHigh,
                          child: Icon(
                            Icons.terrain,
                            size: 48,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 9,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CardHomeStats(
                          title: l10n.promoteStatsProvinces,
                          value: '10/34',
                          icon: Icons.map_outlined,
                          iconColor: colorScheme.primary,
                        ),
                        CardHomeStats(
                          title: l10n.promoteStatsDistance,
                          value: '192 km',
                          icon: Icons.directions_walk_rounded,
                          iconColor: colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildAchievementBadgeCard(
                    context: context,
                    icon: Icons.forest_rounded,
                    title: l10n.promoteStatsBadgeMountain,
                    subtitle: l10n.promoteStatsBadgeMountainSub,
                  ),
                  const SizedBox(width: 8),
                  _buildAchievementBadgeCard(
                    context: context,
                    icon: Icons.waves_rounded,
                    title: l10n.promoteStatsBadgeIsland,
                    subtitle: l10n.promoteStatsBadgeIslandSub,
                  ),
                  const SizedBox(width: 8),
                  _buildAchievementBadgeCard(
                    context: context,
                    icon: Icons.explore_rounded,
                    title: l10n.promoteStatsBadgeExplore,
                    subtitle: l10n.promoteStatsBadgeExploreSub,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}