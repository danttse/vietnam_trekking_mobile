import 'package:flutter/material.dart';

import '../viewmodels/route_detail_viewmodel.dart';
import '../../../core/widgets/buttons/btn_login_style.dart';
import 'widgets/offline_map_card.dart';
import 'widgets/trekking_empty_state.dart';
import 'download_success_screen.dart';
import '../../../core/widgets/cards/trekking_map_preview.dart';

class RouteDetailScreen extends StatefulWidget {
  final String routeId;
  const RouteDetailScreen({super.key, required this.routeId});

  @override
  State<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen> {
  late final RouteDetailViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = RouteDetailViewModel(routeId: widget.routeId);
    WidgetsBinding.instance.addPostFrameCallback((_) => _vm.load());
    _vm.addListener(_onVmChange);
  }

  void _onVmChange() {
    if (!mounted) return;
    if (_vm.offlineStatus == OfflineMapStatus.ready &&
        _vm.downloadProgress == 1.0) {
      // Navigate to download success screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DownloadSuccessScreen(routeId: widget.routeId),
        ),
      );
    }
    setState(() {});
  }

  @override
  void dispose() {
    _vm.removeListener(_onVmChange);
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) {
        if (_vm.loading && _vm.route == null) {
          return Scaffold(
            backgroundColor: cs.surface,
            body: const Center(
              child: CircularProgressIndicator(color: Color(0xFFE8620A)),
            ),
          );
        }
        if (_vm.error != null && _vm.route == null) {
          return Scaffold(
            appBar: AppBar(backgroundColor: cs.surface, elevation: 0),
            body: TrekkingEmptyState.error(
              message: _vm.error,
              onRetry: _vm.load,
            ),
          );
        }
        return _buildContent(cs);
      },
    );
  }

  Widget _buildContent(ColorScheme cs) {
    final route = _vm.route;

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          // ── Hero image app bar ────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: cs.surface,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 16,
                  color: Colors.white,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              if (route?.difficulty != null)
                Padding(
                  padding: const EdgeInsets.only(right: 12, top: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _difficultyColor(route!.difficulty!),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${route.difficultyLabel} (Level ${route.difficultyLevel})',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: route?.imageUrl != null
                  ? Image.network(route!.imageUrl!, fit: BoxFit.cover)
                  : Container(
                      color: const Color(0xFF0D1A0F),
                      child: const Icon(
                        Icons.landscape,
                        size: 64,
                        color: Color(0xFF1E3A1E),
                      ),
                    ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Name + address ────────────────────────────────────────
                  Text(
                    route?.name ?? 'Đang tải...',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  if (route?.placeAddress != null ||
                      route?.placeName != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      route?.placeAddress ?? route?.placeName ?? '',
                      style: TextStyle(
                        fontSize: 13,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),
                  // ── Stats grid ────────────────────────────────────────────
                  _buildStatsGrid(cs, route),

                  const SizedBox(height: 20),
                  // ── Description ───────────────────────────────────────────
                  if (route?.description != null) ...[
                    Text(
                      route!.description!,
                      style: TextStyle(
                        fontSize: 13,
                        color: cs.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── Map preview ───────────────────────────────────────────
                  Text(
                    'BẢN ĐỒ LỘ TRÌNH',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurfaceVariant,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildMapPreview(cs),

                  const SizedBox(height: 24),
                  // ── Milestones ────────────────────────────────────────────
                  if (_vm.milestones.isNotEmpty) ...[
                    Text(
                      'ĐIỂM KIỂM SOÁT (${_vm.milestones.length} điểm)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurfaceVariant,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ..._vm.milestones.map(
                      (m) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: _MilestoneRow(
                          name: m.name,
                          altitude: m.altitude,
                          isFirst: m.sequenceNumber == 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── Offline map card ──────────────────────────────────────
                  if (_vm.packageInfo != null ||
                      _vm.offlineStatus != OfflineMapStatus.none)
                    OfflineMapCard(
                      packageInfo: _vm.packageInfo,
                      status: _vm.offlineStatus,
                      downloadProgress: _vm.downloadProgress,
                      onDownload: _vm.downloadOfflineMap,
                      onCancel: _vm.cancelDownload,
                      onRetry: _vm.retryDownload,
                    ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: _vm.offlineStatus == OfflineMapStatus.downloading
              ? const SizedBox.shrink()
              : BtnLoginPrimary(
                  text: _vm.offlineStatus == OfflineMapStatus.ready
                      ? 'Bắt đầu hành trình'
                      : 'Tải bản đồ Offline',
                  onPressed: _vm.offlineStatus == OfflineMapStatus.ready
                      ? () => Navigator.of(context).pop()
                      : _vm.downloadOfflineMap,
                ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(ColorScheme cs, route) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.onSurface.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _StatItem(
                icon: Icons.route_outlined,
                label: 'Tổng quãng đường',
                value: _vm.route?.distanceLabel ?? '--',
              ),
              _StatItem(
                icon: Icons.arrow_upward,
                label: 'Độ cao tăng',
                value: _vm.route?.elevationGain != null
                    ? '+${_vm.route!.elevationGain} m'
                    : '--',
              ),
            ],
          ),
          const Divider(height: 16),
          Row(
            children: [
              _StatItem(
                icon: Icons.landscape_outlined,
                label: 'Điểm cao nhất',
                value: _vm.route?.maxElevation != null
                    ? '${_vm.route!.maxElevation} m'
                    : '--',
              ),
              _StatItem(
                icon: Icons.schedule_outlined,
                label: 'Thời gian dự kiến',
                value: _vm.route?.durationLabel ?? '--',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapPreview(ColorScheme cs) {
    return TrekkingMapPreview(
      placeId: _vm.route?.trekkingPlaceId ?? '',
      route: _vm.route?.catalogRoute,
      placeName: _vm.route?.placeName,
    );
  }

  Color _difficultyColor(String d) {
    switch (d.toUpperCase()) {
      case 'EASY':
        return const Color(0xFF4CAF50);
      case 'MEDIUM':
        return const Color(0xFFFF9800);
      case 'HARD':
        return const Color(0xFFE8620A);
      case 'EXPERT':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 18, color: cs.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MilestoneRow extends StatelessWidget {
  final String name;
  final double? altitude;
  final bool isFirst;
  const _MilestoneRow({
    required this.name,
    this.altitude,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(
          isFirst ? Icons.play_circle_outline : Icons.radio_button_unchecked,
          size: 16,
          color: cs.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            name,
            style: TextStyle(fontSize: 13, color: cs.onSurface),
          ),
        ),
        if (altitude != null)
          Text(
            '${altitude!.toInt()}m',
            style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
          ),
      ],
    );
  }
}
