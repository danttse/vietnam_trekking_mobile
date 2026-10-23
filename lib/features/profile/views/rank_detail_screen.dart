import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../view_models/profile_viewmodel.dart';
import '../widgets/rank_widgets.dart';
import 'xp_history_screen.dart';

class RankDetailScreen extends StatefulWidget {
  const RankDetailScreen({super.key});

  @override
  State<RankDetailScreen> createState() => _RankDetailScreenState();
}

class _RankDetailScreenState extends State<RankDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final vm = context.read<ProfileViewModel>();
      if (!vm.isRankLoading) vm.loadRank();
      if (!vm.isRankCatalogLoading) vm.loadRankCatalog();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final progress = vm.rankProgress;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.rankDetailTitle)),
      body: RefreshIndicator(
        onRefresh: () => Future.wait([vm.loadRank(), vm.loadRankCatalog()]),
        child: ListView(
          padding: const EdgeInsets.all(18),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            RankSummaryCard(
              profile: vm.rankProfile,
              progress: progress,
              isLoading: vm.isRankLoading,
              error: vm.rankError,
              onRetry: vm.loadRank,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.history_rounded),
              label: Text(l10n.xpHistoryTitle),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const XpHistoryScreen()),
              ),
            ),
            if (progress?.nextRank != null) ...[
              const SizedBox(height: 24),
              Text(
                l10n.rankRequirementsTitle,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.rankOverallProgress(
                  rankNumber(context, progress!.overallProgressPercent),
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress.fraction,
                minHeight: 6,
                backgroundColor: colors.onSurface.withValues(alpha: 0.08),
              ),
              const SizedBox(height: 10),
              ...progress.requirements.entries
                  .where((item) => item.value.required > 0)
                  .map(
                    (item) => RankRequirementRow(
                      requirementKey: item.key,
                      requiredValue: item.value.required,
                      progress: item.value,
                    ),
                  ),
              const SizedBox(height: 8),
              Text(
                l10n.rankRequirementsHint,
                style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
              ),
            ],
            const SizedBox(height: 24),
            Text(
              l10n.rankAllTitle,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            if (vm.isRankCatalogLoading) const LinearProgressIndicator(),
            if (vm.rankCatalogError != null) ...[
              Text(vm.rankCatalogError!, style: TextStyle(color: colors.error)),
              TextButton(
                onPressed: vm.isRankCatalogLoading ? null : vm.loadRankCatalog,
                child: Text(l10n.rankRetry),
              ),
            ] else if (!vm.isRankCatalogLoading && vm.ranks.isEmpty)
              Text(l10n.rankCatalogEmpty),
            ...vm.ranks.map((rank) {
              final isCurrent = rank.code == vm.rankProfile?.rank.code;
              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isCurrent
                          ? colors.primary
                          : colors.onSurface.withValues(alpha: 0.1),
                    ),
                  ),
                  child: ExpansionTile(
                    key: ValueKey('rank-${rank.code}'),
                    shape: const Border(),
                    collapsedShape: const Border(),
                    iconColor: colors.onSurfaceVariant,
                    collapsedIconColor: colors.onSurfaceVariant,
                    leading: RankEmblem(rank: rank, size: 40),
                    title: Text(
                      rank.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '${l10n.rankLevel(rank.level)} · ${rankNumber(context, rank.requirements['xp']!)} XP${isCurrent ? ' · ${l10n.rankCurrent}' : ''}',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (rank.description?.isNotEmpty == true) ...[
                        Text(
                          rank.description!,
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      ...rank.requirements.entries
                          .where((item) => item.key == 'xp' || item.value > 0)
                          .map(
                            (item) => RankRequirementRow(
                              requirementKey: item.key,
                              requiredValue: item.value,
                            ),
                          ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
