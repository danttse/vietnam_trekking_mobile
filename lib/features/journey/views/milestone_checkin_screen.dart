import 'package:flutter/material.dart';
import '../../../core/widgets/app_bar/app_top_bar_with_back.dart';
import '../../../core/widgets/buttons/btn_login_style.dart';
import '../../../l10n/app_localizations.dart';
import '../data/models/journey_model.dart';
import '../data/models/milestone_model.dart';
import '../viewmodels/milestone_checkin_viewmodel.dart';
import 'checkin_success_screen.dart';

class MilestoneCheckinScreen extends StatefulWidget {
  final MilestoneModel milestone;
  final JourneyModel? journey;
  final String? mapImageUrl;

  const MilestoneCheckinScreen({
    super.key,
    required this.milestone,
    this.journey,
    this.mapImageUrl,
  });

  @override
  State<MilestoneCheckinScreen> createState() => _MilestoneCheckinScreenState();
}

class _MilestoneCheckinScreenState extends State<MilestoneCheckinScreen> {
  late final MilestoneCheckinViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = MilestoneCheckinViewModel(
      milestone: widget.milestone,
      journey: widget.journey,
      mapImageUrl: widget.mapImageUrl,
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _handleCheckIn() async {
    final success = await _viewModel.checkIn();
    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CheckinSuccessScreen(
            milestone: _viewModel.milestone,
            journey: _viewModel.journey,
          ),
        ),
      );
    }
  }

  Widget _buildGpsMapCard(BuildContext context, ColorScheme colorScheme) {
    return AspectRatio(
      aspectRatio: 1/1,
      child: Stack(
        fit: StackFit.expand,
        children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child:
          Image.network(
            _viewModel.mapImageUrl,
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
        )
        ]
      )
    );
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
              color: const Color(0xFF2ED573).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF2ED573).withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF2ED573),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.checkinWithinRange(_viewModel.distanceMeters),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2ED573),
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
              text: _viewModel.isCheckedIn
                  ? l10n.checkinAlreadySuccess
                  : l10n.checkinNowButton,
              isLoading: _viewModel.isLoading,
              onPressed: _viewModel.isCheckedIn ? null : _handleCheckIn,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              l10n.checkinRadiusNotice,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
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
            AppTopBarWithBack(
              title: l10n.checkinControlPointTitle,
            ),
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
