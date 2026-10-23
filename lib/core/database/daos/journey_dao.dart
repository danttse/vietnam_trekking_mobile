import 'package:sqflite/sqflite.dart';

import '../database_helper.dart';
import '../upsert.dart';
import '../models/local_journey.dart';
import '../models/track_point.dart';

/// DAO cho local_journeys và track_points.
class JourneyDao {
  final DatabaseHelper _dbHelper;

  JourneyDao({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<Database> get _db => _dbHelper.database;

  // =========================================================================
  // LOCAL JOURNEYS
  // =========================================================================

  Future<void> insertJourney(LocalJourney journey) async {
    final db = await _db;
    await upsertRow(db, 'local_journeys', journey.toMap(), 'localJourneyId');
  }

  Future<void> updateJourney(LocalJourney journey) async {
    final db = await _db;
    await db.update(
      'local_journeys',
      journey.toMap(),
      where: 'localJourneyId = ?',
      whereArgs: [journey.localJourneyId],
    );
  }

  Future<LocalJourney?> getJourney(String localJourneyId) async {
    final db = await _db;
    final rows = await db.query(
      'local_journeys',
      where: 'localJourneyId = ?',
      whereArgs: [localJourneyId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return LocalJourney.fromMap(rows.first);
  }

  Future<List<LocalJourney>> getJourneysByUser(String userId) async {
    final db = await _db;
    final rows = await db.query(
      'local_journeys',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );
    return rows.map(LocalJourney.fromMap).toList();
  }

  Future<List<LocalJourney>> getJourneysByStatus(String status) async {
    final db = await _db;
    final rows = await db.query(
      'local_journeys',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'createdAt DESC',
    );
    return rows.map(LocalJourney.fromMap).toList();
  }

  /// Lấy journey đang ACTIVE (chỉ có 1 tại một thời điểm)
  Future<LocalJourney?> getActiveJourney(String userId) async {
    final db = await _db;
    final rows = await db.query(
      'local_journeys',
      where: 'userId = ? AND status = ?',
      whereArgs: [userId, 'ACTIVE'],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return LocalJourney.fromMap(rows.first);
  }

  /// Lấy các journey chưa đồng bộ lên server
  Future<List<LocalJourney>> getPendingSyncJourneys() async {
    final db = await _db;
    final rows = await db.query(
      'local_journeys',
      where: 'syncStatus != ?',
      whereArgs: ['SYNCED'],
      orderBy: 'createdAt ASC',
    );
    return rows.map(LocalJourney.fromMap).toList();
  }

  /// Cập nhật serverJourneyId sau khi sync thành công
  Future<void> markSynced(String localJourneyId, String serverJourneyId) async {
    final db = await _db;
    await db.update(
      'local_journeys',
      {
        'serverJourneyId': serverJourneyId,
        'syncStatus': 'SYNCED',
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'localJourneyId = ?',
      whereArgs: [localJourneyId],
    );
  }

  /// Cập nhật thống kê journey trong khi đang đi
  Future<void> updateStats({
    required String localJourneyId,
    required double distanceMeters,
    required int durationSeconds,
    required double elevationGain,
    double? maxAltitude,
    int? checkinCount,
    int? markerCount,
  }) async {
    final db = await _db;
    final updates = <String, Object?>{
      'distanceMeters': distanceMeters,
      'durationSeconds': durationSeconds,
      'elevationGain': elevationGain,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    if (maxAltitude != null) updates['maxAltitude'] = maxAltitude;
    if (checkinCount != null) updates['checkinCount'] = checkinCount;
    if (markerCount != null) updates['markerCount'] = markerCount;

    await db.update(
      'local_journeys',
      updates,
      where: 'localJourneyId = ?',
      whereArgs: [localJourneyId],
    );
  }

  Future<void> deleteJourney(String localJourneyId) async {
    final db = await _db;
    await db.delete(
      'local_journeys',
      where: 'localJourneyId = ?',
      whereArgs: [localJourneyId],
    );
  }

  // =========================================================================
  // TRACK POINTS
  // =========================================================================

  /// Insert một điểm GPS mới (hot path — dùng raw insert)
  Future<int> insertTrackPoint(TrackPoint point) async {
    final db = await _db;
    return db.insert('track_points', point.toMap());
  }

  /// Bulk insert nhiều điểm GPS cùng lúc (khi buffer flush)
  Future<void> insertTrackPoints(List<TrackPoint> points) async {
    if (points.isEmpty) return;
    final db = await _db;
    final batch = db.batch();
    for (final p in points) {
      batch.insert('track_points', p.toMap());
    }
    await batch.commit(noResult: true);
  }

  Future<List<TrackPoint>> getTrackPoints(String localJourneyId) async {
    final db = await _db;
    final rows = await db.query(
      'track_points',
      where: 'localJourneyId = ?',
      whereArgs: [localJourneyId],
      orderBy: 'recordedAt ASC',
    );
    return rows.map(TrackPoint.fromMap).toList();
  }

  /// Lấy N điểm GPS mới nhất (preview track)
  Future<List<TrackPoint>> getRecentTrackPoints(
    String localJourneyId, {
    int limit = 100,
  }) async {
    final db = await _db;
    final rows = await db.query(
      'track_points',
      where: 'localJourneyId = ?',
      whereArgs: [localJourneyId],
      orderBy: 'recordedAt DESC',
      limit: limit,
    );
    // Trả về theo thứ tự thời gian tăng dần
    return rows.reversed.map(TrackPoint.fromMap).toList();
  }

  Future<int> countTrackPoints(String localJourneyId) async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as cnt FROM track_points WHERE localJourneyId = ?',
      [localJourneyId],
    );
    return result.first['cnt'] as int;
  }

  Future<void> deleteTrackPoints(String localJourneyId) async {
    final db = await _db;
    await db.delete(
      'track_points',
      where: 'localJourneyId = ?',
      whereArgs: [localJourneyId],
    );
  }
}
