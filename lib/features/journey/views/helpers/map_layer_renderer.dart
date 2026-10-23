import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../../data/models/milestone_model.dart';
import '../../data/models/marker_model.dart';
import '../../../route/data/models/route_model.dart';
import '../../../../core/database/models/track_point.dart';

/// Helper chuyên biệt quản lý và kết xuất các lớp đồ họa trên MapLibreMapController
class MapLayerRenderer {
  MapLibreMapController? controller;
  Line? _trackLine;
  Circle? _trackStart;
  bool _drawingTrack = false;
  bool _trackDirty = false;

  void setController(MapLibreMapController mapController) {
    controller = mapController;
  }

  void resetTrack() {
    _trackLine = null;
    _trackStart = null;
  }

  Future<void> clearAll() async {
    await controller?.clearCircles();
    _trackStart = null;
    _trackLine = null;
    await controller?.clearSymbols();
  }

  Future<void> addMapLayers({
    required List<MilestoneModel> milestones,
    required List<MarkerModel> markers,
    required bool Function() isMounted,
  }) async {
    final c = controller;
    if (c == null || !isMounted()) return;

    await c.setSymbolTextAllowOverlap(true);
    await c.setSymbolTextIgnorePlacement(true);

    for (final m in milestones) {
      if (!isMounted()) return;
      await c.addCircle(
        CircleOptions(
          geometry: LatLng(m.latitude, m.longitude),
          circleColor: m.isCheckedIn ? '#4CAF50' : '#E8620A',
          circleRadius: 8,
          circleStrokeWidth: 2,
          circleStrokeColor: '#ffffff',
        ),
        {'milestoneId': m.id},
      );
      await c.addSymbol(
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

    for (final mk in markers) {
      if (!isMounted()) return;
      await addMarker(mk, isMounted: isMounted);
    }
  }

  Future<void> addMarker(
    MarkerModel marker, {
    required bool Function() isMounted,
  }) async {
    final c = controller;
    if (c == null || !isMounted()) return;

    await c.addCircle(
      CircleOptions(
        geometry: LatLng(marker.latitude, marker.longitude),
        circleColor: '#3B82F6',
        circleRadius: 7,
        circleStrokeColor: '#ffffff',
        circleStrokeWidth: 2,
      ),
      {'markerId': marker.markerId},
    );
    if (!isMounted()) return;
    await c.addSymbol(
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

  Future<void> drawTrack({
    required List<TrackPoint> points,
    required bool backtracking,
    required bool styleReady,
    required bool trackReady,
    required bool Function() isMounted,
  }) async {
    if (_drawingTrack) {
      _trackDirty = true;
      return;
    }
    final c = controller;
    if (c == null || !styleReady || !trackReady || !isMounted()) return;
    _drawingTrack = true;
    try {
      do {
        _trackDirty = false;
        if (points.isEmpty) return;
        if (_trackStart == null) {
          _trackStart = await c.addCircle(
            CircleOptions(
              geometry: LatLng(points.first.latitude, points.first.longitude),
              circleColor: '#16A34A',
              circleRadius: 8,
              circleStrokeColor: '#FFFFFF',
              circleStrokeWidth: 3,
            ),
          );
          await c.addSymbol(
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
        final ordered = backtracking ? points.reversed : points;
        final options = LineOptions(
          geometry: ordered
              .map((p) => LatLng(p.latitude, p.longitude))
              .toList(),
          lineColor: backtracking ? '#F59E0B' : '#16A34A',
          lineWidth: 5,
          lineOpacity: 0.9,
        );
        if (_trackLine == null) {
          _trackLine = await c.addLine(options);
        } else {
          await c.updateLine(_trackLine!, options);
        }
      } while (_trackDirty && isMounted() && styleReady);
    } catch (e) {
      debugPrint('[Backtrack] render: $e');
    } finally {
      _drawingTrack = false;
    }
  }

  Future<void> fitRoute({
    required List<GeoPoint> pathPoints,
    required List<MilestoneModel> milestones,
    required List<MarkerModel> markers,
    required List<TrackPoint> trackPoints,
    required bool trackReady,
    required bool backtracking,
  }) async {
    final c = controller;
    if (c == null) return;

    final locations = <LatLng>[
      if (trackReady)
        ...trackPoints.map((p) => LatLng(p.latitude, p.longitude)),
      if (!backtracking) ...[
        ...pathPoints.map((p) => LatLng(p.latitude, p.longitude)),
        ...milestones.map((m) => LatLng(m.latitude, m.longitude)),
        ...markers.map((m) => LatLng(m.latitude, m.longitude)),
      ],
    ];
    if (locations.isEmpty) return;
    if (locations.length == 1) {
      await c.animateCamera(
        CameraUpdate.newLatLngZoom(locations.first, 14),
      );
      return;
    }
    final south = locations.map((p) => p.latitude).reduce(math.min);
    final north = locations.map((p) => p.latitude).reduce(math.max);
    final west = locations.map((p) => p.longitude).reduce(math.min);
    final east = locations.map((p) => p.longitude).reduce(math.max);
    await c.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(south, west),
          northeast: LatLng(north, east),
        ),
        left: 90,
        right: 110,
        top: 100,
        bottom: 100,
      ),
    );
  }
}
