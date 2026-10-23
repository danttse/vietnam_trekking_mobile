import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:vietnam_trekking_mobile/features/offline_map/utils/entity_map_style.dart';
import 'package:vietnam_trekking_mobile/features/route/data/models/route_model.dart';
import 'package:vietnam_trekking_mobile/features/journey/data/models/route_model.dart'
    as legacy;

void main() {
  final base = jsonEncode({
    'version': 8,
    'sources': {
      'terrain': {
        'type': 'vector',
        'tiles': ['http://127.0.0.1:9999/base/{z}/{x}/{y}'],
      },
      'routes': {
        'type': 'geojson',
        'data': {'type': 'FeatureCollection', 'features': []},
      },
      'milestones': {
        'type': 'geojson',
        'data': {'type': 'FeatureCollection', 'features': []},
      },
    },
    'layers': [
      {'id': 'terrain', 'type': 'fill', 'source': 'terrain'},
      {'id': 'old-route', 'type': 'line', 'source': 'routes'},
      {'id': 'old-milestones', 'type': 'circle', 'source': 'milestones'},
    ],
  });
  RouteModel route(List<List<double>> path) => RouteModel.fromJson({
    'trekkingRouteId': 'r',
    'trekkingPlaceId': 'p',
    'path': {'type': 'LineString', 'coordinates': path},
  });
  test(
    'place preview preserves local tile sources and removes all bundled routes',
    () {
      final style = jsonDecode(entityMapStyle(base)) as Map;
      expect((style['sources'] as Map).keys, ['terrain']);
      expect((style['layers'] as List).map((l) => l['id']), ['terrain']);
      expect((jsonDecode(base)['sources'] as Map).keys, [
        'terrain',
        'routes',
        'milestones',
      ]);
    },
  );
  test('different routes use the same offline tiles with only their own path and endpoints', () {
    final first = jsonDecode(
      entityMapStyle(
        base,
        route: route([
          [106.16, 11.38],
          [106.17, 11.39],
        ]),
      ),
    );
    final second = jsonDecode(
      entityMapStyle(
        base,
        route: route([
          [106.18, 11.36],
          [106.19, 11.37],
        ]),
      ),
    );
    expect(first['sources']['terrain'], second['sources']['terrain']);
    expect(
      second['sources']['selected-route']['data']['geometry']['coordinates'],
      [
        [106.18, 11.36],
        [106.19, 11.37],
      ],
    );
    expect(
      second['sources']['selected-points']['data']['features'][1]['geometry']['coordinates'],
      [106.19, 11.37],
    );
    expect(second['sources']['routes'], isNull);
  });
  test(
    'route without a photo does not inherit place photo or its old map image',
    () {
      final parsed = RouteModel.fromJson(
        {'trekkingRouteId': 'r'},
        place: {
          'images': ['https://cdn.example/place.jpg'],
          'imageMapUrl': 'https://cdn.example/map.jpg',
        },
      );
      expect(parsed.imageUrl, isNull);
      expect(parsed.mapImageUrl, isNull);
    },
  );
  test(
    'legacy route screen preserves GeoJSON path, metadata, and its own photo',
    () {
      final parsed = legacy.RouteModel.fromJson({
        'trekkingRouteId': 'r',
        'trekkingPlaceId': 'p',
        'description': 'Đường lên đỉnh',
        'difficulty': 'MODERATE',
        'imageUrl': 'https://cdn.example/route.jpg',
        'path': {
          'type': 'LineString',
          'coordinates': [
            [106.16, 11.38],
            [106.17, 11.39],
          ],
        },
      });
      expect(parsed.catalogRoute.startPoint.latitude, 11.38);
      expect(parsed.catalogRoute.endPoint.longitude, 106.17);
      expect(parsed.catalogRoute.path.length, 2);
      expect(parsed.catalogRoute.imageUrl, 'https://cdn.example/route.jpg');
      expect(parsed.difficultyLabel, 'Trung bình');
      final cached = legacy.RouteModel.fromJson({
        'id': 'r',
        'startLatitude': 11.38,
        'startLongitude': 106.16,
      });
      expect(cached.startLatitude, 11.38);
      expect(cached.startLongitude, 106.16);
    },
  );
}
