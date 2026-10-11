import 'package:sqflite/sqflite.dart';

import '../database_helper.dart';
import '../../services/offline_store.dart';
import '../models/visited_province.dart';
import '../models/downloaded_map.dart';

/// DAO cho visited_provinces và downloaded_maps.
class OfflineDataDao {
  final DatabaseHelper _dbHelper;
  final Future<String?> Function() _ownerProvider;

  OfflineDataDao({
    DatabaseHelper? dbHelper,
    Future<String?> Function()? ownerProvider,
  }) : _ownerProvider = ownerProvider ?? OfflineStore.currentOwner,
       _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<Database> get _db => _dbHelper.database;

  // =========================================================================
  // VISITED PROVINCES
  // =========================================================================

  Future<String> _owner() async {
    final owner = await _ownerProvider();
    if (owner == null || owner.isEmpty)
      throw StateError('Vui lòng đăng nhập để xem tỉnh đã thăm.');
    return owner;
  }

  Future<void> upsertVisitedProvince(VisitedProvince province) async {
    final owner = await _owner();
    if (province.ownerId.isNotEmpty && province.ownerId != owner)
      throw StateError('Tài khoản không khớp.');
    final db = await _db;
    await db.insert('visited_provinces', {
      ...province.toMap(),
      'ownerId': owner,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> recordVisit({
    required String provinceId,
    required String provinceName,
    String? source,
  }) async {
    final owner = await _owner();
    final now = DateTime.now().toUtc().toIso8601String();
    final db = await _db;
    await db.rawInsert(
      'INSERT INTO visited_provinces(ownerId,provinceId,name,firstVisitedAt,lastVisitedAt,visitCount,source,syncStatus,updatedAt) '
      "VALUES(?,?,?,?,?,1,?,'PENDING',?) ON CONFLICT(ownerId,provinceId) DO UPDATE SET lastVisitedAt=excluded.lastVisitedAt,"
      "visitCount=visited_provinces.visitCount+1,syncStatus='PENDING',updatedAt=excluded.updatedAt",
      [owner, provinceId, provinceName, now, now, source, now],
    );
  }

  Future<VisitedProvince?> getVisitedProvince(String provinceId) async {
    final rows = await (await _db).query(
      'visited_provinces',
      where: 'ownerId = ? AND provinceId = ?',
      whereArgs: [await _owner(), provinceId],
      limit: 1,
    );
    return rows.isEmpty ? null : VisitedProvince.fromMap(rows.first);
  }

  Future<List<VisitedProvince>> getAllVisitedProvinces() async {
    final rows = await (await _db).query(
      'visited_provinces',
      where: 'ownerId = ?',
      whereArgs: [await _owner()],
      orderBy: 'lastVisitedAt DESC',
    );
    return rows.map(VisitedProvince.fromMap).toList();
  }

  Future<List<VisitedProvince>> getPendingSyncVisitedProvinces() async {
    final rows = await (await _db).query(
      'visited_provinces',
      where: 'ownerId = ? AND syncStatus = ?',
      whereArgs: [await _owner(), 'PENDING'],
    );
    return rows.map(VisitedProvince.fromMap).toList();
  }

  Future<void> markVisitedProvinceSynced(String provinceId) async {
    await (await _db).update(
      'visited_provinces',
      {'syncStatus': 'SYNCED'},
      where: 'ownerId = ? AND provinceId = ?',
      whereArgs: [await _owner(), provinceId],
    );
  }

  Future<int> countVisitedProvinces() async {
    final rows = await (await _db).rawQuery(
      'SELECT COUNT(*) AS cnt FROM visited_provinces WHERE ownerId = ?',
      [await _owner()],
    );
    return rows.first['cnt'] as int;
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

  /// Tìm map theo route ID và scope
  Future<DownloadedMap?> getMapByRoute(String trekkingRouteId) async {
    final db = await _db;
    final rows = await db.query(
      'downloaded_maps',
      where: 'scope = ? AND trekkingRouteId = ? AND status = ?',
      whereArgs: ['ROUTE', trekkingRouteId, 'READY'],
      orderBy: 'mapVersion DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return DownloadedMap.fromMap(rows.first);
  }

  /// Tìm map theo place ID và scope
  Future<DownloadedMap?> getMapByPlace(String trekkingPlaceId) async {
    final db = await _db;
    final rows = await db.query(
      'downloaded_maps',
      where: 'scope = ? AND trekkingPlaceId = ? AND status = ?',
      whereArgs: ['PLACE', trekkingPlaceId, 'READY'],
      orderBy: 'mapVersion DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return DownloadedMap.fromMap(rows.first);
  }

  /// Lấy tất cả maps của place (có thể có nhiều versions)
  Future<List<DownloadedMap>> getMapsByPlace(String trekkingPlaceId) async {
    final db = await _db;
    final rows = await db.query(
      'downloaded_maps',
      where: 'scope = ? AND trekkingPlaceId = ?',
      whereArgs: ['PLACE', trekkingPlaceId],
      orderBy: 'mapVersion DESC',
    );
    return rows.map(DownloadedMap.fromMap).toList();
  }

  /// Lấy tất cả maps theo scope
  Future<List<DownloadedMap>> getMapsByScope(String scope) async {
    final db = await _db;
    final rows = await db.query(
      'downloaded_maps',
      where: 'scope = ?',
      whereArgs: [scope],
      orderBy: 'downloadedAt DESC',
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
    await db.delete('downloaded_maps', where: 'mapId = ?', whereArgs: [mapId]);
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
