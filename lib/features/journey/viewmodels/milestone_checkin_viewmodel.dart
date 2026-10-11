import 'package:geolocator/geolocator.dart';

import '../../../core/services/trekking_catalog_service.dart';
import '../../../core/services/location_service.dart';
import '../../../core/network/api_error_handler.dart';

import 'package:flutter/material.dart';

import '../data/models/journey_model.dart';
import '../data/models/milestone_model.dart';

class MilestoneCheckinViewModel extends ChangeNotifier {
  MilestoneModel _milestone;
  JourneyModel? journey;
  final String? _customMapImageUrl;

  bool _isLoading = false;
  late bool _isCheckedIn;
  int? _distanceMeters;
  bool _disposed = false;
  String? error;
  final TrekkingCatalogService _api;
  final LocationService location;
  bool _pendingSync = false;
  bool get pendingSync => _pendingSync;
  bool get finishesJourney => _milestone.type == 'FINISH';

  MilestoneCheckinViewModel({
    required MilestoneModel milestone,
    this.journey,
    String? mapImageUrl,
    TrekkingCatalogService? api,
    LocationService? locationService,
  }) : _milestone = milestone,
       _api = api ?? TrekkingCatalogService(),
       location = locationService ?? LocationService.instance,
       _customMapImageUrl = mapImageUrl {
    _isCheckedIn = milestone.isCheckedIn;
    location.addListener(_updateLocation);
    _updateLocation();
  }

  void _updateLocation() {
    final pos = location.position;
    _distanceMeters = pos == null
        ? null
        : Geolocator.distanceBetween(
            pos.latitude,
            pos.longitude,
            _milestone.latitude,
            _milestone.longitude,
          ).round();
    if (!_disposed) notifyListeners();
  }

  MilestoneModel get milestone => _milestone;
  bool get isLoading => _isLoading;
  bool get isCheckedIn => _isCheckedIn;
  int? get distanceMeters => _distanceMeters;
  int get allowedRadiusMeters => _milestone.checkinRadiusMeters.round();
  bool get isWithinRange =>
      _distanceMeters != null && _distanceMeters! <= allowedRadiusMeters;
  bool get canActivateJourney =>
      journey?.status == JourneyStatus.planned ||
      journey?.status == JourneyStatus.paused;
  String get activateJourneyLabel => journey?.status == JourneyStatus.paused
      ? 'Tiếp tục hành trình'
      : 'Bắt đầu hành trình';
  bool get canCheckIn =>
      !_isLoading &&
      !_isCheckedIn &&
      journey?.status == JourneyStatus.active &&
      isWithinRange &&
      location.hasPermission &&
      location.serviceEnabled &&
      location.error == null &&
      (location.position?.accuracy ?? 999) <= 50;
  String get locationStatus {
    if (_isCheckedIn) return 'Bạn đã check-in cột mốc này';
    if (journey?.status == JourneyStatus.paused) {
      return 'Hành trình đang tạm dừng. Tiếp tục hành trình để check-in.';
    }
    if (journey?.status == JourneyStatus.planned) {
      return 'Hành trình chưa bắt đầu. Bắt đầu hành trình để check-in.';
    }
    if (journey?.status != JourneyStatus.active) {
      return 'Chỉ có thể check-in khi hành trình đang đi.';
    }
    if (location.error != null) return location.error!;
    if (_distanceMeters == null) return 'Đang xác định vị trí GPS…';
    if ((location.position?.accuracy ?? 999) > 50) {
      return 'GPS chưa đủ chính xác. Hãy ra nơi thoáng và thử lại.';
    }
    return '${isWithinRange ? 'Trong' : 'Ngoài'} phạm vi check-in • cách $_distanceMeters m';
  }

  String get mapImageUrl {
    final customUrl = _customMapImageUrl;
    if (customUrl != null && customUrl.isNotEmpty) {
      return customUrl;
    }
    return journey?.route.imageUrl ??
        'https://images.unsplash.com/photo-1524661135-423995f22d0b?w=800';
  }

  String get destinationName {
    if (_milestone.name.isNotEmpty) {
      return _milestone.name;
    }
    return journey?.name ?? 'Điểm kiểm soát';
  }

  String get formattedAltitude {
    final alt = _milestone.altitude > 0
        ? _milestone.altitude
        : (journey?.route.maxElevation ?? 0);
    return alt.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  Future<bool> activateJourney() async {
    final current = journey;
    if (_isLoading || !canActivateJourney || current == null) return false;
    _isLoading = true;
    error = null;
    notifyListeners();
    try {
      await _api.transitionJourney(
        current.journeyId,
        current.status == JourneyStatus.paused ? 'resume' : 'start',
      );
      final refreshed = await _api.getJourney(current.journeyId);
      if (_disposed) return false;
      journey = refreshed;
      if (refreshed.status != JourneyStatus.active) {
        throw StateError(
          'Hành trình chưa chuyển sang trạng thái đang đi. Vui lòng thử lại.',
        );
      }
      return true;
    } catch (e) {
      if (!_disposed) error = ApiErrorHandler.handle(e);
      return false;
    } finally {
      if (!_disposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<bool> checkIn() async {
    if (_isLoading || _isCheckedIn) return false;
    if (journey?.status != JourneyStatus.active) {
      error = 'Bắt đầu hoặc tiếp tục hành trình để check-in.';
      notifyListeners();
      return false;
    }
    _isLoading = true;
    error = null;
    notifyListeners();
    try {
      final pos = await location.currentPosition();
      if (_disposed) return false;
      if (!pos.accuracy.isFinite || pos.accuracy > 50) {
        throw StateError(
          'GPS chưa đủ chính xác. Hãy ra nơi thoáng và thử lại.',
        );
      }
      _distanceMeters = Geolocator.distanceBetween(
        pos.latitude,
        pos.longitude,
        _milestone.latitude,
        _milestone.longitude,
      ).round();
      final now = DateTime.now().toUtc();
      if (_distanceMeters! > allowedRadiusMeters) {
        throw StateError('Bạn đang ngoài bán kính check-in.');
      }
      final data = await _api.checkIn(journey!.journeyId, {
        'milestoneId': _milestone.id,
        'latitude': pos.latitude,
        'longitude': pos.longitude,
        'accuracyMeters': pos.accuracy,
        'checkedAt': now.toIso8601String(),
      });
      if (_disposed) return false;
      _pendingSync = data['offlineSyncStatus'] == 'PENDING';
      if (finishesJourney) {
        await _api.completeJourneyAfterCheckin(journey!.journeyId);
        if (_disposed) return false;
      }
      _milestone = _milestone.copyWith(
        isCheckedIn: true,
        checkedInAt:
            DateTime.tryParse(data['checkedAt']?.toString() ?? '') ?? now,
      );
      _isCheckedIn = true;
      return true;
    } catch (e) {
      if (!_disposed) {
        error = e is StateError ? e.message : ApiErrorHandler.handle(e);
      }
      return false;
    } finally {
      if (!_disposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    location.removeListener(_updateLocation);
    super.dispose();
  }
}
