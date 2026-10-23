import 'package:flutter/material.dart';
import 'package:vietnam_trekking_mobile/core/widgets/buttons/btn_login_style.dart';
import 'package:vietnam_trekking_mobile/core/widgets/buttons/btn_outline_style.dart';

import '../../../l10n/app_localizations.dart';
import '../data/models/journey_model.dart';
import '../data/models/milestone_model.dart';
import '../viewmodels/journey_detail_viewmodel.dart';
import 'milestone_checkin_screen.dart';
import 'journey_map_screen.dart';
import 'contribution_screen.dart';
import 'widgets/place_review_section.dart';
import 'widgets/trekking_button.dart';
import '../data/repositories/journey_repository.dart';
import '../../../core/widgets/cards/profile_stat_card.dart';
import '../../../core/widgets/cards/profile_progress_bar.dart';

class JourneyDetailScreen extends StatefulWidget {
  final JourneyModel? route;
  final JourneyDetailViewModel? viewModel;
  const JourneyDetailScreen({super.key, this.route, this.viewModel});

  @override
  State<JourneyDetailScreen> createState() => _JourneyDetailScreenState();
}

class _JourneyDetailScreenState extends State<JourneyDetailScreen> {
  late final JourneyDetailViewModel _viewModel;
  @override
  void initState() {
    super.initState();
    _viewModel =
        widget.viewModel ?? JourneyDetailViewModel(route: widget.route);
  }

  @override
  void dispose() {
    if (widget.viewModel == null) _viewModel.dispose();
    super.dispose();
  }

  Future<void> _openMilestone(MilestoneModel milestone) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => MilestoneCheckinScreen(
          milestone: milestone,
          journey: _viewModel.journey,
          mapImageUrl: _viewModel.mapImageUrl,
        ),
      ),
    );
    if (mounted) await _viewModel.loadMilestones();
  }

  Future<void> _shareRoute() async {
    final journey = _viewModel.journey;
    if (journey == null || journey.status != JourneyStatus.completed) return;
    try {
      final markers = await JourneyRepository().getMarkers(journey.journeyId);
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ContributionScreen(
            journey: journey,
            markers: markers,
            userId: journey.userId,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không mở được chia sẻ route. ${e.toString()}'),
          ),
        );
      }
    }
  }

  Future<void> _finishJourney() async {
    final share = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: const Text('Kết thúc hành trình?'),
        content: const Text(
          'Lưu đường GPS đã ghi cùng hành trình và gửi route cho admin xét duyệt nếu bạn chọn chia sẻ.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog),
            child: const Text('Tiếp tục đi'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: const Text('Kết thúc'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, true),
            child: const Text('Kết thúc & chia sẻ'),
          ),
        ],
      ),
    );
    if (share == null || !mounted) return;
    await _viewModel.updateStatus('complete');
    if (!mounted) return;
    if (_viewModel.error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(_viewModel.error!)));
    } else if (share) {
      await _shareRoute();
    }
  }

  Future<void> _openCheckin({bool reload = false}) async {
    if (reload ||
        _viewModel.isLoadingMilestones ||
        _viewModel.milestones.isEmpty ||
        _viewModel.milestoneError != null) {
      await _viewModel.loadMilestones();
    }
    if (!mounted) return;
    if (_viewModel.milestoneError != null || _viewModel.milestones.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      final loadError = _viewModel.milestoneError;
      final failed = loadError != null;
      final retry = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(
            failed
                ? l10n.journeyMilestonesLoadFailed
                : l10n.journeyMilestonesEmpty,
          ),
          content: Text(loadError ?? l10n.journeyMilestonesEmptyMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.journeyCheckinClose),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.journeyReloadMilestones),
            ),
          ],
        ),
      );
      if (retry == true && mounted) await _openCheckin(reload: true);
      return;
    }
    final target = _viewModel.milestones.firstWhere(
      (m) => !m.isCheckedIn,
      orElse: () => _viewModel.milestones.first,
    );
    await _openMilestone(target);
  }

  Widget _buildMilestoneState(AppLocalizations l10n, ColorScheme colors) {
    if (_viewModel.isLoadingMilestones) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(l10n.journeyMilestonesLoading)),
          ],
        ),
      );
    }
    if (_viewModel.milestoneError == null && _viewModel.milestones.isNotEmpty) {
      return const SizedBox.shrink();
    }
    final failed = _viewModel.milestoneError != null;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            failed
                ? l10n.journeyMilestonesLoadFailed
                : l10n.journeyMilestonesEmpty,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            failed
                ? _viewModel.milestoneError!
                : l10n.journeyMilestonesEmptyMessage,
            style: TextStyle(color: colors.onSurfaceVariant, height: 1.4),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _viewModel.loadMilestones,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.journeyReloadMilestones),
          ),
        ],
      ),
    );
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
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _openMilestone(milestone),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
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
                      color: isCheckedIn
                          ? Colors.white
                          : colorScheme.onSurfaceVariant,
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
                        l10n.milestoneAltitude(
                          milestone.altitude.toInt().toString(),
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (isCheckedIn)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
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
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Container(
            margin: const EdgeInsets.only(left: 17),
            width: 2,
            height: 24,
            color: Colors.grey.shade400,
          ),
      ],
    );
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
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) => Scaffold(
        backgroundColor: colorScheme.surface,
        body: SafeArea(
          top: false,
          bottom: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.4,
                          ),
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
                      top: 30,
                      left: 12,
                      right: 12,
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () => Navigator.of(context).maybePop(),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest
                                    .withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.navigate_before,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                size: 15,
                              ),
                            ),
                          ),
                          const Spacer(),
                          ListenableBuilder(
                            listenable: _viewModel,
                            builder: (context, _) {
                              final currentStatus = _viewModel.journeyStatus;
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest
                                      .withValues(alpha: 0.5),
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
                        ],
                      ),
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
                            ),
                          ],
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
                    padding: const EdgeInsets.fromLTRB(16, 25, 16, 0),
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
                                  value: _viewModel.maxElevationText,
                                  label: l10n.journeyCurrentElevation,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          ListenableBuilder(
                            listenable: _viewModel,
                            builder: (context, _) {
                              if (!_viewModel.hasLoadedMilestones) {
                                return Text(
                                  _viewModel.isLoadingMilestones
                                      ? l10n.journeyMilestonesLoading
                                      : l10n.journeyMilestonesLoadFailed,
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                );
                              }
                              return ProfileProvinceProgressBar(
                                title: l10n.journeyProgressTitle,
                                current: _viewModel.checkedInCount,
                                total: _viewModel.totalMilestoneCount,
                                unit: l10n.journeyCheckinPoints,
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          ListenableBuilder(
                            listenable: _viewModel,
                            builder: (context, _) {
                              final milestones = _viewModel.milestones;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          l10n.milestonesSectionTitle,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.8,
                                            color: colorScheme.onSurfaceVariant
                                                .withValues(alpha: 0.8),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        !_viewModel.hasLoadedMilestones
                                            ? '—'
                                            : l10n.milestoneProgress(
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
                                  _buildMilestoneState(l10n, colorScheme),
                                  ...milestones.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final milestone = entry.value;
                                    final isLast =
                                        index == milestones.length - 1;
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
                          const SizedBox(height: 20),
                          Text(
                            l10n.journeyDetailMapTitle,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                              color: colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.map_outlined, size: 40),
                                const SizedBox(height: 8),
                                Text(
                                  _viewModel.isDownloaded
                                      ? 'Đã có bản đồ offline trên thiết bị'
                                      : 'Chưa tải bản đồ offline',
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Bấm Xem bản đồ để mở bản đồ của hành trình.',
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          if (_viewModel.journeyStatus ==
                                  JourneyStatus.completed &&
                              _viewModel.journey != null)
                            PlaceReviewSection(
                              placeId: _viewModel.journey!.trekkingPlaceId,
                            ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: FilledButton.icon(
                              key: const ValueKey('journey-checkin'),
                              onPressed: _viewModel.isLoadingMilestones
                                  ? null
                                  : _openCheckin,
                              icon: _viewModel.isLoadingMilestones
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.directions_walk),
                              label: Text(l10n.milestoneCheckInButton),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ListenableBuilder(
                              listenable: _viewModel,
                              builder: (context, _) {
                                return BtnLoginPrimary(
                                  text: _getActionText(
                                    _viewModel.journeyStatus,
                                    l10n,
                                  ),
                                  isLoading: _viewModel.isUpdating,
                                  onPressed:
                                      _viewModel.journeyStatus ==
                                              JourneyStatus.completed ||
                                          _viewModel.journeyStatus ==
                                              JourneyStatus.cancelled
                                      ? null
                                      : () async {
                                          await _viewModel
                                              .toggleJourneyStatus();
                                          if (context.mounted &&
                                              _viewModel.error != null) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      _viewModel.error!,
                                                    ),
                                                  ),
                                                );
                                          }
                                        },
                                );
                              },
                            ),
                          ),
                          if (_viewModel.journeyStatus ==
                                  JourneyStatus.active ||
                              _viewModel.journeyStatus == JourneyStatus.paused)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: TrekkingSecondaryButton(
                                key: const ValueKey('journey-finish'),
                                onPressed: _viewModel.isUpdating
                                    ? null
                                    : _finishJourney,
                                icon: Icons.check_circle_outline,
                                label: 'Kết thúc hành trình',
                                loading: _viewModel.isUpdating,
                              ),
                            ),
                          if (_viewModel.journeyStatus ==
                              JourneyStatus.completed)
                            FilledButton.icon(
                              key: const ValueKey('journey-share-route'),
                              onPressed: _shareRoute,
                              icon: const Icon(Icons.share_outlined),
                              label: const Text('Chia sẻ route tới admin'),
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
                                  onPressed: () async {
                                    final journey = _viewModel.journey;
                                    if (journey == null) return;
                                    try {
                                      final markers = await JourneyRepository()
                                          .getMarkers(journey.journeyId);
                                      if (!context.mounted) return;
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => JourneyMapScreen(
                                            journey: journey,
                                            milestones: _viewModel.milestones,
                                            markers: markers,
                                            routeId: journey.trekkingRouteId,
                                            readOnly:
                                                journey.status ==
                                                    JourneyStatus.completed ||
                                                journey.status ==
                                                    JourneyStatus.cancelled,
                                          ),
                                        ),
                                      );
                                      if (mounted) {
                                        await _viewModel
                                            .refreshDownloadedState();
                                        await _viewModel.loadMilestones();
                                      }
                                    } catch (_) {
                                      if (context.mounted)
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Không thể mở dữ liệu hành trình. Vui lòng thử lại.',
                                                ),
                                              ),
                                            );
                                    }
                                  },
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
            ],
          ),
        ),
      ),
    );
  }
}
