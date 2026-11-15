import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vietnam_trekking_mobile/core/services/trekking_catalog_service.dart';
import 'package:vietnam_trekking_mobile/core/widgets/sheet/select_route_sheet.dart';
import 'package:vietnam_trekking_mobile/features/journey/viewmodels/create_new_journey_viewmodel.dart';
import 'package:vietnam_trekking_mobile/features/route/data/models/route_model.dart';
import 'package:vietnam_trekking_mobile/l10n/app_localizations.dart';

class PickerCatalog extends TrekkingCatalogService {
  final calls = <String>[];
  final places = [
    {'trekkingPlaceId': 'a', 'name': 'Bà Đen'},
    {'trekkingPlaceId': 'b', 'name': 'Chứa Chan'},
  ];
  @override
  Future<List<Map<String, dynamic>>> getPlaces({
    bool includeRoutes = false,
    int? maxItems,
    String? query,
    String? region,
    String? sort,
  }) async => places;
  @override
  Future<List<RouteModel>> getRoutes(
    String placeId, {
    Map<String, dynamic>? place,
  }) async {
    calls.add(placeId);
    return [
      RouteModel.fromJson({
        'trekkingRouteId': 'route-$placeId',
        'trekkingPlaceId': placeId,
        'name': placeId == 'a' ? 'Đường Cột' : 'Đường Chùa',
        'difficulty': 'EASY',
      }),
    ];
  }
}

void main() {
  testWidgets(
    'place list opens first; only the clicked place fetches and shows routes',
    (tester) async {
      final catalog = PickerCatalog();
      RouteModel? selected;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('vi'),
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => SelectRouteSheet(
                      routes: const [],
                      places: catalog.places,
                      catalog: catalog,
                      onRouteSelected: (r) => selected = r,
                    ),
                  );
                },
                child: const Text('Mở bộ chọn'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Mở bộ chọn'));
      await tester.pumpAndSettle();
      expect(find.text('Chọn địa điểm'), findsOneWidget);
      expect(find.text('Đường Cột'), findsNothing);
      expect(catalog.calls, isEmpty);
      await tester.tap(find.text('Bà Đen'));
      await tester.pumpAndSettle();
      expect(catalog.calls, ['a']);
      expect(find.text('Đường Cột'), findsOneWidget);
      expect(find.text('Đường Chùa'), findsNothing);
      await tester.tap(find.text('Đổi địa điểm'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Chứa Chan'));
      await tester.pumpAndSettle();
      expect(catalog.calls, ['a', 'b']);
      expect(find.text('Đường Cột'), findsNothing);
      await tester.tap(find.text('Đường Chùa'));
      await tester.pumpAndSettle();
      expect(selected?.trekkingPlaceId, 'b');
      expect(find.text('Chọn địa điểm'), findsNothing);
    },
  );

  test('form loads places without fetching all routes and requires an explicit selection', () async {
    final catalog = PickerCatalog();
    final vm = CreateNewJourneyViewModel(catalog: catalog, autoLoad: false);
    await vm.loadRoutes();
    expect(vm.places.length, 2);
    expect(catalog.calls, isEmpty);
    expect(await vm.submit(), isNull);
    expect(vm.error, contains('chọn địa điểm'));
    vm.setRoute((await catalog.getRoutes('a')).single);
    vm.participantCountController.text = '0';
    expect(await vm.submit(), isNull);
    vm.participantCountController.text = '1';
    vm.startedAtController.text = '31/02/2026';
    expect(await vm.submit(), isNull);
    vm.startedAtController.text = '12/10/2026';
    vm.completedAtController.text = '10/10/2026';
    expect(await vm.submit(), isNull);
    vm.dispose();
  });
}
