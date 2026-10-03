import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import '../models/sync_queue_item.dart';
import '../models/local_contribution.dart';

/// DAO cho sync_queue và local_contributions.
class SyncDao {
  final DatabaseHelper _dbHelper;

  SyncDao({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<Database> get _db => _dbHelper.database;

  // =========================================================================
  // SYNC QUEUE
  // =========================================================================

  /// Thêm item vào sync queue.
  /// Bỏ qua nếu idempotencyKey đã tồn tại (tránh duplicate).
  Future<int?> enqueue(SyncQueueItem item) async {
    final db = await _db;
    try {
      final id = await db.insert(
        'sync_queue',
        item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      return id > 0 ? id : null;
    } catch (_) {
      return null;
    }
  }

  Future<SyncQueueItem?> getSyncItem(int syncQueueId) async {
    final db = await _db;
    final rows = await db.query(
      'sync_queue',
      where: 'syncQueueId = ?',
      whereArgs: [syncQueueId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return SyncQueueItem.fromMap(rows.first);
  }

  /// Lấy danh sách items cần xử lý (PENDING, theo priority và thời gian)
  Future<List<SyncQueueItem>> getPendingItems({int limit = 20}) async {
    final db = await _db;
    final now = DateTime.now().toIso8601String();
    final rows = await db.rawQuery(
      '''
      SELECT * FROM sync_queue
      WHERE status = 'PENDING'
        AND (scheduledAfter IS NULL OR scheduledAfter <= ?)
      ORDER BY
        CASE priority
          WHEN 'IMMEDIATE' THEN 0
          WHEN 'NORMAL'    THEN 1
          WHEN 'OFF_PEAK'  THEN 2
          WHEN 'BULK'      THEN 3
          ELSE 4
        END,
        createdAt ASC
      LIMIT ?
      ''',
      [now, limit],
    );
    return rows.map(SyncQueueItem.fromMap).toList();
  }

  /// Lấy items theo entityType (ví dụ: lấy tất cả CHECKIN pending)
  Future<List<SyncQueueItem>> getItemsByEntity(
    String entityType,
    String entityId,
  ) async {
    final db = await _db;
    final rows = await db.query(
      'sync_queue',
      where: 'entityType = ? AND entityId = ?',
      whereArgs: [entityType, entityId],
      orderBy: 'createdAt ASC',
    );
    return rows.map(SyncQueueItem.fromMap).toList();
  }

  /// Đánh dấu item đang xử lý
  Future<void> markProcessing(int syncQueueId) async {
    final db = await _db;
    await db.update(
      'sync_queue',
      {
        'status': 'PROCESSING',
        'lastAttemptAt': DateTime.now().toIso8601String(),
      },
      where: 'syncQueueId = ?',
      whereArgs: [syncQueueId],
    );
  }

  /// Xóa item sau khi sync thành công
  Future<void> removeSyncItem(int syncQueueId) async {
    final db = await _db;
    await db.delete(
      'sync_queue',
      where: 'syncQueueId = ?',
      whereArgs: [syncQueueId],
    );
  }

  /// Đánh dấu thất bại và lên lịch retry
  Future<void> markFailed(
    int syncQueueId, {
    required String error,
    DateTime? nextRetryAt,
  }) async {
    final db = await _db;
    final current = await getSyncItem(syncQueueId);
    if (current == null) return;

    await db.update(
      'sync_queue',
      {
        'status': 'FAILED',
        'retryCount': current.retryCount + 1,
        'lastError': error,
        'lastAttemptAt': DateTime.now().toIso8601String(),
        'nextRetryAt': nextRetryAt?.toIso8601String(),
      },
      where: 'syncQueueId = ?',
      whereArgs: [syncQueueId],
    );
  }

  /// Reset failed items về PENDING để retry
  Future<void> resetFailedItems() async {
    final db = await _db;
    await db.update(
      'sync_queue',
      {'status': 'PENDING', 'nextRetryAt': null},
      where: 'status = ?',
      whereArgs: ['FAILED'],
    );
  }

  Future<int> countPendingItems() async {
    final db = await _db;
    final result = await db.rawQuery(
      "SELECT COUNT(*) as cnt FROM sync_queue WHERE status = 'PENDING'",
    );
    return result.first['cnt'] as int;
  }

  Future<void> clearSyncQueue() async {
    final db = await _db;
    await db.delete('sync_queue');
  }

  // =========================================================================
  // LOCAL CONTRIBUTIONS
  // =========================================================================

  Future<void> insertContribution(LocalContribution contribution) async {
    final db = await _db;
    await db.insert(
      'local_contributions',
      contribution.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateContribution(LocalContribution contribution) async {
    final db = await _db;
    await db.update(
      'local_contributions',
      contribution.toMap(),
      where: 'localContributionId = ?',
      whereArgs: [contribution.localContributionId],
    );
  }

  Future<LocalContribution?> getContribution(
    String localContributionId,
  ) async {
    final db = await _db;
    final rows = await db.query(
      'local_contributions',
      where: 'localContributionId = ?',
      whereArgs: [localContributionId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return LocalContribution.fromMap(rows.first);
  }

  Future<List<LocalContribution>> getContributionsByUser(
    String userId,
  ) async {
    final db = await _db;
    final rows = await db.query(
      'local_contributions',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );
    return rows.map(LocalContribution.fromMap).toList();
  }

  Future<List<LocalContribution>> getPendingSyncContributions() async {
    final db = await _db;
    final rows = await db.query(
      'local_contributions',
      where: 'syncStatus IN (?, ?)',
      whereArgs: ['PENDING', 'FAILED'],
      orderBy: 'createdAt ASC',
    );
    return rows.map(LocalContribution.fromMap).toList();
  }

  Future<void> updateContributionServerStatus(
    String localContributionId, {
    required String serverContributionId,
    required String serverStatus,
    String? adminNote,
    String? resultingEntityId,
  }) async {
    final db = await _db;
    final now = DateTime.now().toIso8601String();
    await db.update(
      'local_contributions',
      {
        'serverContributionId': serverContributionId,
        'serverStatus': serverStatus,
        'syncStatus': 'SYNCED',
        'adminNote': adminNote,
        'resultingEntityId': resultingEntityId,
        'lastSyncedAt': now,
        'updatedAt': now,
      },
      where: 'localContributionId = ?',
      whereArgs: [localContributionId],
    );
  }

  Future<void> deleteContribution(String localContributionId) async {
    final db = await _db;
    await db.delete(
      'local_contributions',
      where: 'localContributionId = ?',
      whereArgs: [localContributionId],
    );
  }
}
