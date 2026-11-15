import 'package:flutter/material.dart';
import 'package:vietnam_trekking_mobile/core/widgets/buttons/btn_login_style.dart';
import 'package:vietnam_trekking_mobile/core/widgets/buttons/btn_outline_style.dart';

import '../../../core/services/trekking_catalog_service.dart';
import '../../../core/widgets/cards/card_home_stats.dart';
import '../../../core/widgets/cards/trekking_map_preview.dart';
import '../../../core/widgets/carousels/place_image_gallery.dart';
import '../../../l10n/app_localizations.dart';
import '../../journey/data/models/journey_model.dart';
import '../../journey/views/journey_map_screen.dart';
import '../../offline_map/services/offline_map_storage_service.dart';
import '../data/models/route_model.dart';
import '../viewmodel/route_detail_viewmodel.dart';
import 'download_offline_map_screen.dart';

class RouteDetailScreen extends StatefulWidget {
  final RouteModel? route;
  final JourneyModel? pendingJourney;
  final OfflineMapStorageService? mapStorage;
  final TrekkingCatalogService? catalog;
  final bool? initialDownloaded;
  const RouteDetailScreen({
    super.key,
    this.route,
    this.pendingJourney,
    this.mapStorage,
    this.catalog,
    this.initialDownloaded,
  });

  @override
  State<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen> {
  late final RouteDetailViewModel _viewModel;
  bool _startingJourney = false;

  String _difficultyText(RouteModel? route, AppLocalizations l10n) {
    if (route == null) return '--';
    switch (route.difficulty) {
      case RouteDifficulty.easy:
        return l10n.difficultyEasy;
      case RouteDifficulty.moderate:
        return l10n.difficultyModerate;
      case RouteDifficulty.hard:
        return l10n.difficultyHard;
      case RouteDifficulty.extreme:
        return l10n.difficultyExtreme;
    }
  }

  String _durationText(RouteModel? route, AppLocalizations l10n) {
    if (route == null) return '--';
    final minutes = route.estimatedDuration.inMinutes;
    if (minutes <= 0) return '--';
    if (minutes >= 1440) {
      final days = minutes / 1440;
      final daysStr = days == days.roundToDouble()
          ? days.toInt().toString()
          : days.toStringAsFixed(1);
      return l10n.durationDays(daysStr);
    }
    final hours = minutes ~/ 60;
    final remaining = minutes % 60;
    if (hours == 0) {
      return l10n.durationMinutes(remaining);
    }
    return remaining == 0
        ? l10n.durationHours(hours)
        : l10n.durationHoursMinutes(hours, remaining);
  }

  Future<void> _startJourney() async {
    final journey = widget.pendingJourney;
    if (journey == null || _startingJourney) return;
    final l10n = AppLocalizations.of(context)!;
    if (!_viewModel.isDownloaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.downloadMapBeforeStart),
        ),
      );
      return;
    }
    setState(() => _startingJourney = true);
    try {
      final api = widget.catalog ?? TrekkingCatalogService();
      if (journey.status == JourneyStatus.planned) {
        await api.transitionJourney(journey.journeyId, 'start');
      }
      final updated = await api.getJourney(journey.journeyId);
      if (mounted) Navigator.pop(context, updated);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.cannotStartJourney(e.toString())),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _startingJourney = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _viewModel = RouteDetailViewModel(
      route: widget.route,
      storage: widget.mapStorage,
      initialDownloaded: widget.initialDownloaded,
    );
    _viewModel.addListener(_onChanged);
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onChanged);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final difficultyText = _difficultyText(_viewModel.route, l10n);
    final durationText = _durationText(_viewModel.route, l10n);
    final width = MediaQuery.sizeOf(context).width;
    final topInset = MediaQuery.paddingOf(context).top;
    final heroHeight = (_viewModel.heroImages.length > 1
            ? (width * 0.72).clamp(260.0, 380.0)
            : (width * 0.65).clamp(240.0, 360.0)) +
        topInset;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        top: false,
        bottom: true,
        child: Column(
          children: [
            SizedBox(
              height: heroHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PlaceImageGallery(
                    images: _viewModel.heroImages,
                    indicatorBottom: 26,
                    foreground: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0, 0.35, 0.6, 1],
                          colors: [
                            Colors.black.withValues(alpha: 0.4),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.12),
                            Theme.of(context).brightness == Brightness.dark
                                ? colorScheme.surface
                                : Colors.black87,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: topInset + 10,
                    left: 12,
                    right: 12,
                    child: Row(
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: _startingJourney
                              ? null
                              : () =>
                                    Navigator.of(context)
                                        .pop(widget.pendingJourney),
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
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            difficultyText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: _viewModel.heroImages.length > 1 ? 44 : 25,
                    left: 0,
                    right: 0,
                    child: IgnorePointer(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _viewModel.routeName,
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
                                Expanded(
                                  child: Text(
                                    _viewModel.routeLocation,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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
                  clipBehavior: Clip.antiAlias,
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
                              child: CardHomeStats(
                                title: l10n.statTotalDistance,
                                value: _viewModel.totalDistanceText,
                                icon: Icons.linear_scale,
                                iconColor: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CardHomeStats(
                                title: l10n.statElevationGain,
                                value: _viewModel.elevationGainText,
                                icon: Icons.terrain,
                                iconColor: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: CardHomeStats(
                                title: l10n.statMaxElevation,
                                value: _viewModel.maxElevationText,
                                icon: Icons.navigation_outlined,
                                iconColor: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CardHomeStats(
                                title: l10n.statEstimatedDuration,
                                value: durationText,
                                icon: Icons.calendar_today_outlined,
                                iconColor: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          l10n.routeDescriptionTitle,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _viewModel.route?.description?.trim().isNotEmpty ==
                                  true
                              ? _viewModel.route!.description!
                              : l10n.routeNoDescription,
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.6,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(l10n.routeDifficultyPrefix(difficultyText)),
                        if (_viewModel.route?.placeName != null)
                          Text(
                            l10n.routePlacePrefix(
                              _viewModel.route!.placeName!,
                            ),
                          ),
                        if (_viewModel.route != null) ...[
                          Text(
                            l10n.routeStartPrefix(
                              '${_viewModel.route!.startPoint.latitude.toStringAsFixed(6)}, ${_viewModel.route!.startPoint.longitude.toStringAsFixed(6)}',
                            ),
                          ),
                          Text(
                            l10n.routeEndPrefix(
                              '${_viewModel.route!.endPoint.latitude.toStringAsFixed(6)}, ${_viewModel.route!.endPoint.longitude.toStringAsFixed(6)}',
                            ),
                          ),
                        ],
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
                        if (_viewModel.route != null)
                          TrekkingMapPreview(
                            storage: widget.mapStorage,
                            key: ValueKey(
                              '${_viewModel.route!.trekkingPlaceId}:${_viewModel.route!.routeId}:${_viewModel.isDownloaded}',
                            ),
                            placeId: _viewModel.route!.trekkingPlaceId,
                            placeName: _viewModel.route!.placeName,
                            route: _viewModel.route,
                            onDownloaded: () => _viewModel.setDownloaded(true),
                          ),
                        const SizedBox(height: 24),
                        if (widget.pendingJourney != null) ...[
                          if (!_viewModel.isDownloaded) ...[
                            SizedBox(
                              width: double.infinity,
                              child: ListenableBuilder(
                                listenable: _viewModel,
                                builder: (context, _) {
                                  return BtnLoginPrimary(
                                    text: l10n.journeyDetailDownloadMap,
                                    isLoading: _viewModel.isDownloading,
                                    onPressed: () async {
                                      final result =
                                          await Navigator.push<dynamic>(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  DownloadOfflineMapScreen(
                                                    route: _viewModel.route,
                                                    pendingJourney:
                                                        widget.pendingJourney,
                                                  ),
                                            ),
                                          );
                                      if (!context.mounted) return;
                                      if (result is JourneyModel) {
                                        Navigator.pop(context, result);
                                      } else if (result == true) {
                                        _viewModel.setDownloaded(true);
                                      }
                                    },
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: BtnOutlineStyle(
                                text: l10n.journeyActionStart,
                                icon: const Icon(Icons.play_arrow_outlined),
                                onPressed: _startJourney,
                              ),
                            ),
                          ] else ...[
                            SizedBox(
                              width: double.infinity,
                              child: BtnLoginPrimary(
                                text: l10n.journeyActionStart,
                                isLoading: _startingJourney,
                                onPressed: _startJourney,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ListenableBuilder(
                                listenable: _viewModel,
                                builder: (context, _) {
                                  return BtnOutlineStyle(
                                    text: l10n.journeyDetailViewMap,
                                    icon: const Icon(
                                      Icons.open_in_new_outlined,
                                    ),
                                    onPressed: () async {
                                      if (_viewModel.route != null) {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                JourneyMapScreen.preview(
                                                  _viewModel.route!,
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
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              onPressed: _startingJourney
                                  ? null
                                  : () => Navigator.pop(
                                      context,
                                      widget.pendingJourney,
                                    ),
                              child: Text(l10n.backToJourneyScreen),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ] else ...[
                          if (!_viewModel.isDownloaded)
                            SizedBox(
                              width: double.infinity,
                              child: ListenableBuilder(
                                listenable: _viewModel,
                                builder: (context, _) {
                                  return BtnLoginPrimary(
                                    text: l10n.journeyDetailDownloadMap,
                                    isLoading: _viewModel.isDownloading,
                                    onPressed: () async {
                                      final result =
                                          await Navigator.push<dynamic>(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  DownloadOfflineMapScreen(
                                                    route: _viewModel.route,
                                                    pendingJourney:
                                                        widget.pendingJourney,
                                                  ),
                                            ),
                                          );
                                      if (!context.mounted) return;
                                      if (result is JourneyModel) {
                                        Navigator.pop(context, result);
                                      } else if (result == true) {
                                        _viewModel.setDownloaded(true);
                                      }
                                    },
                                  );
                                },
                              ),
                            ),
                          if (_viewModel.isDownloaded)
                            SizedBox(
                              width: double.infinity,
                              child: ListenableBuilder(
                                listenable: _viewModel,
                                builder: (context, _) {
                                  return BtnOutlineStyle(
                                    text: l10n.journeyDetailViewMap,
                                    icon: const Icon(
                                      Icons.open_in_new_outlined,
                                    ),
                                    onPressed: () async {
                                      if (_viewModel.route != null) {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                JourneyMapScreen.preview(
                                                  _viewModel.route!,
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
