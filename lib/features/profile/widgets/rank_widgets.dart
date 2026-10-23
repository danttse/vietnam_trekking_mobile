import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/models/rank_model.dart';
import '../../../l10n/app_localizations.dart';

String rankNumber(BuildContext context, num value) =>
    NumberFormat.decimalPattern(Localizations.localeOf(context).toString())
        .format(value);

String rankRequirementLabel(AppLocalizations l10n, String key) => switch (key) {
  'xp' => l10n.rankXpLabel,
  'completedJourneys' => l10n.rankJourneysLabel,
  'visitedProvinces' => l10n.rankProvincesLabel,
  'badges' => l10n.rankBadgesLabel,
  'distanceMeters' => l10n.rankDistanceLabel,
  'approvedContributions' => l10n.rankContributionsLabel,
  _ => key,
};

String rankRequirementValue(BuildContext context, String key, num value) =>
    rankNumber(context, key == 'distanceMeters' ? value / 1000 : value);

class RankEmblem extends StatelessWidget {
  final RankInfo rank;
  final double size;
  const RankEmblem({super.key, required this.rank, this.size = 48});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final fallback = Center(
      child: Text(rank.emoji, style: TextStyle(fontSize: size * 0.55)),
    );
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.primary.withValues(alpha: 0.4)),
      ),
      padding: const EdgeInsets.all(6),
      child: rank.iconUrl?.isNotEmpty == true
          ? Image.network(
              rank.iconUrl!,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => fallback,
            )
          : fallback,
    );
  }
}

class RankSummaryCard extends StatelessWidget {
  final UserRankProfile? profile;
  final RankProgress? progress;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;
  final VoidCallback? onViewDetails;

  const RankSummaryCard({
    super.key,
    required this.profile,
    required this.progress,
    this.isLoading = false,
    this.error,
    required this.onRetry,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final data = profile;
    final next = data?.nextRank;
    final xpTarget = progress?.requirements['xp']?.required;
    return Container(
      key: const ValueKey('rank-summary-card'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.primary.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isLoading) ...[
            const LinearProgressIndicator(),
            const SizedBox(height: 12),
          ],
          if (data != null) ...[
            Row(
              children: [
                RankEmblem(rank: data.rank),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.rank.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        l10n.rankLevel(data.rank.level),
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              l10n.rankCurrentXp,
              style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            Text(
              '${rankNumber(context, data.totalXp)} XP',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            if (next == null)
              Text(l10n.rankHighest)
            else ...[
              Text(
                l10n.rankNextTarget(next.name),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              if (xpTarget != null && xpTarget > 0) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: (data.totalXp / xpTarget).clamp(0.0, 1.0).toDouble(),
                    minHeight: 7,
                    backgroundColor: colors.onSurface.withValues(alpha: 0.08),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${rankNumber(context, data.totalXp)} / ${rankNumber(context, xpTarget)} XP',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data.totalXp >= xpTarget
                      ? l10n.rankXpReached
                      : l10n.rankXpRemaining(
                          rankNumber(context, xpTarget - data.totalXp),
                        ),
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ] else
            Text(isLoading ? l10n.rankLoading : l10n.rankUnavailable),
          if (error != null) ...[
            const SizedBox(height: 10),
            Text(error!, style: TextStyle(fontSize: 12, color: colors.error)),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: isLoading ? null : onRetry,
                child: Text(l10n.rankRetry),
              ),
            ),
          ],
          if (onViewDetails != null) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: onViewDetails,
              child: Row(
                children: [
                  Expanded(child: Text(l10n.rankViewDetails)),
                  const Icon(Icons.chevron_right, size: 20),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class RankRequirementRow extends StatelessWidget {
  final String requirementKey;
  final num requiredValue;
  final RankRequirementProgress? progress;
  const RankRequirementRow({
    super.key,
    required this.requirementKey,
    required this.requiredValue,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final current = progress;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          if (current != null) ...[
            Icon(
              current.completed
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              size: 18,
              color: current.completed
                  ? colors.primary
                  : colors.onSurfaceVariant,
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              rankRequirementLabel(l10n, requirementKey),
              style: const TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            current == null
                ? rankRequirementValue(context, requirementKey, requiredValue)
                : '${rankRequirementValue(context, requirementKey, current.current)} / ${rankRequirementValue(context, requirementKey, requiredValue)}',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
