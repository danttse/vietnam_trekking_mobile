import 'package:flutter/material.dart';

import 'download_offline_map_viewmodel.dart';
import '../data/models/route_model.dart';
import '../../offline_map/services/offline_map_storage_service.dart';

class RouteDetailViewModel extends ChangeNotifier {
  final RouteModel? _route;
  bool _isDownloading = false;
  bool _isDownloaded = false;
  final OfflineMapStorageService _storage;

  RouteDetailViewModel({RouteModel? route, OfflineMapStorageService? storage})
    : _route = route,
      _storage = storage ?? OfflineMapStorageService() {
    _loadSavedMap();
  }
  Future<void> _loadSavedMap() async {
    if (_route == null) return;
    try {
      final map = await _storage.findReadyMap(
        _route.routeId,
        _route.trekkingPlaceId,
      );
      if (!_disposed) {
        _isDownloaded = map != null;
        notifyListeners();
      }
    } catch (_) {
      if (!_disposed) error = 'Không thể kiểm tra bản đồ đã tải.';
    }
  }

  bool _disposed = false;
  String? error;

  RouteModel? get route => _route;
  bool get isDownloading => _isDownloading;
  bool get isDownloaded => _isDownloaded;

  String get routeName => _route?.name ?? 'Chưa chọn cung đường';
  String get routeLocation => _route?.province ?? '';

  String get difficultyText {
    if (_route == null) return '--';
    switch (_route.difficulty) {
      case RouteDifficulty.easy:
        return 'Dễ';
      case RouteDifficulty.moderate:
        return 'Trung bình';
      case RouteDifficulty.hard:
        return 'Khó';
      case RouteDifficulty.extreme:
        return 'Cực khó';
    }
  }

  String get totalDistanceText =>
      '${_route?.distanceKm.toStringAsFixed(1) ?? "--"} km';

  String get elevationGainText => '+${_route?.elevationGain.toInt() ?? "--"} m';

  String get maxElevationText => '${_route?.maxElevation.toInt() ?? "--"} m';

  String get estimatedDurationText {
    if (_route == null) return '--';
    final minutes = _route.estimatedDuration.inMinutes;
    if (minutes <= 0) return '--';
    if (minutes >= 1440) {
      final days = minutes / 1440;
      return '${days == days.roundToDouble() ? days.toInt() : days.toStringAsFixed(1)} ngày';
    }
    final hours = minutes ~/ 60;
    final remaining = minutes % 60;
    return hours == 0
        ? '$remaining phút'
        : '$hours giờ${remaining == 0 ? '' : ' $remaining phút'}';
  }

  String get heroImageUrl => _route?.imageUrl ?? '';

  String? get mapImageUrl => _route?.mapImageUrl;

  Future<void> downloadOfflineMap() async {
    _isDownloading = true;
    notifyListeners();

    final download = DownloadOfflineMapViewModel(
      route: _route,
      autoStart: false,
      storage: _storage,
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

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void setDownloaded(bool value) {
    _isDownloaded = value;
    notifyListeners();
  }
}
