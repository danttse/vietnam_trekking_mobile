import 'dart:async';
import 'package:flutter/material.dart';
import '../data/models/downloaded_map_model.dart';
import '../data/models/route_model.dart';

class DownloadOfflineMapViewModel extends ChangeNotifier {
  final RouteModel? route;
  late final DownloadedMapModel mapInfo;

  double _progress = 0.0;
  bool _isCompleted = false;
  Timer? _timer;

  DownloadOfflineMapViewModel({this.route}) {
    mapInfo = DownloadedMapModel(
      mapId: 'map_${route?.routeId ?? "default"}',
      trekkingPlaceId: route?.trekkingPlaceId ?? 'place_default',
      trekkingRouteId: route?.routeId ?? 'route_default',
      mapName: route?.name ?? 'Langbiang Peak',
      mapVersion: route?.mapVersion ?? 1,
      sizeBytes: 44040192,
      minZoom: 12,
      maxZoom: 17,
      waypointCount: 28,
      hasTrailSupport: true,
    );
    startDownload();
  }

  double get progress => _progress;
  bool get isCompleted => _isCompleted;
  int get progressPercent => (_progress * 100).toInt();

  void startDownload() {
    _timer?.cancel();
    _progress = 0.0;
    _isCompleted = false;
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      _progress += 0.02;
      if (_progress >= 1.0) {
        _progress = 1.0;
        _isCompleted = true;
        _timer?.cancel();
      }
      notifyListeners();
    });
  }

  void cancelDownload() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
