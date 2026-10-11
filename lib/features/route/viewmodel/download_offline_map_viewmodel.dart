import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

import '../../../core/services/trekking_catalog_service.dart';
import '../../offline_map/services/offline_map_storage_service.dart';
import '../../offline_map/data/offline_package_installer.dart';
import '../../../core/database/models/downloaded_map.dart';
import '../data/models/route_model.dart';

class DownloadOfflineMapViewModel extends ChangeNotifier {
  final RouteModel? route;
  final String? placeId;
  final String? placeName;
  final OfflineMapStorageService _storage;
  final TrekkingCatalogService _catalog;
  final Dio Function() _downloadClient;
  late DownloadedMap mapInfo;
  double _progress = 0;
  bool _isCompleted = false;
  bool _disposed = false;
  bool _running = false;
  CancelToken? _cancel;
  String? error;
  String? coverageWarning;
  DownloadOfflineMapViewModel({
    this.route,
    this.placeId,
    this.placeName,
    bool autoStart = true,
    OfflineMapStorageService? storage,
    TrekkingCatalogService? catalog,
    Dio Function()? downloadClient,
  }) : _storage = storage ?? OfflineMapStorageService(),
       _catalog = catalog ?? TrekkingCatalogService(),
       _downloadClient =
           downloadClient ??
           (() =>
               Dio(BaseOptions(receiveTimeout: const Duration(minutes: 10)))) {
    mapInfo = DownloadedMap(
      mapId: route?.trekkingPlaceId ?? placeId ?? '',
      scope: 'PLACE',
      trekkingRouteId: route?.routeId ?? '',
      trekkingPlaceId: route?.trekkingPlaceId ?? placeId ?? '',
      mapName: placeName ?? route?.placeName ?? route?.name ?? '',
      localPath: '',
      sizeBytes: 0,
      status: 'DOWNLOADING',
    );
    if (autoStart) startDownload();
  }
  double get progress => _progress;
  bool get isCompleted => _isCompleted;
  int get progressPercent => (_progress * 100).toInt();
  bool get isRunning => _running;

  Future<void> startDownload() async {
    if (_running || _disposed) return;
    if (route == null && (placeId == null || placeId!.isEmpty)) {
      error = 'Vui lòng chọn địa điểm hoặc cung đường.';
      notifyListeners();
      return;
    }
    final cancel = CancelToken();
    _cancel = cancel;
    _running = true;
    _progress = 0;
    _isCompleted = false;
    error = null;
    coverageWarning = null;
    notifyListeners();
    File? partial;
    Directory? installed;
    bool committed = false;
    bool fetchingFile = false;
    try {
      Map<String, dynamic>? data;
      if (route != null)
        try {
          final response = await _catalog.dio.get(
            '/routes/${route!.routeId}/offline-package',
            cancelToken: cancel,
          );
          data = Map<String, dynamic>.from(response.data['data'] as Map);
        } on DioException catch (e) {
          if (e.response?.statusCode != 404) rethrow;
        }
      if (data != null) await _catalog.offline.cachePackage(data);
      Map<String, dynamic>? manifest = data?['mapManifest'] is Map
          ? Map<String, dynamic>.from(data!['mapManifest'] as Map)
          : null;
      if (manifest?['available'] != true ||
          manifest?['downloadUrl'] == null ||
          manifest?['scope'] != 'PLACE') {
        final response = await _catalog.dio.get(
          '/places/${route?.trekkingPlaceId ?? placeId}/offline-package',
          cancelToken: cancel,
        );
        data = Map<String, dynamic>.from(response.data['data'] as Map);
        await _catalog.offline.cachePackage(data);
        manifest = data['mapManifest'] is Map
            ? Map<String, dynamic>.from(data['mapManifest'] as Map)
            : null;
        if (route != null)
          data['milestones'] = await _catalog.getMilestones(route!.routeId);
      }
      if (manifest?['available'] != true)
        throw StateError(
          'Địa điểm và cung đường chưa có gói bản đồ offline đã xuất bản.',
        );
      final url = manifest!['downloadUrl']?.toString();
      if (url == null || url.isEmpty)
        throw StateError('Backend chưa cấu hình link tải gói bản đồ.');
      final version = (manifest['version'] as num).toInt();
      const scope = 'PLACE';
      final entityId = route?.trekkingPlaceId ?? placeId!;
      final checksum = manifest['checksum']?.toString() ?? '';
      if (checksum.isEmpty) throw StateError('Gói bản đồ thiếu checksum.');
      final mapDir = await _storage.getPlaceMapDirectory(
        entityId,
        version: version,
      );
      final temp = await _storage.getTempDownloadDirectory();
      final installId = DateTime.now().microsecondsSinceEpoch;
      partial = File(p.join(temp.path, '$installId.zip.part'));
      installed = Directory(p.join(mapDir.path, 'package_$installId'));
      final downloader = _downloadClient();
      fetchingFile = true;
      try {
        await downloader.download(
          url,
          partial.path,
          cancelToken: cancel,
          onReceiveProgress: (received, total) {
            if (!_disposed && total > 0) {
              _progress = (received / total).clamp(0, 1) * .9;
              notifyListeners();
            }
          },
        );
      } finally {
        downloader.close();
      }
      if (cancel.isCancelled) throw cancel.cancelError!;
      final metadata = await OfflinePackageInstaller().install(
        zip: partial,
        target: installed,
        checksum: checksum,
        expectedVersion: version,
      );
      if (_disposed || cancel.isCancelled) return;
      final bounds = metadata.bounds;
      final apiBounds = manifest['bounds'] as Map?;
      if (apiBounds != null) {
        final advertised = [
          apiBounds['minLon'],
          apiBounds['minLat'],
          apiBounds['maxLon'],
          apiBounds['maxLat'],
        ];
        for (var i = 0; i < 4; i++) {
          if (advertised[i] is! num ||
              ((advertised[i] as num).toDouble() - bounds[i]).abs() > 1e-6) {
            throw StateError('BBOX của gói tải về khác manifest trên backend.');
          }
        }
      }
      final place = data?['place'] as Map?;
      final coordinates = (place?['location'] as Map?)?['coordinates'] as List?;
      if (coordinates != null &&
          coordinates.length >= 2 &&
          ((coordinates[0] as num) < bounds[0] ||
              (coordinates[0] as num) > bounds[2] ||
              (coordinates[1] as num) < bounds[1] ||
              (coordinates[1] as num) > bounds[3])) {
        coverageWarning = 'Gói này không phủ tọa độ địa điểm. Admin cần tạo lại bản đồ với BBOX đúng.';
      }
      await File(p.join(installed.path, 'package.json'))
          .writeAsString(jsonEncode(data), flush: true);
      mapInfo = DownloadedMap(
        mapId: '$scope:$entityId:v$version',
        scope: scope,
        trekkingPlaceId: entityId,
        trekkingRouteId: null,
        mapName: metadata.name,
        mapVersion: version,
        localPath: p.join(
          installed.path,
          metadata.layers.firstWhere((l) => l.id == 'base').file,
        ),
        sizeBytes: await partial.length(),
        waypointCount: (data?['milestones'] as List? ?? []).length,
        checksum: checksum,
        minZoom: metadata.minZoom,
        maxZoom: metadata.maxZoom,
        minLatitude: bounds[1],
        minLongitude: bounds[0],
        maxLatitude: bounds[3],
        maxLongitude: bounds[2],
        downloadedAt: DateTime.now(),
        status: 'READY',
      );
      final previous = await _storage.getDownloadedMap(mapInfo.mapId);
      await _storage.saveDownloadedMap(mapInfo);
      committed = true;
      if (previous != null && previous.localPath != mapInfo.localPath)
        await _storage.deletePackageFiles(previous);
      await _storage.cleanupOldVersions(scope: scope, entityId: entityId);
      _progress = 1;
      _isCompleted = true;
    } on DioException catch (e) {
      if (!_disposed) {
        if (e.response?.statusCode == 404) {
          error = fetchingFile
              ? 'Link tải file bản đồ trên R2 trả 404. Backend cần kiểm tra bucket và objectKey của gói đã xuất bản.'
              : 'Không tìm thấy địa điểm hoặc cung đường trên backend.';
        } else if (e.type == DioExceptionType.cancel) {
          error = 'Đã hủy tải xuống.';
        } else {
          error = 'Không thể tải bản đồ. Kiểm tra kết nối và thử lại.';
        }
      }
    } catch (e) {
      if (!_disposed)
        error = e is StateError
            ? e.message
            : e is FormatException
            ? e.message
            : 'Gói bản đồ không hợp lệ: $e';
    } finally {
      if (partial != null && await partial.exists()) await partial.delete();
      if (!committed && installed != null && await installed.exists())
        await installed.delete(recursive: true);
      _running = false;
      if (!_disposed) notifyListeners();
    }
  }

  void cancelDownload() => _cancel?.cancel();
  @override
  void dispose() {
    _disposed = true;
    cancelDownload();
    super.dispose();
  }
}
