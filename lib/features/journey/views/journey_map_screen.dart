import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../../offline_map/services/offline_map_storage_service.dart';
import '../../route/view/download_offline_map_screen.dart';
import '../../route/data/models/route_model.dart';
import '../data/models/journey_model.dart';
import '../data/models/milestone_model.dart';
import '../data/models/marker_model.dart';
import '../viewmodels/journey_map_viewmodel.dart';
import 'helpers/map_layer_renderer.dart';
import 'widgets/journey_mini_gps_bar.dart';
import 'marker_form_screen.dart';
import 'milestone_checkin_screen.dart';
import 'contribution_screen.dart';
import '../../../core/widgets/app_bar/app_top_bar.dart';
import '../../../core/widgets/buttons/btn_login_style.dart';
import '../../../core/widgets/buttons/btn_outline_style.dart';
import '../../../core/widgets/sheet/app_draggable_sheet.dart';

/// Bản đồ hành trình đầy đủ với route, milestones, markers, user position.
class JourneyMapScreen extends StatefulWidget {
  final JourneyModel journey;
  final List<MilestoneModel> milestones;
  final List<MarkerModel> markers;
  final String routeId;
  final bool readOnly;
  final OfflineMapStorageService? mapStorage;

  const JourneyMapScreen({
    super.key,
    required this.journey,
    required this.milestones,
    required this.markers,
    required this.routeId,
    this.readOnly = false,
    this.mapStorage,
  });

  factory JourneyMapScreen.preview(RouteModel route) => JourneyMapScreen(
    journey: JourneyModel(
      journeyId: '',
      name: route.name,
      route: route,
      status: JourneyStatus.planned,
    ),
    milestones: const [],
    markers: const [],
    routeId: route.routeId,
    readOnly: true,
  );

  @override
  State<JourneyMapScreen> createState() => _JourneyMapScreenState();
}

class _JourneyMapScreenState extends State<JourneyMapScreen> {
  late final JourneyMapViewModel _viewModel;
  final MapLayerRenderer _mapRenderer = MapLayerRenderer();
  MapLibreMapController? _mapController;
  bool _openingMarker = false;
  bool _openingMilestone = false;

  @override
  void initState() {
    super.initState();
    _viewModel = JourneyMapViewModel(
      initialJourney: widget.journey,
      initialMilestones: widget.milestones,
      initialMarkers: widget.markers,
      routeId: widget.routeId,
      readOnly: widget.readOnly,
      customMapStorage: widget.mapStorage,
    );
    _viewModel.addListener(_onViewModelChanged);
    _viewModel.tracking.addListener(_onTrackUpdated);
    _viewModel.init();
  }

  void _onViewModelChanged() {
    if (!mounted) return;
    if (_viewModel.errorMessage != null) {
      _showError(_viewModel.errorMessage!);
      _viewModel.clearErrorMessage();
    }
  }

  void _onTrackUpdated() {
    if (!mounted) return;
    _drawTrack();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _drawTrack() async {
    await _mapRenderer.drawTrack(
      points: _viewModel.tracking.points,
      backtracking: _viewModel.backtracking,
      styleReady: _viewModel.styleReady,
      trackReady: _viewModel.trackReady,
      isMounted: () => mounted,
    );
  }

  Future<void> _fitRoute() async {
    await _mapRenderer.fitRoute(
      pathPoints: _viewModel.journey.route.path,
      milestones: _viewModel.milestones,
      markers: _viewModel.markers,
      trackPoints: _viewModel.tracking.points,
      trackReady: _viewModel.trackReady,
      backtracking: _viewModel.backtracking,
    );
  }

  Future<void> _toggleBacktrack() async {
    final changed = _viewModel.toggleBacktrack();
    if (changed) {
      await _drawTrack();
      await _fitRoute();
    }
  }

  Future<void> _completeJourney() async {
    if (!_viewModel.canMark || _viewModel.updatingJourney) return;
    final share = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: const Text('Kết thúc hành trình?'),
        content: const Text(
          'Đường GPS đã ghi sẽ được lưu cùng hành trình. Bạn có thể gửi route và cột mốc cho admin xét duyệt.',
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

    final saved = await _viewModel.completeJourney();
    if (saved != null && share && mounted) {
      await _shareContribution();
    }
  }

  Future<void> _locateUser() async {
    final location = _viewModel.location;
    if (location.loading) return;
    if (!location.hasPermission || !location.serviceEnabled) {
      await location.recover();
    }
    try {
      final pos = await location.currentPosition();
      if (!mounted) return;
      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(pos.latitude, pos.longitude), 16),
      );
    } catch (e) {
      if (mounted) {
        _showError(
          e is StateError
              ? e.message
              : 'Chưa lấy được vị trí. Vui lòng thử lại.',
        );
      }
    }
  }

  void _onMilestoneTapped(Circle circle) => _openAnnotation(circle.data);
  void _onMilestoneSymbolTapped(Symbol symbol) => _openAnnotation(symbol.data);
  void _openAnnotation(Map? data) {
    if (data?['milestoneId'] != null) {
      _openMilestone(data!['milestoneId']);
    } else if (data?['markerId'] != null && !_viewModel.readOnly) {
      _editMarker(data!['markerId'].toString());
    }
  }

  Future<void> _openMilestone(dynamic id) async {
    if (id == null || _openingMilestone) return;
    final milestone =
        _viewModel.milestones.where((m) => m.id == id).firstOrNull;
    if (milestone == null) return;
    _openingMilestone = true;
    try {
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => MilestoneCheckinScreen(
            milestone: milestone,
            journey: _viewModel.journey,
          ),
        ),
      );
      if (result == true && mounted) {
        Navigator.pop(context, true);
      }
    } finally {
      _openingMilestone = false;
    }
  }

  Future<void> _openMarkerForm() async {
    if (_openingMarker || !_viewModel.canMark) return;
    _openingMarker = true;
    try {
      final location = _viewModel.location;
      if (!location.hasPermission || !location.serviceEnabled) {
        await location.recover();
      }
      final position = await location.currentPosition();
      if (!mounted) return;
      final marker = await showModalBottomSheet<MarkerModel>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => MarkerFormScreen(
          localJourneyId: _viewModel.journey.journeyId,
          userId: _viewModel.journey.userId,
          initialLat: position.latitude,
          initialLng: position.longitude,
          initialAlt: position.altitude,
          initialAccuracy: position.accuracy,
        ),
      );
      if (marker != null && mounted) {
        _viewModel.addMarker(marker);
        await _mapRenderer.addMarker(marker, isMounted: () => mounted);
        _showMarkerSaved(marker);
      }
    } catch (e) {
      if (mounted) {
        _showError(
          e is StateError
              ? e.message
              : 'Chưa lấy được vị trí để đánh dấu cột mốc.',
        );
      }
    } finally {
      _openingMarker = false;
    }
  }

  Future<void> _editMarker(String id) async {
    if (_openingMarker) return;
    final index =
        _viewModel.markers.indexWhere((marker) => marker.markerId == id);
    if (index < 0) return;
    _openingMarker = true;
    try {
      final saved = await showModalBottomSheet<MarkerModel>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => MarkerFormScreen(
          localJourneyId: _viewModel.journey.journeyId,
          userId: _viewModel.journey.userId,
          editingMarker: _viewModel.markers[index],
        ),
      );
      if (saved == null || !mounted) return;
      _viewModel.updateMarker(index, saved);
      await _mapRenderer.clearAll();
      await _mapRenderer.addMapLayers(
        milestones: _viewModel.milestones,
        markers: _viewModel.markers,
        isMounted: () => mounted,
      );
      await _drawTrack();
      _showMarkerSaved(saved);
    } finally {
      _openingMarker = false;
    }
  }

  void _showMarkerSaved(MarkerModel marker) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        action: SnackBarAction(
          label: 'Gửi cho admin',
          onPressed: () => _shareContribution(markerOnly: true),
        ),
        content: Text(
          marker.isSynced
              ? 'Đã đồng bộ cột mốc riêng. Gửi đóng góp để admin nhận.'
              : marker.syncStatus == 'FAILED'
              ? 'Đã lưu trên máy nhưng chưa đồng bộ được. Chạm cột mốc để chỉnh sửa.'
              : 'Đã lưu cột mốc trên máy. Sẽ tự đồng bộ khi có mạng.',
        ),
      ),
    );
  }

  Future<void> _shareContribution({bool markerOnly = false}) async {
    if (_viewModel.journey.journeyId.isEmpty) return;
    if (!markerOnly && _viewModel.journey.status != JourneyStatus.completed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Hoàn thành hành trình để gửi cung đường và cột mốc cho admin.',
          ),
        ),
      );
      return;
    }
    try {
      final markers = await _viewModel.getMarkersForContribution();
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ContributionScreen(
            journey: _viewModel.journey,
            markers: markers,
            userId: _viewModel.journey.userId,
            markerOnly: markerOnly,
          ),
        ),
      );
    } catch (_) {
      if (mounted) {
        _showError('Không tải được cột mốc. Vui lòng thử lại.');
      }
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.tracking.removeListener(_onTrackUpdated);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // ── Map 100% ────────────────────────────────────────────────
              _buildMap(cs),

              // ── Top Bar với AppTopBar ────────────────────────────────────
              _buildTopBar(cs),

              // ── Right controls ──────────────────────────────────────────
              if (!_viewModel.loadingMap && _viewModel.mapError == null)
                Positioned(
                  right: 12,
                  top: kToolbarHeight + MediaQuery.of(context).padding.top + 12,
                  child: _buildRightControls(cs),
                ),

              // ── Floating Mini GPS Status Bar ────────────────────────────
              if (!_viewModel.loadingMap && _viewModel.mapError == null)
                JourneyMiniGpsBar(
                  trackReady: _viewModel.trackReady,
                  isRecording: _viewModel.tracking.recording,
                  isPaused:
                      _viewModel.tracking.enabled &&
                      !_viewModel.tracking.recording,
                  isBacktracking: _viewModel.backtracking,
                  hasPoints: _viewModel.tracking.points.isNotEmpty,
                  distanceMeters: _viewModel.tracking.distanceMeters,
                  pointsCount: _viewModel.tracking.points.length,
                  checkedMilestonesCount:
                      _viewModel.milestones.where((m) => m.isCheckedIn).length,
                  totalMilestonesCount: _viewModel.milestones.length,
                  onTap: _openJourneyDetailsSheet,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMap(ColorScheme cs) {
    if (_viewModel.loadingMap) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_viewModel.mapError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_viewModel.mapError!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              BtnLoginPrimary(
                text: 'Tải / cập nhật bản đồ offline',
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DownloadOfflineMapScreen(
                        route: _viewModel.journey.route,
                        pendingJourney:
                            _viewModel.readOnly ? null : _viewModel.journey,
                      ),
                    ),
                  );
                  if (mounted) _viewModel.loadOfflineMap();
                },
              ),
            ],
          ),
        ),
      );
    }

    final manifest = _viewModel.offline.manifest;
    return MapLibreMap(
      styleString: _viewModel.style!,
      initialCameraPosition: CameraPosition(
        target: _viewModel.center,
        zoom: (manifest?.minZoom ?? 12).toDouble() + 1,
      ),
      onMapCreated: (controller) {
        _mapController = controller;
        _mapRenderer.setController(controller);
        controller.onCircleTapped.add(_onMilestoneTapped);
        controller.onSymbolTapped.add(_onMilestoneSymbolTapped);
      },
      onStyleLoadedCallback: () {
        _viewModel.setStyleReady(true);
        _mapRenderer.addMapLayers(
          milestones: _viewModel.milestones,
          markers: _viewModel.markers,
          isMounted: () => mounted,
        );
        _drawTrack();
        _fitRoute();
      },
      myLocationEnabled:
          _viewModel.location.hasPermission &&
          _viewModel.location.serviceEnabled,
      minMaxZoomPreference: MinMaxZoomPreference(
        manifest!.minZoom.toDouble(),
        manifest.maxZoom.toDouble(),
      ),
      myLocationTrackingMode: MyLocationTrackingMode.none,
      compassEnabled: true,
      rotateGesturesEnabled: true,
      attributionButtonMargins: const math.Point(12, 85),
    );
  }

  Widget _buildTopBar(ColorScheme cs) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: AppTopBar(
              title: _viewModel.journey.name.isNotEmpty
                  ? _viewModel.journey.name
                  : 'Bản đồ hành trình',
              icon: Icons.tune,
              onClickIcon: _openJourneyDetailsSheet,
              leading: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Navigator.of(context).maybePop(),
                child: Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    color: cs.onSurfaceVariant,
                    size: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRightControls(ColorScheme cs) {
    final pointsCount = _viewModel.tracking.points.length;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _MapBtn(
          icon: Icons.my_location,
          onTap: _locateUser,
          color: _viewModel.location.hasPermission
              ? cs.primary
              : cs.onSurfaceVariant,
        ),
        const SizedBox(height: 8),
        _MapBtn(icon: Icons.route_outlined, onTap: _fitRoute),
        const SizedBox(height: 8),
        _MapBtn(
          icon: Icons.tune,
          label: 'Chi tiết',
          onTap: _openJourneyDetailsSheet,
        ),
        const SizedBox(height: 8),
        if (_viewModel.trackReady && pointsCount >= 2) ...[
          _MapBtn(
            icon: Icons.undo,
            label: 'Backtrack',
            onTap: _toggleBacktrack,
            color: _viewModel.backtracking
                ? const Color(0xFFF59E0B)
                : cs.onSurface,
          ),
          const SizedBox(height: 8),
        ],
        _MapBtn(
          icon: Icons.add,
          onTap: () => _mapController?.animateCamera(CameraUpdate.zoomIn()),
        ),
        const SizedBox(height: 8),
        _MapBtn(
          icon: Icons.remove,
          onTap: () => _mapController?.animateCamera(CameraUpdate.zoomOut()),
        ),
        const SizedBox(height: 8),
        if (_viewModel.canMark)
          _MapBtn(
            icon: Icons.flag_outlined,
            onTap: _openMarkerForm,
            color: Theme.of(context).colorScheme.primary,
          ),
      ],
    );
  }

  void _openJourneyDetailsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => ListenableBuilder(
        listenable: Listenable.merge([_viewModel, _viewModel.tracking, _viewModel.location]),
        builder: (ctx, _) => AppDraggableSheet(
          title: _viewModel.journey.name.isNotEmpty
              ? _viewModel.journey.name
              : 'Chi tiết hành trình',
          initialChildSize: 0.6,
          minChildSize: 0.35,
          maxChildSize: 0.92,
          contentBuilder: (ctx, scrollController) =>
              _buildSheetContent(sheetContext, scrollController),
        ),
      ),
    );
  }

  Widget _buildSheetContent(
    BuildContext sheetContext,
    ScrollController scrollController,
  ) {
    final cs = Theme.of(context).colorScheme;
    final checkedMilestones =
        _viewModel.milestones.where((m) => m.isCheckedIn).length;
    final tracking = _viewModel.tracking;

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        // Summary row
        Row(
          children: [
            Expanded(
              child: Text(
                'Tiến độ hành trình',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ),
            Text(
              '$checkedMilestones/${_viewModel.milestones.length} điểm đã đến',
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Tracking status tile
        if (_viewModel.trackReady) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    _viewModel.backtracking ? Icons.undo : Icons.route,
                    color: _viewModel.backtracking
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFF16A34A),
                  ),
                  title: Text(
                    _viewModel.backtracking
                        ? 'Backtrack · Quay lại điểm đầu'
                        : tracking.points.isEmpty
                        ? 'Backtrack · Ghi lại đường đi'
                        : 'Đường đi đã lưu',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '${tracking.points.length} điểm GPS · ${(tracking.distanceMeters / 1000).toStringAsFixed(2)} km\n'
                    '${tracking.error ?? (tracking.recording
                            ? 'Đang ghi GPS khi ứng dụng mở'
                            : tracking.enabled
                            ? 'Tạm dừng ghi GPS'
                            : 'Lưu trên máy, dùng được khi mất mạng')}',
                    style: const TextStyle(fontSize: 11),
                  ),
                  trailing: _viewModel.canMark &&
                          _viewModel.journey.status == JourneyStatus.active
                      ? IconButton(
                          tooltip: tracking.enabled
                              ? 'Dừng ghi GPS'
                              : 'Ghi lại đường đi',
                          onPressed: _viewModel.toggleRecording,
                          icon: Icon(
                            tracking.enabled
                                ? Icons.stop_circle_outlined
                                : Icons.fiber_manual_record,
                            color: tracking.enabled
                                ? Colors.redAccent
                                : const Color(0xFF16A34A),
                          ),
                        )
                      : null,
                ),
                if (_viewModel.canMark &&
                    _viewModel.journey.status == JourneyStatus.active &&
                    tracking.points.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 8),
                    child: BtnOutlineStyle(
                      text: tracking.enabled ? 'Dừng ghi GPS' : 'Bắt đầu ghi GPS',
                      icon: Icon(
                        tracking.enabled
                            ? Icons.stop_circle_outlined
                            : Icons.route,
                      ),
                      onPressed: _viewModel.toggleRecording,
                    ),
                  ),
                if (tracking.points.length >= 2)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: BtnOutlineStyle(
                      text: _viewModel.backtracking
                          ? 'Thoát backtrack'
                          : 'Quay lại theo đường đã đi',
                      icon: const Icon(Icons.undo),
                      onPressed: _toggleBacktrack,
                    ),
                  ),
                if (_viewModel.backtracking)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      'Theo vệt màu cam về điểm bắt đầu GPS màu xanh lá.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Map legend
        const Row(
          children: [
            Icon(Icons.circle, size: 9, color: Color(0xFFE8620A)),
            SizedBox(width: 4),
            Text('Điểm check-in', style: TextStyle(fontSize: 11)),
            SizedBox(width: 12),
            Icon(Icons.circle, size: 9, color: Color(0xFF3B82F6)),
            SizedBox(width: 4),
            Text('Cột mốc của bạn', style: TextStyle(fontSize: 11)),
          ],
        ),
        const SizedBox(height: 8),

        // Milestones horizontal chips
        if (_viewModel.milestones.isNotEmpty)
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _viewModel.milestones
                  .map(
                    (m) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ActionChip(
                        avatar: Icon(
                          m.isCheckedIn
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          size: 14,
                          color: m.isCheckedIn
                              ? const Color(0xFF16A34A)
                              : cs.onSurfaceVariant,
                        ),
                        label: Text('${m.sequence}. ${m.name}'),
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          _mapController?.animateCamera(
                            CameraUpdate.newLatLngZoom(
                              LatLng(m.latitude, m.longitude),
                              16,
                            ),
                          );
                        },
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),

        if (_viewModel.location.error != null) ...[
          const SizedBox(height: 8),
          _locationBanner(cs),
        ],

        if (_viewModel.location.position != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.circle,
                color: Color(0xFF3B82F6),
                size: 10,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Vị trí của bạn • sai số ±${_viewModel.location.position!.accuracy.round()} m',
                  style: TextStyle(
                    fontSize: 11,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],

        if (!_viewModel.readOnly && _viewModel.markers.isNotEmpty) ...[
          const SizedBox(height: 8),
          InkWell(
            onTap: () {
              Navigator.pop(sheetContext);
              _shareContribution(markerOnly: true);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.share_outlined,
                    size: 14,
                    color: cs.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Gửi ${_viewModel.markers.length} cột mốc cho admin',
                      style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: cs.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ],

        const SizedBox(height: 16),

        // Main CTA: Đánh dấu cột mốc
        if (_viewModel.canMark) ...[
          BtnLoginPrimary(
            text: 'Đánh dấu cột mốc',
            onPressed: () {
              Navigator.pop(sheetContext);
              _openMarkerForm();
            },
          ),
          const SizedBox(height: 10),
        ],

        // Secondary CTA: Kết thúc hành trình
        if (_viewModel.canMark) ...[
          BtnOutlineStyle(
            text: _viewModel.updatingJourney
                ? 'Đang lưu hành trình...'
                : 'Kết thúc hành trình',
            icon: const Icon(Icons.check_circle_outline, size: 20),
            onPressed: _viewModel.updatingJourney
                ? null
                : () {
                    Navigator.pop(sheetContext);
                    _completeJourney();
                  },
          ),
          const SizedBox(height: 10),
        ],

        // Completed journey CTA: Chia sẻ route tới admin
        if (_viewModel.journey.status == JourneyStatus.completed &&
            _viewModel.journey.journeyId.isNotEmpty)
          BtnOutlineStyle(
            text: 'Chia sẻ route tới admin',
            icon: const Icon(Icons.share_outlined, size: 20),
            onPressed: () {
              Navigator.pop(sheetContext);
              _shareContribution();
            },
          ),
      ],
    );
  }

  Widget _locationBanner(ColorScheme cs) => Material(
    color: cs.surfaceContainerHighest,
    borderRadius: BorderRadius.circular(10),
    child: InkWell(
      onTap: _viewModel.location.recover,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Icon(Icons.location_off_outlined, color: cs.primary, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _viewModel.location.error ?? '',
                style: TextStyle(fontSize: 11, color: cs.onSurface),
              ),
            ),
            const Icon(Icons.settings_outlined, size: 16),
          ],
        ),
      ),
    ),
  );
}

class _MapBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? label;
  final Color? color;

  const _MapBtn({
    required this.icon,
    required this.onTap,
    this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final btn = Material(
      color: cs.surfaceContainerHighest.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Icon(icon, size: 20, color: color ?? cs.onSurface),
        ),
      ),
    );
    if (label == null) return btn;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        btn,
        const SizedBox(height: 2),
        Text(
          label!,
          style: const TextStyle(color: Colors.white70, fontSize: 9),
        ),
      ],
    );
  }
}
