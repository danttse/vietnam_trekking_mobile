import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:vietnam_trekking_mobile/core/database/database_helper.dart';
import 'package:vietnam_trekking_mobile/core/services/offline_store.dart';
import 'package:vietnam_trekking_mobile/core/services/trekking_catalog_service.dart';
import 'package:vietnam_trekking_mobile/features/explore/data/explore_cache_manager.dart';

import 'frontend_api_integration_test.dart' show client;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  late DatabaseHelper helper;
  late OfflineStore store;
  late TrekkingCatalogService service;
  late DateTime time;
  late int calls;
  late bool failing;

  setUp(() async {
    helper = await DatabaseHelper.openForTesting(inMemoryDatabasePath);
    store = OfflineStore(
      databaseHelper: helper,
      ownerProvider: () async => null,
    );
    time = DateTime.utc(2026, 10, 27);
    calls = 0;
    failing = false;
    service = TrekkingCatalogService(
      store: store,
      client: client((r) {
        calls++;
        if (failing) return {'_httpStatus': 503};
        return {
          'data': {
            'items': [
              {'trekkingPlaceId': 'p$calls'},
            ],
            'page': r.queryParameters['page'],
            'limit': r.queryParameters['limit'],
            'total': 1,
            'hasMore': false,
          },
        };
      }),
    );
  });
  tearDown(() async => (await helper.database).close());

  test('RAM hits and SQLite across manager recreation avoid requests for ten minutes', () async {
    var cache = ExploreCacheManager(clock: () => time);
    await cache.getPage(service: service, path: '/places');
    time = time.add(const Duration(minutes: 9));
    await cache.getPage(service: service, path: '/places');
    cache = ExploreCacheManager(clock: () => time);
    final data = await cache.getPage(service: service, path: '/places');
    expect(calls, 1);
    expect(data.items.single['trekkingPlaceId'], 'p1');
  });

  test(
    'expired pages are displayed before revalidation; reads do not extend TTL',
    () async {
      final cache = ExploreCacheManager(clock: () => time);
      await cache.getPage(service: service, path: '/places');
      time = time.add(const Duration(minutes: 10));
      String? shown;
      final fresh = await cache.getPage(
        service: service,
        path: '/places',
        onCached: (old) {
          shown = old.items.single['trekkingPlaceId'] as String;
        },
      );
      expect(shown, 'p1');
      expect(fresh.items.single['trekkingPlaceId'], 'p2');
      expect(calls, 2);
    },
  );

  test('force refresh bypasses fresh local cache, offline failure retains old data', () async {
    final cache = ExploreCacheManager(clock: () => time);
    await cache.getPage(service: service, path: '/places');
    await cache.getPage(service: service, path: '/places', forceRefresh: true);
    expect(calls, 2);
    failing = true;
    time = time.add(const Duration(minutes: 11));
    Object? error;
    final old = await cache.getPage(
      service: service,
      path: '/places',
      onRefreshError: (e) => error = e,
    );
    expect(old.items.single['trekkingPlaceId'], 'p2');
    expect(error, isNotNull);
    expect(calls, 3);
  });

  test(
    'filter, search, sort, resource and page have isolated cache entries',
    () async {
      final cache = ExploreCacheManager(clock: () => time);
      await cache.getPage(service: service, path: '/places');
      await cache.getPage(service: service, path: '/places', region: 'NORTH');
      await cache.getPage(service: service, path: '/places', region: 'SOUTH');
      await cache.getPage(service: service, path: '/places', sort: 'popular');
      await cache.getPage(service: service, path: '/places', query: 'Fansipan');
      await cache.getPage(service: service, path: '/places', page: 2);
      await cache.getPage(service: service, path: '/routes');
      expect(calls, 7);
      await cache.getPage(service: service, path: '/places', region: 'NORTH');
      expect(calls, 7);
    },
  );

  test('refreshing the first page invalidates old subsequent pages in RAM and SQLite', () async {
    var cache = ExploreCacheManager(clock: () => time);
    await cache.getPage(service: service, path: '/places');
    await cache.getPage(service: service, path: '/places', page: 2);
    await cache.getPage(service: service, path: '/places', forceRefresh: true);
    cache = ExploreCacheManager(clock: () => time);
    await cache.getPage(service: service, path: '/places', page: 2);
    expect(calls, 4);
  });

  test(
    'concurrent readers share requests and pruning preserves downloaded data',
    () async {
      final cache = ExploreCacheManager(clock: () => time);
      await Future.wait(
        List.generate(
          6,
          (_) => cache.getPage(service: service, path: '/places'),
        ),
      );
      expect(calls, 1);
      await store.cache('/places/downloaded', {
        'trekkingPlaceId': 'downloaded',
      });
      await store.pruneExplorePages(0);
      expect(await store.read('/places/downloaded'), isNotNull);
      expect(
        await (await helper.database).query(
          'offline_snapshots',
          where: 'resource LIKE ?',
          whereArgs: ['/explore-pages/v2/%'],
        ),
        isEmpty,
      );
    },
  );
}
