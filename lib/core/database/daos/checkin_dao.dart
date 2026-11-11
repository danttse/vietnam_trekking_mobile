import 'package:sqflite/sqflite.dart';

import '../database_helper.dart';
import '../models/offline_checkin.dart';

/// DAO cho offline_checkins.
class CheckinDao {
  final DatabaseHelper _dbHelper;

  CheckinDao({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<Database> get _db => _dbHelper.database;

  static const String _table = 'offline_checkins';

  Future<void> insertCheckin(OfflineCheckin checkin) async {
    final db = await _db;
    await db.insert(
      _table,
      checkin.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateCheckin(OfflineCheckin checkin) async {
    final db = await _db;
    await db.update(
      _table,
      checkin.toMap(),
      where: 'localCheckinId = ?',
      whereArgs: [checkin.localCheckinId],
    );
  }

  Future<OfflineCheckin?> getCheckin(String localCheckinId) async {
    final db = await _db;
    final rows = await db.query(
      _table,
      where: 'localCheckinId = ?',
      whereArgs: [localCheckinId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return OfflineCheckin.fromMap(rows.first);
  }

  // Lay danh sach checkin theo journey id (ho tro ca local va server id)
  Future<List<OfflineCheckin>> getCheckinsByJourney(String journeyRef) async {
    return getCheckinsByJourneyIds([journeyRef]);
  }

  // Lay danh sach checkin theo tap hop journey ids
  Future<List<OfflineCheckin>> getCheckinsByJourneyIds(Iterable<String> journeyIds) async {
    final ids = journeyIds.where((id) => id.isNotEmpty).toSet();
    if (ids.isEmpty) return [];
    final db = await _db;
    final inClause = ids.map((_) => '?').join(',');
    final rows = await db.rawQuery(
      '''
      SELECT DISTINCT c.* FROM $_table c
      LEFT JOIN local_journeys j ON c.localJourneyId = j.localJourneyId OR c.localJourneyId = j.serverJourneyId
      WHERE c.localJourneyId IN ($inClause)
         OR j.localJourneyId IN ($inClause)
         OR j.serverJourneyId IN ($inClause)
         OR c.localJourneyId IN (
           SELECT j2.localJourneyId FROM local_journeys j2
           WHERE j2.localJourneyId IN ($inClause) OR j2.serverJourneyId IN ($inClause)
         )
         OR c.localJourneyId IN (
           SELECT j3.serverJourneyId FROM local_journeys j3
           WHERE j3.localJourneyId IN ($inClause) OR j3.serverJourneyId IN ($inClause)
         )
      ORDER BY c.checkedAt ASC
    ''',
      [...ids, ...ids, ...ids, ...ids, ...ids, ...ids, ...ids],
    );
    return rows
        .map((r) => OfflineCheckin.fromMap(Map<String, dynamic>.from(r)))
        .toList();
  }

  // Kiem tra milestone da duoc checkin chua
  Future<bool> hasCheckin({
    required String localJourneyId,
    required String milestoneId,
    required String userId,
  }) async {
    final db = await _db;
    final rows = await db.rawQuery(
      '''
      SELECT 1 FROM $_table c
      LEFT JOIN local_journeys j ON c.localJourneyId = j.localJourneyId OR c.localJourneyId = j.serverJourneyId
      WHERE c.milestoneId = ? AND (
        c.localJourneyId = ?
        OR j.localJourneyId = ?
        OR j.serverJourneyId = ?
        OR c.localJourneyId IN (
          SELECT j2.localJourneyId FROM local_journeys j2
          WHERE j2.localJourneyId = ? OR j2.serverJourneyId = ?
        )
      )
      LIMIT 1
    ''',
      [milestoneId, localJourneyId, localJourneyId, localJourneyId, localJourneyId, localJourneyId],
    );
    return rows.isNotEmpty;
  }

  /// Lấy check-in chờ sync
  Future<List<OfflineCheckin>> getPendingSyncCheckins() async {
    final db = await _db;
    final rows = await db.query(
      _table,
      where: 'syncStatus = ?',
      whereArgs: ['PENDING'],
      orderBy: 'checkedAt ASC',
    );
    return rows.map(OfflineCheckin.fromMap).toList();
  }

  Future<void> markCheckinSynced(
    String localCheckinId,
    String serverCheckinId,
  ) async {
    final db = await _db;
    await db.update(
      _table,
      {
        'serverCheckinId': serverCheckinId,
        'syncStatus': 'SYNCED',
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'localCheckinId = ?',
      whereArgs: [localCheckinId],
    );
  }

  Future<void> updateVerificationStatus(
    String localCheckinId,
    String verificationStatus,
  ) async {
    final db = await _db;
    await db.update(
      _table,
      {
        'verificationStatus': verificationStatus,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'localCheckinId = ?',
      whereArgs: [localCheckinId],
    );
  }

  Future<int> countCheckins(String localJourneyId) async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as cnt FROM $_table WHERE localJourneyId = ?',
      [localJourneyId],
    );
    return result.first['cnt'] as int;
  }

  Future<void> deleteCheckin(String localCheckinId) async {
    final db = await _db;
    await db.delete(
      _table,
      where: 'localCheckinId = ?',
      whereArgs: [localCheckinId],
    );
  }

  Future<void> deleteCheckinsByJourney(String localJourneyId) async {
    final db = await _db;
    await db.delete(
      _table,
      where: 'localJourneyId = ?',
      whereArgs: [localJourneyId],
    );
  }
}
