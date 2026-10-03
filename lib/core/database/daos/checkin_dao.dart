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

  Future<List<OfflineCheckin>> getCheckinsByJourney(
    String localJourneyId,
  ) async {
    final db = await _db;
    final rows = await db.query(
      _table,
      where: 'localJourneyId = ?',
      whereArgs: [localJourneyId],
      orderBy: 'checkedAt ASC',
    );
    return rows.map(OfflineCheckin.fromMap).toList();
  }

  /// Kiểm tra xem milestone đã được check-in trong journey này chưa
  Future<bool> hasCheckin({
    required String localJourneyId,
    required String milestoneId,
    required String userId,
  }) async {
    final db = await _db;
    final rows = await db.query(
      _table,
      where: 'localJourneyId = ? AND milestoneId = ? AND userId = ?',
      whereArgs: [localJourneyId, milestoneId, userId],
      limit: 1,
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
