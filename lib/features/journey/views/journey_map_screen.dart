import 'dart:math' show Point;
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import '../data/models/journey_model.dart';
import '../data/models/milestone_model.dart';
import '../data/models/marker_model.dart';
import 'widgets/trekking_button.dart';
import 'marker_form_screen.dart';

/// Bản đồ hành trình đầy đủ với route, milestones, markers, user position.
class JourneyMapScreen extends StatefulWidget {
  final JourneyModel journey;
  final List<MilestoneModel> milestones;
  final List<MarkerModel> markers;
  final String routeId;

  const JourneyMapScreen({
    super.key,
    required this.journey,
    required this.milestones,
    required this.markers,
    required this.routeId,
  });

  @override
  State<JourneyMapScreen> createState() => _JourneyMapScreenState();
}

class _JourneyMapScreenState extends State<JourneyMapScreen> {
  MapLibreMapController? _mapController;
  bool _isFullScreen = false;

  // Default center (Vietnam center — will be overridden by route coords)
  LatLng get _center {
    if (widget.milestones.isNotEmpty) {
      final first = widget.milestones.first;
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
          Positioned(
            right: 12,
            top: kToolbarHeight + MediaQuery.of(context).padding.top + 12,
            child: _buildRightControls(cs),
          ),

          // ── Bottom info panel (Đánh dấu cột mốc CTA) ─────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomPanel(cs),
          ),
        ],
      ),
    );
  }

  Widget _buildMap(ColorScheme cs) {
    // Use a simple online style when offline map not available.
    const styleUrl =
        'https://demotiles.maplibre.org/style.json';

    return MapLibreMap(
      styleString: styleUrl,
      initialCameraPosition: CameraPosition(
        target: _center,
        zoom: 12.0,
      ),
      onMapCreated: (controller) {
        _mapController = controller;
        _addMapLayers();
      },
      myLocationEnabled: true,
      myLocationTrackingMode: MyLocationTrackingMode.tracking,
      compassEnabled: true,
      rotateGesturesEnabled: true,
      logoViewMargins: const Point(-100, -100),
      attributionButtonMargins: const Point(-100, -100),
    );
  }

  Future<void> _addMapLayers() async {
    if (_mapController == null) return;
    // Milestone circles
    for (final m in widget.milestones) {
      await _mapController!.addCircle(CircleOptions(
        geometry: LatLng(m.latitude, m.longitude),
        circleColor: m.isCheckedIn ? '#4CAF50' : '#E8620A',
        circleRadius: 8,
        circleStrokeWidth: 2,
        circleStrokeColor: '#ffffff',
      ));
    }
    // User markers
    for (final mk in widget.markers) {
      await _mapController!.addCircle(CircleOptions(
        geometry: LatLng(mk.latitude, mk.longitude),
        circleColor: '#9C27B0',
        circleRadius: 6,
        circleStrokeWidth: 1.5,
        circleStrokeColor: '#ffffff',
      ));
    }
  }

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
              colors: [
                Colors.black.withValues(alpha: 0.7),
                Colors.transparent,
              ],
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
                          fontWeight: FontWeight.w700),
                    ),
                    Text(
                      widget.journey.name,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
              _MapBtn(
                icon: _isFullScreen
                    ? Icons.fullscreen_exit
                    : Icons.fullscreen,
                label: _isFullScreen ? 'Thu nhỏ' : 'Toàn màn hình',
                onTap: () =>
                    setState(() => _isFullScreen = !_isFullScreen),
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
          onTap: () => _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(_center, 14),
          ),
        ),
        const SizedBox(height: 8),
        _MapBtn(
          icon: Icons.add,
          onTap: () => _mapController?.animateCamera(
            CameraUpdate.zoomIn(),
          ),
        ),
        const SizedBox(height: 8),
        _MapBtn(
          icon: Icons.remove,
          onTap: () => _mapController?.animateCamera(
            CameraUpdate.zoomOut(),
          ),
        ),
        const SizedBox(height: 8),
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
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
                Text(
                  widget.journey.name,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface),
                ),
                const Spacer(),
                Text(
                  '${widget.milestones.where((m) => m.isCheckedIn).length}/${widget.milestones.length} điểm',
                  style: TextStyle(
                      fontSize: 12, color: cs.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Share route note
            Row(
              children: [
                Icon(Icons.share_outlined,
                    size: 14, color: cs.onSurfaceVariant),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Chia sẻ route + cột mốc cho admin',
                    style: TextStyle(
                        fontSize: 11, color: cs.onSurfaceVariant),
                  ),
                ),
                Icon(Icons.chevron_right,
                    size: 16, color: cs.onSurfaceVariant),
              ],
            ),
            const SizedBox(height: 12),
            // Main CTA
            TrekkingPrimaryButton(
              label: '📍  Đánh dấu cột mốc',
              onPressed: _openMarkerForm,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _openMarkerForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MarkerFormScreen(
        localJourneyId: widget.journey.journeyId,
        userId: widget.journey.userId,
        // Pass current GPS location — placeholder
        initialLat: _center.latitude,
        initialLng: _center.longitude,
        onMarkerSaved: (marker) {
          setState(() {
            // Refresh markers — in prod would update vm
          });
        },
      ),
    );
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
          child: Icon(icon,
              size: 20, color: color ?? cs.onSurface),
        ),
      ),
    );
    if (label == null) return btn;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        btn,
        const SizedBox(height: 2),
        Text(label!,
            style: const TextStyle(
                color: Colors.white70, fontSize: 9)),
      ],
    );
  }
}
