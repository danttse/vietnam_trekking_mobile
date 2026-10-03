import 'package:flutter/material.dart';
import 'package:vietnam_trekking_mobile/core/widgets/buttons/btn_login_style.dart';
import 'package:vietnam_trekking_mobile/core/widgets/buttons/btn_outline_style.dart';
import '../data/models/route_model.dart';
import '../viewmodel/route_detail_viewmodel.dart';
import 'download_offline_map_screen.dart';
import '../../../core/widgets/cards/card_home_stats.dart';

class RouteDetailScreen extends StatefulWidget {
  final RouteModel? route;
  const RouteDetailScreen({super.key, this.route});

  @override
  State<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen> {
  late final RouteDetailViewModel _viewModel;
  @override
  void initState() {
    super.initState();
    _viewModel = RouteDetailViewModel(route: widget.route);
  }
  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: Column(children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  _viewModel.heroImageUrl,
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _viewModel.difficultyText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
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
                          Text(
                            _viewModel.routeLocation,
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
                            child: CardHomeStats(
                                title: 'Tổng quãng đường',
                                value: _viewModel.totalDistanceText,
                                icon: Icons.linear_scale,
                                iconColor: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                            child: CardHomeStats(
                              title: 'Độ cao tổng',
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
                              title: 'Điểm cao nhất',
                              value: _viewModel.maxElevationText,
                              icon: Icons.navigation_outlined,
                              iconColor: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CardHomeStats(
                              title: 'Thời gian dự kiến',
                              value: _viewModel.estimatedDurationText,
                              icon: Icons.calendar_today_outlined,
                              iconColor: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height:20),
                      Text(
                        "BẢN ĐỒ LỘ TRÌNH",
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
                      const SizedBox(height: 24),
                      if (!_viewModel.isDownloaded)
                        SizedBox(
                          width: double.infinity,
                          child: ListenableBuilder(
                            listenable: _viewModel,
                            builder: (context, _) {
                              return BtnLoginPrimary(
                                text: 'Tải bản đồ Offline',
                                isLoading: _viewModel.isDownloading,
                                onPressed: () async {
                                  final result = await Navigator.push<bool>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DownloadOfflineMapScreen(
                                        route: _viewModel.route,
                                      ),
                                    ),
                                  );
                                  if (result == true) {
                                    _viewModel.setDownloaded(true);
                                  }
                                },
                              );
                            },
                          ),
                        )
                      else
                        SizedBox(
                          width: double.infinity,
                          child: ListenableBuilder(
                            listenable: _viewModel,
                            builder: (context, _) {
                              return BtnOutlineStyle(
                                text: 'Xem bản đồ Offline',
                                icon: Icon(Icons.open_in_new_outlined),
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
        ])
      )
    );
  }
}