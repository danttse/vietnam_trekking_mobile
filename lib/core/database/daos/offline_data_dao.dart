import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import '../models/visited_province.dart';
import '../models/downloaded_map.dart';

/// DAO cho visited_provinces và downloaded_maps.
class OfflineDataDao {
  final DatabaseHelper _dbHelper;

  OfflineDataDao({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<Database> get _db => _dbHelper.database;

  // =========================================================================
  // VISITED PROVINCES
  // =========================================================================

  Future<void> upsertVisitedProvince(VisitedProvince province) async {
    final db = await _db;
    await db.insert(
      'visited_provinces',
      province.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Ghi nhận visit mới: tăng visitCount hoặc insert nếu chưa có
  Future<void> recordVisit({
    required String provinceId,
    required String provinceName,
    String? source,
  }) async {
    final db = await _db;
    final now = DateTime.now().toIso8601String();

    // Thử lấy bản ghi hiện có
    final rows = await db.query(
      'visited_provinces',
      where: 'provinceId = ?',
      whereArgs: [provinceId],
      limit: 1,
    );

    if (rows.isEmpty) {
      await db.insert('visited_provinces', {
        'provinceId': provinceId,
        'name': provinceName,
        'firstVisitedAt': now,
        'lastVisitedAt': now,
        'visitCount': 1,
        'source': source,
        'syncStatus': 'PENDING',
        'updatedAt': now,
      });
    } else {
      final currentCount = rows.first['visitCount'] as int? ?? 1;
      await db.update(
        'visited_provinces',
        {
          'lastVisitedAt': now,
          'visitCount': currentCount + 1,
          'syncStatus': 'PENDING',
          'updatedAt': now,
        },
        where: 'provinceId = ?',
        whereArgs: [provinceId],
      );
    }
  }

  Future<VisitedProvince?> getVisitedProvince(String provinceId) async {
    final db = await _db;
    final rows = await db.query(
      'visited_provinces',
      where: 'provinceId = ?',
      whereArgs: [provinceId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return VisitedProvince.fromMap(rows.first);
  }

  Future<List<VisitedProvince>> getAllVisitedProvinces() async {
    final db = await _db;
    final rows = await db.query(
      'visited_provinces',
      orderBy: 'lastVisitedAt DESC',
    );
    return rows.map(VisitedProvince.fromMap).toList();
  }

  Future<List<VisitedProvince>> getPendingSyncVisitedProvinces() async {
    final db = await _db;
    final rows = await db.query(
      'visited_provinces',
      where: 'syncStatus = ?',
      whereArgs: ['PENDING'],
    );
    return rows.map(VisitedProvince.fromMap).toList();
  }

  Future<void> markVisitedProvinceSynced(String provinceId) async {
    final db = await _db;
    await db.update(
      'visited_provinces',
      {'syncStatus': 'SYNCED', 'updatedAt': DateTime.now().toIso8601String()},
      where: 'provinceId = ?',
      whereArgs: [provinceId],
    );
  }

  Future<int> countVisitedProvinces() async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as cnt FROM visited_provinces',
    );
    return result.first['cnt'] as int;
  }

  // =========================================================================
  // DOWNLOADED MAPS
  // =========================================================================

  Future<void> insertMap(DownloadedMap map) async {
    final db = await _db;
    await db.insert(
      'downloaded_maps',
      map.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateMap(DownloadedMap map) async {
    final db = await _db;
    await db.update(
      'downloaded_maps',
      map.toMap(),
      where: 'mapId = ?',
      whereArgs: [map.mapId],
    );
  }

  Future<DownloadedMap?> getMap(String mapId) async {
    final db = await _db;
    final rows = await db.query(
      'downloaded_maps',
      where: 'mapId = ?',
      whereArgs: [mapId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return DownloadedMap.fromMap(rows.first);
  }

  Future<List<DownloadedMap>> getAllMaps() async {
    final db = await _db;
    final rows = await db.query(
      'downloaded_maps',
      orderBy: 'downloadedAt DESC',
    );
    return rows.map(DownloadedMap.fromMap).toList();
  }

  Future<DownloadedMap?> getMapByRoute(String trekkingRouteId) async {
    final db = await _db;
    final rows = await db.query(
      'downloaded_maps',
      where: 'trekkingRouteId = ? AND status = ?',
      whereArgs: [trekkingRouteId, 'READY'],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return DownloadedMap.fromMap(rows.first);
  }

  Future<List<DownloadedMap>> getMapsByPlace(String trekkingPlaceId) async {
    final db = await _db;
    final rows = await db.query(
      'downloaded_maps',
      where: 'trekkingPlaceId = ? AND status = ?',
      whereArgs: [trekkingPlaceId, 'READY'],
    );
    return rows.map(DownloadedMap.fromMap).toList();
  }

  /// Cập nhật thời điểm sử dụng gần nhất (dùng để LRU eviction)
  Future<void> touchMap(String mapId) async {
    final db = await _db;
    await db.update(
      'downloaded_maps',
      {'lastUsedAt': DateTime.now().toIso8601String()},
      where: 'mapId = ?',
      whereArgs: [mapId],
    );
  }

  Future<void> deleteMap(String mapId) async {
    final db = await _db;
    await db.delete(
      'downloaded_maps',
      where: 'mapId = ?',
      whereArgs: [mapId],
    );
  }

  /// Lấy tổng dung lượng các bản đồ đã tải (bytes)
  Future<int> getTotalMapSizeBytes() async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT SUM(sizeBytes) as total FROM downloaded_maps WHERE status = ?',
      ['READY'],
    );
    return (result.first['total'] as int?) ?? 0;
  }
}
