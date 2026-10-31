import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:vietnam_trekking_mobile/core/models/catalog_page.dart';
import 'package:vietnam_trekking_mobile/core/services/trekking_catalog_service.dart';
import 'package:vietnam_trekking_mobile/features/explore/viewmodel/explore_view_model.dart';

import 'frontend_api_integration_test.dart' show client;

class _DelayedCatalog extends TrekkingCatalogService {
  final north = Completer<CatalogPage>();
  _DelayedCatalog() : super(cacheEnabled: false);
  @override
  Future<CatalogPage> getCatalogPage(
    String path, {
    String? query,
    String? region,
    String? sort,
    int page = 1,
    int limit = 20,
  }) async {
    if (path == '/places' && region == 'NORTH') return north.future;
    return CatalogPage(
      items: path == '/places'
          ? [
              {'trekkingPlaceId': region},
            ]
          : [],
      page: page,
      limit: limit,
      total: 1,
      hasMore: false,
    );
  }
}

Map<String, dynamic> page(
  List<Map<String, dynamic>> items, {
  int number = 1,
  int limit = 20,
  int? total,
}) => {
  'data': {
    'items': items,
    'total': total ?? items.length,
    'page': number,
    'limit': limit,
    'hasMore': number * limit < (total ?? items.length),
  },
};

void main() {
  test(
    'late response from a previous filter cannot replace the current filter',
    () async {
      final service = _DelayedCatalog();
      final vm = ExploreViewModel(service: service, autoLoad: false);
      addTearDown(vm.dispose);
      final oldLoad = vm.setRegion(ExploreFilter.north.index);
      await vm.setRegion(ExploreFilter.south.index);
      service.north.complete(
        const CatalogPage(
          items: [
            {'trekkingPlaceId': 'NORTH'},
          ],
          page: 1,
          limit: 20,
          total: 1,
          hasMore: false,
        ),
      );
      await oldLoad;
      expect(vm.recommendedPlaces.single.id, 'SOUTH');
      expect(vm.selectedFilter, ExploreFilter.south);
      expect(vm.isLoading, false);
    },
  );

  test(
    'route pagination appends once even if load-more is triggered twice',
    () async {
      var secondPageCalls = 0;
      final service = TrekkingCatalogService(
        cacheEnabled: false,
        client: client((r) {
          if (r.path == '/places') return page([]);
          final number = r.queryParameters['page'] as int;
          if (number == 2) secondPageCalls++;
          return page(
            [
              {'trekkingRouteId': 'r$number'},
            ],
            number: number,
            limit: 10,
            total: number == 1 ? 11 : 2,
          );
        }),
      );
      final vm = ExploreViewModel(service: service, autoLoad: false);
      addTearDown(vm.dispose);
      await vm.load();
      await Future.wait([vm.loadMoreTrails(), vm.loadMoreTrails()]);
      expect(vm.popularTrails.map((r) => r.id), ['r1', 'r2']);
      expect(secondPageCalls, 1);
      expect(vm.hasMoreTrails, false);
    },
  );

  test('Explore requests two independent bounded summary pages, no per-place routes', () async {
    final calls = <String>[];
    final service = TrekkingCatalogService(
      cacheEnabled: false,
      client: client((r) {
        calls.add(r.path);
        expect(r.queryParameters['summary'], 'true');
        expect(r.queryParameters.containsKey('includeRoutes'), false);
        if (r.path == '/places') {
          expect(r.queryParameters['limit'], 20);
          return page([
            {'trekkingPlaceId': 'p', 'name': 'Mountain'},
          ], total: 100);
        }
        expect(r.path, '/routes');
        expect(r.queryParameters['limit'], 10);
        return page([
          {'trekkingRouteId': 'r', 'name': 'Trail'},
        ], limit: 10);
      }),
    );
    final vm = ExploreViewModel(service: service, autoLoad: false);
    addTearDown(vm.dispose);
    await vm.load();
    expect(calls, ['/places', '/routes']);
    expect(vm.recommendedPlaces.single.id, 'p');
    expect(vm.popularTrails.single.id, 'r');
    expect(vm.hasMorePlaces, true);
    expect(vm.error, isNull);
  });

  test(
    'each filter is sent to backend; returning to a fresh filter reuses RAM',
    () async {
      final requests = <Map<String, dynamic>>[];
      final service = TrekkingCatalogService(
        cacheEnabled: false,
        client: client((r) {
          if (r.path == '/routes') return page([], limit: 10);
          requests.add(Map<String, dynamic>.from(r.queryParameters));
          return page([
            {'trekkingPlaceId': r.queryParameters['region'] ?? 'all'},
          ]);
        }),
      );
      final vm = ExploreViewModel(service: service, autoLoad: false);
      addTearDown(vm.dispose);
      await vm.load();
      for (final filter in ExploreFilter.values.skip(1)) {
        await vm.setRegion(filter.index);
        expect(requests.last['region'], filter.region);
        expect(
          requests.last['sort'],
          filter == ExploreFilter.popular ? 'popular' : null,
        );
      }
      expect(requests.length, 5);
      await vm.setRegion(ExploreFilter.north.index);
      expect(vm.recommendedPlaces.single.id, 'NORTH');
      expect(requests.length, 5);
      await vm.refresh();
      expect(requests.length, 6);
    },
  );

  test(
    'next page appends unique cards and route failures preserve places',
    () async {
      final service = TrekkingCatalogService(
        cacheEnabled: false,
        client: client((r) {
          if (r.path == '/routes') return {'_httpStatus': 503};
          final number = r.queryParameters['page'] as int;
          return page(
            [
              {'trekkingPlaceId': number == 1 ? 'p1' : 'p2'},
            ],
            number: number,
            total: number == 1 ? 21 : 2,
          );
        }),
      );
      final vm = ExploreViewModel(service: service, autoLoad: false);
      addTearDown(vm.dispose);
      await vm.load();
      expect(vm.routesError, isNotNull);
      expect(vm.recommendedPlaces.single.id, 'p1');
      await vm.loadMorePlaces();
      expect(vm.recommendedPlaces.map((p) => p.id), ['p1', 'p2']);
      expect(vm.hasMorePlaces, false);
      expect(vm.error, isNull);
    },
  );

  test('places can fail while routes remain visible', () async {
    final vm = ExploreViewModel(
      autoLoad: false,
      service: TrekkingCatalogService(
        cacheEnabled: false,
        client: client(
          (r) => r.path == '/places'
              ? {'_httpStatus': 429}
              : page([
                  {'trekkingRouteId': 'r'},
                ], limit: 10),
        ),
      ),
    );
    addTearDown(vm.dispose);
    await vm.load();
    expect(vm.error, contains('Quá nhiều yêu cầu'));
    expect(vm.popularTrails.single.id, 'r');
    expect(vm.isLoading, false);
  });

  testWidgets(
    'manual load cancels search debounce and preserves current region',
    (tester) async {
      var calls = 0;
      final vm = ExploreViewModel(
        autoLoad: false,
        service: TrekkingCatalogService(
          cacheEnabled: false,
          client: client((r) {
            calls++;
            expect(r.queryParameters['q'], 'mountain');
            return page([]);
          }),
        ),
      );
      vm.setSearchQuery(' mountain ');
      await tester.runAsync(vm.load);
      await tester.pump(const Duration(seconds: 1));
      expect(calls, 2);
      vm.dispose();
    },
  );

  test('legacy catalog callers still follow pagination', () async {
    final service = TrekkingCatalogService(
      cacheEnabled: false,
      client: client(
        (r) => {
          'data': {
            'items': [
              {'trekkingPlaceId': 'p${r.queryParameters['page']}'},
            ],
            'total': 2,
          },
        },
      ),
    );
    expect((await service.getPlaces()).map((p) => p['trekkingPlaceId']), [
      'p1',
      'p2',
    ]);
  });
}
