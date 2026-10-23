import 'package:flutter_test/flutter_test.dart';
import 'package:vietnam_trekking_mobile/core/services/trekking_catalog_service.dart';
import 'package:vietnam_trekking_mobile/features/explore/viewmodel/explore_view_model.dart';

import 'frontend_api_integration_test.dart' show client;

void main() {
  test(
    'Explore defaults to all places and preserves search and partial results',
    () async {
      final requests = <Map<String, dynamic>>[];
      final service = TrekkingCatalogService(cacheEnabled: false, 
        client: client((r) {
          if (r.path == '/places') {
            requests.add(Map<String, dynamic>.from(r.queryParameters));
            return {
              'data': {
                'items': [
                  {
                    'trekkingPlaceId': 'p1',
                    'name': 'Server mountain',
                    'ratingAverage': 4.2,
                    'ratingCount': 7,
                  },
                ],
                'total': 1,
              },
            };
          }
          return {'_httpStatus': 503, 'message': 'Unavailable'};
        }),
      );
      final vm = ExploreViewModel(service: service, autoLoad: false);
      await vm.load();
      expect(vm.selectedFilter, ExploreFilter.all);
      expect(requests.single.containsKey('region'), isFalse);
      expect(vm.recommendedPlaces.single.id, 'p1');
      expect(vm.recommendedPlaces.single.rating, 4.2);
      expect(vm.error, isNull);
      expect(vm.routesError, isNotNull);
      vm.setSearchQuery('  mountain  ');
      await vm.load();
      expect(requests.last['q'], 'mountain');
      vm.dispose();
    },
  );

  test(
    'each visible filter sends its own region and popular keeps all places',
    () async {
      final requests = <Map<String, dynamic>>[];
      final service = TrekkingCatalogService(cacheEnabled: false, 
        client: client((r) {
          if (r.path == '/places') {
            requests.add(Map<String, dynamic>.from(r.queryParameters));
            return {
              'data': {
                'items': [
                  {
                    'trekkingPlaceId': 'unrated',
                    'name': 'New place',
                    'ratingAverage': 0,
                  },
                  {
                    'trekkingPlaceId': 'rated',
                    'name': 'Popular place',
                    'ratingAverage': 4.8,
                  },
                ],
                'total': 2,
              },
            };
          }
          return {'data': []};
        }),
      );
      final vm = ExploreViewModel(service: service, autoLoad: false);
      addTearDown(vm.dispose);
      const expected = {
        'Tất cả': null,
        'Phổ biến': null,
        'Miền Bắc': 'NORTH',
        'Miền Trung': 'CENTRAL',
        'Miền Nam': 'SOUTH',
      };
      expect(ExploreFilter.values.map((f) => f.label), expected.keys);
      await vm.load();
      for (final filter in ExploreFilter.values) {
        await vm.setRegion(filter.index);
        expect(
          requests.last['region'],
          expected[filter.label],
          reason: filter.label,
        );
        if (expected[filter.label] == null) {
          expect(requests.last.containsKey('region'), isFalse);
        }
        expect(vm.recommendedPlaces, hasLength(2));
        if (filter == ExploreFilter.popular) {
          expect(vm.recommendedPlaces.map((p) => p.id), ['rated', 'unrated']);
        }
      }
      await vm.setRegion(ExploreFilter.all.index);
      expect(requests.last.containsKey('region'), isFalse);
      expect(vm.recommendedPlaces, hasLength(2));
      expect(vm.error, isNull);
    },
  );

  test(
    'catalog follows pagination without replacing results with samples',
    () async {
      final service = TrekkingCatalogService(cacheEnabled: false, 
        client: client((r) {
          final page = r.queryParameters['page'];
          return {
            'data': {
              'items': [
                {'trekkingPlaceId': 'p$page'},
              ],
              'total': 2,
            },
          };
        }),
      );
      final places = await service.getPlaces();
      expect(places.map((p) => p['trekkingPlaceId']), ['p1', 'p2']);
    },
  );
}
