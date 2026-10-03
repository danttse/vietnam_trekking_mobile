import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';
import '../data/models/route_model.dart';
import '../data/models/milestone_model.dart';
import '../data/repositories/journey_repository.dart';
import '../../../../core/database/daos/offline_data_dao.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/database/models/downloaded_map.dart';

enum OfflineMapStatus { none, downloading, ready, failed, outdated }

class RouteDetailViewModel extends ChangeNotifier {
  final JourneyRepository _repo;
  final OfflineDataDao _offlineDao;
  final String routeId;

  RouteDetailViewModel({
    required this.routeId,
    JourneyRepository? repo,
    DatabaseHelper? dbHelper,
  })  : _repo = repo ?? JourneyRepository(),
        _offlineDao =
            OfflineDataDao(dbHelper: dbHelper ?? DatabaseHelper.instance);

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

  CancelToken? _cancelToken;

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
    final existing = await _offlineDao.getMapByRoute(routeId);
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
    if (_packageInfo == null) return;
    if (_offlineStatus == OfflineMapStatus.downloading) return;

    _offlineStatus = OfflineMapStatus.downloading;
    _downloadProgress = 0;
    _error = null;
    notifyListeners();

    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath =
          '${dir.path}/maps/${routeId}_v${_packageInfo!.mapVersion}.mbtiles';
      await Directory('${dir.path}/maps').create(recursive: true);

      _cancelToken = CancelToken();
      final dio = Dio();

      await dio.download(
        _packageInfo!.downloadUrl,
        filePath,
        cancelToken: _cancelToken,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            _downloadProgress = received / total;
            notifyListeners();
          }
        },
      );

      // Verify checksum (strip "sha256:" prefix nếu có)
      if (_packageInfo!.checksum.isNotEmpty) {
        final bytes = await File(filePath).readAsBytes();
        final actualHash = sha256.convert(bytes).toString();
        final expectedHash = _packageInfo!.checksumHash;
        if (actualHash != expectedHash) {
          throw Exception('Checksum không khớp — file có thể bị lỗi');
        }
      }

      // Save to DB
      final mapId = routeId;
      final existing = await _offlineDao.getMap(routeId);
      final mapRecord = DownloadedMap(
        mapId: mapId,
        trekkingRouteId: routeId,
        trekkingPlaceId: _route?.trekkingPlaceId,
        mapName: _packageInfo!.mapName,
        localPath: filePath,
        mapVersion: _packageInfo!.mapVersion,
        sizeBytes: _packageInfo!.sizeBytes,
        minZoom: _packageInfo!.minZoom,
        maxZoom: _packageInfo!.maxZoom,
        checksum: _packageInfo!.checksum,
        downloadedAt: DateTime.now(),
        status: 'READY',
      );
      if (existing != null) {
        await _offlineDao.updateMap(mapRecord);
      } else {
        await _offlineDao.insertMap(mapRecord);
      }

      _offlineStatus = OfflineMapStatus.ready;
      _downloadProgress = 1.0;
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        _offlineStatus = OfflineMapStatus.none;
      } else {
        _error = 'Tải xuống thất bại: ${e.message}';
        _offlineStatus = OfflineMapStatus.failed;
      }
    } catch (e) {
      _error = e.toString();
      _offlineStatus = OfflineMapStatus.failed;
    }
    notifyListeners();
  }

  void cancelDownload() {
    _cancelToken?.cancel('Người dùng hủy tải xuống');
    _offlineStatus = OfflineMapStatus.none;
    _downloadProgress = 0;
    notifyListeners();
  }

  Future<void> retryDownload() async {
    _offlineStatus = OfflineMapStatus.none;
    await downloadOfflineMap();
  }

  String get downloadProgressPercent =>
      '${(_downloadProgress * 100).toStringAsFixed(0)}%';
}
