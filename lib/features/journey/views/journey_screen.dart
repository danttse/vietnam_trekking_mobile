import 'package:flutter/material.dart';
import '../../../core/widgets/app_bar/app_top_bar.dart';
import '../../../core/widgets/cards/journey_group_card.dart';
import '../../../core/widgets/sheet/journey_options_sheet.dart';
import '../../../l10n/app_localizations.dart';
import '../../route/view/route_detail_screen.dart';
import '../data/models/journey_group_model.dart';
import '../data/models/journey_model.dart';
import '../viewmodels/journey_viewmodel.dart';
import 'create_new_journey_screen.dart';
import 'journey_detail_screen.dart';

class JourneyScreen extends StatefulWidget {
  const JourneyScreen({super.key});

  @override
  State<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends State<JourneyScreen> {
  late final JourneyViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = JourneyViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Widget _buildTabBar(ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(child: _buildTabItem(0, l10n.journeyCompleted)),
          Expanded(child: _buildTabItem(1, l10n.journeyUpcoming)),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String title) {
    final isSelected = _viewModel.selectedTabIndex == index;
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => _viewModel.setTab(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? colorScheme.onSurface
                  : colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 6),
          AnimatedContainer(
            height: 2.5,
            width: isSelected ? 40 : 0,
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? colorScheme.onSurface : null,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          _buildStatColumn('${_viewModel.currentTripsCount}', l10n.journeyStatTrips),
          _buildStatDivider(),
          _buildStatColumn(_viewModel.currentTotalDistanceText, l10n.journeyStatDistance),
          _buildStatDivider(),
          _buildStatColumn('${_viewModel.currentTotalParticipants}', l10n.journeyStatCompanions),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String value, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 28,
      width: 1,
      color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.1),
    );
  }

  void _showJourneyOptionsSheet(JourneyModel journey) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => JourneyOptionsSheet(
        onRouteDetail: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RouteDetailScreen(route: journey.route),
            ),
          );
        },
        onJourneyDetail: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JourneyDetailScreen(route: journey),
            ),
          );
        },
      ),
    );
  }

  Widget _buildJourneyList(List<JourneyGroupModel> groups) {
    if (_viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    if (groups.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            l10n.journeyEmptyList,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
      itemCount: groups.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return JourneyGroupCard(
          group: groups[index],
          onJourneyTap: (journey) => _showJourneyOptionsSheet(journey),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            final currentGroups = _viewModel.currentGroups;
            return Column(
              children: [
                Align(alignment: Alignment.centerLeft, child: AppTopBar(title: l10n.navJourney)),
                const SizedBox(height: 8),
                _buildTabBar(colorScheme),
                const SizedBox(height: 16),
                _buildStatsSection(colorScheme),
                Expanded(
                  child: _buildJourneyList(currentGroups),
                ),
              ],
            );
          },
        ),
        floatingActionButton: Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: FloatingActionButton(
            backgroundColor: colorScheme.primary,
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
            elevation: 4,
            onPressed: () async {
              final newJourney = await Navigator.push<JourneyModel>(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateNewJourneyScreen(),
                ),
              );
              if (newJourney != null) {
                _viewModel.addJourney(newJourney);
              } else {
                _viewModel.loadJourneys();
              }
            },
            child: const Icon(Icons.add, size: 28),
          ),
        ),
      ),
    );
  }
}
