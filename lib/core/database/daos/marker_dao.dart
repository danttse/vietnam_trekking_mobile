import 'package:sqflite/sqflite.dart';

import '../database_helper.dart';
import '../upsert.dart';
import '../models/local_journey_marker.dart';
import '../models/local_marker_media.dart';

/// DAO cho local_journey_markers và local_marker_media.
class MarkerDao {
  final DatabaseHelper _dbHelper;

  MarkerDao({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<Database> get _db => _dbHelper.database;

  // =========================================================================
  // JOURNEY MARKERS
  // =========================================================================

  Future<void> insertMarker(LocalJourneyMarker marker) async {
    final db = await _db;
    await upsertRow(
      db,
      'local_journey_markers',
      marker.toMap(),
      'localMarkerId',
    );
  }

  Future<void> updateMarker(LocalJourneyMarker marker) async {
    final db = await _db;
    await db.update(
      'local_journey_markers',
      marker.toMap(),
      where: 'localMarkerId = ?',
      whereArgs: [marker.localMarkerId],
    );
  }

  Future<LocalJourneyMarker?> getMarker(String localMarkerId) async {
    final db = await _db;
    final rows = await db.query(
      'local_journey_markers',
      where: 'localMarkerId = ?',
      whereArgs: [localMarkerId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return LocalJourneyMarker.fromMap(rows.first);
  }

  Future<List<LocalJourneyMarker>> getMarkersByJourney(
    String localJourneyId,
  ) async {
    final db = await _db;
    final rows = await db.query(
      'local_journey_markers',
      where: 'localJourneyId = ?',
      whereArgs: [localJourneyId],
      orderBy: 'markedAt ASC',
    );
    return rows.map(LocalJourneyMarker.fromMap).toList();
  }

  /// Lấy markers chờ sync
  Future<List<LocalJourneyMarker>> getPendingSyncMarkers() async {
    final db = await _db;
    final rows = await db.query(
      'local_journey_markers',
      where: 'syncStatus IN (?, ?)',
      whereArgs: ['LOCAL_ONLY', 'PENDING_SYNC'],
      orderBy: 'createdAt ASC',
    );
    return rows.map(LocalJourneyMarker.fromMap).toList();
  }

  Future<void> markMarkerSynced(
    String localMarkerId,
    String serverMarkerId,
  ) async {
    final db = await _db;
    await db.update(
      'local_journey_markers',
      {
        'serverMarkerId': serverMarkerId,
        'syncStatus': 'SYNCED',
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'localMarkerId = ?',
      whereArgs: [localMarkerId],
    );
  }

  Future<void> deleteMarker(String localMarkerId) async {
    final db = await _db;
    await db.delete(
      'local_journey_markers',
      where: 'localMarkerId = ?',
      whereArgs: [localMarkerId],
    );
  }

  Future<void> deleteMarkersByJourney(String localJourneyId) async {
    final db = await _db;
    await db.delete(
      'local_journey_markers',
      where: 'localJourneyId = ?',
      whereArgs: [localJourneyId],
    );
  }

  // =========================================================================
  // MARKER MEDIA
  // =========================================================================

  Future<void> insertMedia(LocalMarkerMedia media) async {
    final db = await _db;
    await db.insert(
      'local_marker_media',
      media.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<LocalMarkerMedia>> getMediaByMarker(String localMarkerId) async {
    final db = await _db;
    final rows = await db.query(
      'local_marker_media',
      where: 'localMarkerId = ?',
      whereArgs: [localMarkerId],
      orderBy: 'createdAt ASC',
    );
    return rows.map(LocalMarkerMedia.fromMap).toList();
  }

  /// Lấy tất cả media chờ upload
  Future<List<LocalMarkerMedia>> getPendingUploadMedia() async {
    final db = await _db;
    final rows = await db.query(
      'local_marker_media',
      where: 'uploadStatus IN (?, ?)',
      whereArgs: ['LOCAL', 'PENDING_UPLOAD'],
      orderBy: 'createdAt ASC',
    );
    return rows.map(LocalMarkerMedia.fromMap).toList();
  }

  Future<void> markMediaUploaded(
    String localMarkerMediaId,
    String remoteUrl,
  ) async {
    final db = await _db;
    await db.update(
      'local_marker_media',
      {'remoteUrl': remoteUrl, 'uploadStatus': 'UPLOADED'},
      where: 'localMarkerMediaId = ?',
      whereArgs: [localMarkerMediaId],
    );
  }

  Future<void> updateMediaUploadStatus(
    String localMarkerMediaId,
    String uploadStatus,
  ) async {
    final db = await _db;
    await db.update(
      'local_marker_media',
      {'uploadStatus': uploadStatus},
      where: 'localMarkerMediaId = ?',
      whereArgs: [localMarkerMediaId],
    );
  }

  Future<void> deleteMedia(String localMarkerMediaId) async {
    final db = await _db;
    await db.delete(
      'local_marker_media',
      where: 'localMarkerMediaId = ?',
      whereArgs: [localMarkerMediaId],
    );
  }

  Future<void> deleteMediaByMarker(String localMarkerId) async {
    final db = await _db;
    await db.delete(
      'local_marker_media',
      where: 'localMarkerId = ?',
      whereArgs: [localMarkerId],
    );
  }
}
