import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../../../core/database/database.dart';

/// Service quản lý storage của offline maps.
///
/// Cấu trúc thư mục:
/// ```
/// <AppDocuments>/offline_maps/
///   ├── routes/
///   │   ├── {routeId}/
///   │   │   ├── v1/
///   │   │   │   ├── map.mbtiles
///   │   │   │   ├── package.json
///   │   │   │   └── metadata.json
///   │   │   └── v2/
///   │   │       └── ...
///   │   └── ...
///   ├── places/
///   │   ├── {placeId}/
///   │   │   ├── v1/
///   │   │   └── v2/
///   │   └── ...
///   └── cache/
///       └── temp_downloads/
/// ```
class OfflineMapStorageService {
  static const String _baseDir = 'offline_maps';
  static const String _routesDir = 'routes';
  static const String _placesDir = 'places';
  static const String _cacheDir = 'cache';
  static const String _tempDownloadsDir = 'temp_downloads';

  final OfflineDataDao _dao;
  final Directory? rootDirectory;

  OfflineMapStorageService({OfflineDataDao? dao, this.rootDirectory})
    : _dao = dao ?? OfflineDataDao();

  // ══════════════════════════════════════════════════════════════════════════
  // PATH BUILDERS
  // ══════════════════════════════════════════════════════════════════════════

  /// Lấy base directory cho offline maps
  Future<Directory> getBaseDirectory() async {
    final appDoc = rootDirectory ?? await getApplicationDocumentsDirectory();
    final dir = Directory(path.join(appDoc.path, _baseDir));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Lấy directory cho route map
  Future<Directory> getRouteMapDirectory(String routeId, {int? version}) async {
    _validateEntityId(routeId);
    final base = await getBaseDirectory();
    final routeDir = Directory(
      path.join(
        base.path,
        _routesDir,
        routeId,
        version != null ? 'v$version' : '',
      ),
    );
    if (!await routeDir.exists()) {
      await routeDir.create(recursive: true);
    }
    return routeDir;
  }

  /// Lấy directory cho place map
  Future<Directory> getPlaceMapDirectory(String placeId, {int? version}) async {
    _validateEntityId(placeId);
    final base = await getBaseDirectory();
    final placeDir = Directory(
      path.join(
        base.path,
        _placesDir,
        placeId,
        version != null ? 'v$version' : '',
      ),
    );
    if (!await placeDir.exists()) {
      await placeDir.create(recursive: true);
    }
    return placeDir;
  }

  /// Lấy temp download directory
  Future<Directory> getTempDownloadDirectory() async {
    final base = await getBaseDirectory();
    final tempDir = Directory(
      path.join(base.path, _cacheDir, _tempDownloadsDir),
    );
    if (!await tempDir.exists()) {
      await tempDir.create(recursive: true);
    }
    return tempDir;
  }

  /// Lấy path cho file .mbtiles
  Future<String> getMBTilesPath({
    required String scope,
    required String entityId,
    required int version,
  }) async {
    final Directory dir;
    if (scope == 'ROUTE') {
      dir = await getRouteMapDirectory(entityId, version: version);
    } else {
      dir = await getPlaceMapDirectory(entityId, version: version);
    }
    return path.join(dir.path, 'map.mbtiles');
  }

  /// Lấy path cho package.json
  Future<String> getPackageJsonPath({
    required String scope,
    required String entityId,
    required int version,
  }) async {
    final Directory dir;
    if (scope == 'ROUTE') {
      dir = await getRouteMapDirectory(entityId, version: version);
    } else {
      dir = await getPlaceMapDirectory(entityId, version: version);
    }
    return path.join(dir.path, 'package.json');
  }

  // ══════════════════════════════════════════════════════════════════════════
  // MAP MANAGEMENT
  // ══════════════════════════════════════════════════════════════════════════

  /// Lưu downloaded map vào database
  Future<void> saveDownloadedMap(DownloadedMap map) async {
    await _dao.insertMap(map);
  }

  /// Lấy downloaded map từ database
  Future<DownloadedMap?> getDownloadedMap(String mapId) async {
    return _dao.getMap(mapId);
  }

  /// Lấy map theo route
  Future<DownloadedMap?> getMapByRoute(String routeId) async {
    return _dao.getMapByRoute(routeId);
  }

  /// Lấy map theo place
  Future<DownloadedMap?> getMapByPlace(String placeId) async {
    return _dao.getMapByPlace(placeId);
  }

  /// Lấy tất cả downloaded maps
  Future<List<DownloadedMap>> getAllDownloadedMaps() async {
    return _dao.getAllMaps();
  }

  /// Touch map (cập nhật lastUsedAt)
  Future<void> touchMap(String mapId) async {
    await _dao.touchMap(mapId);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FILE OPERATIONS
  // ══════════════════════════════════════════════════════════════════════════

  /// Kiểm tra map file có tồn tại không
  Future<bool> mapFileExists(String localPath) async {
    final file = File(localPath);
    return file.exists();
  }

  /// Lấy kích thước file
  Future<int> getFileSize(String localPath) async {
    final file = File(localPath);
    if (!await file.exists()) return 0;
    return file.length();
  }

  /// Xóa map file và database record
  static void _validateEntityId(String id) {
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(id))
      throw ArgumentError('Invalid offline map entity ID');
  }

  Future<DownloadedMap?> findReadyMap(String routeId, String placeId) async {
    for (final candidate in [
      await getMapByPlace(placeId),
    ]) {
      if (candidate == null) continue;
      final file = File(candidate.localPath);
      if (await file.exists() &&
          await File(path.join(file.parent.path, 'manifest.json')).exists()) {
        return candidate;
      }
      await _dao.updateMap(candidate.copyWith(status: 'OUTDATED'));
    }
    return null;
  }

  Future<void> deletePackageFiles(DownloadedMap map) async {
    final base = path.normalize((await getBaseDirectory()).absolute.path);
    final file = File(map.localPath);
    final parent = path.normalize(file.parent.absolute.path);
    if (!path.isWithin(base, parent))
      throw StateError('Map directory is outside offline storage.');
    if (await File(path.join(parent, 'manifest.json')).exists() ||
        path.basename(parent).startsWith('package_')) {
      if (await Directory(parent).exists())
        await Directory(parent).delete(recursive: true);
    } else if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> deleteMap(String mapId) async {
    final map = await _dao.getMap(mapId);
    if (map != null) await deletePackageFiles(map);
    await _dao.deleteMap(mapId);
  }

  /// Xóa old versions (giữ lại version mới nhất)
  Future<void> cleanupOldVersions({
    required String scope,
    required String entityId,
  }) async {
    final List<DownloadedMap> maps;
    if (scope == 'ROUTE') {
      final routeMaps = await _dao.getMapsByScope('ROUTE');
      maps = routeMaps.where((m) => m.trekkingRouteId == entityId).toList();
    } else {
      maps = await _dao.getMapsByPlace(entityId);
    }

    if (maps.length <= 1) return;

    // Sort by version descending
    maps.sort((a, b) => (b.mapVersion ?? 0).compareTo(a.mapVersion ?? 0));

    // Xóa các versions cũ (giữ lại version đầu tiên - mới nhất)
    for (int i = 1; i < maps.length; i++) {
      await deleteMap(maps[i].mapId);
    }
  }

  /// Dọn dẹp temp downloads
  Future<void> cleanupTempDownloads() async {
    final tempDir = await getTempDownloadDirectory();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
      await tempDir.create(recursive: true);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // STORAGE INFO
  // ══════════════════════════════════════════════════════════════════════════

  /// Lấy tổng dung lượng offline maps
  Future<int> getTotalStorageBytes() async {
    return _dao.getTotalMapSizeBytes();
  }

  /// Lấy số lượng maps đã download
  Future<int> getDownloadedMapCount() async {
    final maps = await _dao.getAllMaps();
    return maps.where((m) => m.status == 'READY').length;
  }

  /// Lấy storage info chi tiết
  Future<StorageInfo> getStorageInfo() async {
    final maps = await _dao.getAllMaps();
    final readyMaps = maps.where((m) => m.status == 'READY').toList();

    int totalBytes = 0;
    int routeMapsCount = 0;
    int placeMapsCount = 0;

    for (final map in readyMaps) {
      totalBytes += map.sizeBytes ?? 0;
      if (map.scope == 'ROUTE') {
        routeMapsCount++;
      } else {
        placeMapsCount++;
      }
    }

    return StorageInfo(
      totalMaps: readyMaps.length,
      routeMapsCount: routeMapsCount,
      placeMapsCount: placeMapsCount,
      totalBytes: totalBytes,
      totalMB: (totalBytes / (1024 * 1024)).toStringAsFixed(2),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // LRU EVICTION
  // ══════════════════════════════════════════════════════════════════════════

  /// Xóa maps cũ nhất khi vượt quá giới hạn storage
  Future<void> evictLRUMapsIfNeeded({int maxStorageMB = 500}) async {
    final totalBytes = await getTotalStorageBytes();
    final maxBytes = maxStorageMB * 1024 * 1024;

    if (totalBytes <= maxBytes) return;

    // Lấy tất cả maps, sort by lastUsedAt ascending (cũ nhất trước)
    final maps = await _dao.getAllMaps();
    maps.sort((a, b) {
      final aTime = a.lastUsedAt ?? a.downloadedAt ?? DateTime(2000);
      final bTime = b.lastUsedAt ?? b.downloadedAt ?? DateTime(2000);
      return aTime.compareTo(bTime);
    });

    int currentBytes = totalBytes;
    for (final map in maps) {
      if (currentBytes <= maxBytes) break;

      await deleteMap(map.mapId);
      currentBytes -= (map.sizeBytes ?? 0);
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════
// MODELS
// ══════════════════════════════════════════════════════════════════════════

class StorageInfo {
  final int totalMaps;
  final int routeMapsCount;
  final int placeMapsCount;
  final int totalBytes;
  final String totalMB;

  const StorageInfo({
    required this.totalMaps,
    required this.routeMapsCount,
    required this.placeMapsCount,
    required this.totalBytes,
    required this.totalMB,
  });

  @override
  String toString() {
    return 'StorageInfo(total: $totalMaps maps, $totalMB MB, '
        'routes: $routeMapsCount, places: $placeMapsCount)';
  }
}
