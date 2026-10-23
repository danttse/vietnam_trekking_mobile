import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../../offline_map/services/offline_map_manager.dart';
import '../../offline_map/services/offline_map_storage_service.dart';
import '../../offline_map/utils/entity_map_style.dart';
import '../data/models/journey_model.dart';
import '../data/models/milestone_model.dart';
import '../data/models/marker_model.dart';
import '../data/repositories/journey_repository.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/journey_tracking_service.dart';
import '../../../core/network/api_error_handler.dart';

class JourneyMapViewModel extends ChangeNotifier {
  final JourneyModel initialJourney;
  final List<MilestoneModel> initialMilestones;
  final List<MarkerModel> initialMarkers;
  final String routeId;
  final bool readOnly;
  final OfflineMapStorageService? customMapStorage;

  late JourneyModel _journey;
  late List<MilestoneModel> _milestones;
  late List<MarkerModel> _markers;

  final OfflineMapManager _offline = OfflineMapManager.create();
  String? _mapError;
  bool _loadingMap = true;
  bool _styleReady = false;
  final LocationService _location = LocationService.instance;
  String? _style;
  late final JourneyTrackingService _tracking;
  late final bool _ownsTracking;
  bool _trackReady = false;
  bool _backtracking = false;
  bool _updatingJourney = false;
  String? _errorMessage;

  JourneyMapViewModel({
    required this.initialJourney,
    required this.initialMilestones,
    required this.initialMarkers,
    required this.routeId,
    this.readOnly = false,
    this.customMapStorage,
  }) {
    _journey = initialJourney;
    _markers = List.of(initialMarkers);
    _milestones = List.of(initialMilestones);
    _ownsTracking =
        readOnly ||
        (_journey.status != JourneyStatus.active &&
            _journey.status != JourneyStatus.paused);
    _tracking = _ownsTracking
        ? JourneyTrackingService()
        : JourneyTrackingService.instance;
  }

  // Getters
  JourneyModel get journey => _journey;
  List<MilestoneModel> get milestones => _milestones;
  List<MarkerModel> get markers => _markers;
  OfflineMapManager get offline => _offline;
  LocationService get location => _location;
  JourneyTrackingService get tracking => _tracking;
  bool get loadingMap => _loadingMap;
  String? get mapError => _mapError;
  bool get styleReady => _styleReady;
  String? get style => _style;
  bool get trackReady => _trackReady;
  bool get backtracking => _backtracking;
  bool get updatingJourney => _updatingJourney;
  String? get errorMessage => _errorMessage;

  bool get canMark =>
      !readOnly &&
      (_journey.status == JourneyStatus.active ||
          _journey.status == JourneyStatus.paused);

  LatLng get center {
    final manifest = _offline.manifest;
    if (manifest != null) return LatLng(manifest.centerLat, manifest.centerLng);
    if (_milestones.isNotEmpty) {
      final first = _milestones.first;
      return LatLng(first.latitude, first.longitude);
    }
    return const LatLng(14.0583, 108.2772);
  }

  void setStyleReady(bool ready) {
    _styleReady = ready;
    notifyListeners();
  }

  void clearErrorMessage() {
    _errorMessage = null;
  }

  void init() {
    _location.addListener(_onLocationChanged);
    _location.initialize();
    _loadOfflineMap();
    if (_journey.journeyId.isNotEmpty) {
      _tracking.addListener(_onTrackChanged);
      unawaited(_loadTrack());
    }
  }

  void _onLocationChanged() {
    notifyListeners();
  }

  void _onTrackChanged() {
    notifyListeners();
  }

  Future<void> _loadTrack() async {
    try {
      await _tracking.open(
        _journey.journeyId,
        encodedPolyline: _journey.encodedPolyline,
      );
      _trackReady = true;
      notifyListeners();
    } catch (e) {
      _errorMessage = ApiErrorHandler.handle(e);
      notifyListeners();
    }
  }

  Future<void> loadOfflineMap() => _loadOfflineMap();

  Future<void> _loadOfflineMap() async {
    _loadingMap = true;
    _mapError = null;
    notifyListeners();

    try {
      if (readOnly && _milestones.isEmpty) {
        try {
          _milestones = await JourneyRepository().getMilestones(routeId);
        } catch (_) {
          /* Keep the downloaded route usable when catalog is unavailable. */
        }
      }
      final storage = customMapStorage ?? OfflineMapStorageService();
      final map = await storage.findReadyMap(
        routeId,
        _journey.trekkingPlaceId,
      );
      if (map == null) {
        throw StateError('Chưa có bản đồ offline đã cài cho địa điểm này.');
      }
      final point = _journey.route.startPoint;
      if ((point.latitude != 0 || point.longitude != 0) &&
          (point.latitude < (map.minLatitude ?? -90) ||
              point.latitude > (map.maxLatitude ?? 90) ||
              point.longitude < (map.minLongitude ?? -180) ||
              point.longitude > (map.maxLongitude ?? 180))) {
        throw StateError(
          'Gói bản đồ chưa phủ cung đường này. Vui lòng tải bản đồ mới nhất.',
        );
      }
      _styleReady = false;
      await _offline.close();
      await _offline.initialize(
        packageDirectory: File(map.localPath).parent.path,
      );
      if (!_offline.isReady) {
        throw StateError(
          _offline.errorMessage ?? 'Không thể mở bản đồ offline.',
        );
      }
      await storage.touchMap(map.mapId);
      _style = entityMapStyle(
        _offline.styleString!,
        route: _journey.route,
        routeColor: '#3B82F6',
      );
    } catch (e) {
      _mapError = e is StateError ? e.message : e.toString();
    } finally {
      _loadingMap = false;
      notifyListeners();
    }
  }

  Future<void> toggleRecording() async {
    if (!_trackReady || _updatingJourney) return;
    try {
      await _tracking.setEnabled(!_tracking.enabled);
      notifyListeners();
    } catch (e) {
      _errorMessage = ApiErrorHandler.handle(e);
      notifyListeners();
    }
  }

  bool toggleBacktrack() {
    if (_tracking.points.length < 2) {
      _errorMessage = 'Cần ít nhất 2 điểm GPS đã lưu để quay lại đường đã đi.';
      notifyListeners();
      return false;
    }
    _backtracking = !_backtracking;
    notifyListeners();
    return true;
  }

  Future<JourneyModel?> completeJourney() async {
    if (!canMark || _updatingJourney) return null;
    _updatingJourney = true;
    notifyListeners();
    try {
      await _tracking.flush();
      final saved = await JourneyRepository().completeJourney(
        _journey.journeyId,
      );
      _journey = saved;
      return saved;
    } catch (e) {
      _errorMessage = ApiErrorHandler.handle(e);
      return null;
    } finally {
      _updatingJourney = false;
      notifyListeners();
    }
  }

  void addMarker(MarkerModel marker) {
    _markers.add(marker);
    notifyListeners();
  }

  void updateMarker(int index, MarkerModel marker) {
    if (index >= 0 && index < _markers.length) {
      _markers[index] = marker;
      notifyListeners();
    }
  }

  Future<List<MarkerModel>> getMarkersForContribution() async {
    if (_journey.journeyId.isEmpty) return [];
    return JourneyRepository().getMarkers(_journey.journeyId);
  }

  @override
  void dispose() {
    _tracking.removeListener(_onTrackChanged);
    if (_ownsTracking) _tracking.dispose();
    _location.removeListener(_onLocationChanged);
    _offline.dispose();
    super.dispose();
  }
}
