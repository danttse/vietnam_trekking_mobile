import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:vietnam_trekking_mobile/features/offline_map/data/offline_package_installer.dart';

/// Opt-in, read-only API audit. Downloads and validates published packages in
/// temporary storage; does not change account data or the application's DB.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // This separate opt-in audit intentionally uses real network access.
  HttpOverrides.global = null;
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  test(
    'published offline packages match checksums, versions and place bounds',
    () async {
      const base = String.fromEnvironment(
        'AUDIT_TREKKING_URL',
        defaultValue: 'http://127.0.0.1:3003/api/v1',
      );
      final api = Dio(
        BaseOptions(
          baseUrl: base,
          connectTimeout: Duration(seconds: 10),
          receiveTimeout: Duration(seconds: 30),
        ),
      );
      final files = Dio(
        BaseOptions(
          connectTimeout: Duration(seconds: 10),
          receiveTimeout: Duration(seconds: 30),
        ),
      );
      final directory = await Directory.systemTemp.createTemp(
        'trekvn-live-package-',
      );
      final failures = <String>[];
      try {
        var page = 1;
        final places = <Map>[];
        while (true) {
          final data =
              (await api.get(
                    '/places',
                    queryParameters: {'page': page++, 'limit': 100},
                  )).data['data']
                  as Map;
          final batch = data['items'] as List;
          places.addAll(batch.cast<Map>());
          if (batch.isEmpty || places.length >= (data['total'] as num)) break;
        }
        var checked = 0;
        for (final place in places) {
          if (place['offlineMap']?['available'] != true) continue;
          checked++;
          final id = place['trekkingPlaceId'];
          try {
            final package =
                (await api.get('/places/$id/offline-package')).data['data']
                    as Map;
            final metadata = package['mapManifest'] as Map;
            final zip = File('${directory.path}/$id.zip');
            await files.download(metadata['downloadUrl'] as String, zip.path);
            expect(
              await zip.length(),
              metadata['sizeBytes'],
              reason: '${place['name']} size',
            );
            final manifest = await OfflinePackageInstaller().install(
              zip: zip,
              target: Directory('${directory.path}/$id'),
              checksum: metadata['checksum'] as String,
              expectedVersion: metadata['version'] as int,
            );
            final point = place['location']['coordinates'] as List;
            expect(
              point[0],
              inInclusiveRange(manifest.bounds[0], manifest.bounds[2]),
            );
            expect(
              point[1],
              inInclusiveRange(manifest.bounds[1], manifest.bounds[3]),
            );
            // ignore: avoid_print
            print('VALID: ${place['name']} v${manifest.version}');
          } catch (error) {
            failures.add('${place['name']}: $error');
          }
        }
        expect(
          checked,
          greaterThan(0),
          reason: 'No published maps available to audit.',
        );
        expect(failures, isEmpty, reason: failures.join('\n'));
      } finally {
        api.close();
        files.close();
        await directory.delete(recursive: true);
      }
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
