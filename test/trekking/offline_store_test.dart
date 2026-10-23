import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:vietnam_trekking_mobile/core/database/database_helper.dart';
import 'package:vietnam_trekking_mobile/core/database/daos/offline_data_dao.dart';
import 'package:vietnam_trekking_mobile/core/database/models/local_journey.dart';
import 'package:vietnam_trekking_mobile/core/services/offline_store.dart';
import 'package:vietnam_trekking_mobile/core/services/trekking_catalog_service.dart';

class TestAdapter implements HttpClientAdapter {
  final Future<ResponseBody> Function(RequestOptions) handler;
  TestAdapter(this.handler);
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? stream,
    Future<void>? cancel,
  ) => handler(options);
  @override
  void close({bool force = false}) {}
}

ResponseBody reply(dynamic data, {int status = 200}) => ResponseBody.fromString(
  jsonEncode({'data': data}),
  status,
  headers: {
    Headers.contentTypeHeader: ['application/json'],
  },
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  late Directory directory;
  late DatabaseHelper helper;
  late OfflineStore store;
  late Dio trekking, checkin;
  var owner = 'user-a';
  final place = {
    'trekkingPlaceId': 'p',
    'name': 'Bà Đen',
    'provinceId': 'province-tay-ninh',
  };
  final route = {
    'trekkingRouteId': 'r',
    'trekkingPlaceId': 'p',
    'name': 'Đường Cột',
    'distanceMeters': 5000,
  };
  Map<String, dynamic> body(String id) => {
    'clientJourneyId': id,
    'name': 'Chuyến đi',
    'trekkingPlaceId': 'p',
    'trekkingRouteId': 'r',
    'note': 'Offline note',
    'participantCount': 3,
    'plannedStartAt': '2026-10-10T00:00:00.000Z',
    'plannedEndAt': '2026-10-12T00:00:00.000Z',
  };
  Future<void> offline(RequestOptions request) async => throw DioException(
    requestOptions: request,
    type: DioExceptionType.connectionError,
  );

  setUp(() async {
    owner = 'user-a';
    directory = await Directory.systemTemp.createTemp('trekvn-sqlite-test-');
    helper = await DatabaseHelper.openForTesting('${directory.path}/app.db');
    store = OfflineStore(
      databaseHelper: helper,
      ownerProvider: () async => owner,
      markerImageUploader: (path, _) async =>
          'https://images.example/marker.jpg',
    );
    trekking = Dio(BaseOptions(baseUrl: 'http://tests'));
    checkin = Dio(BaseOptions(baseUrl: 'http://tests'));
    trekking.httpClientAdapter = TestAdapter((r) async {
      await offline(r);
      return reply(null);
    });
    checkin.httpClientAdapter = TestAdapter((r) async {
      await offline(r);
      return reply(null);
    });
    await store.cache('/places', [place]);
    await store.cache('/places/p/routes', [route]);
    await store.cache('/routes/r/milestones', [
      {
        'milestoneId': 'm1',
        'sequence': 1,
        'name': 'Điểm 1',
        'location': {
          'coordinates': [106.17, 11.38],
        },
      },
      {
        'milestoneId': 'm2',
        'sequence': 2,
        'name': 'Điểm 2',
        'location': {
          'coordinates': [106.18, 11.39],
        },
      },
    ]);
  });
  tearDown(() async {
    trekking.close();
    checkin.close();
    await helper.close();
    await directory.delete(recursive: true);
  });

  test(
    'check-in and finish save locally without waiting for network sync',
    () async {
      final localId = await store.createJourney(body('background-checkin'));
      await store.transition(localId, 'start');
      final gate = Completer<void>();
      final started = Completer<void>();
      trekking.httpClientAdapter = TestAdapter((request) async {
        if (!started.isCompleted) started.complete();
        await gate.future;
        await offline(request);
        return reply(null);
      });
      final service = TrekkingCatalogService(
        client: trekking,
        checkinClient: checkin,
        store: store,
      );
      try {
        final saved = await service
            .checkIn(localId, {
              'milestoneId': 'm1',
              'latitude': 11.38,
              'longitude': 106.17,
              'accuracyMeters': 8,
              'checkedAt': '2026-10-11T05:00:00Z',
            })
            .timeout(const Duration(seconds: 3));
        await started.future;
        expect(saved['offlineSyncStatus'], 'PENDING');
        expect(saved['milestoneId'], 'm1');
        await service
            .completeJourneyAfterCheckin(localId)
            .timeout(const Duration(seconds: 3));
        final ownerId = await store.requireOwner();
        expect(
          (await store.read('/journeys/$localId', owner: ownerId)
              as Map)['status'],
          'COMPLETED',
        );
        final db = await helper.database;
        final outbox = await db.query('offline_outbox', orderBy: 'rowid ASC');
        expect(outbox.map((r) => r['path']).toList(), [
          '/journeys',
          '/journeys/@journey/start',
          '/checkins',
          '/journeys/@journey/complete',
        ]);
        final stored = (await db.query('offline_checkins')).single;
        expect(stored['latitude'], 11.38);
        expect(stored['longitude'], 106.17);
        expect(stored['checkedAt'], '2026-10-11T05:00:00Z');
      } finally {
        gate.complete();
        await service.syncPending();
      }
    },
  );

  test(
    'offline catalog and complete journey data survive SQLite reopen',
    () async {
      final service = TrekkingCatalogService(
        client: trekking,
        checkinClient: checkin,
        store: store,
      );
      final model = await service.getRoute('r');
      final journey = await service.createJourney(body('j1'), model);
      expect(journey.pendingSync, isTrue);
      expect(journey.participantCount, 3);
      expect(journey.note, 'Offline note');
      final local = LocalJourney.fromMap(
        (await (await helper.database).query('local_journeys')).single,
      );
      final updated = local.copyWith(status: 'ACTIVE').toMap();
      expect(updated['participantCount'], 3);
      expect(updated['note'], 'Offline note');
      expect(DateTime.parse(updated['plannedEndAt']).day, 12);
      final path = (await helper.database).path;
      await helper.close();
      helper = await DatabaseHelper.openForTesting(path);
      store = OfflineStore(
        databaseHelper: helper,
        ownerProvider: () async => owner,
      );
      final reopened = TrekkingCatalogService(
        client: trekking,
        checkinClient: checkin,
        store: store,
      );
      final journeys = await reopened.getJourneys();
      expect(journeys.single.route.name, 'Đường Cột');
      expect(journeys.single.plannedEndAt?.day, 12);
      expect((await helper.database).isOpen, isTrue);
      expect(
        await (await helper.database).rawQuery('PRAGMA foreign_key_check'),
        isEmpty,
      );
    },
  );

  test(
    'catalog refresh updates parents without deleting journeys or check-ins',
    () async {
      await store.createJourney(body('j1'));
      await store.transition('j1', 'start');
      await store.checkin('j1', {
        'milestoneId': 'm1',
        'latitude': 11.38,
        'longitude': 106.17,
        'checkedAt': '2026-10-10T01:00:00.000Z',
      });
      await store.cache('/places', [
        {...place, 'name': 'Núi Bà Đen'},
      ]);
      await store.cache('/places/p/routes', [
        {...route, 'name': 'Tên mới'},
      ]);
      expect((await store.journeys(owner)).length, 1);
      expect(
        (await store.checkins('j1')).single['verification']['status'],
        'PENDING',
      );
      expect(
        await (await helper.database).rawQuery('PRAGMA foreign_key_check'),
        isEmpty,
      );
    },
  );

  test('create, start, check-in replay in order using real server ID and original GPS/time', () async {
    await store.createJourney(body('j1'));
    await store.transition('j1', 'start');
    final now = '2026-10-10T01:02:03.000Z';
    await store.checkin('j1', {
      'milestoneId': 'm1',
      'latitude': 11.38,
      'longitude': 106.17,
      'accuracyMeters': 8,
      'checkedAt': now,
    });
    final requests = <RequestOptions>[];
    trekking.httpClientAdapter = TestAdapter((r) async {
      requests.add(r);
      if (r.path == '/journeys')
        return reply({
          ...body('j1'),
          'journeyId': 'server-j1',
          'status': 'PLANNED',
        });
      return reply({
        ...body('j1'),
        'journeyId': 'server-j1',
        'status': 'ACTIVE',
      });
    });
    checkin.httpClientAdapter = TestAdapter((r) async {
      requests.add(r);
      expect(r.data['journeyId'], 'server-j1');
      expect(r.data['checkedAt'], now);
      expect(r.data['latitude'], 11.38);
      return reply({
        'milestoneCheckinId': 'server-c1',
        'verification': {'status': 'VERIFIED'},
        'qualifiesPlaceVisit': true,
        'milestoneType': 'SUMMIT',
      });
    });
    await store.sync(trekking: trekking, checkin: checkin);
    expect(requests.map((r) => r.path).toList(), [
      '/journeys',
      '/journeys/server-j1/start',
      '/checkins',
    ]);
    expect(
      (await store.checkins('server-j1')).single['verification']['status'],
      'VERIFIED',
    );
    expect(
      (await store.checkins('server-j1')).single['qualifiesPlaceVisit'],
      isTrue,
    );
    expect(
      (await store.checkins('server-j1')).single['milestoneType'],
      'SUMMIT',
    );
    expect(await (await helper.database).query('offline_outbox'), isEmpty);
    expect(
      (await store.checkins('server-j1')).single['checkinId'],
      'server-c1',
    );
  });

  test('lost acknowledgement retries with the same idempotency key without local duplicates', () async {
    await store.createJourney(body('j1'));
    await store.createJourney(body('j1'));
    final keys = <dynamic>[];
    var attempt = 0;
    trekking.httpClientAdapter = TestAdapter((r) async {
      keys.add(r.headers['Idempotency-Key']);
      if (++attempt == 1) {
        await offline(r);
      }
      return reply({
        ...body('j1'),
        'journeyId': 'server-j1',
        'status': 'PLANNED',
      });
    });
    await store.sync(trekking: trekking, checkin: checkin);
    await store.sync(trekking: trekking, checkin: checkin);
    expect(keys, ['j1', 'j1']);
    expect((await store.journeys(owner)).length, 1);
  });

  test(
    'canonical server check-in IDs do not overwrite other milestones in cache',
    () async {
      await store.createJourney(body('j1'));
      await store.cacheCheckins('j1', [
        {
          'milestoneCheckinId': 'server-1',
          'milestoneId': 'm1',
          'checkedAt': '2026-10-10T01:00:00Z',
          'verification': {'status': 'VERIFIED'},
        },
        {
          'milestoneCheckinId': 'server-2',
          'milestoneId': 'm2',
          'checkedAt': '2026-10-10T02:00:00Z',
          'verification': {'status': 'VERIFIED'},
        },
      ]);
      expect((await store.checkins('j1')).map((row) => row['checkinId']), [
        'server-1',
        'server-2',
      ]);
    },
  );

  test('upgrade retries old milestone-provider failures once and keeps the original GPS receipt', () async {
    await store.createJourney(body('j1'));
    await store.transition('j1', 'start');
    await store.checkin('j1', {
      'milestoneId': 'm1',
      'latitude': 11.38,
      'longitude': 106.17,
      'accuracyMeters': 30,
      'checkedAt': '2026-10-10T01:00:00Z',
    });
    final db = await helper.database;
    await db.update('offline_outbox', {
      'state': 'FAILED',
      'lastError': 'Milestone "m1" không tồn tại',
    }, where: "path = '/checkins'");
    await db.update('offline_checkins', {'syncStatus': 'FAILED'});
    trekking.httpClientAdapter = TestAdapter(
      (r) async =>
          reply({...body('j1'), 'journeyId': 'server-j1', 'status': 'ACTIVE'}),
    );
    var sent = 0;
    checkin.httpClientAdapter = TestAdapter((r) async {
      sent++;
      expect(r.data['latitude'], 11.38);
      expect(r.data['checkedAt'], '2026-10-10T01:00:00Z');
      return reply({
        'milestoneCheckinId': 'server-1',
        'verification': {'status': 'VERIFIED'},
      });
    });
    await store.sync(trekking: trekking, checkin: checkin);
    await store.sync(trekking: trekking, checkin: checkin);
    expect(sent, 1);
    expect((await store.checkins('j1')).single['offlineSyncStatus'], 'SYNCED');
  });

  test('34 province codes and server IDs survive offline; manual visits stay unverified', () async {
    final provinces = List.generate(
      34,
      (i) => {
        'provinceId': 'server-$i',
        'code': 'code_$i',
        'name': 'Tỉnh $i',
        'visitStatus': 'UNVISITED',
      },
    );
    await store.cacheProvinces(provinces, owner);
    await store.markProvince('server-7', true);
    await store.cacheProvinces(
      provinces,
      owner,
    ); // A stale online refresh cannot erase pending edits.
    final cached =
        await store.read('/visits/provinces/me', owner: owner) as List;
    expect(cached.length, 34);
    expect(cached[7]['code'], 'code_7');
    expect(cached[7]['visitStatus'], 'SELF_REPORTED');
    checkin.httpClientAdapter = TestAdapter((r) async {
      expect(r.path, '/visits/provinces/me/server-7');
      expect(r.data['visited'], isTrue);
      return reply({});
    });
    await store.sync(trekking: trekking, checkin: checkin);
    expect(await (await helper.database).query('offline_outbox'), isEmpty);
  });

  test('changing account hides private cache and cannot replay the other account queue', () async {
    await store.createJourney(body('j1'));
    await store.cacheProvinces([
      {'provinceId': 'p1', 'visitStatus': 'VERIFIED'},
    ], owner);
    owner = 'user-b';
    expect(await store.journeys(owner), isEmpty);
    expect(await store.read('/visits/provinces/me', owner: owner), isNull);
    var sent = 0;
    trekking.httpClientAdapter = TestAdapter((r) async {
      sent++;
      return reply({});
    });
    await store.sync(trekking: trekking, checkin: checkin);
    expect(sent, 0);
    expect(
      (await (await helper.database).query('offline_outbox')).single['ownerId'],
      'user-a',
    );
  });

  test(
    'province projection keeps independent visits for two accounts',
    () async {
      final provinces = List.generate(
        34,
        (i) => {
          'provinceId': 'server-$i',
          'code': 'code_$i',
          'name': 'Tỉnh $i',
          'visitStatus': 'UNVISITED',
        },
      );
      final dao = OfflineDataDao(
        dbHelper: helper,
        ownerProvider: () async => owner,
      );
      await store.cacheProvinces(provinces, owner);
      await store.markProvince('server-7', true);
      expect((await dao.getAllVisitedProvinces()).single.ownerId, 'user-a');
      owner = 'user-b';
      await store.cacheProvinces(provinces, owner);
      expect(await dao.getAllVisitedProvinces(), isEmpty);
      await store.markProvince('server-7', true);
      final visits = await (await helper.database).query('visited_provinces');
      expect(visits.map((v) => v['ownerId']).toSet(), {'user-a', 'user-b'});
      expect(
        (await (await helper.database).query(
          'cached_provinces',
          where: "provinceId LIKE 'server-%'",
        )).length,
        34,
      );
      owner = 'user-a';
      expect(
        (await dao.getAllVisitedProvinces()).single.provinceId,
        'server-7',
      );
    },
  );

  test(
    'milestone reordering and removal preserve check-in foreign keys',
    () async {
      await store.createJourney(body('j1'));
      await store.transition('j1', 'start');
      await store.checkin('j1', {
        'milestoneId': 'm1',
        'latitude': 11.38,
        'longitude': 106.17,
      });
      await store.cache('/routes/r/milestones', [
        {'milestoneId': 'm2', 'sequence': 1, 'name': 'Điểm 2'},
        {'milestoneId': 'm1', 'sequence': 2, 'name': 'Điểm 1'},
      ]);
      await store.cache('/routes/r/milestones', [
        {'milestoneId': 'm2', 'sequence': 1, 'name': 'Điểm 2'},
      ]);
      expect(
        (await store.read(
          '/routes/r/milestones',
        ) as List).single['milestoneId'],
        'm2',
      );
      expect((await store.checkins('j1')).single['milestoneId'], 'm1');
      expect(
        await (await helper.database).rawQuery('PRAGMA foreign_key_check'),
        isEmpty,
      );
    },
  );

  test(
    'older owned journeys remain readable without a JSON snapshot',
    () async {
      await store.createJourney(body('j1'));
      await (await helper.database).delete(
        'offline_snapshots',
        where: "resource LIKE '/journeys/%'",
      );
      final cached = await store.read('/journeys/j1', owner: owner) as Map;
      expect(cached['clientJourneyId'], 'j1');
      expect(cached['note'], 'Offline note');
      expect((await store.journeys(owner)).single['participantCount'], 3);
      owner = 'user-b';
      expect(await store.read('/journeys/j1', owner: owner), isNull);
    },
  );

  test('HTTP validation rejection is recorded as FAILED, not retried as offline success', () async {
    await store.createJourney(body('j1'));
    trekking.httpClientAdapter = TestAdapter(
      (r) async => ResponseBody.fromString(
        jsonEncode({
          'error': {'message': 'Invalid route'},
        }),
        422,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      ),
    );
    await store.sync(trekking: trekking, checkin: checkin);
    expect(await store.operationError('j1'), 'Invalid route');
    expect(
      (await (await helper.database).query('offline_outbox')).single['state'],
      'FAILED',
    );
  });

  test('v2 migration tolerates columns already present and preserves pending records', () async {
    await store.createJourney(body('j1'));
    final path = (await helper.database).path;
    await (await helper.database).execute('PRAGMA user_version = 2');
    await helper.close();
    helper = await DatabaseHelper.openForTesting(path);
    expect(await (await helper.database).getVersion(), 4);
    expect(
      (await (await helper.database).query('local_journeys'))
          .single['localJourneyId'],
      'j1',
    );
    expect(
      await (await helper.database).rawQuery('PRAGMA foreign_key_check'),
      isEmpty,
    );
  });

  test('v3 province migration preserves ownerless rows without assigning them to the next account', () async {
    final db = await helper.database;
    await db.execute('DROP TABLE visited_provinces');
    await db.execute('''CREATE TABLE visited_provinces (
      provinceId TEXT PRIMARY KEY, name TEXT NOT NULL, firstVisitedAt TEXT,
      lastVisitedAt TEXT, visitCount INTEGER DEFAULT 1, source TEXT,
      syncStatus TEXT DEFAULT 'SYNCED', updatedAt TEXT)''');
    await db.insert('visited_provinces', {
      'provinceId': 'province-tay-ninh',
      'name': 'Tây Ninh',
      'visitCount': 2,
    });
    await db.execute('PRAGMA user_version = 3');
    final dbPath = db.path;
    await helper.close();
    helper = await DatabaseHelper.openForTesting(dbPath);
    final rows = await (await helper.database).query('visited_provinces');
    expect(rows.single['ownerId'], '');
    expect(rows.single['visitCount'], 2);
    final dao = OfflineDataDao(
      dbHelper: helper,
      ownerProvider: () async => owner,
    );
    expect(await dao.getAllVisitedProvinces(), isEmpty);
    expect(
      await (await helper.database).rawQuery('PRAGMA foreign_key_check'),
      isEmpty,
    );
  });

  test('lost start acknowledgement checks server status instead of repeating an invalid transition', () async {
    await store.cacheJourneys([
      {...body('j1'), 'journeyId': 'server-j1', 'status': 'PLANNED'},
    ], owner);
    await store.transition('j1', 'start');
    var starts = 0;
    trekking.httpClientAdapter = TestAdapter((r) async {
      if (r.method == 'POST') {
        starts++;
        await offline(r);
      }
      return reply({
        ...body('j1'),
        'journeyId': 'server-j1',
        'status': 'ACTIVE',
      });
    });
    await store.sync(trekking: trekking, checkin: checkin);
    await store.sync(trekking: trekking, checkin: checkin);
    expect(starts, 1);
    expect(await (await helper.database).query('offline_outbox'), isEmpty);
    expect((await store.journeys(owner)).single['status'], 'ACTIVE');
  });

  test(
    'marker images retain uploaded URLs across offline retries and edits',
    () async {
      final uploads = <String>[];
      var offlineSecondPhoto = true;
      store = OfflineStore(
        databaseHelper: helper,
        ownerProvider: () async => owner,
        markerImageUploader: (path, client) async {
          uploads.add(path);
          if (path == '/photo-2.jpg' && offlineSecondPhoto) {
            throw DioException(
              requestOptions: RequestOptions(path: '/uploads'),
              type: DioExceptionType.connectionError,
            );
          }
          return 'https://images.example${path}';
        },
      );
      await store.cacheJourneys([
        {...body('j1'), 'journeyId': 'server-j1', 'status': 'ACTIVE'},
      ], owner);
      final now = DateTime.now().toUtc().toIso8601String();
      await store.createMarker(
        {
          'localMarkerId': 'm1',
          'localJourneyId': 'j1',
          'userId': owner,
          'name': 'Bãi nghỉ',
          'type': 'REST_POINT',
          'latitude': 11.58,
          'longitude': 108.1,
          'accuracyMeters': 8,
          'markedAt': now,
          'createdAt': now,
        },
        [
          for (var i = 1; i <= 2; i++)
            {
              'localMarkerMediaId': 'photo-$i',
              'localMarkerId': 'm1',
              'localPath': '/photo-$i.jpg',
              'createdAt': now,
            },
        ],
      );
      var writes = 0;
      trekking.httpClientAdapter = TestAdapter((r) async {
        writes++;
        expect(r.path, '/journeys/server-j1/markers');
        expect(r.data['images'], [
          'https://images.example/photo-1.jpg',
          'https://images.example/photo-2.jpg',
        ]);
        expect(r.data['accuracyMeters'], 8);
        return reply({'journeyMarkerId': 'server-m1'});
      });
      await store.sync(trekking: trekking, checkin: checkin);
      expect(writes, 0);
      expect(
        (await (await helper.database).query('local_marker_media'))
            .first['uploadStatus'],
        'UPLOADED',
      );
      offlineSecondPhoto = false;
      await store.sync(trekking: trekking, checkin: checkin);
      expect(writes, 1);
      expect(uploads, ['/photo-1.jpg', '/photo-2.jpg', '/photo-2.jpg']);
      final db = await helper.database;
      for (final name in ['removed', 'kept']) {
        await db.insert('local_marker_media', {
          'localMarkerMediaId': 'remote-$name',
          'localMarkerId': 'm1',
          'localPath': '',
          'remoteUrl': 'https://images.example/$name.jpg',
          'uploadStatus': 'UPLOADED',
          'createdAt': now,
        });
      }
      await store.changeMarker(
        'm1',
        values: {'note': ''},
        mediaLocalPaths: ['/photo-2.jpg'],
        mediaRemoteUrls: ['https://images.example/kept.jpg'],
      );
      trekking.httpClientAdapter = TestAdapter((r) async {
        expect(r.method, 'PUT');
        expect(r.data['images'], [
          'https://images.example/photo-2.jpg',
          'https://images.example/kept.jpg',
        ]);
        expect(r.data['note'], '');
        return reply({'journeyMarkerId': 'server-m1'});
      });
      await store.sync(trekking: trekking, checkin: checkin);
      expect(uploads.length, 3);
      owner = 'user-b';
      await expectLater(
        store.changeMarker('m1', mediaLocalPaths: [], mediaRemoteUrls: []),
        throwsStateError,
      );
      expect(
        (await (await helper.database).query('local_marker_media')).length,
        2,
      );
    },
  );

  test('marker create, edit and delete replay through the backend marker ID with no foreign key leftovers', () async {
    await store.cacheJourneys([
      {...body('j1'), 'journeyId': 'server-j1', 'status': 'ACTIVE'},
    ], owner);
    await store.createMarker(
      {
        'localMarkerId': 'local-marker',
        'localJourneyId': 'j1',
        'userId': owner,
        'name': 'Điểm nghỉ',
        'type': 'REST_POINT',
        'latitude': 11.38,
        'longitude': 106.17,
        'markedAt': '2026-10-10T01:00:00.000Z',
        'createdAt': '2026-10-10T01:00:00.000Z',
      },
      [
        {
          'localMarkerMediaId': 'media-1',
          'localMarkerId': 'local-marker',
          'localPath': '/offline/photo.jpg',
          'createdAt': '2026-10-10T01:00:00.000Z',
        },
      ],
    );
    await store.changeMarker('local-marker', values: {'name': 'Điểm nghỉ mới'});
    await store.changeMarker('local-marker', delete: true);
    final methods = <String>[];
    trekking.httpClientAdapter = TestAdapter((r) async {
      methods.add('${r.method} ${r.path}');
      expect(r.data.containsKey('_markerRef'), isFalse);
      return reply(
        r.method == 'DELETE' ? null : {'journeyMarkerId': 'server-marker'},
      );
    });
    await store.sync(trekking: trekking, checkin: checkin);
    expect(methods, [
      'POST /journeys/server-j1/markers',
      'PUT /journeys/server-j1/markers/server-marker',
      'DELETE /journeys/server-j1/markers/server-marker',
    ]);
    expect(
      await (await helper.database).query('local_journey_markers'),
      isEmpty,
    );
    expect(await (await helper.database).query('local_marker_media'), isEmpty);
    expect(await (await helper.database).query('offline_outbox'), isEmpty);
    expect(
      await (await helper.database).rawQuery('PRAGMA foreign_key_check'),
      isEmpty,
    );
  });

  test('offline contribution follows create, start and complete with the server journey ID', () async {
    await store.createJourney(body('j1'));
    await store.transition('j1', 'start');
    await store.transition(
      'j1',
      'complete',
      body: {
        'statistics': {'distanceMeters': 5000},
        'track': {'encodedPolyline': 'test-track'},
      },
    );
    await store.submitContribution('ROUTE_SUBMISSION', {
      'sourceJourneyId': 'j1',
      'proposedName': 'Cung đường mới',
      'clientOperationId': 'contribution-1',
    });
    expect((await store.contribution('contribution-1'))!['status'], 'DRAFT');
    final requests = <String>[];
    trekking.httpClientAdapter = TestAdapter((r) async {
      requests.add(r.path);
      if (r.path == '/contributions/routes') {
        expect(r.data['sourceJourneyId'], 'server-j1');
        expect(r.data['clientOperationId'], 'contribution-1');
        expect(r.data.containsKey('_contributionRef'), isFalse);
        return reply({
          'routeSubmissionId': 'server-contribution',
          'status': 'PENDING_REVIEW',
        });
      }
      return reply({
        ...body('j1'),
        'journeyId': 'server-j1',
        'status': r.path.endsWith('/complete')
            ? 'COMPLETED'
            : r.path.endsWith('/start')
            ? 'ACTIVE'
            : 'PLANNED',
      });
    });
    await store.sync(trekking: trekking, checkin: checkin);
    expect(requests, [
      '/journeys',
      '/journeys/server-j1/start',
      '/journeys/server-j1/complete',
      '/contributions/routes',
    ]);
    expect(
      (await store.contribution('contribution-1'))!['contributionId'],
      'server-contribution',
    );
    expect(
      (await store.contribution('contribution-1'))!['offlineSyncStatus'],
      'SYNCED',
    );
    expect(await (await helper.database).query('offline_outbox'), isEmpty);
  });

  test('active marker contribution remaps local IDs and reaches admin review state', () async {
    await store.cacheJourneys([
      {...body('j1'), 'journeyId': 'server-j1', 'status': 'ACTIVE'},
    ], owner);
    await store.createMarker({
      'localMarkerId': 'local-marker',
      'localJourneyId': 'j1',
      'userId': owner,
      'name': 'Điểm nghỉ',
      'type': 'REST_POINT',
      'latitude': 11.38,
      'longitude': 106.17,
      'markedAt': '2026-10-10T01:00:00.000Z',
      'createdAt': '2026-10-10T01:00:00.000Z',
    }, []);
    await store.submitContribution('ROUTE_SUBMISSION', {
      'sourceJourneyId': 'server-j1',
      'contributionKind': 'MARKERS',
      'markerIds': ['local-marker'],
      'proposedName': 'Cột mốc',
      'clientOperationId': 'markers-only',
    });
    trekking.httpClientAdapter = TestAdapter((r) async {
      if (r.path.endsWith('/markers'))
        return reply({'journeyMarkerId': 'server-marker'});
      expect(r.path, '/contributions/routes');
      expect(r.data['contributionKind'], 'MARKERS');
      expect(r.data['markerIds'], ['server-marker']);
      expect(r.data['sourceJourneyId'], 'server-j1');
      return reply({
        'routeSubmissionId': 'submission',
        'status': 'PENDING_REVIEW',
      });
    });
    await store.sync(trekking: trekking, checkin: checkin);
    expect(
      (await store.contribution('markers-only'))!['status'],
      'PENDING_REVIEW',
    );
  });

  test(
    'permanent rejection does not block a separate queued contribution',
    () async {
      for (final id in ['bad', 'good']) {
        await store.submitContribution('PLACE_SUGGESTION', {
          'clientOperationId': id,
          'proposedName': id,
        });
      }
      trekking.httpClientAdapter = TestAdapter(
        (r) async => r.data['clientOperationId'] == 'bad'
            ? reply({'message': 'Invalid province'}, status: 422)
            : reply({
                'placeSuggestionId': 'accepted',
                'status': 'PENDING_REVIEW',
              }),
      );
      await store.sync(trekking: trekking, checkin: checkin);
      expect((await store.contribution('bad'))!['offlineSyncStatus'], 'FAILED');
      expect(
        (await store.contribution('good'))!['offlineSyncStatus'],
        'SYNCED',
      );
    },
  );

  test('legacy contribution queue resumes only for its owner using the original operation ID', () async {
    final db = await helper.database;
    await store.createJourney(body('j1'));
    await db.delete('offline_outbox');
    final payload = {
      'sourceJourneyId': 'server-j1',
      'clientOperationId': 'original-operation',
      'proposedName': 'Cung đường',
    };
    await db.insert('local_contributions', {
      'localContributionId': 'legacy',
      'userId': owner,
      'type': 'ROUTE_SUBMISSION',
      'payload': jsonEncode(payload),
      'syncStatus': 'PENDING',
    });
    await db.insert('sync_queue', {
      'entityType': 'ROUTE_SUBMISSION',
      'entityId': 'legacy',
      'operation': 'CREATE',
      'payload': jsonEncode(payload),
      'idempotencyKey': 'legacy-key',
      'createdAt': '2026-10-10',
    });
    owner = 'user-b';
    await store.sync(trekking: trekking, checkin: checkin);
    expect(await db.query('offline_outbox'), isEmpty);
    owner = 'user-a';
    trekking.httpClientAdapter = TestAdapter((r) async {
      expect(r.path, '/contributions/routes');
      expect(r.data['clientOperationId'], 'original-operation');
      return reply({
        'routeSubmissionId': 'server-contribution',
        'status': 'PENDING_REVIEW',
      });
    });
    await store.sync(trekking: trekking, checkin: checkin);
    expect(await db.query('sync_queue'), isEmpty);
    expect(
      (await store.contribution('legacy'))!['offlineSyncStatus'],
      'SYNCED',
    );
  });

  test('place contribution validation errors remain FAILED and can be explicitly corrected', () async {
    await store.submitContribution('PLACE_SUGGESTION', {
      'clientOperationId': 'suggestion-1',
      'proposedName': 'Núi mới',
    });
    trekking.httpClientAdapter = TestAdapter(
      (r) async => reply({'message': 'Invalid province'}, status: 422),
    );
    await store.sync(trekking: trekking, checkin: checkin);
    expect(
      (await store.contribution('suggestion-1'))!['offlineSyncStatus'],
      'FAILED',
    );
    await store.submitContribution('PLACE_SUGGESTION', {
      'clientOperationId': 'suggestion-1',
      'provinceId': 'tay_ninh',
      'proposedName': 'Núi mới',
    });
    trekking.httpClientAdapter = TestAdapter(
      (r) async => reply({
        'placeSuggestionId': 'server-suggestion',
        'status': 'PENDING_REVIEW',
      }),
    );
    await store.sync(trekking: trekking, checkin: checkin);
    expect(
      (await store.contribution('suggestion-1'))!['offlineSyncStatus'],
      'SYNCED',
    );
    expect(
      (await (await helper.database).query('local_contributions')).length,
      1,
    );
  });
}
