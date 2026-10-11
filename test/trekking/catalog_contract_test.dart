import 'package:flutter_test/flutter_test.dart';
import 'package:vietnam_trekking_mobile/core/services/trekking_catalog_service.dart';
import 'package:vietnam_trekking_mobile/features/route/data/models/route_model.dart';

void main() {
  test('maps backend route IDs, GeoJSON longitude/latitude, duration and expert difficulty', () {
    final route = TrekkingCatalogService.parseRoute(
      {
        'trekkingRouteId': 'route-42',
        'trekkingPlaceId': 'place-7',
        'name': 'Summit route',
        'difficulty': 'EXPERT',
        'distanceMeters': 12500.5,
        'estimatedDurationMinutes': 150,
        'elevationGain': 1100.5,
        'maxElevation': 2167.5,
        'imageUrl': 'https://example.com/route.jpg',
        'startLocation': {
          'coordinates': [108.4, 12.0],
        },
        'endLocation': {
          'coordinates': [108.5, 12.1],
        },
        'offlineMap': {'version': 3},
      },
      {
        'address': 'Lam Dong',
        'images': ['https://example.com/place.jpg'],
        'imageMapUrl': 'https://example.com/place-map.jpg',
      },
    );
    expect(route.routeId, 'route-42');
    expect(route.trekkingPlaceId, 'place-7');
    expect(route.startPoint.latitude, 12.0);
    expect(route.startPoint.longitude, 108.4);
    expect(route.endPoint.latitude, 12.1);
    expect(route.estimatedDuration.inMinutes, 150);
    expect(route.difficulty, RouteDifficulty.extreme);
    expect(route.distanceKm, 12.5005);
    expect(route.mapVersion, 3);
    expect(route.imageUrl, 'https://example.com/route.jpg');
    expect(route.mapImageUrl, 'https://example.com/route.jpg');
  });
}
