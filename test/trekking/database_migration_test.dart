import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:vietnam_trekking_mobile/core/database/database_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  for (final version in [1, 2, 3]) {
    test(
      'real v$version columns upgrade to v4 preserving rows and indexes',
      () async {
        final directory = await Directory.systemTemp.createTemp(
          'trekvn-migration-',
        );
        final path = '${directory.path}/app.db';
        var helper = await DatabaseHelper.openForTesting(path);
        try {
          final db = await helper.database;
          await db.insert('local_user', {
            'userId': 'existing-user',
            'displayName': 'Trekker',
          });
          await db.insert('cached_places', {
            'trekkingPlaceId': 'p',
            'name': 'Place',
          });
          await db.insert('cached_routes', {
            'trekkingRouteId': 'r',
            'trekkingPlaceId': 'p',
            'name': 'Route',
          });
          await db.insert('local_journeys', {
            'localJourneyId': 'pending-trip',
            'userId': 'existing-user',
            'trekkingPlaceId': 'p',
            'trekkingRouteId': 'r',
            'name': 'Trip',
            'syncStatus': 'PENDING',
          });
          await db.insert('sync_queue', {
            'entityType': 'JOURNEY',
            'entityId': 'pending-trip',
            'operation': 'CREATE',
            'idempotencyKey': 'original-key',
            'createdAt': '2026-10-10T00:00:00Z',
          });
          await db.execute('DROP TABLE offline_snapshots');
          await db.execute('DROP TABLE offline_outbox');
          await db.execute('DROP TABLE visited_provinces');
          await db.execute('''CREATE TABLE visited_provinces (
          provinceId TEXT PRIMARY KEY, name TEXT NOT NULL, firstVisitedAt TEXT,
          lastVisitedAt TEXT, visitCount INTEGER DEFAULT 1, source TEXT,
          syncStatus TEXT DEFAULT 'SYNCED', updatedAt TEXT)''');
          await db.execute(
            'ALTER TABLE local_journeys DROP COLUMN plannedEndAt',
          );
          if (version < 3) {
            for (final index in [
              'idx_maps_scope',
              'idx_maps_scope_place',
              'idx_maps_scope_route',
            ]) {
              await db.execute('DROP INDEX $index');
            }
            for (final entry in {
              'downloaded_maps': ['scope', 'waypointCount'],
              'cached_places': [
                'elevationMeters',
                'imageMapUrl',
                'offlineMapAvailable',
                'offlineMapVersion',
                'offlineMapSizeBytes',
              ],
              'local_journeys': ['note', 'participantCount'],
            }.entries) {
              for (final column in entry.value) {
                await db.execute(
                  'ALTER TABLE ${entry.key} DROP COLUMN $column',
                );
              }
            }
          }
          if (version < 2) {
            for (final column in [
              'currentRankCode',
              'currentRankName',
              'currentRankLevel',
              'totalXp',
              'nextRankCode',
              'nextRankXp',
              'rankUpdatedAt',
            ]) {
              await db.execute('ALTER TABLE local_user DROP COLUMN $column');
            }
          }
          await db.execute('PRAGMA user_version = $version');
          await helper.close();
          helper = await DatabaseHelper.openForTesting(path);
          final upgraded = await helper.database;
          expect(await upgraded.getVersion(), 4);
          expect(
            (await upgraded.query('local_user')).single['displayName'],
            'Trekker',
          );
          expect(
            (await upgraded.query('local_journeys')).single['syncStatus'],
            'PENDING',
          );
          expect(
            (await upgraded.query('sync_queue')).single['idempotencyKey'],
            'original-key',
          );
          expect(await upgraded.rawQuery('PRAGMA foreign_key_check'), isEmpty);
          final fresh = await DatabaseHelper.openForTesting(
            '${directory.path}/fresh.db',
          );
          try {
            final freshDb = await fresh.database;
            for (final table in [
              'local_user',
              'local_journeys',
              'cached_places',
              'downloaded_maps',
              'visited_provinces',
              'offline_snapshots',
              'offline_outbox',
            ]) {
              Future<List<String>> columns(Database db) async =>
                  (await db.rawQuery('PRAGMA table_info($table)'))
                      .map((r) => r['name'] as String)
                      .toList()
                    ..sort();
              expect(
                await columns(upgraded),
                await columns(freshDb),
                reason: table,
              );
            }
            Future<List<String>> indexes(Database db) async =>
                (await db.rawQuery(
                  "SELECT name FROM sqlite_master WHERE type = 'index' AND name LIKE 'idx_%' ORDER BY name",
                )).map((r) => r['name'] as String).toList();
            expect(await indexes(upgraded), await indexes(freshDb));
          } finally {
            await fresh.close();
          }
        } finally {
          await helper.close();
          await directory.delete(recursive: true);
        }
      },
    );
  }
}
