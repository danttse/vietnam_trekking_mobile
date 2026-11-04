import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vietnam_trekking_mobile/core/services/trekking_catalog_service.dart';
import 'package:vietnam_trekking_mobile/core/widgets/carousels/paged_carousel.dart';
import 'package:vietnam_trekking_mobile/features/explore/viewmodel/explore_view_model.dart';
import 'package:vietnam_trekking_mobile/features/explore/views/explore_screen.dart';
import 'package:vietnam_trekking_mobile/l10n/app_localizations.dart';

import 'frontend_api_integration_test.dart' show client;

void main() {
  testWidgets(
    'load-more tile stays at the horizontal tail and loads only when tapped',
    (tester) async {
      var moreRequests = 0;
      final vm = ExploreViewModel(
        autoLoad: false,
        service: TrekkingCatalogService(
          cacheEnabled: false,
          client: client((r) {
            final routes = r.path == '/routes';
            final page = r.queryParameters['page'] as int;
            if (routes && page == 2) moreRequests++;
            return {
              'data': {
                'items': routes
                    ? List.generate(
                        page == 1 ? 10 : 1,
                        (i) => {
                          'trekkingRouteId': 'r$page-$i',
                          'name': 'Trail $page-$i',
                        },
                      )
                    : [],
                'page': page,
                'limit': routes ? 10 : 20,
                'total': routes ? 11 : 0,
                'hasMore': routes && page == 1,
              },
            };
          }),
        ),
      );
      addTearDown(vm.dispose);
      await tester.runAsync(vm.load);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('vi'),
          home: Scaffold(body: ExploreScreen(viewModel: vm)),
        ),
      );
      await tester.pump();
      expect(find.text('Thêm cung đường').hitTestable(), findsNothing);
      expect(moreRequests, 0);
      final horizontal = find.byKey(const ValueKey('popular-trails-list'));
      final scrollable = find.descendant(
        of: horizontal,
        matching: find.byType(Scrollable),
      );
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('more-trails-tile')),
        350,
        scrollable: scrollable,
      );
      await tester.pumpAndSettle();
      expect(find.text('Thêm cung đường').hitTestable(), findsOneWidget);
      expect(
        find.ancestor(of: find.text('Thêm cung đường'), matching: horizontal),
        findsOneWidget,
      );
      expect(moreRequests, 0);
      await tester.tap(find.text('Thêm cung đường'));
      await tester.pumpAndSettle();
      expect(moreRequests, 1);
      expect(vm.popularTrails.length, 11);
      expect(find.text('Thêm cung đường'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'featured places use a three-second carousel and remain tappable',
    (tester) async {
      String? opened;
      final vm = ExploreViewModel(
        autoLoad: false,
        service: TrekkingCatalogService(
          cacheEnabled: false,
          client: client(
            (r) => {
              'data': {
                'items': r.path == '/places'
                    ? List.generate(
                        3,
                        (i) => {'trekkingPlaceId': 'p$i', 'name': 'Place $i'},
                      )
                    : [],
                'page': 1,
                'limit': 20,
                'total': 3,
                'hasMore': false,
              },
            },
          ),
        ),
      );
      addTearDown(vm.dispose);
      await tester.runAsync(vm.load);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ExploreScreen(
              viewModel: vm,
              onPlaceTap: (place) => opened = place.id,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 3));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 450));
      final pager = find.descendant(
        of: find.byType(PagedCarousel),
        matching: find.byType(PageView),
      );
      expect(tester.widget<PageView>(pager).controller!.page, 1);
      await tester.tap(
        find.descendant(of: pager, matching: find.text('Place 1')),
      );
      expect(opened, 'p1');
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('Explore paginated cards and controls fit a narrow screen', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final vm = ExploreViewModel(
      autoLoad: false,
      service: TrekkingCatalogService(
        cacheEnabled: false,
        client: client(
          (r) => {
            'data': {
              'items': [
                r.path == '/places'
                    ? {'trekkingPlaceId': 'p', 'name': 'Fansipan'}
                    : {'trekkingRouteId': 'r', 'name': 'Cung đường Fansipan'},
              ],
              'page': 1,
              'limit': r.queryParameters['limit'],
              'total': 100,
              'hasMore': true,
            },
          },
        ),
      ),
    );
    addTearDown(vm.dispose);
    await tester.runAsync(vm.load);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('vi'),
        home: Scaffold(body: ExploreScreen(viewModel: vm)),
      ),
    );
    await tester.pump();
    expect(find.text('Thêm địa điểm'), findsOneWidget);
    expect(find.text('Thêm cung đường'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
