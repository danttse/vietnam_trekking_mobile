import 'package:flutter/material.dart';

import '../viewmodels/journey_list_viewmodel.dart';
import '../../../l10n/app_localizations.dart';
import '../data/models/journey_model.dart';
import 'widgets/journey_card.dart';
import 'widgets/trekking_empty_state.dart';
import 'journey_detail_screen.dart';
import 'create_new_journey_screen.dart';

class JourneyListScreen extends StatefulWidget {
  const JourneyListScreen({super.key});

  @override
  State<JourneyListScreen> createState() => _JourneyListScreenState();
}

class _JourneyListScreenState extends State<JourneyListScreen> {
  late final JourneyListViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = JourneyListViewModel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _vm.loadAll();
    });
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  void _openJourney(JourneyModel j) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => JourneyDetailScreen(route: j)));
  }

  void _openCreate() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const CreateNewJourneyScreen()),
    );
    if (created == true) _vm.loadAll();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: cs.surface,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(cs),
                _buildSummary(cs),
                _buildTabBar(cs),
                Expanded(child: _buildBody(cs)),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _openCreate,
            backgroundColor: cs.primary,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildHeader(ColorScheme cs) {
    final l10n = AppLocalizations.of(context);
    final tabCount = _vm.tab == JourneyListTab.completed
        ? '${_vm.totalCompleted} ${l10n?.journeyStatTrips ?? "Chuyến đi"}'
        : '${_vm.upcomingCount} ${l10n?.journeyUpcoming ?? "Sắp tới"}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              l10n?.navJourney ?? 'Hành Trình',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              tabCount,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Summary stats (only on completed tab) ────────────────────────────────

  Widget _buildSummary(ColorScheme cs) {
    final l10n = AppLocalizations.of(context);
    if (_vm.tab != JourneyListTab.completed) {
      // Show upcoming summary
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        child: Row(
          children: [
            _SummaryChip(
              value: '${_vm.upcomingCount}',
              label: l10n?.journeyPlansLabel ?? 'Kế hoạch',
            ),
            const SizedBox(width: 10),
            _SummaryChip(
              value:
                  '${(_vm.upcomingJourneys.fold<double>(0, (s, j) => s + j.routeDistanceMeters) / 1000).toStringAsFixed(0)} km',
              label: l10n?.journeyEstimatedTotal(0) ?? 'Tổng dự kiến',
            ),
            const SizedBox(width: 10),
            _SummaryChip(
              value: l10n?.personCount(
                    _vm.upcomingJourneys.fold<int>(
                      0,
                      (s, j) => s + j.memberCount,
                    ),
                  ) ??
                  '${_vm.upcomingJourneys.fold<int>(0, (s, j) => s + j.memberCount)} người',
              label: l10n?.journeyStatCompanions ?? 'Bạn đồng hành',
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Row(
        children: [
          _SummaryChip(
            value: '${_vm.totalCompleted}',
            label: l10n?.journeyStatTrips ?? 'Chuyến đi',
          ),
          const SizedBox(width: 10),
          _SummaryChip(
            value: '${_vm.totalDistanceKm.toStringAsFixed(0)} km',
            label: l10n?.journeyStatDistance ?? 'Quãng đường',
          ),
          const SizedBox(width: 10),
          _SummaryChip(
            value: '${_vm.totalCheckins}/63',
            label: l10n?.provincesLabel ?? 'Tỉnh thành',
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(ColorScheme cs) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          _TabButton(
            label: l10n?.journeyCompleted ?? 'Đã hoàn thành',
            selected: _vm.tab == JourneyListTab.completed,
            onTap: () => _vm.setTab(JourneyListTab.completed),
          ),
          const SizedBox(width: 24),
          _TabButton(
            label: l10n?.journeyUpcoming ?? 'Sắp tới',
            selected: _vm.tab == JourneyListTab.upcoming,
            onTap: () => _vm.setTab(JourneyListTab.upcoming),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ColorScheme cs) {
    if (_vm.loading) {
      return Center(
        child: CircularProgressIndicator(color: cs.primary),
      );
    }
    if (_vm.error != null) {
      return TrekkingEmptyState.error(message: _vm.error, onRetry: _vm.refresh);
    }

    final items = _vm.current;
    final l10n = AppLocalizations.of(context);

    if (items.isEmpty) {
      return TrekkingEmptyState.empty(
        title: _vm.tab == JourneyListTab.completed
            ? (l10n?.journeyEmptyList ?? 'Chưa có hành trình nào')
            : (l10n?.noPlansYet ?? 'Chưa có kế hoạch nào'),
        subtitle: _vm.tab == JourneyListTab.completed
            ? (l10n?.startFirstJourneyHint ??
                'Bắt đầu hành trình đầu tiên của bạn')
            : (l10n?.createPlanForNextTripHint ??
                'Tạo kế hoạch trekking cho chuyến đi sắp tới'),
        onRetry: _vm.refresh,
      );
    }

    return RefreshIndicator(
      color: cs.primary,
      onRefresh: _vm.refresh,
      child: ListView(
        padding: const EdgeInsets.only(top: 12, bottom: 100),
        children: _buildGroupedList(items, cs),
      ),
    );
  }

  List<Widget> _buildGroupedList(List<JourneyModel> items, ColorScheme cs) {
    // Group by month/year
    final l10n = AppLocalizations.of(context);
    final Map<String, List<JourneyModel>> groups = {};
    for (final j in items) {
      final dt =
          j.completedAt ?? j.plannedStartAt ?? j.startedAt ?? j.createdAt;
      final otherLabel = (l10n?.otherLabel ?? 'Khác').toUpperCase();
      final key = dt != null ? 'THÁNG ${dt.month}, ${dt.year}' : otherLabel;
      groups.putIfAbsent(key, () => []).add(j);
    }

    final widgets = <Widget>[];
    for (final entry in groups.entries) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(
            entry.key,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
        ),
      );
      for (final j in entry.value) {
        widgets.add(JourneyCard(journey: j, onTap: () => _openJourney(j)));
      }
    }
    return widgets;
  }
}

class _SummaryChip extends StatelessWidget {
  final String value;
  final String label;
  const _SummaryChip({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              color: selected ? cs.primary : cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          if (selected)
            Container(
              height: 2,
              width: 40,
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
        ],
      ),
    );
  }
}
