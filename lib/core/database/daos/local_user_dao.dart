import 'package:sqflite/sqflite.dart';

import '../database_helper.dart';
import '../upsert.dart';
import '../../services/offline_store.dart';
import '../models/local_user.dart';

class LocalUserDao {
  final DatabaseHelper _dbHelper;

  LocalUserDao({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<Database> get _db => _dbHelper.database;

  static const String _table = 'local_user';

  /// Lưu hoặc cập nhật user local (upsert)
  Future<void> upsert(LocalUser user) async {
    final db = await _db;
    await upsertRow(db, _table, user.toMap(), 'userId');
  }

  /// Lấy user theo userId
  Future<LocalUser?> findById(String userId) async {
    final db = await _db;
    final rows = await db.query(
      _table,
      where: 'userId = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return LocalUser.fromMap(rows.first);
  }

  /// Lấy user đang đăng nhập (chỉ có 1 row duy nhất trong app)
  Future<LocalUser?> getCurrentUser() async {
    final db = await _db;
    final owner = await OfflineStore.currentOwner();
    if (owner == null) return null;
    final rows = await db.query(
      _table,
      where: 'userId = ?',
      whereArgs: [owner],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return LocalUser.fromMap(rows.first);
  }

  /// Xóa user khi logout
  Future<void> deleteAll() async {
    final db = await _db;
    await db.delete(_table);
  }

  /// Cập nhật riêng phần gamification profile (rank + XP)
  /// để tránh overwrite toàn bộ row khi chỉ cần refresh rank.
  Future<void> updateRankProfile({
    required String userId,
    String? currentRankCode,
    String? currentRankName,
    int? currentRankLevel,
    int? totalXp,
    String? nextRankCode,
    int? nextRankXp,
    DateTime? rankUpdatedAt,
  }) async {
    final db = await _db;
    final values = <String, dynamic>{
      if (currentRankCode != null) 'currentRankCode': currentRankCode,
      if (currentRankName != null) 'currentRankName': currentRankName,
      if (currentRankLevel != null) 'currentRankLevel': currentRankLevel,
      if (totalXp != null) 'totalXp': totalXp,
      if (nextRankCode != null) 'nextRankCode': nextRankCode,
      if (nextRankXp != null) 'nextRankXp': nextRankXp,
      'rankUpdatedAt': (rankUpdatedAt ?? DateTime.now()).toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
    if (values.isEmpty) return;
    await db.update(_table, values, where: 'userId = ?', whereArgs: [userId]);
  }
}
