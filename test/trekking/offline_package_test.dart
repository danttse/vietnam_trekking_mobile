import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:vietnam_trekking_mobile/core/database/database_helper.dart';
import 'package:vietnam_trekking_mobile/core/database/daos/offline_data_dao.dart';
import 'package:vietnam_trekking_mobile/core/services/offline_store.dart';
import 'package:vietnam_trekking_mobile/core/services/trekking_catalog_service.dart';
import 'package:vietnam_trekking_mobile/features/offline_map/data/offline_package_installer.dart';
import 'package:vietnam_trekking_mobile/features/offline_map/services/offline_map_manager.dart';
import 'package:vietnam_trekking_mobile/features/offline_map/services/offline_map_storage_service.dart';
import 'package:vietnam_trekking_mobile/features/route/data/models/route_model.dart';
import 'package:vietnam_trekking_mobile/features/route/viewmodel/download_offline_map_viewmodel.dart';

import 'offline_store_test.dart' show TestAdapter, reply;

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  late Directory directory;
  final zip = File('test/fixtures/offline_maps/generated-v2.zip');
  late String checksum;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('trekvn-map-test-');
    checksum = (await sha256.bind(zip.openRead()).first).toString();
  });
  tearDown(() async => directory.delete(recursive: true));

  test(
    'real generated ZIP installs three actual tile databases and its style',
    () async {
      final target = Directory('${directory.path}/installed');
      final manifest = await OfflinePackageInstaller().install(
        zip: zip,
        target: target,
        checksum: checksum,
        expectedVersion: 2,
      );
      expect(manifest.layers.length, 3);
      var count = 0;
      for (final layer in manifest.layers) {
        final db = await openDatabase(
          '${target.path}/${layer.file}',
          readOnly: true,
        );
        count +=
            ((await db.rawQuery('SELECT COUNT(*) AS n FROM tiles')).single['n']
                as int);
        await db.close();
      }
      expect(count, 70);
      expect(await File('${target.path}/style.json').exists(), isTrue);
    },
  );

  test('download uses PLACE scope, stores extracted MBTiles, and reports wrong coverage', () async {
    final helper = await DatabaseHelper.openForTesting(
      '${directory.path}/app.db',
    );
    final store = OfflineStore(
      databaseHelper: helper,
      ownerProvider: () async => 'user-a',
    );
    final storage = OfflineMapStorageService(
      dao: OfflineDataDao(dbHelper: helper),
      rootDirectory: directory,
    );
    final routeJson = {
      'trekkingRouteId': 'r',
      'trekkingPlaceId': 'p',
      'name': 'Đường CD',
    };
    final route = RouteModel.fromJson(routeJson);
    final place = {
      'trekkingPlaceId': 'p',
      'name': 'Bà Đen',
      'location': {
        'coordinates': [106.17, 11.38],
      },
    };
    final api = Dio(BaseOptions(baseUrl: 'http://tests'));
    api.httpClientAdapter = TestAdapter(
      (r) async => reply({
        'place': place,
        'route': routeJson,
        'milestones': [],
        'mapManifest': {
          'available': true,
          'scope': 'PLACE',
          'version': 2,
          'checksum': checksum,
          'downloadUrl': 'https://maps.example/map.zip',
        },
      }),
    );
    final vm = DownloadOfflineMapViewModel(
      route: route,
      autoStart: false,
      storage: storage,
      catalog: TrekkingCatalogService(client: api, store: store),
      downloadClient: () {
        final downloader = Dio();
        downloader.httpClientAdapter = TestAdapter(
          (r) async => ResponseBody.fromBytes(
            await zip.readAsBytes(),
            200,
            headers: {
              Headers.contentLengthHeader: ['${await zip.length()}'],
              Headers.contentTypeHeader: ['application/zip'],
            },
          ),
        );
        return downloader;
      },
    );
    try {
      await vm.startDownload();
      expect(vm.error, isNull);
      expect(vm.isCompleted, isTrue);
      expect(vm.coverageWarning, contains('không phủ'));
      final map = await storage.findReadyMap('another-route-at-p', 'p');
      expect(map?.scope, 'PLACE');
      expect(
        await File(map!.localPath).openRead(0, 16).first,
        utf8.encode('SQLite format 3\u0000'),
      );
      expect(
        await File('${File(map.localPath).parent.path}/manifest.json').exists(),
        isTrue,
      );
      expect((await store.read('/routes/r') as Map)['name'], 'Đường CD');
      expect(
        (await storage.findReadyMap('another-route-at-p', 'p'))?.localPath,
        map.localPath,
      );
      expect(await storage.findReadyMap('r', 'different-place'), isNull);
    } finally {
      vm.dispose();
      api.close();
      await helper.close();
    }
  });

  test(
    'place detail downloads its ZIP without requiring a selected route',
    () async {
      final helper = await DatabaseHelper.openForTesting(
        '${directory.path}/app.db',
      );
      final storage = OfflineMapStorageService(
        dao: OfflineDataDao(dbHelper: helper),
        rootDirectory: directory,
      );
      final requests = <String>[];
      final api = Dio(BaseOptions(baseUrl: 'http://tests'));
      api.httpClientAdapter = TestAdapter((request) async {
        requests.add(request.path);
        return reply({
          'place': {'trekkingPlaceId': 'p', 'name': 'Bà Đen'},
          'routes': [],
          'mapManifest': {
            'available': true,
            'scope': 'PLACE',
            'version': 2,
            'checksum': checksum,
            'downloadUrl': 'https://maps.example/map.zip',
          },
        });
      });
      final vm = DownloadOfflineMapViewModel(
        placeId: 'p',
        placeName: 'Bà Đen',
        autoStart: false,
        storage: storage,
        catalog: TrekkingCatalogService(
          client: api,
          store: OfflineStore(
            databaseHelper: helper,
            ownerProvider: () async => 'user-a',
          ),
        ),
        downloadClient: () {
          final downloader = Dio();
          downloader.httpClientAdapter = TestAdapter(
            (r) async => ResponseBody.fromBytes(await zip.readAsBytes(), 200),
          );
          return downloader;
        },
      );
      try {
        await vm.startDownload();
        expect(vm.error, isNull);
        expect(vm.isCompleted, isTrue);
        expect(requests, ['/places/p/offline-package']);
        expect((await storage.findReadyMap('new-route', 'p'))?.scope, 'PLACE');
        expect((await storage.getAllDownloadedMaps()).length, 1);
      } finally {
        vm.dispose();
        api.close();
        await helper.close();
      }
    },
  );

  test('download file 404 identifies the CDN link instead of claiming the package is missing', () async {
    final helper = await DatabaseHelper.openForTesting(
      '${directory.path}/app.db',
    );
    final store = OfflineStore(
      databaseHelper: helper,
      ownerProvider: () async => 'user-a',
    );
    final storage = OfflineMapStorageService(
      dao: OfflineDataDao(dbHelper: helper),
      rootDirectory: directory,
    );
    final routeJson = {
      'trekkingRouteId': 'r',
      'trekkingPlaceId': 'p',
      'name': 'CD',
    };
    final api = Dio(BaseOptions(baseUrl: 'http://tests'));
    api.httpClientAdapter = TestAdapter(
      (r) async => reply({
        'place': {'trekkingPlaceId': 'p', 'name': 'Bà Đen'},
        'route': routeJson,
        'mapManifest': {
          'available': true,
          'version': 2,
          'checksum': checksum,
          'downloadUrl': 'https://wrong.example/map.zip',
          'scope': 'PLACE',
        },
      }),
    );
    final vm = DownloadOfflineMapViewModel(
      route: RouteModel.fromJson(routeJson),
      autoStart: false,
      storage: storage,
      catalog: TrekkingCatalogService(client: api, store: store),
      downloadClient: () {
        final d = Dio();
        d.httpClientAdapter = TestAdapter(
          (r) async => ResponseBody.fromString('not found', 404),
        );
        return d;
      },
    );
    try {
      await vm.startDownload();
      expect(vm.error, contains('R2 trả 404'));
      expect(await storage.getAllDownloadedMaps(), isEmpty);
    } finally {
      vm.dispose();
      api.close();
      await helper.close();
    }
  });

  test('style and all sources bind to localhost; tile server returns bytes from the installed SQLite', () async {
    final target = Directory('${directory.path}/installed');
    await OfflinePackageInstaller().install(
      zip: zip,
      target: target,
      checksum: checksum,
    );
    final manager = OfflineMapManager.create();
    final http = HttpClient();
    try {
      await manager.initialize(packageDirectory: target.path);
      expect(manager.errorMessage, isNull);
      expect(manager.isReady, isTrue);
      final style = jsonDecode(manager.styleString!) as Map;
      expect(style['glyphs'], startsWith('http://127.0.0.1:'));
      for (final source in (style['sources'] as Map).values) {
        if (source['tiles'] != null)
          expect(source['tiles'][0], startsWith('http://127.0.0.1:'));
      }
      final layer = manager.manifest!.layers.firstWhere((l) => l.id == 'base');
      final db = await openDatabase(
        '${target.path}/${layer.file}',
        readOnly: true,
        singleInstance: false,
      );
      final tile = (await db.rawQuery('SELECT * FROM tiles LIMIT 1')).single;
      await db.close();
      final source = (style['sources'] as Map).values.firstWhere(
        (s) => s['type'] == 'vector',
      );
      final z = tile['zoom_level'] as int;
      final y = (1 << z) - 1 - (tile['tile_row'] as int);
      final url = (source['tiles'][0] as String)
          .replaceAll('{z}', '$z')
          .replaceAll('{x}', '${tile['tile_column']}')
          .replaceAll('{y}', '$y');
      // Opening a fullscreen map must not share a SQLite handle with the inline
      // preview: closing either one must leave the other tile server working.
      final second = OfflineMapManager.create();
      await second.initialize(packageDirectory: target.path);
      expect(second.isReady, isTrue);
      await second.close();
      second.dispose();
      final response = await (await http.getUrl(Uri.parse(url))).close();
      expect(response.statusCode, 200);
      final bytes = await response.fold<List<int>>(
        [],
        (all, chunk) => all..addAll(chunk),
      );
      final original = (tile['tile_data'] as List).cast<int>();
      expect(bytes, original[0] == 0x1f ? gzip.decode(original) : original);
    } finally {
      http.close(force: true);
      await manager.close();
      manager.dispose();
    }
  });

  test('bad checksum, wrong version, and ZIP path traversal leave no installed package', () async {
    final target = Directory('${directory.path}/bad');
    await expectLater(
      OfflinePackageInstaller().install(
        zip: zip,
        target: target,
        checksum: '0' * 64,
      ),
      throwsFormatException,
    );
    await expectLater(
      OfflinePackageInstaller().install(
        zip: zip,
        target: target,
        checksum: checksum,
        expectedVersion: 3,
      ),
      throwsFormatException,
    );
    final malicious = Archive()..addFile(ArchiveFile('../escaped.txt', 1, [1]));
    final attack = File('${directory.path}/attack.zip');
    await attack.writeAsBytes(ZipEncoder().encode(malicious));
    await expectLater(
      OfflinePackageInstaller().install(
        zip: attack,
        target: target,
        checksum: sha256.convert(await attack.readAsBytes()).toString(),
      ),
      throwsFormatException,
    );
    expect(await target.exists(), isFalse);
    expect(await File('${directory.path}/escaped.txt').exists(), isFalse);
  });
}
