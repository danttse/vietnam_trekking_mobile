import 'dart:async';

import '../../route/viewmodel/download_offline_map_viewmodel.dart';

import 'package:flutter/material.dart';

import '../../../core/services/trekking_catalog_service.dart';
import '../../../core/network/api_error_handler.dart';
import '../../../core/services/journey_tracking_service.dart';
import '../../offline_map/services/offline_map_storage_service.dart';
import '../data/models/journey_model.dart';
import '../data/models/milestone_model.dart';

class JourneyDetailViewModel extends ChangeNotifier {
  JourneyModel? _journey;
  final TrekkingCatalogService _api;
  StreamSubscription<String>? _offlineSubscription;
  Future<void>? _refreshing;
  bool _isLoadingMilestones = false;
  bool _hasLoadedMilestones = false;
  String? milestoneError;

  bool _isDownloading = false;
  bool _isDownloaded = false;
  late List<MilestoneModel> _milestones;
  JourneyDetailViewModel({
    JourneyModel? route,
    TrekkingCatalogService? catalog,
    bool autoLoad = true,
  }) : _journey = route,
       _api = catalog ?? TrekkingCatalogService() {
    _milestones = [];
    _offlineSubscription = _api.offline.changes.listen((owner) async {
      if (!_disposed &&
          !isUpdating &&
          await _api.offline.ownerProvider() == owner &&
          !_disposed) {
        await loadMilestones();
      }
    });
    if (autoLoad) {
      loadMilestones();
      _loadDownloadedState();
    }
  }

  Future<void> _loadDownloadedState() async {
    final current = _journey;
    if (current == null) return;
    try {
      final map = await OfflineMapStorageService().findReadyMap(
        current.route.routeId,
        current.route.trekkingPlaceId,
      );
      if (!_disposed) {
        _isDownloaded = map != null;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[JourneyDetailViewModel] offline map: $e');
    }
  }

  bool _disposed = false;
  Future<void> refreshDownloadedState() => _loadDownloadedState();
  bool isUpdating = false;
  String? error;
  Future<void> loadMilestones() async {
    if (_disposed) return;
    if (_refreshing != null) return _refreshing!;
    _isLoadingMilestones = true;
    milestoneError = null;
    _refreshing = _loadMilestones();
    notifyListeners();
    try {
      await _refreshing;
    } finally {
      _refreshing = null;
      if (!_disposed) {
        _isLoadingMilestones = false;
        notifyListeners();
      }
    }
  }

  Future<void> _loadMilestones() async {
    final current = _journey;
    if (current == null) return;
    try {
      final refreshed = await _api.getJourney(current.journeyId);
      if (_disposed) return;
      _journey = refreshed;
      notifyListeners();
      final data = await _api.getMilestones(refreshed.route.routeId);
      if (_disposed) return;
      final milestones = data
          .map(
            (m) => MilestoneModel.fromJson(Map<String, dynamic>.from(m as Map)),
          )
          .toList();
      final checkins = await _api.getJourneyCheckins(refreshed.journeyId);
      if (_disposed) return;
      final verified = <String, DateTime?>{};
      for (final checkin in checkins) {
        if (checkin['offlineSyncStatus'] != 'FAILED' &&
            ((checkin['verification'] as Map?)?['status'] == 'VERIFIED' ||
                checkin['offlineSyncStatus'] == 'PENDING')) {
          verified[checkin['milestoneId'].toString()] = DateTime.tryParse(
            checkin['checkedAt']?.toString() ?? '',
          );
        }
      }
      _milestones = milestones
          .map(
            (m) => verified.containsKey(m.id)
                ? m.copyWith(isCheckedIn: true, checkedInAt: verified[m.id])
                : m,
          )
          .toList();
      _hasLoadedMilestones = true;
      milestoneError = null;
      error = null;
      notifyListeners();
    } catch (e, stack) {
      if (_disposed) return;
      debugPrint('[JourneyDetailViewModel] refresh: $e\n$stack');
      error = 'Không thể làm mới hành trình. ${ApiErrorHandler.handle(e)}';
      milestoneError = ApiErrorHandler.handle(e);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _offlineSubscription?.cancel();
    super.dispose();
  }

  JourneyModel? get journey => _journey;
  JourneyStatus get journeyStatus => _journey?.status ?? JourneyStatus.planned;
  bool get isDownloading => _isDownloading;
  bool get isDownloaded => _isDownloaded;
  List<MilestoneModel> get milestones => _milestones;
  bool get isLoadingMilestones => _isLoadingMilestones;
  bool get hasLoadedMilestones => _hasLoadedMilestones;

  Future<void> toggleJourneyStatus() async {
    if (_journey == null || isUpdating) return;
    final action = switch (journeyStatus) {
      JourneyStatus.planned => 'start',
      JourneyStatus.active => 'pause',
      JourneyStatus.paused => 'resume',
      _ => null,
    };
    if (action == null) return;
    await updateStatus(action);
  }

  Future<void> updateStatus(String action) async {
    final current = _journey;
    if (current == null || isUpdating || _disposed) return;
    isUpdating = true;
    error = null;
    notifyListeners();
    try {
      if (action == 'complete') await JourneyTrackingService.instance.flush();
      await _api.transitionJourney(current.journeyId, action);
      final refreshed = await _api.getJourney(current.journeyId);
      if (!_disposed) _journey = refreshed;
    } catch (e, stack) {
      debugPrint('[JourneyDetailViewModel] $action: $e\n$stack');
      if (!_disposed) error = ApiErrorHandler.handle(e);
    } finally {
      if (!_disposed) {
        isUpdating = false;
        notifyListeners();
      }
    }
  }

  String get journeyName => _journey?.name ?? 'Hành trình trekking';
  String get journeyLocation => _journey?.route.province ?? 'Việt Nam';

  String get journeyImageUrl =>
      _journey?.route.imageUrl ??
      'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=800';

  String get mapImageUrl => _journey?.route.mapImageUrl ?? '';

  String get distanceKm {
    final km = _journey?.displayDistanceKm ?? 0;
    return km.truncateToDouble() == km
        ? km.toStringAsFixed(0)
        : km.toStringAsFixed(1);
  }

  String get maxElevationText =>
      '${_journey?.route.maxElevation.toInt() ?? 0} m';

  String get estimatedDurationText {
    final minutes = _journey?.route.estimatedDuration.inMinutes ?? 0;
    if (minutes == 0) return 'Chưa có dữ liệu';
    final hours = minutes ~/ 60;
    final remainder = minutes % 60;
    return hours == 0
        ? '$remainder phút'
        : '$hours giờ${remainder == 0 ? '' : ' $remainder phút'}';
  }

  int get checkedInCount => _milestones.where((m) => m.isCheckedIn).length;
  int get totalMilestoneCount => _milestones.length;

  Future<void> downloadOfflineMap() async {
    _isDownloading = true;
    notifyListeners();
    final download = DownloadOfflineMapViewModel(
      route: _journey?.route,
      autoStart: false,
    );
    await download.startDownload();
    if (!_disposed) {
      _isDownloading = false;
      _isDownloaded = download.isCompleted;
      error = download.error;
      notifyListeners();
    }
    download.dispose();
  }

  void checkIn(String milestoneId) {
    final index = _milestones.indexWhere((m) => m.id == milestoneId);
    if (index == -1) return;
    _milestones = List.from(_milestones);
    _milestones[index] = _milestones[index].copyWith(
      isCheckedIn: true,
      checkedInAt: DateTime.now(),
    );
    notifyListeners();
  }
}
