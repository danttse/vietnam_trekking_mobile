import '../../../core/database/daos/checkin_dao.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    _loadPersistedData();
    if (autoLoad) {
      loadMilestones();
      _loadDownloadedState();
    }
  }

  Future<void> _loadDownloadedState() async {
    final current = _journey;
    if (current == null) return;
    try {
      final routeId = current.trekkingRouteId.isNotEmpty
          ? current.trekkingRouteId
          : current.route.routeId;
      final placeId = current.trekkingPlaceId.isNotEmpty
          ? current.trekkingPlaceId
          : current.route.trekkingPlaceId;
      final map = await OfflineMapStorageService().findReadyMap(
        routeId,
        placeId,
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
    // 1. Cố gắng làm mới thông tin journey, nhưng không để lỗi này chặn việc tải cột mốc
    JourneyModel activeJourney = current;
    try {
      final refreshed = await _api.getJourney(current.journeyId);
      if (!_disposed) {
        _journey = refreshed;
        activeJourney = refreshed;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[JourneyDetailViewModel] refresh journey skipped: $e');
    }
    final routeId = activeJourney.trekkingRouteId.isNotEmpty
        ? activeJourney.trekkingRouteId
        : activeJourney.route.routeId;
    if (routeId.isEmpty) {
      if (!_disposed) {
        milestoneError = 'Không tìm thấy thông tin cung đường của hành trình.';
        notifyListeners();
      }
      return;
    }
    try {
      // 2. Tải danh sách cột mốc của cung đường
      final data = await _api.getMilestones(routeId);
      if (_disposed) return;
      final milestones = data
          .map(
            (m) => MilestoneModel.fromJson(Map<String, dynamic>.from(m as Map)),
          )
          .toList();
      // Lay danh sach checkin tu SQLite va server
      final verified = <String, DateTime?>{};
      try {
        final checkins = await _api.getJourneyCheckins(activeJourney.journeyId);
        for (final checkin in checkins) {
          final syncStatus =
              checkin['offlineSyncStatus'] ?? checkin['syncStatus'];
          final verification = (checkin['verification'] is Map)
              ? (checkin['verification'] as Map)['status']
              : checkin['verificationStatus'] ?? checkin['verification'];
          final isVerified = verification == 'VERIFIED' ||
              verification == 'APPROVED' ||
              verification == 'PENDING_VERIFICATION';
          final isLocalPending = syncStatus == 'PENDING';
          if (syncStatus != 'FAILED' && (isVerified || isLocalPending)) {
            // Trich xuat milestoneId an toan
            final rawMId = checkin['milestoneId'] ?? checkin['milestone'] ?? checkin['milestone_id'];
            final mId = (rawMId is Map)
                ? (rawMId['_id'] ?? rawMId['id'] ?? rawMId['milestoneId'])?.toString()
                : rawMId?.toString();
            if (mId != null && mId.isNotEmpty) {
              verified[mId] = DateTime.tryParse(
                (checkin['checkedAt'] ?? checkin['createdAt'] ?? checkin['checkinTime'] ?? '').toString(),
              ) ?? DateTime.now();
            }
          }
        }
      } catch (e) {
        debugPrint('[JourneyDetailViewModel] optional checkins load: $e');
      }
      // Kiem tra truc tiep tu bang offline_checkins
      try {
        final localCheckins = await CheckinDao().getCheckinsByJourney(
          activeJourney.journeyId,
        );
        for (final c in localCheckins) {
          final isRejected = c.verificationStatus == 'REJECTED' || c.verificationStatus == 'FAILED';
          if (c.syncStatus != 'FAILED' && !isRejected) {
            if (c.milestoneId.isNotEmpty) {
              verified[c.milestoneId] = c.checkedAt;
            }
          }
        }
      } catch (e) {
        debugPrint('[JourneyDetailViewModel] local checkins load error: $e');
      }
      _milestones = milestones.map((m) {
        final isChecked =
            verified.containsKey(m.id) ||
            verified.containsKey(m.milestoneId) ||
            _localCheckedInMilestones.contains(m.id) ||
            _localCheckedInMilestones.contains(m.milestoneId);
        if (isChecked) {
          return m.copyWith(
            isCheckedIn: true,
            checkedInAt: verified[m.id] ?? verified[m.milestoneId] ?? DateTime.now(),
          );
        }
        return m;
      }).toList();
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
  final List<String> _checkinImages = [];
  List<String> get checkinImages => List.unmodifiable(_checkinImages);
  final Set<String> _localCheckedInMilestones = {};
  // Doc du lieu anh checkin da luu

  Future<void> _loadPersistedData() async {
    final id = _journey?.journeyId;
    if (id == null || id.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedImages =
          prefs.getStringList('journey_checkin_images_$id') ?? [];
      if (!_disposed) {
        _checkinImages.clear();
        _checkinImages.addAll(savedImages);
        notifyListeners();
      }
    } catch (_) {}
  }
  // Cap nhat trang thai checkin vao bo nho

  void checkIn(String milestoneId) {
    _localCheckedInMilestones.add(milestoneId);
    final index = _milestones.indexWhere((m) => m.id == milestoneId);
    if (index != -1) {
      _milestones = List.from(_milestones);
      _milestones[index] = _milestones[index].copyWith(
        isCheckedIn: true,
        checkedInAt: DateTime.now(),
      );
      notifyListeners();
    }
  }
  // Dong bo hoa du lieu checkin

  Future<void> syncPendingCheckins() async {
    try {
      await _api.syncPending();
      await loadMilestones();
    } catch (_) {}
  }

  void addCheckinImage(String path) {
    _checkinImages.add(path);
    final id = _journey?.journeyId;
    if (id != null && id.isNotEmpty) {
      SharedPreferences.getInstance().then((prefs) {
        prefs.setStringList('journey_checkin_images_$id', _checkinImages);
      });
    }
    notifyListeners();
  }

  void removeCheckinImage(int index) {
    if (index >= 0 && index < _checkinImages.length) {
      _checkinImages.removeAt(index);
      final id = _journey?.journeyId;
      if (id != null && id.isNotEmpty) {
        SharedPreferences.getInstance().then((prefs) {
          prefs.setStringList('journey_checkin_images_$id', _checkinImages);
        });
      }
      notifyListeners();
    }
  }
}
