import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:vietnam_trekking_mobile/core/database/database_helper.dart';
import 'package:vietnam_trekking_mobile/core/services/offline_store.dart';
import 'package:vietnam_trekking_mobile/core/services/trekking_catalog_service.dart';
import 'package:vietnam_trekking_mobile/features/journey/data/models/journey_model.dart';
import 'package:vietnam_trekking_mobile/features/journey/viewmodels/journey_detail_viewmodel.dart';
import 'package:vietnam_trekking_mobile/features/journey/viewmodels/journey_viewmodel.dart';

import 'offline_store_test.dart' show TestAdapter, reply;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  late Directory directory;
  late DatabaseHelper helper;
  late OfflineStore store;
  late Dio dio;
  late TrekkingCatalogService api;
  const serverId = '6aca4d092d9049976837255b';
  const place = {
    'trekkingPlaceId': 'p',
    'name': 'Bà Đen',
    'provinceId': 'tay_ninh',
  };
  const route = {
    'trekkingRouteId': 'r',
    'trekkingPlaceId': 'p',
    'name': 'Đường Cột',
    'distanceMeters': 5000,
    'estimatedDurationMinutes': 200,
  };
  Map<String, dynamic> journey({
    String id = serverId,
    String status = 'ACTIVE',
    bool embedded = true,
  }) => {
    'journeyId': id,
    'clientJourneyId': 'client-$id',
    'userId': 'user-a',
    'trekkingPlaceId': 'p',
    'trekkingRouteId': 'r',
    'name': 'Chuyến đi $id',
    'status': status,
    'note': 'Mang nước',
    'participantCount': 3,
    'plannedStartAt': '2026-10-10T00:00:00Z',
    'plannedEndAt': '2026-10-11T00:00:00Z',
    'statistics': {'distanceMeters': 0, 'durationSeconds': 0},
    if (embedded) 'route': {...route, 'status': 'DISABLED'},
    if (embedded) 'place': place,
  };
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('journey-history-');
    helper = await DatabaseHelper.openForTesting('${directory.path}/test.db');
    store = OfflineStore(
      databaseHelper: helper,
      ownerProvider: () async => 'user-a',
    );
    dio = Dio(BaseOptions(baseUrl: 'http://tests'));
    api = TrekkingCatalogService(client: dio, checkinClient: dio, store: store);
    await store.cache('/places/p', place);
    await store.cache('/routes/r', route);
  });
  tearDown(() async {
    await (await helper.database).close();
    await directory.delete(recursive: true);
  });

  test(
    'uncached milestone 404 propagates instead of becoming an empty route',
    () async {
      dio.httpClientAdapter = TestAdapter(
        (request) async => reply(null, status: 404),
      );
      await expectLater(api.getMilestones('r'), throwsA(isA<DioException>()));
    },
  );

  test(
    'disabled route still returns previously cached official milestones',
    () async {
      await store.cache('/routes/r/milestones', [
        {
          'milestoneId': 'summit',
          'trekkingRouteId': 'r',
          'name': 'Đỉnh núi',
          'sequence': 1,
          'location': {
            'type': 'Point',
            'coordinates': [106.17, 11.38],
          },
        },
      ]);
      dio.httpClientAdapter = TestAdapter(
        (request) async => reply(null, status: 404),
      );
      expect((await api.getMilestones('r')).single['milestoneId'], 'summit');
    },
  );

  test(
    'one disabled route never hides other trips on an older server',
    () async {
      dio.httpClientAdapter = TestAdapter((request) async {
        if (request.path == '/journeys')
          return reply({
            'items': [
              journey(embedded: false),
              {
                ...journey(id: 'old', embedded: false),
                'trekkingRouteId': 'missing',
              },
            ],
            'total': 2,
          });
        if (request.path == '/routes/missing') return reply(null, status: 404);
        if (request.path == '/routes/r') return reply(route);
        if (request.path == '/places/p') return reply(place);
        throw StateError('Unexpected path: ${request.path}');
      });
      final vm = JourneyViewModel(catalog: api, autoLoad: false);
      await vm.loadJourneys();
      vm.setTab(1);
      expect(vm.error, isNull);
      expect(vm.currentTripsCount, 2);
      expect(vm.currentJourneys.first.journeyId, serverId);
      expect(vm.currentTotalDistanceText, '5 km');
      expect(await store.journeys('user-b'), isEmpty);
      vm.dispose();
    },
  );

  test(
    'embedded disabled route is displayed and survives a fully offline restart',
    () async {
      dio.httpClientAdapter = TestAdapter((request) async {
        expect(request.path, '/journeys');
        return reply({
          'items': [journey()],
          'total': 1,
        });
      });
      final online = await api.getJourneys();
      expect(online.single.route.name, 'Đường Cột');
      expect(online.single.summarySubtitle, contains('5 km'));
      dio.httpClientAdapter = TestAdapter(
        (request) async => throw DioException(
          requestOptions: request,
          type: DioExceptionType.connectionError,
        ),
      );
      final offline = await api.getJourneys();
      expect(offline.single.journeyId, serverId);
      expect(offline.single.route.name, 'Đường Cột');
      expect(offline.single.note, 'Mang nước');
      expect(offline.single.participantCount, 3);
    },
  );

  test('opening detail fetches current server status and keeps one stable SQLite row', () async {
    var status = 'ACTIVE';
    dio.httpClientAdapter = TestAdapter((request) async {
      expect(request.path, '/journeys/$serverId');
      return reply(journey(status: status));
    });
    expect((await api.getJourney(serverId)).status, JourneyStatus.active);
    status = 'PAUSED';
    final refreshed = await api.getJourney(serverId);
    expect(refreshed.status, JourneyStatus.paused);
    expect(refreshed.clientJourneyId, 'client-$serverId');
    expect((await store.journeys('user-a')).length, 1);
  });

  test(
    'pause updates the actual detail model passed to check-in and map',
    () async {
      await store.cacheJourneys([journey()], 'user-a');
      var status = 'ACTIVE';
      dio.httpClientAdapter = TestAdapter((request) async {
        if (request.path.endsWith('/pause')) status = 'PAUSED';
        expect(
          request.path,
          anyOf('/journeys/$serverId/pause', '/journeys/$serverId'),
        );
        return reply(journey(status: status));
      });
      final vm = JourneyDetailViewModel(
        route: await api.parseJourney(journey()),
        catalog: api,
        autoLoad: false,
      );
      await vm.toggleJourneyStatus();
      expect(vm.error, isNull);
      expect(vm.journeyStatus, JourneyStatus.paused);
      expect(vm.journey!.status, JourneyStatus.paused);
      expect(vm.estimatedDurationText, '3 giờ 20 phút');
      expect(vm.isUpdating, isFalse);
      expect(await (await helper.database).query('offline_outbox'), isEmpty);
      vm.dispose();
    },
  );

  test(
    'offline pause remains visible and is synced once after reconnection',
    () async {
      await store.cacheJourneys([journey()], 'user-a');
      dio.httpClientAdapter = TestAdapter(
        (request) async => throw DioException(
          requestOptions: request,
          type: DioExceptionType.connectionError,
        ),
      );
      final vm = JourneyDetailViewModel(
        route: await api.parseJourney(journey()),
        catalog: api,
        autoLoad: false,
      );
      await vm.toggleJourneyStatus();
      expect(vm.journey!.status, JourneyStatus.paused);
      expect(vm.journey!.pendingSync, isTrue);
      vm.dispose();
      expect((await api.getJourney(serverId)).status, JourneyStatus.paused);
      var paused = false;
      var writes = 0;
      dio.httpClientAdapter = TestAdapter((request) async {
        if (request.method == 'POST') {
          writes++;
          paused = true;
        }
        return reply(journey(status: paused ? 'PAUSED' : 'ACTIVE'));
      });
      await api.syncPending();
      final refreshed = await api.getJourney(serverId);
      expect(writes, 1);
      expect(refreshed.status, JourneyStatus.paused);
      expect(refreshed.pendingSync, isFalse);
      expect((await store.journeys('user-a')).length, 1);
    },
  );

  test(
    'private auth errors propagate even when a local journey exists',
    () async {
      await store.cacheJourneys([journey()], 'user-a');
      dio.httpClientAdapter = TestAdapter(
        (request) async => reply(null, status: 403),
      );
      await expectLater(api.getJourney(serverId), throwsA(isA<DioException>()));
      await expectLater(api.getJourneys(), throwsA(isA<DioException>()));
    },
  );

  test(
    'statistics and check-in counts are projected into SQLite columns',
    () async {
      dio.httpClientAdapter = TestAdapter(
        (request) async => throw DioException(
          requestOptions: request,
          type: DioExceptionType.connectionError,
        ),
      );
      await store.cacheJourneys([
        {
          ...journey(status: 'COMPLETED'),
          'statistics': {
            'distanceMeters': 6000,
            'durationSeconds': 7200,
            'elevationGain': 800,
            'maxAltitude': 986,
          },
          'checkinCount': 5,
          'markerCount': 2,
        },
      ], 'user-a');
      final db = await helper.database;
      final row = (await db.query('local_journeys')).single;
      expect(row['distanceMeters'], 6000);
      expect(row['durationSeconds'], 7200);
      expect(row['checkinCount'], 5);
      await db.delete(
        'offline_snapshots',
        where: 'ownerId = ?',
        whereArgs: ['user-a'],
      );
      final restored = await api.parseJourney(
        (await store.journeys('user-a')).single,
      );
      expect(restored.distanceMeters, 6000);
      expect(restored.checkinCount, 5);
    },
  );
}
