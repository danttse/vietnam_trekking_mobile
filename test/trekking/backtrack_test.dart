import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:vietnam_trekking_mobile/core/database/database_helper.dart';
import 'package:vietnam_trekking_mobile/core/database/models/track_point.dart';
import 'package:vietnam_trekking_mobile/core/services/journey_track.dart';
import 'package:vietnam_trekking_mobile/core/services/offline_store.dart';
import 'package:vietnam_trekking_mobile/core/services/journey_tracking_service.dart';
import 'package:vietnam_trekking_mobile/core/services/location_service.dart';
import 'package:vietnam_trekking_mobile/core/services/auth_event_bus.dart';

import 'offline_store_test.dart' show TestAdapter, reply;

class RecordingLocation extends LocationService {
  @override
  Future<void> initialize({bool requestPermission = false}) async {}

  void emit(TrackPoint point) {
    position = Position(
      latitude: point.latitude,
      longitude: point.longitude,
      timestamp: point.recordedAt,
      accuracy: point.accuracy!,
      altitude: point.altitude!,
      altitudeAccuracy: 5,
      heading: 0,
      headingAccuracy: 0,
      speed: 1,
      speedAccuracy: 1,
    );
    notifyListeners();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  late Directory directory;
  late DatabaseHelper helper;
  late OfflineStore store;
  var owner = 'walker';
  late DateTime now;
  TrackPoint point(int index, {double accuracy = 8, double? latitude}) =>
      TrackPoint(
        localJourneyId: 'local-trip',
        latitude: latitude ?? 11 + index * 0.0001,
        longitude: 106,
        altitude: 100 + index * 4.0,
        accuracy: accuracy,
        recordedAt: now.subtract(Duration(seconds: 20 - index * 10)),
      );

  setUp(() async {
    now = DateTime.now().toUtc();
    owner = 'walker';
    directory = await Directory.systemTemp.createTemp('trekvn-backtrack-');
    helper = await DatabaseHelper.openForTesting('${directory.path}/app.db');
    store = OfflineStore(
      databaseHelper: helper,
      ownerProvider: () async => owner,
    );
    await store.createJourney({
      'clientJourneyId': 'local-trip',
      'name': 'Test trip',
      'trekkingPlaceId': 'place',
      'trekkingRouteId': 'route',
    });
    await store.transition('local-trip', 'start');
    await store.setTrackRecording('local-trip', true);
  });
  tearDown(() async {
    await helper.close();
    await directory.delete(recursive: true);
  });

  test('precision-5 polyline matches the standard example and rejects malformed input', () {
    const encoded = '_p~iF~ps|U_ulLnnqC_mqNvxq`@';
    final points = JourneyTrack.decode(encoded, 'trip');
    expect(points.map((p) => [p.latitude, p.longitude]), [
      [38.5, -120.2],
      [40.7, -120.95],
      [43.252, -126.453],
    ]);
    expect(JourneyTrack.encode(points), encoded);
    expect(JourneyTrack.decode('_', 'trip'), isEmpty);
    expect(JourneyTrack.decode('invalid!', 'trip'), isEmpty);
  });

  test('filters inaccurate, stale, duplicate and jumping GPS fixes', () async {
    expect(await store.recordTrackPoint(point(0), owner: owner), isTrue);
    expect(await store.recordTrackPoint(point(0), owner: owner), isFalse);
    expect(
      await store.recordTrackPoint(point(1, accuracy: 100), owner: owner),
      isFalse,
    );
    expect(
      await store.recordTrackPoint(point(1, latitude: 12), owner: owner),
      isFalse,
    );
    final stale = TrackPoint(
      localJourneyId: 'local-trip',
      latitude: 11,
      longitude: 106,
      accuracy: 5,
      recordedAt: now.subtract(const Duration(minutes: 5)),
    );
    expect(await store.recordTrackPoint(stale, owner: owner), isFalse);
    expect(await store.recordTrackPoint(point(1), owner: owner), isTrue);
    expect(await store.trackPoints('local-trip'), hasLength(2));
  });

  test(
    'saved GPS and recording setting survive reopening the database',
    () async {
      await store.recordTrackPoint(point(0), owner: owner);
      await helper.close();
      helper = await DatabaseHelper.openForTesting('${directory.path}/app.db');
      store = OfflineStore(
        databaseHelper: helper,
        ownerProvider: () async => owner,
      );
      expect(await store.trackPoints('local-trip'), hasLength(1));
      expect(await store.isRecordingTrack('local-trip'), isTrue);
    },
  );

  test('pausing, stopping or completing prevents more points; resume preserves track', () async {
    await store.recordTrackPoint(point(0), owner: owner);
    await store.transition('local-trip', 'pause');
    expect(await store.recordTrackPoint(point(1), owner: owner), isFalse);
    await store.transition('local-trip', 'resume');
    expect(await store.recordTrackPoint(point(1), owner: owner), isTrue);
    await store.setTrackRecording('local-trip', false);
    expect(await store.recordTrackPoint(point(2), owner: owner), isFalse);
    await store.transition('local-trip', 'complete');
    expect(await store.isRecordingTrack('local-trip'), isFalse);
    expect(await store.recordTrackPoint(point(2), owner: owner), isFalse);
  });

  test('other accounts cannot read or append a private GPS track', () async {
    await store.recordTrackPoint(point(0), owner: owner);
    owner = 'other-account';
    await expectLater(store.trackPoints('local-trip'), throwsStateError);
    await expectLater(
      store.recordTrackPoint(point(1), owner: 'walker'),
      throwsStateError,
    );
  });

  test(
    'recorder keeps saving without map listeners, pauses and clears on logout',
    () async {
      final location = RecordingLocation();
      final tracking = JourneyTrackingService(store: store, location: location);
      await tracking.open('local-trip');
      location.emit(point(0));
      await tracking.flush();
      expect(tracking.points, hasLength(1));
      await store.transition('local-trip', 'pause');
      await Future<void>.delayed(Duration.zero);
      await tracking.flush();
      location.emit(point(1));
      await tracking.flush();
      expect(tracking.recording, isFalse);
      expect(tracking.points, hasLength(1));
      await store.transition('local-trip', 'resume');
      await Future<void>.delayed(Duration.zero);
      await tracking.flush();
      location.emit(point(1));
      await tracking.flush();
      expect(tracking.points, hasLength(2));
      AuthEventBus().fire(AuthEvent.loggedOut);
      await Future<void>.delayed(Duration.zero);
      expect(tracking.points, isEmpty);
      expect(tracking.enabled, isFalse);
      location.emit(point(2));
      await tracking.flush();
      expect(await store.trackPoints('local-trip'), hasLength(2));
      tracking.dispose();
      location.dispose();
    },
  );

  test(
    'completion and sharing replay in order with GPS and server journey id',
    () async {
      final points = [point(0), point(1), point(2)];
      for (final p in points) {
        await store.recordTrackPoint(p, owner: owner);
      }
      await store.transition('local-trip', 'complete');
      final snapshot =
          await store.read('/journeys/local-trip', owner: owner) as Map;
      expect(snapshot['track']['encodedPolyline'], JourneyTrack.encode(points));
      expect(snapshot['statistics']['distanceMeters'], greaterThan(20));
      expect(snapshot['statistics']['durationSeconds'], 20);
      await store.submitContribution('ROUTE_SUBMISSION', {
        'sourceJourneyId': 'local-trip',
        'proposedName': 'Recorded route',
        'encodedPolyline': snapshot['track']['encodedPolyline'],
        'statistics': snapshot['statistics'],
        'clientOperationId': 'share-trip',
      });
      final requests = <RequestOptions>[];
      const serverId = '507f1f77bcf86cd799439011';
      final dio = Dio(BaseOptions(baseUrl: 'http://tests'));
      dio.httpClientAdapter = TestAdapter((request) async {
        requests.add(request);
        if (request.path == '/contributions/routes') {
          return reply({
            'routeSubmissionId': 'submission',
            'status': 'PENDING_REVIEW',
          });
        }
        final status = request.path.endsWith('/complete')
            ? 'COMPLETED'
            : request.path.endsWith('/start')
            ? 'ACTIVE'
            : 'PLANNED';
        return reply({
          'journeyId': serverId,
          'clientJourneyId': 'local-trip',
          'trekkingPlaceId': 'place',
          'trekkingRouteId': 'route',
          'name': 'Trip',
          'status': status,
          if (status == 'COMPLETED') ...{
            'track': snapshot['track'],
            'statistics': snapshot['statistics'],
          },
        });
      });
      await store.sync(trekking: dio, checkin: dio);
      expect(requests.map((r) => r.path), [
        '/journeys',
        '/journeys/$serverId/start',
        '/journeys/$serverId/complete',
        '/contributions/routes',
      ]);
      final completion = requests[2].data as Map;
      expect(
        completion['track']['encodedPolyline'],
        JourneyTrack.encode(points),
      );
      expect(completion['completedAt'], isNotNull);
      expect((requests[3].data as Map)['sourceJourneyId'], serverId);
      expect(
        (await store.contribution('share-trip'))!['status'],
        'PENDING_REVIEW',
      );
      await store.sync(trekking: dio, checkin: dio);
      expect(requests, hasLength(4));
    },
  );
}
