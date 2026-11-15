import 'package:flutter_test/flutter_test.dart';
import 'package:vietnam_trekking_mobile/core/services/user_api_service.dart';
import 'package:vietnam_trekking_mobile/core/services/trekking_catalog_service.dart';
import 'package:vietnam_trekking_mobile/features/home/repository/province_visit_repository.dart';
import 'package:vietnam_trekking_mobile/features/home/viewmodel/home_view_model.dart';

import 'frontend_api_integration_test.dart' show client;

class _UnusedRepository implements ProvinceVisitRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  HomeViewModel createHome({
    required Map<String, dynamic> Function() visits,
    required Map<String, dynamic> Function(String, Map<String, dynamic>)
    catalog,
  }) {
    final vm = HomeViewModel(
      repository: _UnusedRepository(),
      userApi: UserApiService(
        cacheEnabled: false,
        checkinClient: client((_) => visits()),
      ),
      catalog: TrekkingCatalogService(
        cacheEnabled: false,
        client: client((r) => catalog(r.path, r.queryParameters)),
      ),
      autoLoad: false,
    );
    addTearDown(vm.dispose);
    return vm;
  }

  Map<String, dynamic> recommendations() => {
    'data': {
      'items': [
        {'trekkingPlaceId': 'suggested', 'name': 'Fansipan'},
      ],
      'total': 1,
    },
  };

  for (final status in [404, 429, 503]) {
    test(
      'history HTTP $status does not block public recommendations',
      () async {
        var calls = 0;
        final vm = createHome(
          visits: () => {'_httpStatus': status},
          catalog: (path, query) {
            calls++;
            expect(path, '/places');
            expect(query['limit'], 10);
            return recommendations();
          },
        );
        await vm.loadPlaces();
        expect(vm.displayedPlaces.single.placeId, 'suggested');
        expect(vm.placesError, isNull);
        expect(vm.isLoadingPlaces, isFalse);
        expect(calls, 1);
      },
    );
  }

  test('one removed place does not hide other recent places', () async {
    final calls = <String>[];
    final vm = createHome(
      visits: () => {
        'data': [
          {'trekkingPlaceId': 'removed'},
          {'trekkingPlaceId': 'valid', 'lastVisitedAt': '2026-10-11T08:00:00Z'},
          {'trekkingPlaceId': 'valid'},
          {'trekkingPlaceId': null},
        ],
      },
      catalog: (path, _) {
        calls.add(path);
        return path == '/places/removed'
            ? {'_httpStatus': 404}
            : {
                'data': {'trekkingPlaceId': 'valid', 'name': 'Valid place'},
              };
      },
    );
    await vm.loadPlaces();
    expect(vm.recentPlaces.single.placeId, 'valid');
    expect(vm.recentPlaces.single.lastVisited, '11/10');
    expect(vm.placesError, isNull);
    expect(calls, ['/places/removed', '/places/valid']);
  });

  test('all removed places fall back to recommendations', () async {
    final vm = createHome(
      visits: () => {
        'data': [
          {'trekkingPlaceId': 'removed'},
        ],
      },
      catalog: (path, _) =>
          path == '/places' ? recommendations() : {'_httpStatus': 404},
    );
    await vm.loadPlaces();
    expect(vm.recentPlaces, isEmpty);
    expect(vm.explorePlaces.single.placeId, 'suggested');
    expect(vm.placesError, isNull);
  });

  test('catalog failure exposes HTTP error and retry recovers', () async {
    var failing = true;
    final vm = createHome(
      visits: () => {'data': []},
      catalog: (_, _) => failing ? {'_httpStatus': 429} : recommendations(),
    );
    await vm.loadPlaces();
    expect(vm.placesError, contains('Quá nhiều yêu cầu'));
    expect(vm.isLoadingPlaces, isFalse);
    failing = false;
    await vm.loadPlaces();
    expect(vm.placesError, isNull);
    expect(vm.displayedPlaces.single.placeId, 'suggested');
  });

  for (final status in [401, 403]) {
    test('history auth HTTP $status is not silently hidden', () async {
      final vm = createHome(
        visits: () => {'_httpStatus': status},
        catalog: (_, _) => throw StateError('Catalog must not be called'),
      );
      await vm.loadPlaces();
      expect(vm.displayedPlaces, isEmpty);
      expect(vm.placesError, isNotNull);
    });
  }

  test(
    'Home only fetches ten suggestions instead of the whole catalog',
    () async {
      var calls = 0;
      final vm = createHome(
        visits: () => {'data': []},
        catalog: (_, query) {
          calls++;
          expect(query['limit'], 10);
          return {
            'data': {
              'items': List.generate(
                10,
                (i) => {'trekkingPlaceId': 'p$i', 'name': 'Place $i'},
              ),
              'total': 150,
            },
          };
        },
      );
      await vm.loadPlaces();
      expect(calls, 1);
      expect(vm.displayedPlaces, hasLength(10));
      expect(vm.placesError, isNull);
    },
  );

  for (final empty in [null, <dynamic>[]]) {
    test(
      'Home replaces $empty recent visits and switches back after check-in',
      () async {
        dynamic visits = empty;
        var catalogCalls = 0;
        final api = UserApiService(
          cacheEnabled: false,
          checkinClient: client((_) => {'data': visits}),
          trekkingClient: client((_) => {'_httpStatus': 503}),
        );
        final place = {
          'trekkingPlaceId': 'p1',
          'name': 'Fansipan',
          'images': ['https://example.com/fansipan.jpg'],
        };
        final catalog = TrekkingCatalogService(
          cacheEnabled: false,
          client: client((r) {
            if (r.path == '/places') {
              catalogCalls++;
              return {
                'data': {
                  'items': [place],
                  'total': 1,
                },
              };
            }
            return {'data': place};
          }),
        );
        final vm = HomeViewModel(
          repository: _UnusedRepository(),
          userApi: api,
          catalog: catalog,
          autoLoad: false,
        );
        addTearDown(vm.dispose);
        await vm.loadActivity();
        expect(vm.activityError, isNotNull);
        expect(vm.placesError, isNull);
        expect(vm.recentPlaces, isEmpty);
        expect(vm.displayedPlaces.single.name, 'Fansipan');
        expect(vm.displayedPlaces.single.imageUrl, endsWith('fansipan.jpg'));

        visits = [
          {'trekkingPlaceId': 'p1', 'lastVisitedAt': '2026-10-11T08:00:00Z'},
        ];
        await vm.loadPlaces();
        expect(vm.recentPlaces, hasLength(1));
        expect(vm.displayedPlaces.single.lastVisited, '11/10');
        expect(vm.explorePlaces, isEmpty);
        expect(catalogCalls, 1);
      },
    );
  }
}
