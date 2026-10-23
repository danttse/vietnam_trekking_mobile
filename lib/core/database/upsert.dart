import 'package:sqflite/sqflite.dart';

String _sql(String table, Map<String, Object?> row, String key) {
  final columns = row.keys.toList();
  return 'INSERT INTO $table (${columns.join(',')}) VALUES (${columns.map((_) => '?').join(',')}) '
      'ON CONFLICT($key) DO UPDATE SET ${columns.where((c) => c != key).map((c) => '$c=excluded.$c').join(',')}';
}

/// SQLite REPLACE deletes the old parent row and breaks foreign keys. Update
/// in place so refreshing the catalog keeps journeys and check-ins intact.
Future<void> upsertRow(
  DatabaseExecutor db,
  String table,
  Map<String, Object?> row,
  String key,
) async {
  await db.rawInsert(_sql(table, row, key), row.values.toList());
}

void batchUpsert(
  Batch batch,
  String table,
  Map<String, Object?> row,
  String key,
) {
  batch.rawInsert(_sql(table, row, key), row.values.toList());
}
