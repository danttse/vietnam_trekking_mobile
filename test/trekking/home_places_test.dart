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
