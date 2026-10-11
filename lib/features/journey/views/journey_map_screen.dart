import 'dart:math' as math;
import 'dart:io';
import 'dart:async';

import '../../offline_map/services/offline_map_manager.dart';
import '../../offline_map/services/offline_map_storage_service.dart';
import '../../offline_map/utils/entity_map_style.dart';
import '../../route/view/download_offline_map_screen.dart';
import '../../route/data/models/route_model.dart';

import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../data/models/journey_model.dart';
import '../data/models/milestone_model.dart';
import '../data/models/marker_model.dart';
import 'widgets/trekking_button.dart';
import 'marker_form_screen.dart';
import 'milestone_checkin_screen.dart';
import 'contribution_screen.dart';
import '../data/repositories/journey_repository.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/journey_tracking_service.dart';
import '../../../core/network/api_error_handler.dart';

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
  MapLibreMapController? _mapController;
  bool _isFullScreen = false;
  final OfflineMapManager _offline = OfflineMapManager.create();
  String? _mapError;
  bool _loadingMap = true;
  bool _styleReady = false;
  final _location = LocationService.instance;
  late final List<MarkerModel> _markers;
  late List<MilestoneModel> _milestones;
  String? _style;
  bool _openingMarker = false;
  bool _openingMilestone = false;
  late final JourneyTrackingService _tracking;
  late final bool _ownsTracking;
  late JourneyModel _journey;
  bool _trackReady = false;
  bool _backtracking = false;
  bool _updatingJourney = false;
  bool _drawingTrack = false;
  bool _trackDirty = false;
  Line? _trackLine;
  Circle? _trackStart;
  bool get _canMark =>
      !widget.readOnly &&
      (_journey.status == JourneyStatus.active ||
          _journey.status == JourneyStatus.paused);

  @override
  void initState() {
    super.initState();
    _ownsTracking =
        widget.readOnly ||
        (widget.journey.status != JourneyStatus.active &&
            widget.journey.status != JourneyStatus.paused);
    _tracking = _ownsTracking
        ? JourneyTrackingService()
        : JourneyTrackingService.instance;
    _journey = widget.journey;
    _markers = List.of(widget.markers);
    _milestones = List.of(widget.milestones);
    _location.addListener(_locationChanged);
    _location.initialize();
    _loadOfflineMap();
    if (_journey.journeyId.isNotEmpty) {
      _tracking.addListener(_trackChanged);
      unawaited(_loadTrack());
    }
  }

  Future<void> _loadTrack() async {
    try {
      await _tracking.open(
        _journey.journeyId,
        encodedPolyline: _journey.encodedPolyline,
      );
      if (!mounted) return;
      setState(() => _trackReady = true);
      await _drawTrack();
    } catch (e) {
      if (mounted) _showError(ApiErrorHandler.handle(e));
    }
  }

  void _trackChanged() {
    if (!mounted) return;
    setState(() {});
    unawaited(_drawTrack());
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _toggleRecording() async {
    if (!_trackReady || _updatingJourney) return;
    try {
      await _tracking.setEnabled(!_tracking.enabled);
    } catch (e) {
      _showError(ApiErrorHandler.handle(e));
    }
  }

  Future<void> _toggleBacktrack() async {
    if (_tracking.points.length < 2) {
      _showError('Cần ít nhất 2 điểm GPS đã lưu để quay lại đường đã đi.');
      return;
    }
    setState(() => _backtracking = !_backtracking);
    await _drawTrack();
    await _fitRoute();
  }

  Future<void> _drawTrack() async {
    if (_drawingTrack) {
      _trackDirty = true;
      return;
    }
    final controller = _mapController;
    if (controller == null || !_styleReady || !_trackReady || !mounted) return;
    _drawingTrack = true;
    try {
      do {
        _trackDirty = false;
        final points = _tracking.points;
        if (points.isEmpty) return;
        if (_trackStart == null) {
          _trackStart = await controller.addCircle(
            CircleOptions(
              geometry: LatLng(points.first.latitude, points.first.longitude),
              circleColor: '#16A34A',
              circleRadius: 8,
              circleStrokeColor: '#FFFFFF',
              circleStrokeWidth: 3,
            ),
          );
          await controller.addSymbol(
            SymbolOptions(
              geometry: LatLng(points.first.latitude, points.first.longitude),
              textField: 'Điểm bắt đầu GPS',
              textSize: 12,
              textColor: '#FFFFFF',
              textHaloColor: '#13251B',
              textHaloWidth: 2,
              textAnchor: 'bottom',
              textOffset: const Offset(0, -1.4),
            ),
          );
        }
        if (points.length < 2) return;
        final ordered = _backtracking ? points.reversed : points;
        final options = LineOptions(
          geometry: ordered
              .map((p) => LatLng(p.latitude, p.longitude))
              .toList(),
          lineColor: _backtracking ? '#F59E0B' : '#16A34A',
          lineWidth: 5,
          lineOpacity: 0.9,
        );
        if (_trackLine == null) {
          _trackLine = await controller.addLine(options);
        } else {
          await controller.updateLine(_trackLine!, options);
        }
      } while (_trackDirty && mounted && _styleReady);
    } catch (e) {
      debugPrint('[Backtrack] render: $e');
    } finally {
      _drawingTrack = false;
    }
  }

  Future<void> _completeJourney() async {
    if (!_canMark || _updatingJourney) return;
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
    setState(() => _updatingJourney = true);
    try {
      await _tracking.flush();
      final saved = await JourneyRepository().completeJourney(
        _journey.journeyId,
      );
      if (!mounted) return;
      setState(() => _journey = saved);
      if (share) await _shareContribution();
    } catch (e) {
      _showError(ApiErrorHandler.handle(e));
    } finally {
      if (mounted) setState(() => _updatingJourney = false);
    }
  }

  void _locationChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadOfflineMap() async {
    if (mounted)
      setState(() {
        _loadingMap = true;
        _mapError = null;
      });
    try {
      if (widget.readOnly && _milestones.isEmpty) {
        try {
          _milestones = await JourneyRepository().getMilestones(widget.routeId);
        } catch (_) {
          /* Keep the downloaded route usable when catalog is unavailable. */
        }
      }
      final storage = widget.mapStorage ?? OfflineMapStorageService();
      final map = await storage.findReadyMap(
        widget.routeId,
        widget.journey.trekkingPlaceId,
      );
      if (map == null)
        throw StateError('Chưa có bản đồ offline đã cài cho địa điểm này.');
      final point = widget.journey.route.startPoint;
      if ((point.latitude != 0 || point.longitude != 0) &&
          (point.latitude < (map.minLatitude ?? -90) ||
              point.latitude > (map.maxLatitude ?? 90) ||
              point.longitude < (map.minLongitude ?? -180) ||
              point.longitude > (map.maxLongitude ?? 180))) {
        throw StateError(
          'Gói bản đồ chưa phủ cung đường này. Vui lòng tải bản đồ mới nhất.',
        );
      }
      _styleReady = false;
      _trackLine = null;
      _trackStart = null;
      await _offline.close();
      await _offline.initialize(
        packageDirectory: File(map.localPath).parent.path,
      );
      if (!_offline.isReady)
        throw StateError(
          _offline.errorMessage ?? 'Không thể mở bản đồ offline.',
        );
      await storage.touchMap(map.mapId);
      _style = entityMapStyle(
        _offline.styleString!,
        route: widget.journey.route,
        routeColor: '#3B82F6',
      );
    } catch (e) {
      _mapError = e is StateError ? e.message : e.toString();
    } finally {
      if (mounted) setState(() => _loadingMap = false);
    }
  }

  @override
  void dispose() {
    _tracking.removeListener(_trackChanged);
    if (_ownsTracking) _tracking.dispose();
    _location.removeListener(_locationChanged);
    _offline.dispose();
    super.dispose();
  }

  // Default center (Vietnam center — will be overridden by route coords)
  LatLng get _center {
    final manifest = _offline.manifest;
    if (manifest != null) return LatLng(manifest.centerLat, manifest.centerLng);
    if (_milestones.isNotEmpty) {
      final first = _milestones.first;
      return LatLng(first.latitude, first.longitude);
    }
    return const LatLng(14.0583, 108.2772);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Map ───────────────────────────────────────────────────────
          _buildMap(cs),

          // ── Top bar ───────────────────────────────────────────────────
          _buildTopBar(cs),

          // ── Right controls ────────────────────────────────────────────
          if (!_loadingMap && _mapError == null)
            Positioned(
              right: 12,
              top: kToolbarHeight + MediaQuery.of(context).padding.top + 12,
              child: _buildRightControls(cs),
            ),

          // ── Bottom info panel (Đánh dấu cột mốc CTA) ─────────────────
          if (!_isFullScreen && !_loadingMap && _mapError == null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomPanel(cs),
            ),
          if (_isFullScreen && _location.error != null)
            Positioned(
              left: 16,
              right: 64,
              bottom: 24,
              child: _locationBanner(cs),
            ),
        ],
      ),
    );
  }

  Widget _buildMap(ColorScheme cs) {
    if (_loadingMap) return const Center(child: CircularProgressIndicator());
    if (_mapError != null)
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_mapError!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DownloadOfflineMapScreen(
                        route: widget.journey.route,
                        pendingJourney: widget.readOnly ? null : widget.journey,
                      ),
                    ),
                  );
                  if (mounted) _loadOfflineMap();
                },
                child: const Text('Tải / cập nhật bản đồ offline'),
              ),
            ],
          ),
        ),
      );
    return MapLibreMap(
      styleString: _style!,
      initialCameraPosition: CameraPosition(
        target: _center,
        zoom: (_offline.manifest?.minZoom ?? 12).toDouble() + 1,
      ),
      onMapCreated: (controller) {
        _mapController = controller;
        controller.onCircleTapped.add(_onMilestoneTapped);
        controller.onSymbolTapped.add(_onMilestoneSymbolTapped);
      },
      onStyleLoadedCallback: () {
        _styleReady = true;
        _addMapLayers();
        _drawTrack();
        _fitRoute();
      },
      myLocationEnabled: _location.hasPermission && _location.serviceEnabled,
      minMaxZoomPreference: MinMaxZoomPreference(
        _offline.manifest!.minZoom.toDouble(),
        _offline.manifest!.maxZoom.toDouble(),
      ),
      // A user viewing a future trip (or emulator GPS) may be outside the
      // downloaded region. Open at the package center instead of following GPS.
      myLocationTrackingMode: MyLocationTrackingMode.none,
      compassEnabled: true,
      rotateGesturesEnabled: true,
      attributionButtonMargins: math.Point(12, _isFullScreen ? 12 : 245),
    );
  }

  Future<void> _addMapLayers() async {
    if (_mapController == null || !_styleReady || !mounted) return;
    await _mapController!.setSymbolTextAllowOverlap(true);
    await _mapController!.setSymbolTextIgnorePlacement(true);
    // Names remain visible against terrain and do not disappear behind base-map labels.
    for (final m in _milestones) {
      if (!mounted) return;
      await _mapController!.addCircle(
        CircleOptions(
          geometry: LatLng(m.latitude, m.longitude),
          circleColor: m.isCheckedIn ? '#4CAF50' : '#E8620A',
          circleRadius: 8,
          circleStrokeWidth: 2,
          circleStrokeColor: '#ffffff',
        ),
        {'milestoneId': m.id},
      );
      await _mapController!.addSymbol(
        SymbolOptions(
          geometry: LatLng(m.latitude, m.longitude),
          textField:
              '${m.sequence}. ${m.name}${m.isCheckedIn ? ' · Đã đến' : ''}',
          textSize: 13,
          textColor: '#ffffff',
          textHaloColor: '#13251B',
          textHaloWidth: 2.5,
          textAnchor: 'bottom',
          textOffset: const Offset(0, -1.2),
        ),
        {'milestoneId': m.id},
      );
    }
    // User markers
    for (final mk in _markers) {
      if (!mounted) return;
      await _addMarker(mk);
    }
  }

  Future<void> _addMarker(MarkerModel marker) async {
    final controller = _mapController;
    if (controller == null || !_styleReady || !mounted) return;
    await controller.addCircle(
      CircleOptions(
        geometry: LatLng(marker.latitude, marker.longitude),
        circleColor: '#3B82F6',
        circleRadius: 7,
        circleStrokeColor: '#ffffff',
        circleStrokeWidth: 2,
      ),
      {'markerId': marker.markerId},
    );
    if (!mounted) return;
    await controller.addSymbol(
      SymbolOptions(
        geometry: LatLng(marker.latitude, marker.longitude),
        textField: marker.name,
        textMaxWidth: 12,
        textSize: 13,
        textColor: '#ffffff',
        textHaloColor: '#13251B',
        textHaloWidth: 2.5,
        textAnchor: 'bottom',
        textOffset: const Offset(0, -1.2),
      ),
      {'markerId': marker.markerId},
    );
  }

  void _onMilestoneTapped(Circle circle) => _openAnnotation(circle.data);
  void _onMilestoneSymbolTapped(Symbol symbol) => _openAnnotation(symbol.data);
  void _openAnnotation(Map? data) {
    if (data?['milestoneId'] != null) {
      _openMilestone(data!['milestoneId']);
    } else if (data?['markerId'] != null && !widget.readOnly) {
      _editMarker(data!['markerId'].toString());
    }
  }

  Future<void> _editMarker(String id) async {
    if (_openingMarker) return;
    final index = _markers.indexWhere((marker) => marker.markerId == id);
    if (index < 0) return;
    _openingMarker = true;
    try {
      final saved = await showModalBottomSheet<MarkerModel>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => MarkerFormScreen(
          localJourneyId: widget.journey.journeyId,
          userId: widget.journey.userId,
          editingMarker: _markers[index],
        ),
      );
      if (saved == null || !mounted) return;
      setState(() => _markers[index] = saved);
      await _mapController?.clearCircles();
      _trackStart = null;
      await _mapController?.clearSymbols();
      await _addMapLayers();
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

  Future<void> _openMilestone(dynamic id) async {
    if (id == null || _openingMilestone) return;
    final milestone = _milestones.where((m) => m.id == id).firstOrNull;
    if (milestone == null) return;
    _openingMilestone = true;
    try {
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => MilestoneCheckinScreen(
            milestone: milestone,
            journey: widget.journey,
          ),
        ),
      );
      if (result == true && mounted) {
        // The detail screen reloads verified milestones on return.
        Navigator.pop(context, true);
      }
    } finally {
      _openingMilestone = false;
    }
  }

  Future<void> _fitRoute() async {
    final points = widget.journey.route.path;
    final locations = <LatLng>[
      if (_trackReady)
        ..._tracking.points.map((p) => LatLng(p.latitude, p.longitude)),
      if (!_backtracking) ...[
        ...points.map((p) => LatLng(p.latitude, p.longitude)),
        ..._milestones.map((m) => LatLng(m.latitude, m.longitude)),
        ..._markers.map((m) => LatLng(m.latitude, m.longitude)),
      ],
    ];
    if (locations.isEmpty) return;
    if (locations.length == 1) {
      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(locations.first, 14),
      );
      return;
    }
    final south = locations.map((p) => p.latitude).reduce(math.min);
    final north = locations.map((p) => p.latitude).reduce(math.max);
    final west = locations.map((p) => p.longitude).reduce(math.min);
    final east = locations.map((p) => p.longitude).reduce(math.max);
    await _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(south, west),
          northeast: LatLng(north, east),
        ),
        left: 90,
        right: 110,
        top: 100,
        bottom: _isFullScreen
            ? 60
            : math.min(360, MediaQuery.sizeOf(context).height * 0.45),
      ),
    );
  }

  Future<void> _locateUser() async {
    if (_location.loading) return;
    if (!_location.hasPermission || !_location.serviceEnabled) {
      await _location.recover();
    }
    try {
      final pos = await _location.currentPosition();
      if (!mounted) return;
      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(pos.latitude, pos.longitude), 16),
      );
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e is StateError
                  ? e.message
                  : 'Chưa lấy được vị trí. Vui lòng thử lại.',
            ),
          ),
        );
    }
  }

  Widget _locationBanner(ColorScheme cs) => Material(
    color: cs.surfaceContainerHighest,
    borderRadius: BorderRadius.circular(10),
    child: InkWell(
      onTap: _location.recover,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Icon(Icons.location_off_outlined, color: cs.primary, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _location.error ?? '',
                style: TextStyle(fontSize: 11, color: cs.onSurface),
              ),
            ),
            const Icon(Icons.settings_outlined, size: 16),
          ],
        ),
      ),
    ),
  );

  Widget _buildTopBar(ColorScheme cs) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          height: kToolbarHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
            ),
          ),
          child: Row(
            children: [
              _MapBtn(
                icon: Icons.arrow_back_ios_new,
                onTap: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bản đồ hành trình',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      widget.journey.name,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              _MapBtn(
                icon: _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                label: _isFullScreen ? 'Thu nhỏ' : 'Toàn màn hình',
                onTap: () => setState(() => _isFullScreen = !_isFullScreen),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRightControls(ColorScheme cs) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _MapBtn(
          icon: Icons.my_location,
          onTap: _locateUser,
          color: _location.hasPermission ? cs.primary : cs.onSurfaceVariant,
        ),
        const SizedBox(height: 8),
        _MapBtn(icon: Icons.route_outlined, onTap: _fitRoute),
        const SizedBox(height: 8),
        if (_trackReady && _tracking.points.length >= 2) ...[
          _MapBtn(
            icon: Icons.undo,
            label: 'Backtrack',
            onTap: _toggleBacktrack,
            color: _backtracking ? const Color(0xFFF59E0B) : cs.onSurface,
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
        if (_canMark)
          _MapBtn(
            icon: Icons.flag_outlined,
            onTap: _openMarkerForm,
            color: const Color(0xFFE8620A),
          ),
      ],
    );
  }

  Widget _buildBottomPanel(ColorScheme cs) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.52,
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: cs.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Route info
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.journey.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_milestones.where((m) => m.isCheckedIn).length}/${_milestones.length} điểm',
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_trackReady) ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    _backtracking ? Icons.undo : Icons.route,
                    color: _backtracking
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFF16A34A),
                  ),
                  title: Text(
                    _backtracking
                        ? 'Backtrack · Quay lại điểm đầu'
                        : _tracking.points.isEmpty
                        ? 'Backtrack · Ghi lại đường đi'
                        : 'Đường đi đã lưu',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '${_tracking.points.length} điểm GPS · ${(_tracking.distanceMeters / 1000).toStringAsFixed(2)} km\n'
                    '${_tracking.error ?? (_tracking.recording
                            ? 'Đang ghi GPS khi ứng dụng mở'
                            : _tracking.enabled
                            ? 'Tạm dừng ghi GPS'
                            : 'Lưu trên máy, dùng được khi mất mạng')}',
                    style: const TextStyle(fontSize: 11),
                  ),
                  trailing: _canMark && _journey.status == JourneyStatus.active
                      ? IconButton(
                          tooltip: _tracking.enabled
                              ? 'Dừng ghi GPS'
                              : 'Ghi lại đường đi',
                          onPressed: _toggleRecording,
                          icon: Icon(
                            _tracking.enabled
                                ? Icons.stop_circle_outlined
                                : Icons.fiber_manual_record,
                            color: _tracking.enabled
                                ? Colors.redAccent
                                : const Color(0xFF16A34A),
                          ),
                        )
                      : null,
                ),
                if (_canMark &&
                    _journey.status == JourneyStatus.active &&
                    _tracking.points.isEmpty)
                  FilledButton.tonalIcon(
                    onPressed: _toggleRecording,
                    icon: Icon(
                      _tracking.enabled
                          ? Icons.stop_circle_outlined
                          : Icons.route,
                    ),
                    label: Text(
                      _tracking.enabled ? 'Dừng ghi GPS' : 'Bắt đầu ghi GPS',
                    ),
                  ),
                if (_tracking.points.length >= 2)
                  TextButton.icon(
                    onPressed: _toggleBacktrack,
                    icon: const Icon(Icons.undo),
                    label: Text(
                      _backtracking
                          ? 'Thoát backtrack'
                          : 'Quay lại theo đường đã đi',
                    ),
                  ),
                if (_backtracking)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Theo vệt màu cam về điểm bắt đầu GPS màu xanh lá.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
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
              if (_milestones.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: SizedBox(
                    height: 36,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _milestones
                          .map(
                            (m) => Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ActionChip(
                                label: Text('${m.sequence}. ${m.name}'),
                                onPressed: () => _mapController?.animateCamera(
                                  CameraUpdate.newLatLngZoom(
                                    LatLng(m.latitude, m.longitude),
                                    16,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              // Share route note
              if (_location.error != null) _locationBanner(cs),
              if (_location.position != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.circle,
                        color: Color(0xFF3B82F6),
                        size: 10,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Vị trí của bạn • sai số ±${_location.position!.accuracy.round()} m',
                          style: TextStyle(
                            fontSize: 11,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (!widget.readOnly && _markers.isNotEmpty)
                InkWell(
                  onTap: () => _shareContribution(markerOnly: true),
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
                          'Gửi ${_markers.length} cột mốc cho admin',
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
              const SizedBox(height: 12),
              // Main CTA
              if (_canMark)
                TrekkingPrimaryButton(
                  label: 'Đánh dấu cột mốc',
                  icon: Icons.flag_outlined,
                  onPressed: _openMarkerForm,
                ),
              if (_canMark)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: TrekkingSecondaryButton(
                    onPressed: _updatingJourney ? null : _completeJourney,
                    icon: Icons.check_circle_outline,
                    loading: _updatingJourney,
                    label: _updatingJourney
                        ? 'Đang lưu hành trình...'
                        : 'Kết thúc hành trình',
                  ),
                ),
              if (_journey.status == JourneyStatus.completed &&
                  _journey.journeyId.isNotEmpty)
                FilledButton.icon(
                  onPressed: () => _shareContribution(),
                  icon: const Icon(Icons.share_outlined),
                  label: const Text('Chia sẻ route tới admin'),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openMarkerForm() async {
    if (_openingMarker || !_canMark) return;
    _openingMarker = true;
    try {
      if (!_location.hasPermission || !_location.serviceEnabled) {
        await _location.recover();
      }
      final position = await _location.currentPosition();
      if (!mounted) return;
      final marker = await showModalBottomSheet<MarkerModel>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => MarkerFormScreen(
          localJourneyId: widget.journey.journeyId,
          userId: widget.journey.userId,
          initialLat: position.latitude,
          initialLng: position.longitude,
          initialAlt: position.altitude,
          initialAccuracy: position.accuracy,
        ),
      );
      if (marker != null && mounted) {
        setState(() => _markers.add(marker));
        await _addMarker(marker);
        _showMarkerSaved(marker);
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e is StateError
                  ? e.message
                  : 'Chưa lấy được vị trí để đánh dấu cột mốc.',
            ),
          ),
        );
    } finally {
      _openingMarker = false;
    }
  }

  Future<void> _shareContribution({bool markerOnly = false}) async {
    if (_journey.journeyId.isEmpty) return;
    if (!markerOnly && _journey.status != JourneyStatus.completed) {
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
      final markers = await JourneyRepository().getMarkers(
        widget.journey.journeyId,
      );
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ContributionScreen(
            journey: _journey,
            markers: markers,
            userId: widget.journey.userId,
            markerOnly: markerOnly,
          ),
        ),
      );
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không tải được cột mốc. Vui lòng thử lại.'),
          ),
        );
    }
  }
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
