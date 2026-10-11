import 'package:flutter/material.dart';

import '../../../core/widgets/app_bar/app_top_bar_with_back.dart';
import '../../../core/widgets/buttons/btn_login_style.dart';
import '../../../l10n/app_localizations.dart';
import '../data/models/journey_model.dart';
import '../data/models/milestone_model.dart';
import '../viewmodels/milestone_checkin_viewmodel.dart';
import 'checkin_success_screen.dart';
import 'widgets/checkin_gps_card.dart';

class MilestoneCheckinScreen extends StatefulWidget {
  final MilestoneModel milestone;
  final JourneyModel? journey;
  final String? mapImageUrl;
  final MilestoneCheckinViewModel? viewModel;

  const MilestoneCheckinScreen({
    super.key,
    required this.milestone,
    this.journey,
    this.mapImageUrl,
    this.viewModel,
  });

  @override
  State<MilestoneCheckinScreen> createState() => _MilestoneCheckinScreenState();
}

class _MilestoneCheckinScreenState extends State<MilestoneCheckinScreen> {
  late final MilestoneCheckinViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel =
        widget.viewModel ??
        MilestoneCheckinViewModel(
          milestone: widget.milestone,
          journey: widget.journey,
          mapImageUrl: widget.mapImageUrl,
        );
    if (widget.viewModel == null) _viewModel.location.initialize();
  }

  @override
  void dispose() {
    if (widget.viewModel == null) _viewModel.dispose();
    super.dispose();
  }

  Future<void> _handleCheckIn() async {
    final success = await _viewModel.checkIn();
    if (!success && mounted && _viewModel.error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(_viewModel.error!)));
    }
    if (success && mounted) {
      await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => CheckinSuccessScreen(
            milestone: _viewModel.milestone,
            journey: _viewModel.journey,
            journeyFinished: _viewModel.finishesJourney,
          ),
        ),
      );
      if (mounted) Navigator.pop(context, true);
    }
  }

  Future<void> _handleActivateJourney() async {
    final success = await _viewModel.activateJourney();
    if (!mounted) return;
    if (!success && _viewModel.error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(_viewModel.error!)));
    }
  }

  Widget _buildGpsMapCard(BuildContext context, ColorScheme colorScheme) {
    return CheckinGpsCard(viewModel: _viewModel);
  }

  Widget _buildCheckInInfoCard(
    BuildContext context,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.checkinTargetPointLabel,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _viewModel.destinationName,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.checkinTargetAltitude(_viewModel.formattedAltitude),
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color:
                  (_viewModel.isWithinRange
                          ? colorScheme.primary
                          : colorScheme.error)
                      .withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    (_viewModel.isWithinRange
                            ? colorScheme.primary
                            : colorScheme.error)
                        .withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _viewModel.isWithinRange
                        ? colorScheme.primary
                        : colorScheme.error,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _viewModel.locationStatus,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _viewModel.isWithinRange
                          ? colorScheme.primary
                          : colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: BtnLoginPrimary(
              text: _viewModel.canActivateJourney
                  ? _viewModel.activateJourneyLabel
                  : _viewModel.isCheckedIn
                  ? l10n.checkinAlreadySuccess
                  : l10n.checkinNowButton,
              isLoading: _viewModel.isLoading,
              onPressed: _viewModel.isLoading
                  ? null
                  : _viewModel.canActivateJourney
                  ? _handleActivateJourney
                  : _viewModel.canCheckIn
                  ? _handleCheckIn
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Bạn cần ở trong bán kính ${_viewModel.allowedRadiusMeters} m và GPS có sai số tối đa 50 m.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ),
          if (_viewModel.location.error != null)
            Center(
              child: TextButton.icon(
                onPressed: _viewModel.location.recover,
                icon: const Icon(Icons.location_on_outlined),
                label: const Text('Bật / cấp quyền vị trí'),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            AppTopBarWithBack(title: l10n.checkinControlPointTitle),
            Expanded(
              child: ListenableBuilder(
                listenable: _viewModel,
                builder: (context, _) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildGpsMapCard(context, colorScheme),
                        const SizedBox(height: 16),
                        _buildCheckInInfoCard(context, colorScheme, l10n),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
