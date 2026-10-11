import 'dart:async';

import 'package:flutter/foundation.dart';

import '../database/models/track_point.dart';
import 'journey_track.dart';
import 'location_service.dart';
import 'offline_store.dart';
import 'auth_event_bus.dart';

/// Keeps recording while navigating within the app. GPS is foreground only.
class JourneyTrackingService extends ChangeNotifier {
  static final instance = JourneyTrackingService();
  final OfflineStore store;
  final LocationService location;
  JourneyTrackingService({OfflineStore? store, LocationService? location})
    : store = store ?? OfflineStore.instance,
      location = location ?? LocationService.instance;

  String? journeyId, ownerId;
  bool enabled = false;
  String status = '';
  String? error;
  List<TrackPoint> points = [];
  Future<void> _pending = Future.value();
  StreamSubscription<String>? _changes;
  bool _listening = false;
  bool _disposed = false;
  StreamSubscription<AuthEvent>? _auth;

  bool get recording => enabled && status == 'ACTIVE';
  double get distanceMeters {
    var meters = 0.0;
    for (var i = 1; i < points.length; i++) {
      if (points[i].recordedAt.difference(points[i - 1].recordedAt).inSeconds >
          120) {
        continue;
      }
      meters += JourneyTrack.distance(points[i - 1], points[i]);
    }
    return meters;
  }

  Future<void> open(String ref, {String? encodedPolyline}) async {
    await flush();
    final owner = await store.requireOwner();
    final localId = await store.localJourneyId(ref);
    if (journeyId != localId || ownerId != owner) _detach();
    journeyId = localId;
    ownerId = owner;
    _auth ??= AuthEventBus().stream.listen((_) {
      _detach();
      enabled = false;
      journeyId = null;
      ownerId = null;
      points = [];
      notifyListeners();
    });
    points = await store.trackPoints(localId);
    if (_disposed || journeyId != localId || ownerId != owner) return;
    if (points.isEmpty && encodedPolyline?.isNotEmpty == true) {
      points = JourneyTrack.decode(encodedPolyline!, localId);
    }
    error = null;
    await _refresh();
    if (_disposed || journeyId != localId || ownerId != owner) return;
    _changes ??= store.changes.listen((_) {
      _pending = _pending.then((_) => _refresh()).catchError(_failure);
    });
  }

  Future<void> _refresh() async {
    if (_disposed || journeyId == null) return;
    final ref = journeyId!, owner = ownerId!;
    final currentOwner = await store.ownerProvider();
    if (_disposed || ref != journeyId || owner != ownerId) return;
    if (currentOwner != owner) {
      _detach();
      enabled = false;
      points = [];
      journeyId = null;
      notifyListeners();
      return;
    }
    final saved = await store.read('/journeys/$ref', owner: owner);
    if (_disposed || ref != journeyId || owner != ownerId) return;
    status = (saved as Map?)?['status']?.toString() ?? '';
    final shouldRecord = await store.isRecordingTrack(ref);
    if (_disposed || ref != journeyId || owner != ownerId) return;
    enabled = shouldRecord;
    if (enabled && (status == 'ACTIVE' || status == 'PAUSED')) {
      if (!_listening) {
        location.addListener(_locationChanged);
        _listening = true;
      }
    } else if (_listening) {
      location.removeListener(_locationChanged);
      _listening = false;
    }
    notifyListeners();
  }

  Future<void> setEnabled(bool value) async {
    if (journeyId == null) return;
    await flush();
    await store.setTrackRecording(journeyId!, value);
    error = null;
    await _refresh();
    if (value) await location.initialize(requestPermission: true);
  }

  void _locationChanged() {
    final position = location.position;
    if (!recording || position == null || location.error != null) return;
    final ref = journeyId!, owner = ownerId!;
    final point = TrackPoint(
      localJourneyId: ref,
      latitude: position.latitude,
      longitude: position.longitude,
      altitude: position.altitude.isFinite ? position.altitude : null,
      accuracy: position.accuracy,
      speed: position.speed,
      heading: position.heading,
      recordedAt: position.timestamp.toUtc(),
    );
    _pending = _pending
        .then((_) async {
          if (_disposed || ref != journeyId || owner != ownerId) return;
          if (await store.recordTrackPoint(point, owner: owner)) {
            if (_disposed || ref != journeyId || owner != ownerId) return;
            points = [...points, point];
            error = null;
            notifyListeners();
          }
        })
        .catchError(_failure);
  }

  void _failure(Object failure) {
    if (_disposed) return;
    error = failure is StateError
        ? failure.message
        : 'Không lưu được GPS. Vui lòng thử lại.';
    notifyListeners();
  }

  Future<void> flush() => _pending;

  void _detach() {
    if (_listening) location.removeListener(_locationChanged);
    _listening = false;
    unawaited(_changes?.cancel());
    _changes = null;
    unawaited(_auth?.cancel());
    _auth = null;
  }

  @override
  void dispose() {
    _disposed = true;
    _detach();
    super.dispose();
  }
}
