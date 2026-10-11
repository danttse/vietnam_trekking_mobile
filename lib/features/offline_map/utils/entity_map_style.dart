import 'dart:convert';

import '../../route/data/models/route_model.dart';

/// The downloaded place style supplies terrain/tiles; route metadata supplies
/// the selected path. Bundled route overlays must not leak into other routes.
String entityMapStyle(
  String baseStyle, {
  RouteModel? route,
  GeoPoint? location,
  String routeColor = '#e8620a',
}) {
  final style = jsonDecode(baseStyle) as Map<String, dynamic>;
  final sources = Map<String, dynamic>.from(style['sources'] as Map);
  final removed = sources.keys
      .where(
        (id) =>
            id.startsWith('selected-') ||
            sources[id]['type'] == 'geojson' &&
                (id.toLowerCase().contains('route') ||
                    id.toLowerCase().contains('milestone')),
      )
      .toSet();
  sources.removeWhere((id, _) => removed.contains(id));
  final layers = (style['layers'] as List)
      .where((layer) => !removed.contains(layer['source']))
      .toList();
  final points = route?.path ?? const <GeoPoint>[];
  if (points.length >= 2) {
    sources['selected-route'] = {
      'type': 'geojson',
      'data': {
        'type': 'Feature',
        'properties': <String, dynamic>{},
        'geometry': {
          'type': 'LineString',
          'coordinates': points.map((p) => [p.longitude, p.latitude]).toList(),
        },
      },
    };
    layers.add({
      'id': 'selected-route-line',
      'type': 'line',
      'source': 'selected-route',
      'layout': {'line-cap': 'round', 'line-join': 'round'},
      'paint': {'line-color': routeColor, 'line-width': 4},
    });
  }
  final markers = <Map<String, dynamic>>[];
  void marker(GeoPoint? point, String kind) {
    if (point == null || point.latitude == 0 && point.longitude == 0) return;
    markers.add({
      'type': 'Feature',
      'properties': {'kind': kind},
      'geometry': {
        'type': 'Point',
        'coordinates': [point.longitude, point.latitude],
      },
    });
  }

  marker(location, 'place');
  if (route != null) {
    marker(points.isEmpty ? route.startPoint : points.first, 'start');
    marker(points.isEmpty ? route.endPoint : points.last, 'end');
  }
  if (markers.isNotEmpty) {
    sources['selected-points'] = {
      'type': 'geojson',
      'data': {'type': 'FeatureCollection', 'features': markers},
    };
    layers.add({
      'id': 'selected-point-circles',
      'type': 'circle',
      'source': 'selected-points',
      'paint': {
        'circle-radius': 6,
        'circle-color': [
          'match',
          ['get', 'kind'],
          'end',
          '#ef4444',
          '#16a34a',
        ],
        'circle-stroke-color': '#ffffff',
        'circle-stroke-width': 2,
      },
    });
  }
  return jsonEncode({...style, 'sources': sources, 'layers': layers});
}
