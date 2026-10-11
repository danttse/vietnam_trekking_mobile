import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vietnam_trekking_mobile/core/services/trekking_catalog_service.dart';
import 'package:vietnam_trekking_mobile/features/journey/data/models/journey_model.dart';
import 'package:vietnam_trekking_mobile/features/route/data/models/route_model.dart';
import 'package:vietnam_trekking_mobile/features/route/view/download_offline_map_screen.dart';
import 'package:vietnam_trekking_mobile/features/route/viewmodel/download_offline_map_viewmodel.dart';
import 'package:vietnam_trekking_mobile/l10n/app_localizations.dart';
import 'package:vietnam_trekking_mobile/features/route/view/route_detail_screen.dart';
import 'package:vietnam_trekking_mobile/core/database/models/downloaded_map.dart';
import 'package:vietnam_trekking_mobile/features/offline_map/services/offline_map_storage_service.dart';

class EmptyMaps extends OfflineMapStorageService {
  @override
  Future<DownloadedMap?> findReadyMap(String routeId, String placeId) async =>
      null;
}

final route = RouteModel.fromJson({
  'trekkingRouteId': 'route',
  'trekkingPlaceId': 'place',
  'name': 'Tòa AH1',
});
JourneyModel journey(JourneyStatus status) => JourneyModel(
  journeyId: 'existing-journey',
  name: 'Hành trình mới',
  route: route,
  status: status,
);

class CompletedDownload extends DownloadOfflineMapViewModel {
  CompletedDownload() : super(route: route, autoStart: false);
  @override
  bool get isCompleted => true;
}

class StartCatalog extends TrekkingCatalogService {
  final transitions = <String>[];
  @override
  Future<JourneyStatus> transitionJourney(
    String id,
    String action, {
    Map<String, dynamic> body = const {},
  }) async {
    transitions.add('$id:$action');
    return JourneyStatus.active;
  }

  @override
  Future<JourneyModel> getJourney(String id) async =>
      journey(JourneyStatus.active);
}

void main() {
  for (final detail in [false, true]) {
    for (final start in [false, true]) {
      testWidgets(
        '${detail ? "route detail" : "download"}: ${start ? 'start returns the activated existing journey for the journey map' : 'confirm returns to Journey without starting it at narrow width'}',
        (tester) async {
          tester.view.physicalSize = const Size(320, 640);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final vm = CompletedDownload();
          final catalog = StartCatalog();
          addTearDown(vm.dispose);
          dynamic result;
          await tester.pumpWidget(
            MaterialApp(
              locale: const Locale('vi'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Builder(
                builder: (context) => Scaffold(
                  body: TextButton(
                    onPressed: () async {
                      result = await Navigator.push<dynamic>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => detail
                              ? RouteDetailScreen(
                                  route: route,
                                  pendingJourney: journey(
                                    JourneyStatus.planned,
                                  ),
                                  mapStorage: EmptyMaps(),
                                  catalog: catalog,
                                )
                              : DownloadOfflineMapScreen(
                                  route: route,
                                  pendingJourney: journey(
                                    JourneyStatus.planned,
                                  ),
                                  viewModel: vm,
                                  catalog: catalog,
                                ),
                        ),
                      );
                    },
                    child: const Text('Journey'),
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.text('Journey'));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          final button = find.text(
            start
                ? 'Bắt đầu hành trình'
                : detail
                ? 'Về trang hành trình'
                : 'Xác nhận',
          );
          await tester.ensureVisible(button);
          await tester.tap(button);
          await tester.pumpAndSettle();
          expect(find.text('Journey'), findsOneWidget);
          expect(tester.takeException(), isNull);
          if (start) {
            expect(result, isA<JourneyModel>());
            expect((result as JourneyModel).journeyId, 'existing-journey');
            expect(result.status, JourneyStatus.active);
            expect(catalog.transitions, ['existing-journey:start']);
          } else {
            if (detail) {
              expect(result, isA<JourneyModel>());
              expect(result.status, JourneyStatus.planned);
            } else {
              expect(result, true);
            }
            expect(catalog.transitions, isEmpty);
          }
        },
      );
    }
  }
}
