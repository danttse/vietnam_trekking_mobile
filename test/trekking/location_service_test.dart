import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vietnam_trekking_mobile/core/services/location_service.dart';

class Gps extends GeolocatorPlatform {
  LocationPermission permission = LocationPermission.denied;
  LocationPermission answer = LocationPermission.whileInUse;
  bool enabled = true;
  int requests = 0, fixes = 0, streams = 0, settings = 0, gpsSettings = 0;
  final updates = StreamController<Position>.broadcast();
  final position = Position(
    latitude: 11.58,
    longitude: 108.1,
    timestamp: DateTime.now(),
    accuracy: 8,
    altitude: 1100,
    altitudeAccuracy: 8,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
  );
  @override
  Future<LocationPermission> checkPermission() async => permission;
  @override
  Future<LocationPermission> requestPermission() async {
    requests++;
    return permission = answer;
  }

  @override
  Future<bool> isLocationServiceEnabled() async => enabled;
  @override
  Future<Position> getCurrentPosition({
    LocationSettings? locationSettings,
  }) async {
    fixes++;
    return position;
  }

  @override
  Stream<Position> getPositionStream({LocationSettings? locationSettings}) {
    streams++;
    return updates.stream;
  }

  @override
  Future<bool> openAppSettings() async {
    settings++;
    return true;
  }

  @override
  Future<bool> openLocationSettings() async {
    gpsSettings++;
    return true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Gps gps;
  late LocationService location;
  late GeolocatorPlatform original;
  setUp(() {
    original = GeolocatorPlatform.instance;
    gps = Gps();
    GeolocatorPlatform.instance = gps;
    location = LocationService();
  });
  tearDown(() async {
    location.dispose();
    await gps.updates.close();
    GeolocatorPlatform.instance = original;
  });
  test(
    'startup prompts once, saves a fix and only streams while a screen listens',
    () async {
      await location.initialize(requestPermission: true);
      expect(gps.requests, 1);
      expect(location.position, gps.position);
      expect(gps.streams, 0);
      void listen() {}
      location.addListener(listen);
      await location.initialize();
      expect(gps.requests, 1);
      expect(gps.streams, 1);
      location.removeListener(listen);
      await Future<void>.delayed(Duration.zero);
      expect(gps.updates.hasListener, isFalse);
    },
  );
  test('denial is respected until the user explicitly retries', () async {
    gps.answer = LocationPermission.denied;
    await location.initialize(requestPermission: true);
    expect(location.position, isNull);
    expect(location.error, isNotNull);
    await location.initialize();
    expect(gps.requests, 1);
    expect(gps.fixes, 0);
    gps.answer = LocationPermission.whileInUse;
    await location.recover();
    expect(gps.requests, 2);
    expect(location.hasPermission, isTrue);
  });
  test(
    'permanent denial opens app settings; disabled GPS opens location settings',
    () async {
      gps.permission = LocationPermission.deniedForever;
      await location.initialize(requestPermission: true);
      await location.recover();
      expect(gps.requests, 0);
      expect(gps.settings, 1);
      gps.permission = LocationPermission.whileInUse;
      gps.enabled = false;
      await location.initialize();
      await location.recover();
      expect(gps.gpsSettings, 1);
      expect(location.position, isNull);
    },
  );
  test('GPS stops in background and restores on resume; revocation clears the stored fix', () async {
    void listen() {}
    location.addListener(listen);
    await location.initialize(requestPermission: true);
    expect(gps.updates.hasListener, isTrue);
    location.didChangeAppLifecycleState(AppLifecycleState.paused);
    await Future<void>.delayed(Duration.zero);
    expect(gps.updates.hasListener, isFalse);
    location.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await location.initialize();
    expect(gps.streams, 2);
    gps.permission = LocationPermission.deniedForever;
    await location.initialize();
    expect(location.position, isNull);
    expect(gps.updates.hasListener, isFalse);
  });
  test('a fresh fix clears obsolete coordinates when GPS or permission is disabled', () async {
    await location.initialize(requestPermission: true);
    gps.enabled = false;
    await expectLater(location.currentPosition(), throwsStateError);
    expect(location.serviceEnabled, isFalse);
    expect(location.position, isNull);
    expect(location.error, contains('GPS'));
    gps.enabled = true;
    gps.permission = LocationPermission.deniedForever;
    await expectLater(location.currentPosition(), throwsStateError);
    expect(location.hasPermission, isFalse);
    expect(location.position, isNull);
    expect(location.error, contains('quyền vị trí'));
  });
}
