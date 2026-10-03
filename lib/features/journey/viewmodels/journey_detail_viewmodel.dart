import 'package:flutter/foundation.dart';
import '../data/models/journey_model.dart';
import '../data/models/milestone_model.dart';
import '../data/models/marker_model.dart';
import '../data/models/route_model.dart';
import '../data/repositories/journey_repository.dart';

enum JourneyDetailState { idle, loading, success, error }

class JourneyDetailViewModel extends ChangeNotifier {
  final JourneyRepository _repo;
  final String journeyId; // localJourneyId hoặc serverJourneyId

  JourneyDetailViewModel({
    required this.journeyId,
    JourneyRepository? repo,
  }) : _repo = repo ?? JourneyRepository();

  // ── State ─────────────────────────────────────────────────────────────────
  JourneyDetailState _state = JourneyDetailState.idle;
  JourneyDetailState get state => _state;

  JourneyModel? _journey;
  JourneyModel? get journey => _journey;

  RouteModel? _route;
  RouteModel? get route => _route;

  List<MilestoneModel> _milestones = [];
  List<MilestoneModel> get milestones => _milestones;

  List<MarkerModel> _markers = [];
  List<MarkerModel> get markers => _markers;

  String? _error;
  String? get error => _error;

  bool _actionLoading = false;
  bool get actionLoading => _actionLoading;

  // ── Computed ──────────────────────────────────────────────────────────────

  String get statusLabel {
    switch (_journey?.status ?? '') {
      case 'PLANNED':
        return 'Dự kiến';
      case 'ACTIVE':
        return 'Đang diễn ra';
      case 'PAUSED':
        return 'Đang tạm dừng';
      case 'COMPLETED':
        return 'Đã hoàn thành';
      case 'CANCELLED':
        return 'Đã hủy';
      default:
        return '';
    }
  }

  int get checkedInCount =>
      _milestones.where((m) => m.isCheckedIn).length;

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<void> load() async {
    _state = JourneyDetailState.loading;
    _error = null;
    notifyListeners();

    try {
      _journey = await _repo.getJourneyById(journeyId);
      if (_journey == null) throw Exception('Journey không tồn tại');

      // Parallel: load route + milestones + markers
      final results = await Future.wait([
        _repo.getRoute(_journey!.trekkingRouteId),
        _repo.getMilestones(_journey!.trekkingRouteId),
        _repo.getMarkers(journeyId),
      ]);

      _route = results[0] as RouteModel?;
      _milestones = results[1] as List<MilestoneModel>;
      _markers = results[2] as List<MarkerModel>;

      _state = JourneyDetailState.success;
    } catch (e) {
      _error = e.toString();
      _state = JourneyDetailState.error;
    }
    notifyListeners();
  }

  Future<void> refresh() => load();

  // ── Status transitions ────────────────────────────────────────────────────

  Future<bool> startJourney() => _doAction(() async {
        final updated = await _repo.startJourney(journeyId);
        _journey = updated;
      });

  Future<bool> pauseJourney() => _doAction(() async {
        final updated = await _repo.pauseJourney(journeyId);
        _journey = updated;
      });

  Future<bool> resumeJourney() => _doAction(() async {
        final updated = await _repo.resumeJourney(journeyId);
        _journey = updated;
      });

  Future<bool> completeJourney({
    String? encodedPolyline,
    double? distanceMeters,
    int? durationSeconds,
    double? elevationGain,
  }) =>
      _doAction(() async {
        final updated = await _repo.completeJourney(
          journeyId,
          encodedPolyline: encodedPolyline,
          distanceMeters: distanceMeters,
          durationSeconds: durationSeconds,
          elevationGain: elevationGain,
        );
        _journey = updated;
      });

  Future<bool> cancelJourney() => _doAction(() async {
        final updated = await _repo.cancelJourney(journeyId);
        _journey = updated;
      });

  // ── Markers ───────────────────────────────────────────────────────────────

  Future<bool> addMarker({
    required String userId,
    required String name,
    required String type,
    required double latitude,
    required double longitude,
    double? altitude,
    double? accuracy,
    String? note,
    List<String> mediaLocalPaths = const [],
  }) =>
      _doAction(() async {
        final marker = await _repo.createMarker(
          localJourneyId: journeyId,
          userId: userId,
          name: name,
          type: type,
          latitude: latitude,
          longitude: longitude,
          altitude: altitude,
          accuracy: accuracy,
          note: note,
          mediaLocalPaths: mediaLocalPaths,
        );
        _markers = [..._markers, marker];
        _journey = _journey?.copyWithMarkerCount(
            (_journey?.markerCount ?? 0) + 1);
      });

  Future<bool> updateMarker(
    String localMarkerId, {
    String? name,
    String? type,
    String? note,
  }) =>
      _doAction(() async {
        await _repo.updateMarker(localMarkerId,
            name: name, type: type, note: note);
        _markers = _markers.map((m) {
          if (m.markerId != localMarkerId) return m;
          return MarkerModel(
            markerId: m.markerId,
            serverMarkerId: m.serverMarkerId,
            localJourneyId: m.localJourneyId,
            name: name ?? m.name,
            type: type ?? m.type,
            note: note ?? m.note,
            latitude: m.latitude,
            longitude: m.longitude,
            altitude: m.altitude,
            markedAt: m.markedAt,
            syncStatus: m.syncStatus,
            mediaLocalPaths: m.mediaLocalPaths,
            mediaRemoteUrls: m.mediaRemoteUrls,
          );
        }).toList();
      });

  Future<bool> deleteMarker(String localMarkerId) =>
      _doAction(() async {
        await _repo.deleteMarker(localMarkerId);
        _markers =
            _markers.where((m) => m.markerId != localMarkerId).toList();
        final count = (_journey?.markerCount ?? 1) - 1;
        _journey = _journey?.copyWithMarkerCount(count < 0 ? 0 : count);
      });

  // ── Offline package ───────────────────────────────────────────────────────

  Future<OfflinePackageInfo?> getOfflinePackage() async {
    if (_journey == null) return null;
    return _repo.getOfflinePackage(_journey!.trekkingRouteId);
  }

  // ── Private ───────────────────────────────────────────────────────────────

  Future<bool> _doAction(Future<void> Function() action) async {
    _actionLoading = true;
    _error = null;
    notifyListeners();
    try {
      await action();
      _actionLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _actionLoading = false;
      notifyListeners();
      return false;
    }
  }
}

// Extension để tránh copyWith phức tạp
extension _JourneyModelExt on JourneyModel {
  JourneyModel copyWithMarkerCount(int count) => JourneyModel(
        journeyId: journeyId,
        userId: userId,
        trekkingPlaceId: trekkingPlaceId,
        trekkingRouteId: trekkingRouteId,
        provinceId: provinceId,
        name: name,
        status: status,
        plannedStartAt: plannedStartAt,
        startedAt: startedAt,
        completedAt: completedAt,
        distanceMeters: distanceMeters,
        durationSeconds: durationSeconds,
        elevationGain: elevationGain,
        maxAltitude: maxAltitude,
        checkinCount: checkinCount,
        markerCount: count,
        createdAt: createdAt,
        updatedAt: updatedAt,
        placeName: placeName,
        placeAddress: placeAddress,
        routeName: routeName,
        placeImageUrl: placeImageUrl,
        routeDistanceMeters: routeDistanceMeters,
        totalMilestones: totalMilestones,
        memberCount: memberCount,
      );
}
