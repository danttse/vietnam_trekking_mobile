import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vietnam_trekking_mobile/app/theme/app_theme.dart';
import 'package:vietnam_trekking_mobile/core/services/location_service.dart';
import 'package:vietnam_trekking_mobile/core/services/trekking_catalog_service.dart';
import 'package:vietnam_trekking_mobile/core/services/user_api_service.dart';
import 'package:vietnam_trekking_mobile/features/journey/data/models/journey_model.dart';
import 'package:vietnam_trekking_mobile/features/journey/data/models/milestone_model.dart';
import 'package:vietnam_trekking_mobile/features/journey/viewmodels/milestone_checkin_viewmodel.dart';
import 'package:vietnam_trekking_mobile/features/journey/viewmodels/rate_milestone_viewmodel.dart';
import 'package:vietnam_trekking_mobile/features/journey/views/milestone_checkin_screen.dart';
import 'package:vietnam_trekking_mobile/features/journey/views/marker_form_screen.dart';
import 'package:vietnam_trekking_mobile/features/journey/views/rate_milestone_screen.dart';
import 'package:vietnam_trekking_mobile/features/route/data/models/route_model.dart';
import 'package:vietnam_trekking_mobile/l10n/app_localizations.dart';

const milestone = MilestoneModel(
  id: 'summit',
  name: 'Mốc 2 tỉnh (Tà Năng)',
  latitude: 11.58,
  longitude: 108.1,
  altitude: 1100,
  checkinRadiusMeters: 100,
);
final route = RouteModel.fromJson(
  {
    'trekkingRouteId': 'route',
    'trekkingPlaceId': 'place',
    'name': 'Tà Năng – Phan Dũng',
  },
  place: {'name': 'Tà Năng', 'provinceName': 'Lâm Đồng'},
);
JourneyModel journey([JourneyStatus status = JourneyStatus.active]) =>
    JourneyModel(
      journeyId: 'trip',
      name: 'Tà Năng – Phan Dũng',
      route: route,
      status: status,
      userId: 'owner',
    );

Position fix({double lat = 11.5801, double lng = 108.1, double accuracy = 8}) =>
    Position(
      longitude: lng,
      latitude: lat,
      timestamp: DateTime.now(),
      accuracy: accuracy,
      altitude: 1100,
      altitudeAccuracy: 5,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );

class FakeLocation extends LocationService {
  FakeLocation() {
    position = fix();
    permission = LocationPermission.whileInUse;
    serviceEnabled = true;
  }
  void move(Position value) {
    position = value;
    notifyListeners();
  }

  @override
  Future<Position> currentPosition() async {
    if (!hasPermission)
      throw StateError('Vui lòng cấp quyền vị trí để tiếp tục.');
    return position!;
  }
}

class FakeCatalog extends TrekkingCatalogService {
  final transitions = <String>[];
  bool failTransition = false;
  JourneyStatus refreshedStatus = JourneyStatus.active;
  @override
  Future<JourneyStatus> transitionJourney(
    String journeyId,
    String action, {
    Map<String, dynamic> body = const {},
  }) async {
    transitions.add(action);
    if (failTransition) throw StateError('Không thể tiếp tục hành trình');
    return refreshedStatus;
  }

  @override
  Future<JourneyModel> getJourney(String id) async => journey(refreshedStatus);

  final result = <String, dynamic>{
    'verification': {'status': 'VERIFIED'},
    'checkedAt': '2026-10-11T05:00:00Z',
  };
  int calls = 0;
  int completions = 0;
  @override
  Future<void> completeJourneyAfterCheckin(String id) async {
    completions++;
  }

  Map<String, dynamic>? submitted;
  @override
  Future<Map<String, dynamic>> checkIn(
    String id,
    Map<String, dynamic> body,
  ) async {
    calls++;
    submitted = body;
    return result;
  }
}

class Adapter implements HttpClientAdapter {
  final void Function(RequestOptions) inspect;
  Adapter(this.inspect);
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? stream,
    Future<void>? cancelFuture,
  ) async {
    inspect(options);
    return ResponseBody.fromString(
      jsonEncode({
        'data': {'detailEvaluateId': 'review'},
      }),
      201,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Widget app(Widget child, {bool dark = true}) => MaterialApp(
  theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
  locale: const Locale('vi'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: child,
);

Future<void> preview(WidgetTester tester, String name) async {
  if (!const bool.fromEnvironment('UPDATE_JOURNEY_PREVIEWS')) return;
  await tester.pumpAndSettle();
  await tester.runAsync(() async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(const ValueKey('preview')),
    );
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final directory = Directory('.journey-checkin-qa');
    await directory.create(recursive: true);
    await File('${directory.path}/$name.png')
        .writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final loader = FontLoader('FZ Poppins')
      ..addFont(rootBundle.load('assets/fonts/FZ Poppins-Regular.ttf'));
    await loader.load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });
  late FakeLocation location;
  late FakeCatalog api;
  late MilestoneCheckinViewModel vm;
  setUp(() {
    location = FakeLocation();
    api = FakeCatalog();
    vm = MilestoneCheckinViewModel(
      milestone: milestone,
      journey: journey(),
      locationService: location,
      api: api,
    );
  });
  tearDown(() {
    vm.dispose();
    location.dispose();
  });

  testWidgets('paused journey can resume from check-in before submitting', (
    tester,
  ) async {
    final pausedVm = MilestoneCheckinViewModel(
      milestone: milestone,
      journey: journey(JourneyStatus.paused),
      locationService: location,
      api: api,
    );
    addTearDown(pausedVm.dispose);
    await tester.pumpWidget(
      app(MilestoneCheckinScreen(milestone: milestone, viewModel: pausedVm)),
    );
    expect(pausedVm.canCheckIn, isFalse);
    await tester.ensureVisible(find.text('Tiếp tục hành trình'));
    await tester.tap(find.text('Tiếp tục hành trình'));
    await tester.pumpAndSettle();
    expect(api.transitions, ['resume']);
    expect(pausedVm.canCheckIn, isTrue);
    expect(find.text('Check-in ngay'), findsOneWidget);
    expect(api.calls, 0);
  });

  test('start uses API and failed resume keeps check-in blocked', () async {
    final plannedVm = MilestoneCheckinViewModel(
      milestone: milestone,
      journey: journey(JourneyStatus.planned),
      locationService: location,
      api: api,
    );
    addTearDown(plannedVm.dispose);
    expect(await plannedVm.activateJourney(), isTrue);
    expect(api.transitions, ['start']);
    final pausedVm = MilestoneCheckinViewModel(
      milestone: milestone,
      journey: journey(JourneyStatus.paused),
      locationService: location,
      api: api,
    );
    addTearDown(pausedVm.dispose);
    api.failTransition = true;
    expect(await pausedVm.activateJourney(), isFalse);
    expect(pausedVm.journey!.status, JourneyStatus.paused);
    expect(pausedVm.canCheckIn, isFalse);
    expect(pausedVm.isLoading, isFalse);
    expect(pausedVm.error, isNotNull);
    expect(api.calls, 0);
  });

  test(
    'AH1 GeoJSON coordinates follow GPS updates from 62464 meters to zero',
    () {
      final ah1 = MilestoneModel.fromJson({
        'milestoneId': 'ah1',
        'name': 'Tòa AH1',
        'location': {
          'type': 'Point',
          'coordinates': [106.8087, 10.8821],
        },
        'checkinRadiusMeters': 500,
      });
      final ah1Vm = MilestoneCheckinViewModel(
        milestone: ah1,
        journey: journey(),
        locationService: location,
        api: api,
      );
      addTearDown(ah1Vm.dispose);

      location.move(fix(lat: 10.941, lng: 107.376998, accuracy: 5));
      expect(ah1Vm.distanceMeters, 62464);
      expect(ah1Vm.canCheckIn, isFalse);

      location.move(fix(lat: 10.8821, lng: 106.8087, accuracy: 5));
      expect(ah1Vm.distanceMeters, 0);
      expect(ah1Vm.canCheckIn, isTrue);
      expect(ah1Vm.locationStatus, 'Trong phạm vi check-in • cách 0 m');
      expect(api.calls, 0);
    },
  );

  test('GPS updates range before submission and blocks inaccurate or outside fixes', () async {
    expect(vm.canCheckIn, isTrue);
    location.move(fix(lat: 11.59));
    expect(vm.isWithinRange, isFalse);
    expect(await vm.checkIn(), isFalse);
    expect(api.calls, 0);
    location.move(fix(accuracy: 120));
    expect(vm.canCheckIn, isFalse);
    expect(await vm.checkIn(), isFalse);
    expect(api.calls, 0);
  });
  test(
    'verified check-in sends original GPS and uses server timestamp',
    () async {
      expect(await vm.checkIn(), isTrue);
      expect(api.submitted!['milestoneId'], 'summit');
      expect(api.submitted!['latitude'], location.position!.latitude);
      expect(api.submitted!['accuracyMeters'], 8);
      expect(vm.milestone.checkedInAt, DateTime.utc(2026, 10, 11, 5));
      expect(await vm.checkIn(), isFalse);
      expect(api.calls, 1);
    },
  );
  test(
    'GPS check-in succeeds locally while synchronization is pending',
    () async {
      api.result['offlineSyncStatus'] = 'PENDING';
      expect(await vm.checkIn(), isTrue);
      expect(vm.pendingSync, isTrue);
      expect(vm.isCheckedIn, isTrue);
      expect(vm.error, isNull);
      expect(await vm.checkIn(), isFalse);
      expect(api.calls, 1);
    },
  );
  test(
    'server verification does not block a locally accepted GPS check-in',
    () async {
      api.result['verification'] = {'status': 'PENDING_VERIFICATION'};
      expect(await vm.checkIn(), isTrue);
      expect(vm.isCheckedIn, isTrue);
      expect(vm.error, isNull);
    },
  );
  test('only FINISH check-in queues journey completion', () async {
    final finish = MilestoneCheckinViewModel(
      milestone: const MilestoneModel(
        id: 'finish',
        type: 'FINISH',
        latitude: 11.58,
        longitude: 108.1,
        checkinRadiusMeters: 100,
      ),
      journey: journey(),
      locationService: location,
      api: api,
    );
    addTearDown(finish.dispose);
    api.result['offlineSyncStatus'] = 'PENDING';
    expect(await finish.checkIn(), isTrue);
    expect(finish.finishesJourney, isTrue);
    expect(api.completions, 1);
    expect(await vm.checkIn(), isTrue);
    expect(vm.finishesJourney, isFalse);
    expect(api.completions, 1);
  });
  test(
    'inactive journey and denied location never call the check-in API',
    () async {
      final inactive = MilestoneCheckinViewModel(
        milestone: milestone,
        journey: journey(JourneyStatus.planned),
        locationService: location,
        api: api,
      );
      expect(await inactive.checkIn(), isFalse);
      inactive.dispose();
      location.permission = LocationPermission.deniedForever;
      expect(await vm.checkIn(), isFalse);
      expect(api.calls, 0);
    },
  );
  test(
    'anonymous place review sends the corresponding API contract only once',
    () async {
      var calls = 0;
      final dio = Dio()
        ..httpClientAdapter = Adapter((r) {
          calls++;
          expect(r.path, '/places/place/reviews');
          expect(r.data['point'], 5);
          expect(r.data['isAnonymous'], isTrue);
          expect(r.data['content'], 'Chuyến đi đẹp');
        });
      final review = RateMilestoneViewModel(
        journey: journey(),
        api: UserApiService(trekkingClient: dio, cacheEnabled: false),
      );
      review.setRating(5);
      review.setAnonymous(true);
      review.descriptionController.text = 'Chuyến đi đẹp';
      expect(await review.submit(), isTrue);
      expect(await review.submit(), isFalse);
      expect(calls, 1);
      review.dispose();
    },
  );
  for (final width in [320.0, 390.0]) {
    testWidgets('check-in layout and GPS diagram fit ${width.toInt()}px', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        app(
          RepaintBoundary(
            key: const ValueKey('preview'),
            child: MilestoneCheckinScreen(
              milestone: milestone,
              journey: journey(),
              viewModel: vm,
            ),
          ),
        ),
      );
      expect(find.text('Vùng check-in 100 m'), findsOneWidget);
      expect(tester.takeException(), isNull);
      if (width == 390) await preview(tester, 'checkin-dark');
      await tester.pumpWidget(const SizedBox());
    });
    testWidgets(
      'marker sheet scrolls and validates name at ${width.toInt()}px',
      (tester) async {
        tester.view.physicalSize = Size(width, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          app(
            Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => RepaintBoundary(
                      key: const ValueKey('preview'),
                      child: const MarkerFormScreen(
                        localJourneyId: 'trip',
                        userId: 'owner',
                        initialLat: 11.58,
                        initialLng: 108.1,
                        initialAlt: 1100,
                        initialAccuracy: 8,
                      ),
                    ),
                  ),
                  child: const Text('Mở cột mốc'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Mở cột mốc'));
        await tester.pumpAndSettle();
        await tester.drag(find.byType(ListView).first, const Offset(0, -250));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Lưu trên máy'));
        await tester.pumpAndSettle();
        expect(find.text('Nhập tên cột mốc'), findsOneWidget);
        expect(tester.takeException(), isNull);
        tester.view.viewInsets = const FakeViewPadding(bottom: 300);
        addTearDown(tester.view.resetViewInsets);
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byType(TextFormField));
        await tester.tap(find.byType(TextFormField));
        await tester.enterText(find.byType(TextFormField), 'Cột mốc mới');
        await tester.pumpAndSettle();
        expect(
          tester.getBottomLeft(find.byType(TextFormField)).dy,
          lessThanOrEqualTo(544),
        );
        await tester.ensureVisible(find.text('Lưu trên máy'));
        await tester.pumpAndSettle();
        expect(
          tester.getBottomLeft(find.text('Lưu trên máy')).dy,
          lessThanOrEqualTo(544),
        );
        expect(tester.takeException(), isNull);
        tester.view.resetViewInsets();
        await tester.pumpAndSettle();
        if (width == 390) await preview(tester, 'marker-dark');
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
  testWidgets('review success displays actual stars and navigation action', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final dio = Dio()..httpClientAdapter = Adapter((_) {});
    final review = RateMilestoneViewModel(
      milestone: milestone,
      journey: journey(),
      api: UserApiService(trekkingClient: dio, cacheEnabled: false),
    );
    review.setRating(5);
    await tester.runAsync(() => review.submit());
    await tester.pumpWidget(
      app(
        RepaintBoundary(
          key: const ValueKey('preview'),
          child: RateMilestoneScreen(
            milestone: milestone,
            journey: journey(),
            viewModel: review,
          ),
        ),
      ),
    );
    expect(find.text('Cảm ơn bạn!'), findsOneWidget);
    expect(find.text('Xem đánh giá khác'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await preview(tester, 'review-success-dark');
    await tester.pumpWidget(const SizedBox());
    review.dispose();
  });

  testWidgets(
    'offline GPS check-in returns success to journey after continuing',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      bool? result;
      api.result['offlineSyncStatus'] = 'PENDING';
      await tester.pumpWidget(
        app(
          Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MilestoneCheckinScreen(
                        milestone: milestone,
                        journey: journey(),
                        viewModel: vm,
                      ),
                    ),
                  );
                },
                child: const Text('Mở check-in'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Mở check-in'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Check-in ngay'));
      await tester.pumpAndSettle();
      expect(find.text('Check-in thành công!'), findsOneWidget);
      expect(find.text('Đang chờ xác minh'), findsNothing);
      expect(result, isNull);
      await tester.ensureVisible(find.text('Tiếp tục hành trình'));
      await tester.tap(find.text('Tiếp tục hành trình'));
      await tester.pumpAndSettle();
      expect(result, isTrue);
      expect(find.text('Mở check-in'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets('FINISH succeeds offline and opens rating without closing it', (
    tester,
  ) async {
    const finish = MilestoneModel(
      id: 'finish',
      type: 'FINISH',
      name: 'Điểm cuối',
      latitude: 11.58,
      longitude: 108.1,
      checkinRadiusMeters: 100,
    );
    vm.dispose();
    vm = MilestoneCheckinViewModel(
      milestone: finish,
      journey: journey(),
      api: api,
      locationService: location,
    );
    api.result['offlineSyncStatus'] = 'PENDING';
    await tester.pumpWidget(
      app(MilestoneCheckinScreen(milestone: finish, viewModel: vm)),
    );
    await tester.ensureVisible(find.text('Check-in ngay'));
    await tester.tap(find.text('Check-in ngay'));
    await tester.pumpAndSettle();
    expect(find.text('Check-in thành công!'), findsOneWidget);
    expect(api.completions, 1);
    expect(find.text('Quay lại hành trình'), findsOneWidget);
    final rating = find.text(
      AppLocalizations.of(tester.element(find.text('Check-in thành công!')))!
          .ratePlaceButton,
    );
    await tester.ensureVisible(rating);
    await tester.tap(rating);
    await tester.pumpAndSettle();
    expect(find.byType(RateMilestoneScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
