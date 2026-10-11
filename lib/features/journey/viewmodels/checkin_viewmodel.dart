import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../data/models/milestone_model.dart';

enum CheckinGpsState { acquiring, inRange, outOfRange }

enum CheckinSubmitState { idle, submitting, success, error }

/// ViewModel cho màn hình Check-in GPS.
/// Business logic GPS/radius được xử lý ở đây.
/// Việc gọi API check-in delegate sang checkin-service (không trong JourneyRepository).
class CheckinViewModel extends ChangeNotifier {
  final MilestoneModel milestone;

  CheckinViewModel({required this.milestone});

  // ── GPS state ─────────────────────────────────────────────────────────────
  CheckinGpsState _gpsState = CheckinGpsState.acquiring;
  CheckinGpsState get gpsState => _gpsState;

  double? _currentLat;
  double? _currentLng;
  double? _currentAccuracy;
  double? get distanceToTarget => _distance;
  double? _distance;

  CheckinSubmitState _submitState = CheckinSubmitState.idle;
  CheckinSubmitState get submitState => _submitState;

  String? _error;
  String? get error => _error;

  // Result from successful checkin (badge info, stats, etc.)
  Map<String, dynamic>? checkinResult;

  // ── GPS update (called by screen when location changes) ───────────────────

  void updateLocation(double lat, double lng, double accuracy) {
    _currentLat = lat;
    _currentLng = lng;
    _currentAccuracy = accuracy;
    _distance = _haversineDistance(
      lat,
      lng,
      milestone.latitude,
      milestone.longitude,
    );
    final radius = milestone.checkinRadiusMeters;
    _gpsState = _distance! <= radius
        ? CheckinGpsState.inRange
        : CheckinGpsState.outOfRange;
    notifyListeners();
  }

  bool get canCheckin =>
      _gpsState == CheckinGpsState.inRange &&
      _currentAccuracy != null &&
      _currentAccuracy!.isFinite &&
      _currentAccuracy! >= 0 &&
      _currentAccuracy! <= 50 &&
      _submitState == CheckinSubmitState.idle;

  String get distanceLabel {
    if (_distance == null) return '--';
    if (_distance! < 1000) return '${_distance!.toInt()}m';
    return '${(_distance! / 1000).toStringAsFixed(1)}km';
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  /// Thực hiện check-in. [checkinFn] là hàm gọi checkin-service
  /// (được inject từ screen để tách biệt service).
  Future<void> performCheckin(
    Future<Map<String, dynamic>> Function({
      required String milestoneId,
      required double latitude,
      required double longitude,
      required double accuracy,
      required double distanceToTarget,
    })
    checkinFn,
  ) async {
    if (!canCheckin || _currentLat == null) return;

    _submitState = CheckinSubmitState.submitting;
    _error = null;
    notifyListeners();

    try {
      checkinResult = await checkinFn(
        milestoneId: milestone.milestoneId,
        latitude: _currentLat!,
        longitude: _currentLng!,
        accuracy: _currentAccuracy ?? 0,
        distanceToTarget: _distance ?? 0,
      );
      _submitState = CheckinSubmitState.success;
    } catch (e) {
      _error = e.toString();
      _submitState = CheckinSubmitState.error;
    }
    notifyListeners();
  }

  void reset() {
    _submitState = CheckinSubmitState.idle;
    _error = null;
    notifyListeners();
  }

  // ── Haversine ─────────────────────────────────────────────────────────────

  static double _haversineDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const r = 6371000.0; // metres
    final phi1 = lat1 * math.pi / 180;
    final phi2 = lat2 * math.pi / 180;
    final dPhi = (lat2 - lat1) * math.pi / 180;
    final dLambda = (lng2 - lng1) * math.pi / 180;
    final a =
        math.sin(dPhi / 2) * math.sin(dPhi / 2) +
        math.cos(phi1) *
            math.cos(phi2) *
            math.sin(dLambda / 2) *
            math.sin(dLambda / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }
}
