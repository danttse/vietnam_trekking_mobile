import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import '../models/cached_place.dart';
import '../models/cached_route.dart';
import '../models/cached_milestone.dart';
import '../models/cached_province.dart';

/// DAO cho nhóm cache: places, routes, milestones, provinces.
class CacheDao {
  final DatabaseHelper _dbHelper;

  CacheDao({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<Database> get _db => _dbHelper.database;

  // =========================================================================
  // PROVINCES
  // =========================================================================

  Future<void> upsertProvince(CachedProvince province) async {
    final db = await _db;
    await db.insert(
      'cached_provinces',
      province.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> upsertProvinces(List<CachedProvince> provinces) async {
    final db = await _db;
    final batch = db.batch();
    for (final p in provinces) {
      batch.insert(
        'cached_provinces',
        p.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<CachedProvince?> getProvince(String provinceId) async {
    final db = await _db;
    final rows = await db.query(
      'cached_provinces',
      where: 'provinceId = ?',
      whereArgs: [provinceId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return CachedProvince.fromMap(rows.first);
  }

  Future<List<CachedProvince>> getAllProvinces() async {
    final db = await _db;
    final rows = await db.query('cached_provinces', orderBy: 'name ASC');
    return rows.map(CachedProvince.fromMap).toList();
  }

  Future<void> deleteProvince(String provinceId) async {
    final db = await _db;
    await db.delete(
      'cached_provinces',
      where: 'provinceId = ?',
      whereArgs: [provinceId],
    );
  }

  // =========================================================================
  // PLACES
  // =========================================================================

  Future<void> upsertPlace(CachedPlace place) async {
    final db = await _db;
    await db.insert(
      'cached_places',
      place.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> upsertPlaces(List<CachedPlace> places) async {
    final db = await _db;
    final batch = db.batch();
    for (final p in places) {
      batch.insert(
        'cached_places',
        p.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<CachedPlace?> getPlace(String trekkingPlaceId) async {
    final db = await _db;
    final rows = await db.query(
      'cached_places',
      where: 'trekkingPlaceId = ?',
      whereArgs: [trekkingPlaceId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return CachedPlace.fromMap(rows.first);
  }

  Future<List<CachedPlace>> getAllPlaces() async {
    final db = await _db;
    final rows = await db.query('cached_places', orderBy: 'name ASC');
    return rows.map(CachedPlace.fromMap).toList();
  }

  Future<List<CachedPlace>> getPlacesByProvince(String provinceId) async {
    final db = await _db;
    final rows = await db.query(
      'cached_places',
      where: 'provinceId = ?',
      whereArgs: [provinceId],
      orderBy: 'name ASC',
    );
    return rows.map(CachedPlace.fromMap).toList();
  }

  Future<void> deletePlace(String trekkingPlaceId) async {
    final db = await _db;
    await db.delete(
      'cached_places',
      where: 'trekkingPlaceId = ?',
      whereArgs: [trekkingPlaceId],
    );
  }

  // =========================================================================
  // ROUTES
  // =========================================================================

  Future<void> upsertRoute(CachedRoute route) async {
    final db = await _db;
    await db.insert(
      'cached_routes',
      route.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> upsertRoutes(List<CachedRoute> routes) async {
    final db = await _db;
    final batch = db.batch();
    for (final r in routes) {
      batch.insert(
        'cached_routes',
        r.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<CachedRoute?> getRoute(String trekkingRouteId) async {
    final db = await _db;
    final rows = await db.query(
      'cached_routes',
      where: 'trekkingRouteId = ?',
      whereArgs: [trekkingRouteId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return CachedRoute.fromMap(rows.first);
  }

  Future<List<CachedRoute>> getRoutesByPlace(String trekkingPlaceId) async {
    final db = await _db;
    final rows = await db.query(
      'cached_routes',
      where: 'trekkingPlaceId = ?',
      whereArgs: [trekkingPlaceId],
      orderBy: 'name ASC',
    );
    return rows.map(CachedRoute.fromMap).toList();
  }

  Future<void> deleteRoute(String trekkingRouteId) async {
    final db = await _db;
    await db.delete(
      'cached_routes',
      where: 'trekkingRouteId = ?',
      whereArgs: [trekkingRouteId],
    );
  }

  // =========================================================================
  // MILESTONES
  // =========================================================================

  Future<void> upsertMilestone(CachedMilestone milestone) async {
    final db = await _db;
    await db.insert(
      'cached_milestones',
      milestone.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> upsertMilestones(List<CachedMilestone> milestones) async {
    final db = await _db;
    final batch = db.batch();
    for (final m in milestones) {
      batch.insert(
        'cached_milestones',
        m.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<CachedMilestone?> getMilestone(String milestoneId) async {
    final db = await _db;
    final rows = await db.query(
      'cached_milestones',
      where: 'milestoneId = ?',
      whereArgs: [milestoneId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return CachedMilestone.fromMap(rows.first);
  }

  /// Lấy tất cả milestones của route, theo thứ tự sequenceNumber
  Future<List<CachedMilestone>> getMilestonesByRoute(
    String trekkingRouteId,
  ) async {
    final db = await _db;
    final rows = await db.query(
      'cached_milestones',
      where: 'trekkingRouteId = ?',
      whereArgs: [trekkingRouteId],
      orderBy: 'sequenceNumber ASC',
    );
    return rows.map(CachedMilestone.fromMap).toList();
  }

  Future<void> deleteMilestonesByRoute(String trekkingRouteId) async {
    final db = await _db;
    await db.delete(
      'cached_milestones',
      where: 'trekkingRouteId = ?',
      whereArgs: [trekkingRouteId],
    );
  }

  // =========================================================================
  // BULK CACHE OPERATIONS
  // =========================================================================

  /// Xóa toàn bộ cache (dùng khi refresh từ server)
  Future<void> clearAllCache() async {
    final db = await _db;
    final batch = db.batch();
    batch.delete('cached_milestones');
    batch.delete('cached_routes');
    batch.delete('cached_places');
    batch.delete('cached_provinces');
    await batch.commit(noResult: true);
  }
}
