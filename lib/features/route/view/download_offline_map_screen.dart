import 'package:flutter/material.dart';
import '../../../core/widgets/app_bar/app_top_bar_with_back.dart';
import '../../../core/widgets/buttons/btn_login_style.dart';
import '../../../core/widgets/buttons/btn_outline_style.dart';
import '../../../l10n/app_localizations.dart';
import '../../journey/data/datasources/journey_sample_data.dart';
import '../../journey/views/journey_detail_screen.dart';
import '../data/models/route_model.dart';
import '../viewmodel/download_offline_map_viewmodel.dart';

class DownloadOfflineMapScreen extends StatefulWidget {
  final RouteModel? route;

  const DownloadOfflineMapScreen({
    super.key,
    this.route,
  });

  @override
  State<DownloadOfflineMapScreen> createState() => _DownloadOfflineMapScreenState();
}

class _DownloadOfflineMapScreenState extends State<DownloadOfflineMapScreen> {
  late final DownloadOfflineMapViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = DownloadOfflineMapViewModel(route: widget.route);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Widget _buildInfoRow(String label, String value, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: Color(0xFF2ED573),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadingState(AppLocalizations l10n, ColorScheme colorScheme) {
    final mapInfo = _viewModel.mapInfo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            l10n.downloadOfflineMapSubtitle,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 36),
        Center(
          child: SizedBox(
            width: 170,
            height: 170,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 170,
                  height: 170,
                  child: CircularProgressIndicator(
                    value: _viewModel.progress,
                    strokeWidth: 12,
                    strokeCap: StrokeCap.round,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(colorScheme.surfaceContainerLow),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${_viewModel.progressPercent}%',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.downloading,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 36),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      l10n.mapDataHeader(mapInfo.mapName),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.cloud_download_outlined,
                    color: colorScheme.primary,
                    size: 22,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoRow(l10n.mapLabel, mapInfo.mapName, colorScheme),
              _buildInfoRow(l10n.zoomLevelLabel, mapInfo.zoomRangeText, colorScheme),
              _buildInfoRow(l10n.fileSizeLabel, mapInfo.sizeMBText, colorScheme),
              _buildInfoRow(l10n.waypointsLabel, l10n.waypointsCount(mapInfo.waypointCount), colorScheme),
              _buildInfoRow(l10n.trailSupportLabel, mapInfo.hasTrailSupport ? l10n.supported : '', colorScheme),
            ],
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: SizedBox(
            width: double.infinity,
            child: BtnOutlineStyle(
              text: l10n.cancelDownload,
              icon: const SizedBox.shrink(),
              onPressed: () {
                _viewModel.cancelDownload();
                Navigator.pop(context, false);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedState(AppLocalizations l10n, ColorScheme colorScheme) {
    return Column(
      children: [
        const SizedBox(height: 24),
        Center(
          child: Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF2ED573),
                width: 2,
              ),
              color: const Color(0xFF2ED573).withValues(alpha: 0.1),
            ),
            child: const Icon(
              Icons.check,
              color: Color(0xFF2ED573),
              size: 38,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.mapReadyTitle,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            l10n.mapReadySubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 28),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.mapPackageInfoTitle,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),
              _buildFeatureItem(l10n.offlineMapFeature, colorScheme),
              _buildFeatureItem(l10n.hikingTrailFeature, colorScheme),
              _buildFeatureItem(l10n.waypointsFeature, colorScheme),
              _buildFeatureItem(l10n.backtrackFeature, colorScheme),
            ],
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: BtnLoginPrimary(
                  text: l10n.journeyActionStart,
                  onPressed: () {
                    final journey =
                        JourneySampleData.getOrCreateJourneyForRoute(widget.route);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JourneyDetailScreen(
                          route: journey,
                        ),
                      ),
                      result: true,
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: BtnOutlineStyle(
                  text: l10n.journeyActionViewMap,
                  icon: const Icon(Icons.map_outlined),
                  onPressed: () => Navigator.pop(context, true),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
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
            return Column(
              children: [
                AppTopBarWithBack(
                  title: l10n.downloadOfflineMapTitle,
                  onBack: () => Navigator.pop(context, _viewModel.isCompleted),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _viewModel.isCompleted
                      ? _buildCompletedState(l10n, colorScheme)
                      : _buildDownloadingState(l10n, colorScheme),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
