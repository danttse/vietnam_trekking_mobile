import 'package:flutter/material.dart';
import 'package:vietnam_trekking_mobile/core/widgets/buttons/btn_login_style.dart';
import 'package:vietnam_trekking_mobile/core/widgets/buttons/btn_outline_style.dart';
import '../../../l10n/app_localizations.dart';
import '../data/models/journey_model.dart';
import '../data/models/milestone_model.dart';
import '../viewmodels/journey_detail_viewmodel.dart';
import '../../../core/widgets/cards/profile_stat_card.dart';
import '../../../core/widgets/cards/profile_progress_bar.dart';

class JourneyDetailScreen extends StatefulWidget {
  final JourneyModel? route;
  const JourneyDetailScreen({super.key, this.route});

  @override
  State<JourneyDetailScreen> createState() => _JourneyDetailScreenState();
}

class _JourneyDetailScreenState extends State<JourneyDetailScreen> {
  late final JourneyDetailViewModel _viewModel;
  @override
  void initState() {
    super.initState();
    _viewModel = JourneyDetailViewModel(route: widget.route);
  }
  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Widget _buildMilestoneItem({
    required MilestoneModel milestone,
    required AppLocalizations l10n,
    required ColorScheme colorScheme,
    bool isLast = false,
  }) {
    final isCheckedIn = milestone.isCheckedIn;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCheckedIn
                  ? colorScheme.primary
                  : colorScheme.surfaceContainerHighest,
              border: Border.all(
                color: isCheckedIn
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '${milestone.sequence}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isCheckedIn ? Colors.white : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  milestone.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isCheckedIn
                        ? colorScheme.onSurface
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.milestoneAltitude(milestone.altitude.toInt().toString()),
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isCheckedIn)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                l10n.milestoneCheckedIn,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
            )
          else
            Text(
              l10n.milestoneNotCheckedIn,
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
        ],
      ),
    ),
    if (!isLast)
      Container(
        margin: const EdgeInsets.only(left: 13),
        width: 2,
        height: 24,
        color: Colors.grey.shade400,
      ),
    ]);
  }

  String _getStatusLabel(JourneyStatus status, AppLocalizations l10n) {
    switch (status) {
      case JourneyStatus.planned:
        return l10n.journeyStatusPlanned;
      case JourneyStatus.active:
        return l10n.journeyStatusActive;
      case JourneyStatus.paused:
        return l10n.journeyStatusPaused;
      case JourneyStatus.completed:
        return l10n.journeyStatusCompleted;
      case JourneyStatus.cancelled:
        return l10n.journeyStatusCancelled;
    }
  }

  String _getActionText(JourneyStatus status, AppLocalizations l10n) {
    switch (status) {
      case JourneyStatus.planned:
        return l10n.journeyActionStart;
      case JourneyStatus.active:
        return l10n.journeyActionPause;
      case JourneyStatus.paused:
        return l10n.journeyActionResume;
      case JourneyStatus.completed:
        return l10n.journeyStatusCompleted;
      case JourneyStatus.cancelled:
        return l10n.journeyStatusCancelled;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  _viewModel.journeyImageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: colorScheme.surfaceContainerHigh,
                    child: Icon(
                      Icons.terrain,
                      size: 48,
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    ),
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.35),
                        Colors.black.withValues(alpha: 0.85),
                      ],
                      stops: const [0.45, 0.7, 1.0],
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: Row(children: [
                    InkWell(
                      onTap: () => Navigator.of(context).maybePop(),
                      child: 
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.navigate_before,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            size: 15,
                          ),
                        )
                    ),
                    const Spacer(),
                    ListenableBuilder(
                      listenable: _viewModel,
                      builder: (context, _) {
                        final currentStatus = _viewModel.journeyStatus;
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _getStatusLabel(currentStatus, l10n),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: currentStatus.color,
                              letterSpacing: 0.5,
                            ),
                          ),
                        );
                      },
                    ),
                  ],)
                ),
                Positioned(
                  bottom: 25,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                      Text(
                        _viewModel.journeyName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.place_outlined,
                            size: 13,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _viewModel.journeyLocation,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ProfileStatCard(
                              value: '${_viewModel.distanceKm} km',
                              label: l10n.journeyStatDistance,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ProfileStatCard(
                              value: _viewModel.estimatedDurationText,
                              label: l10n.journeyRemainingTime,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ProfileStatCard(
                              value: '1010 m',
                              label: l10n.journeyCurrentElevation,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24,),
                      ListenableBuilder(
                        listenable: _viewModel,
                        builder: (context, _) {
                          return ProfileProvinceProgressBar(
                            title: l10n.journeyProgressTitle,
                            current: _viewModel.checkedInCount,
                            total: _viewModel.totalMilestoneCount,
                            unit: l10n.journeyCheckinPoints,
                          );
                        },
                      ),
                      const SizedBox(height:20),
                      ListenableBuilder(
                        listenable: _viewModel,
                        builder: (context, _) {
                          final milestones = _viewModel.milestones;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    l10n.milestonesSectionTitle,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.8,
                                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    l10n.milestoneProgress(
                                      _viewModel.checkedInCount,
                                      _viewModel.totalMilestoneCount,
                                    ),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ...milestones.asMap().entries.map((entry) {
                                final index = entry.key;
                                final milestone = entry.value;
                                final isLast = index == milestones.length - 1;
                                return _buildMilestoneItem(
                                  milestone: milestone,
                                  l10n: l10n,
                                  colorScheme: colorScheme,
                                  isLast: isLast,
                                );
                              }),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height:20),
                      Text(
                        l10n.journeyDetailMapTitle,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _viewModel.mapImageUrl,
                          height: 170,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            height: 170,
                            color: colorScheme.surfaceContainerHighest,
                            child: Center(
                              child: Icon(
                                Icons.map_outlined,
                                size: 40,
                                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.directions_walk,
                              color: Colors.white,
                              size: 24,
                            ),
                            onPressed: () {},
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ListenableBuilder(
                          listenable: _viewModel,
                          builder: (context, _) {
                            return BtnLoginPrimary(
                              text: _getActionText(_viewModel.journeyStatus, l10n),
                              isLoading: _viewModel.isDownloading,
                              onPressed: _viewModel.toggleJourneyStatus,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ListenableBuilder(
                          listenable: _viewModel,
                          builder: (context, _) {
                            return BtnOutlineStyle(
                              text: l10n.journeyActionViewMap,
                              icon: const Icon(Icons.open_in_new_outlined),
                              onPressed: _viewModel.downloadOfflineMap,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}