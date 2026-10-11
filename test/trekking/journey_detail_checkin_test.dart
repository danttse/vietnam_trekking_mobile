import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vietnam_trekking_mobile/app/theme/app_theme.dart';
import 'package:vietnam_trekking_mobile/core/services/trekking_catalog_service.dart';
import 'package:vietnam_trekking_mobile/features/journey/data/models/journey_model.dart';
import 'package:vietnam_trekking_mobile/features/journey/viewmodels/journey_detail_viewmodel.dart';
import 'package:vietnam_trekking_mobile/features/journey/views/journey_detail_screen.dart';
import 'package:vietnam_trekking_mobile/features/journey/views/milestone_checkin_screen.dart';
import 'package:vietnam_trekking_mobile/features/route/data/models/route_model.dart';
import 'package:vietnam_trekking_mobile/l10n/app_localizations.dart';

final trip = JourneyModel(
  journeyId: 'trip',
  name: 'demo',
  route: RouteModel.fromJson(
    {
      'trekkingRouteId': 'route',
      'trekkingPlaceId': 'place',
      'name': 'Đường CD',
      'estimatedDurationMinutes': 200,
    },
    place: {'name': 'Núi Bà Đen', 'address': 'Tây Ninh'},
  ),
  status: JourneyStatus.active,
);
Map<String, dynamic> point(String id, int sequence) => {
  'milestoneId': id,
  'trekkingRouteId': 'route',
  'name': 'Mốc $sequence',
  'sequence': sequence,
  'location': {
    'type': 'Point',
    'coordinates': [106.17, 11.38],
  },
  'checkinRadiusMeters': 50,
};

class DetailCatalog extends TrekkingCatalogService {
  List<Map<String, dynamic>> points = [];
  List<Map<String, dynamic>> checkins = [];
  Completer<List<Map<String, dynamic>>>? gate;
  bool fail = false;
  int milestoneCalls = 0;

  @override
  Future<JourneyModel> getJourney(String id) async => trip;

  @override
  Future<List<Map<String, dynamic>>> getMilestones(String routeId) async {
    expectSync(routeId, 'route');
    milestoneCalls++;
    if (fail) {
      throw DioException(
        requestOptions: RequestOptions(path: '/routes/route/milestones'),
        type: DioExceptionType.connectionError,
      );
    }
    return gate == null ? points : await gate!.future;
  }

  @override
  Future<List<Map<String, dynamic>>> getJourneyCheckins(String id) async =>
      checkins;
}

Widget app(JourneyDetailViewModel vm) => MaterialApp(
  theme: AppTheme.darkTheme,
  locale: const Locale('vi'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: RepaintBoundary(
    key: const ValueKey('preview'),
    child: JourneyDetailScreen(route: trip, viewModel: vm),
  ),
);

final shortcut = find.byKey(const ValueKey('journey-checkin'));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await (FontLoader(
      'FZ Poppins',
    )..addFont(rootBundle.load('assets/fonts/FZ Poppins-Regular.ttf'))).load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });
  late DetailCatalog api;
  late JourneyDetailViewModel vm;
  setUp(() {
    api = DetailCatalog();
    vm = JourneyDetailViewModel(route: trip, catalog: api, autoLoad: false);
  });
  tearDown(() => vm.dispose());

  test(
    'pending local GPS check-ins remain checked while failed ones can retry',
    () async {
      api.points = [point('local', 1), point('failed', 2)];
      api.checkins = [
        {
          'milestoneId': 'local',
          'offlineSyncStatus': 'PENDING',
          'verification': {'status': 'PENDING'},
        },
        {
          'milestoneId': 'failed',
          'offlineSyncStatus': 'FAILED',
          'verification': {'status': 'PENDING'},
        },
      ];
      await vm.loadMilestones();
      expect(vm.milestones[0].isCheckedIn, isTrue);
      expect(vm.milestones[1].isCheckedIn, isFalse);
    },
  );

  test(
    'refresh coalesces requests and preserves verified milestones on failure',
    () async {
      api.gate = Completer();
      final first = vm.loadMilestones();
      final second = vm.loadMilestones();
      expect(vm.isLoadingMilestones, isTrue);
      expect(vm.hasLoadedMilestones, isFalse);
      await Future<void>.delayed(Duration.zero);
      expect(api.milestoneCalls, 1);
      api.checkins = [
        {
          'milestoneId': 'one',
          'verification': {'status': 'VERIFIED'},
        },
        {
          'milestoneId': 'two',
          'verification': {'status': 'PENDING'},
        },
      ];
      api.gate!.complete([point('one', 1), point('two', 2)]);
      await Future.wait([first, second]);
      expect(vm.isLoadingMilestones, isFalse);
      expect(vm.hasLoadedMilestones, isTrue);
      expect(vm.checkedInCount, 1);
      api.fail = true;
      await vm.loadMilestones();
      expect(vm.milestoneError, isNotNull);
      expect(vm.milestones.length, 2);
      expect(vm.checkedInCount, 1);
    },
  );

  testWidgets(
    'empty route explains the tap and reload opens a newly added milestone',
    (tester) async {
      await vm.loadMilestones();
      await tester.pumpWidget(app(vm));
      await tester.pumpAndSettle();
      expect(find.text('Chưa có điểm check-in'), findsOneWidget);
      await tester.ensureVisible(shortcut);
      await tester.tap(shortcut);
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(api.milestoneCalls, 2);
      expect(find.textContaining('Quản trị viên cần thêm'), findsNWidgets(2));
      api.points = [point('new-point', 1)];
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Tải lại cột mốc'),
        ),
      );
      await tester.pumpAndSettle();
      final screen = tester.widget<MilestoneCheckinScreen>(
        find.byType(MilestoneCheckinScreen),
      );
      expect(screen.milestone.id, 'new-point');
      expect(screen.journey!.journeyId, trip.journeyId);
      expect(api.milestoneCalls, 3);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'loading disables the shortcut and does not claim zero milestones',
    (tester) async {
      api.gate = Completer();
      final loading = vm.loadMilestones();
      await tester.pumpWidget(app(vm));
      await tester.pump();
      expect(tester.widget<FilledButton>(shortcut).onPressed, isNull);
      expect(find.text('0/0 mốc'), findsNothing);
      expect(find.text('Chưa có điểm check-in'), findsNothing);
      api.gate!.complete([]);
      await loading;
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(shortcut).onPressed, isNotNull);
      expect(find.text('Chưa có điểm check-in'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'load errors can retry and the shortcut chooses an unvisited milestone',
    (tester) async {
      api.fail = true;
      await vm.loadMilestones();
      await tester.pumpWidget(app(vm));
      await tester.pumpAndSettle();
      expect(find.text('Chưa tải được điểm check-in'), findsNWidgets(2));
      expect(find.text('Chưa có điểm check-in'), findsNothing);
      expect(find.text('0/0 mốc'), findsNothing);
      await tester.ensureVisible(shortcut);
      await tester.tap(shortcut);
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(
        find.textContaining('Không thể kết nối máy chủ.'),
        findsNWidgets(2),
      );
      await tester.tap(find.text('Đóng'));
      await tester.pumpAndSettle();
      api.fail = false;
      api.points = [point('visited', 1), point('next', 2)];
      api.checkins = [
        {
          'milestoneId': 'visited',
          'verification': {'status': 'VERIFIED'},
        },
      ];
      await tester.ensureVisible(find.text('Tải lại cột mốc'));
      await tester.tap(find.text('Tải lại cột mốc'));
      await tester.pumpAndSettle();
      expect(vm.milestoneError, isNull);
      await tester.ensureVisible(shortcut);
      await tester.tap(shortcut);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<MilestoneCheckinScreen>(find.byType(MilestoneCheckinScreen))
            .milestone
            .id,
        'next',
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  for (final width in [320.0, 390.0]) {
    testWidgets('empty milestone notice fits a $width px screen', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await vm.loadMilestones();
      await tester.pumpWidget(app(vm));
      await tester.pumpAndSettle();
      if (width == 390 &&
          const bool.fromEnvironment('UPDATE_JOURNEY_PREVIEWS')) {
        await tester.runAsync(() async {
          final boundary = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(const ValueKey('preview')),
          );
          final image = await boundary.toImage(pixelRatio: 2);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await Directory('.journey-checkin-qa').create(recursive: true);
          await File('.journey-checkin-qa/detail-empty-milestones.png')
              .writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
      await tester.ensureVisible(shortcut);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
}
