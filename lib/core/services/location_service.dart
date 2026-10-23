import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';

/// Foreground GPS shared by check-in and journey maps.
class LocationService extends ChangeNotifier with WidgetsBindingObserver {
  static final instance = LocationService();

  Position? position;
  LocationPermission permission = LocationPermission.denied;
  bool serviceEnabled = false;
  bool loading = false;
  String? error;
  StreamSubscription<Position>? _subscription;
  Future<void>? _initializing;
  bool _observing = false;
  bool _active = true;

  bool get hasPermission =>
      permission == LocationPermission.always ||
      permission == LocationPermission.whileInUse;

  Future<void> initialize({bool requestPermission = false}) {
    return _initializing ??= _initialize(requestPermission).whenComplete(() {
      _initializing = null;
    });
  }

  Future<void> _initialize(bool request) async {
    if (!_observing) {
      WidgetsBinding.instance.addObserver(this);
      _observing = true;
    }
    loading = true;
    error = null;
    notifyListeners();
    try {
      permission = await Geolocator.checkPermission();
      if (request && permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!hasPermission) {
        position = null;
        await _subscription?.cancel();
        _subscription = null;
        error = permission == LocationPermission.deniedForever
            ? 'Mở cài đặt để cho phép TrekViệt truy cập vị trí.'
            : 'Cho phép vị trí để xem bạn trên bản đồ và check-in.';
      } else if (!serviceEnabled) {
        position = null;
        await _subscription?.cancel();
        _subscription = null;
        error = 'Vui lòng bật dịch vụ vị trí (GPS).';
      } else {
        await currentPosition();
        if (_active && hasListeners && _subscription == null) {
          _subscription =
              Geolocator.getPositionStream(
                locationSettings: const LocationSettings(
                  accuracy: LocationAccuracy.high,
                  distanceFilter: 5,
                ),
              ).listen(
                (value) {
                  position = value;
                  error = null;
                  notifyListeners();
                },
                onError: (Object _) {
                  error =
                      'GPS bị gián đoạn. Vui lòng kiểm tra vị trí và thử lại.';
                  notifyListeners();
                },
              );
        }
      }
    } catch (e) {
      error = e is StateError
          ? e.message
          : 'Chưa lấy được vị trí. Hãy ra nơi thoáng và thử lại.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Always fetch a fresh fix for check-in or creating a GPS marker.
  Future<Position> currentPosition() async {
    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      permission = await Geolocator.checkPermission();
      if (!serviceEnabled || !hasPermission) {
        position = null;
        await _subscription?.cancel();
        _subscription = null;
        throw StateError(
          !serviceEnabled
              ? 'Vui lòng bật dịch vụ vị trí (GPS).'
              : 'Vui lòng cấp quyền vị trí để tiếp tục.',
        );
      }
      final value = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      position = value;
      error = null;
      return value;
    } catch (e) {
      error = e is StateError
          ? e.message
          : 'Chưa lấy được vị trí. Hãy ra nơi thoáng và thử lại.';
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  Future<void> recover() async {
    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
    } else if (!serviceEnabled && hasPermission) {
      await Geolocator.openLocationSettings();
    } else {
      await initialize(requestPermission: true);
    }
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    if (!hasListeners) {
      unawaited(_subscription?.cancel());
      _subscription = null;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _active = state == AppLifecycleState.resumed;
    if (_active) {
      unawaited(initialize());
    } else {
      unawaited(_subscription?.cancel());
      _subscription = null;
    }
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    if (_observing) WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
