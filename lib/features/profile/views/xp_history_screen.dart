import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../view_models/xp_history_viewmodel.dart';
import '../widgets/rank_widgets.dart';

class XpHistoryScreen extends StatefulWidget {
  const XpHistoryScreen({super.key});
  @override
  State<XpHistoryScreen> createState() => _XpHistoryScreenState();
}

class _XpHistoryScreenState extends State<XpHistoryScreen> {
  final vm = XpHistoryViewModel();
  @override
  void initState() {
    super.initState();
    vm.load();
  }

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  String _sourceLabel(AppLocalizations l10n, String source) => switch (source) {
    'JOURNEY_COMPLETED' => l10n.xpJourneyCompleted,
    'JOURNEY_DISTANCE' => l10n.xpJourneyDistance,
    'JOURNEY_ELEVATION' => l10n.xpJourneyElevation,
    'MILESTONE_CHECKIN' => l10n.xpMilestoneCheckin,
    'PROVINCE_VISITED' => l10n.xpProvinceVisited,
    'PLACE_VISITED' => l10n.xpPlaceVisited,
    'BADGE_EARNED' => l10n.xpBadgeEarned,
    'ROUTE_APPROVED' => l10n.xpRouteApproved,
    'PLACE_APPROVED' => l10n.xpPlaceApproved,
    'ADMIN_ADJUSTMENT' => l10n.xpAdminAdjustment,
    _ => l10n.xpOtherActivity,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.xpHistoryTitle)),
      body: ListenableBuilder(
        listenable: vm,
        builder: (context, _) => RefreshIndicator(
          onRefresh: () => vm.load(refresh: true),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(18),
            children: [
              Text(
                l10n.xpHistoryHint,
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              if (vm.loaded &&
                  vm.items.isEmpty &&
                  vm.error == null &&
                  !vm.isLoading)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.history_rounded,
                        size: 48,
                        color: colors.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(l10n.xpHistoryEmpty, textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ...vm.items.map(
                (item) => Card(
                  color: colors.surfaceContainerHighest,
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          item.amount >= 0
                              ? Icons.add_circle_outline
                              : Icons.remove_circle_outline,
                          color: item.amount >= 0
                              ? colors.primary
                              : colors.error,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.transactionType == 'REVERSAL'
                                    ? l10n.xpReversal
                                    : _sourceLabel(l10n, item.sourceType),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (item.description?.isNotEmpty == true) ...[
                                const SizedBox(height: 4),
                                Text(item.description!),
                              ],
                              if (item.createdAt != null) ...[
                                const SizedBox(height: 6),
                                Text(
                                  DateFormat.yMMMd(
                                    Localizations.localeOf(context).toString(),
                                  ).add_Hm().format(item.createdAt!.toLocal()),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${item.amount > 0 ? '+' : ''}${rankNumber(context, item.amount)} XP',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: item.amount >= 0
                                ? colors.primary
                                : colors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (vm.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                ),
              if (vm.error != null) ...[
                Text(vm.error!, style: TextStyle(color: colors.error)),
                TextButton(
                  onPressed: vm.isLoading ? null : () => vm.load(),
                  child: Text(l10n.rankRetry),
                ),
              ] else if (vm.nextCursor != null && !vm.isLoading)
                OutlinedButton(
                  onPressed: () => vm.load(),
                  child: Text(l10n.xpHistoryLoadMore),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
