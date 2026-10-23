import 'dart:math' show Point;

import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../services/offline_map_manager.dart';

class OfflineMapTestScreen extends StatefulWidget {
  const OfflineMapTestScreen({super.key});

  @override
  State<OfflineMapTestScreen> createState() => _OfflineMapTestScreenState();
}

class _OfflineMapTestScreenState extends State<OfflineMapTestScreen> {
  late final OfflineMapManager _manager;
  MapLibreMapController? _mapController;

  // Fallback bounds / center Bà Đen (dùng khi manifest chưa load)
  static final _fallbackBounds = LatLngBounds(
    southwest: const LatLng(11.36157, 106.13943),
    northeast: const LatLng(11.41239, 106.19162),
  );
  static const _fallbackCenter = LatLng(11.38698, 106.165525);
  static const _defaultZoom = 13.0;

  // Bounds thực từ manifest (set sau khi manager ready)
  LatLngBounds get _bounds {
    final m = _manager.manifest;
    if (m != null && m.bounds.length == 4) {
      // bounds = [minLng, minLat, maxLng, maxLat]
      return LatLngBounds(
        southwest: LatLng(m.bounds[1], m.bounds[0]),
        northeast: LatLng(m.bounds[3], m.bounds[2]),
      );
    }
    return _fallbackBounds;
  }

  LatLng get _center {
    final m = _manager.manifest;
    if (m != null) return LatLng(m.centerLat, m.centerLng);
    return _fallbackCenter;
  }

  @override
  void initState() {
    super.initState();
    _manager = OfflineMapManager.create();
    _manager.addListener(_onManagerChanged);
    // Bắt đầu load ngay khi vào màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) => _manager.initialize());
  }

  @override
  void dispose() {
    _manager.removeListener(_onManagerChanged);
    _manager.dispose();
    super.dispose();
  }

  void _onManagerChanged() {
    if (mounted) setState(() {});
  }

  // ── MAP CONTROLLER CALLBACKS ──────────────────────────────────────────────

  void _onMapCreated(MapLibreMapController controller) {
    _mapController = controller;
  }

  void _onStyleLoaded() {
    // Style đã load → fit route nếu có
    if (_manager.isReady) {
      _fitRoute();
    }
  }

  // ── CONTROLS ──────────────────────────────────────────────────────────────

  void _zoomIn() => _mapController?.animateCamera(
        CameraUpdate.zoomIn(),
      );

  void _zoomOut() => _mapController?.animateCamera(
        CameraUpdate.zoomOut(),
      );

  void _fitRoute() => _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(
          _bounds,
          left: 24,
          top: 24,
          right: 24,
          bottom: 24,
        ),
      );

  void _goToCurrentLocation() {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_center, _defaultZoom),
    );
  }

  Future<void> _resetPackage() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset offline package?'),
        content: const Text(
          'Xóa toàn bộ package đã giải nén và tải lại từ asset.\n'
          'Thao tác này sẽ mất vài giây.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _manager.reset();
      await _manager.initialize();
    }
  }

  // ── BUILD ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          // ── MAP ──────────────────────────────────────────────────────────
          _buildMap(colorScheme),

          // ── TOP BAR ──────────────────────────────────────────────────────
          _buildTopBar(colorScheme),

          // ── STATUS PANEL (bên dưới top bar) ─────────────────────────────
          Positioned(
            top: kToolbarHeight + MediaQuery.of(context).padding.top + 8,
            left: 12,
            right: 12,
            child: _buildStatusPanel(colorScheme),
          ),

          // ── ZOOM + LOCATION CONTROLS (phải) ──────────────────────────────
          Positioned(
            right: 12,
            bottom: 160,
            child: _buildZoomControls(colorScheme),
          ),

          // ── TOGGLE PANEL (trái dưới) ──────────────────────────────────────
          Positioned(
            left: 12,
            bottom: 12,
            child: _buildTogglePanel(colorScheme),
          ),

          // ── BOTTOM ACTION BUTTONS (phải dưới) ────────────────────────────
          Positioned(
            right: 12,
            bottom: 12,
            child: _buildBottomActions(colorScheme),
          ),

          // ── LOADING OVERLAY ───────────────────────────────────────────────
          if (_manager.status == OfflineMapStatus.loading)
            _buildLoadingOverlay(colorScheme),

          // ── ERROR OVERLAY ─────────────────────────────────────────────────
          if (_manager.status == OfflineMapStatus.error)
            _buildErrorOverlay(colorScheme),
        ],
      ),
    );
  }

  // ── MAP WIDGET ────────────────────────────────────────────────────────────

  Widget _buildMap(ColorScheme cs) {
    final style = _manager.styleString;

    if (style == null) {
      // Style chưa sẵn sàng → map nền tối
      return Container(
        color: const Color(0xFF1a1a2e),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.map_outlined, size: 64, color: cs.onSurfaceVariant),
              const SizedBox(height: 12),
              Text(
                'Đang chuẩn bị bản đồ offline…',
                style: TextStyle(color: cs.onSurface, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return MapLibreMap(
      styleString: style,
      initialCameraPosition: CameraPosition(
        target: _center,
        zoom: _defaultZoom,
      ),
      onMapCreated: _onMapCreated,
      onStyleLoadedCallback: _onStyleLoaded,
      // Ẩn logo/attribution ra ngoài viewport để giữ UI gọn
      logoViewMargins: const Point(-100, -100),
      attributionButtonMargins: const Point(-100, -100),
      compassEnabled: true,
      myLocationEnabled: false, // GPS thật không cần trong prototype
      rotateGesturesEnabled: true,
      scrollGesturesEnabled: true,
      zoomGesturesEnabled: true,
      tiltGesturesEnabled: true,
    );
  }

  // ── TOP BAR ───────────────────────────────────────────────────────────────

  Widget _buildTopBar(ColorScheme cs) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          height: kToolbarHeight,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                cs.surface.withValues(alpha: 0.92),
                cs.surface.withValues(alpha: 0.0),
              ],
            ),
          ),
          child: Row(
            children: [
              _MapIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => Navigator.of(context).pop(),
                tooltip: 'Quay lại',
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bản đồ offline – Núi Bà Đen',
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '[TEST PROTOTYPE]',
                      style: TextStyle(
                        color: cs.primary.withValues(alpha: 0.8),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── STATUS PANEL ──────────────────────────────────────────────────────────

  Widget _buildStatusPanel(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatusRow(
            label: 'Package loaded',
            ok: _manager.packageLoaded,
            pending: _manager.status == OfflineMapStatus.loading,
          ),
          const SizedBox(height: 4),
          _StatusRow(
            label: 'SHA-256 verified',
            ok: _manager.shaVerified,
            pending: _manager.status == OfflineMapStatus.loading,
          ),
          const SizedBox(height: 4),
          _StatusRow(
            label: 'Tile server running',
            ok: _manager.tileServerRunning,
            pending: _manager.status == OfflineMapStatus.loading,
          ),
        ],
      ),
    );
  }

  // ── ZOOM CONTROLS ─────────────────────────────────────────────────────────

  Widget _buildZoomControls(ColorScheme cs) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _MapIconButton(
          icon: Icons.add_rounded,
          onTap: _zoomIn,
          tooltip: 'Zoom in',
        ),
        const SizedBox(height: 8),
        _MapIconButton(
          icon: Icons.remove_rounded,
          onTap: _zoomOut,
          tooltip: 'Zoom out',
        ),
        const SizedBox(height: 8),
        _MapIconButton(
          icon: Icons.my_location_rounded,
          onTap: _goToCurrentLocation,
          tooltip: 'Vị trí hiện tại',
        ),
        const SizedBox(height: 8),
        _MapIconButton(
          icon: Icons.fit_screen_rounded,
          onTap: _fitRoute,
          tooltip: 'Fit route',
        ),
      ],
    );
  }

  // ── TOGGLE PANEL ──────────────────────────────────────────────────────────

  Widget _buildTogglePanel(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ToggleRow(
            label: 'Hillshade',
            icon: Icons.terrain_rounded,
            value: _manager.showHillshade,
            onChanged: (_) => _manager.toggleHillshade(),
            enabled: _manager.isReady,
          ),
          _ToggleRow(
            label: 'Contours',
            icon: Icons.layers_rounded,
            value: _manager.showContours,
            onChanged: (_) => _manager.toggleContours(),
            enabled: _manager.isReady,
          ),
          _ToggleRow(
            label: 'Route',
            icon: Icons.route_rounded,
            value: _manager.showRoute,
            onChanged: (_) => _manager.toggleRoute(),
            enabled: _manager.isReady,
          ),
          _ToggleRow(
            label: 'Milestones',
            icon: Icons.place_rounded,
            value: _manager.showMilestones,
            onChanged: (_) => _manager.toggleMilestones(),
            enabled: _manager.isReady,
          ),
        ],
      ),
    );
  }

  // ── BOTTOM ACTIONS ────────────────────────────────────────────────────────

  Widget _buildBottomActions(ColorScheme cs) {
    return FloatingActionButton.small(
      heroTag: 'reset_pkg',
      onPressed: _manager.status == OfflineMapStatus.loading
          ? null
          : _resetPackage,
      backgroundColor: cs.surface,
      foregroundColor: cs.onSurface,
      tooltip: 'Reset offline package',
      child: const Icon(Icons.refresh_rounded, size: 20),
    );
  }

  // ── LOADING OVERLAY ───────────────────────────────────────────────────────

  Widget _buildLoadingOverlay(ColorScheme cs) {
    return Positioned.fill(
      child: Container(
        color: Colors.black54,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: cs.primary),
            const SizedBox(height: 16),
            const Text(
              'Đang khởi tạo bản đồ offline…',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 6),
            Text(
              'Giải nén package, verify SHA-256,\nkhởi động tile server',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── ERROR OVERLAY ─────────────────────────────────────────────────────────

  Widget _buildErrorOverlay(ColorScheme cs) {
    return Positioned.fill(
      child: Container(
        color: Colors.black87,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Colors.redAccent, size: 56),
            const SizedBox(height: 16),
            const Text(
              'Không thể load bản đồ offline',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _manager.errorMessage ?? 'Unknown error',
                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _manager.initialize,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED SMALL WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _MapIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  const _MapIconButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: cs.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            child: Icon(icon, size: 20, color: cs.onSurface),
          ),
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final bool ok;
  final bool pending;

  const _StatusRow({
    required this.label,
    required this.ok,
    this.pending = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final Color color;
    final IconData iconData;

    if (pending && !ok) {
      color = cs.onSurfaceVariant;
      iconData = Icons.hourglass_empty_rounded;
    } else if (ok) {
      color = const Color(0xFF2E7D32);
      iconData = Icons.check_circle_rounded;
    } else {
      color = Colors.redAccent;
      iconData = Icons.cancel_rounded;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(iconData, size: 14, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: cs.onSurface.withValues(alpha: 0.85),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  const _ToggleRow({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Opacity(
      opacity: enabled ? 1.0 : 0.45,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: cs.primary),
          const SizedBox(width: 6),
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: cs.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Transform.scale(
            scale: 0.75,
            child: Switch(
              value: value,
              onChanged: enabled ? onChanged : null,
              thumbColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? cs.primary
                    : cs.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
