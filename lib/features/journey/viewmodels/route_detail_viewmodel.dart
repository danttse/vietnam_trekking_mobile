import 'package:flutter/foundation.dart';

import '../data/models/route_model.dart';
import '../data/models/milestone_model.dart';
import '../data/repositories/journey_repository.dart';
import '../../../core/database/daos/offline_data_dao.dart';
import '../../../core/database/database_helper.dart';
import '../../route/viewmodel/download_offline_map_viewmodel.dart';
import '../../offline_map/services/offline_map_storage_service.dart';
import '../../../core/services/trekking_catalog_service.dart';

enum OfflineMapStatus { none, downloading, ready, failed, outdated }

class RouteDetailViewModel extends ChangeNotifier {
  final JourneyRepository _repo;
  final OfflineDataDao _offlineDao;
  final String routeId;

  RouteDetailViewModel({
    required this.routeId,
    JourneyRepository? repo,
    DatabaseHelper? dbHelper,
  }) : _repo = repo ?? JourneyRepository(),
       _offlineDao = OfflineDataDao(
         dbHelper: dbHelper ?? DatabaseHelper.instance,
       );

  // ── State ─────────────────────────────────────────────────────────────────
  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  RouteModel? _route;
  RouteModel? get route => _route;

  List<MilestoneModel> _milestones = [];
  List<MilestoneModel> get milestones => _milestones;

  OfflinePackageInfo? _packageInfo;
  OfflinePackageInfo? get packageInfo => _packageInfo;

  OfflineMapStatus _offlineStatus = OfflineMapStatus.none;
  OfflineMapStatus get offlineStatus => _offlineStatus;

  double _downloadProgress = 0;
  double get downloadProgress => _downloadProgress;

  DownloadOfflineMapViewModel? _download;

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repo.getRoute(routeId),
        _repo.getMilestones(routeId),
        _repo.getOfflinePackage(routeId),
      ]);
      _route = results[0] as RouteModel?;
      _milestones = results[1] as List<MilestoneModel>;
      _packageInfo = results[2] as OfflinePackageInfo?;

      // Check existing download
      await _checkExistingDownload();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> _checkExistingDownload() async {
    final existing = await OfflineMapStorageService(dao: _offlineDao)
        .findReadyMap(routeId, _route?.trekkingPlaceId ?? '');
    if (existing == null) {
      _offlineStatus = OfflineMapStatus.none;
      return;
    }
    if (_packageInfo != null &&
        existing.mapVersion != null &&
        _packageInfo!.mapVersion > existing.mapVersion!) {
      _offlineStatus = OfflineMapStatus.outdated;
    } else if (existing.status == 'READY') {
      _offlineStatus = OfflineMapStatus.ready;
    } else if (existing.status == 'FAILED') {
      _offlineStatus = OfflineMapStatus.failed;
    } else {
      _offlineStatus = OfflineMapStatus.none;
    }
  }

  // ── Download ──────────────────────────────────────────────────────────────

  Future<void> downloadOfflineMap() async {
    if (_offlineStatus == OfflineMapStatus.downloading) return;
    _offlineStatus = OfflineMapStatus.downloading;
    _error = null;
    notifyListeners();
    try {
      final route = await TrekkingCatalogService().getRoute(routeId);
      _download = DownloadOfflineMapViewModel(
        route: route,
        autoStart: false,
        storage: OfflineMapStorageService(dao: _offlineDao),
      );
      _download!.addListener(_onDownload);
      await _download!.startDownload();
      _error = _download!.error;
      _offlineStatus = _download!.isCompleted
          ? OfflineMapStatus.ready
          : OfflineMapStatus.failed;
    } catch (e) {
      _error = e.toString();
      _offlineStatus = OfflineMapStatus.failed;
    } finally {
      _download?.removeListener(_onDownload);
      _download?.dispose();
      _download = null;
    }
    notifyListeners();
  }

  void _onDownload() {
    _downloadProgress = _download!.progress;
    notifyListeners();
  }

  void cancelDownload() => _download?.cancelDownload();

  Future<void> retryDownload() async {
    _offlineStatus = OfflineMapStatus.none;
    await downloadOfflineMap();
  }

  String get downloadProgressPercent =>
      '${(_downloadProgress * 100).toStringAsFixed(0)}%';
}
