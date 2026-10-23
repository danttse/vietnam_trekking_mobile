import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/offline_map_manifest.dart';

/// Installs into a new directory. The caller commits its SQLite record only
/// after every payload and MBTiles database has passed validation.
class OfflinePackageInstaller {
  static String safePath(String root, String name) {
    if (name.isEmpty ||
        name.contains('\\') ||
        p.isAbsolute(name) ||
        name.split('/').any((part) => part == '..' || part.contains(':'))) {
      throw const FormatException('Đường dẫn trong gói bản đồ không hợp lệ.');
    }
    final result = p.normalize(p.join(root, name));
    if (!p.isWithin(root, result)) {
      throw const FormatException('File nằm ngoài thư mục bản đồ.');
    }
    return result;
  }

  Future<OfflineMapManifest> install({
    required File zip,
    required Directory target,
    required String checksum,
    int? expectedVersion,
  }) async {
    final digest = (await sha256.bind(zip.openRead()).first).toString();
    if (digest != checksum.replaceFirst('sha256:', '').toLowerCase()) {
      throw const FormatException('Checksum bản đồ không hợp lệ.');
    }
    if (await target.exists()) throw StateError('Thư mục cài đặt đã tồn tại.');
    await target.create(recursive: true);
    try {
      final archive = ZipDecoder().decodeBytes(
        await zip.readAsBytes(),
        verify: true,
      );
      final names = <String>{};
      var expandedSize = 0;
      for (final entry in archive) {
        final filePath = safePath(target.path, entry.name);
        if (!names.add(filePath) || entry.isSymbolicLink) {
          throw const FormatException(
            'Gói bản đồ có file trùng hoặc liên kết.',
          );
        }
        expandedSize += entry.size;
        if (expandedSize > 2 * 1024 * 1024 * 1024) {
          throw const FormatException('Gói bản đồ vượt giới hạn giải nén.');
        }
        if (entry.isFile) {
          final file = File(filePath);
          await file.parent.create(recursive: true);
          await file.writeAsBytes(entry.content, flush: true);
        }
      }
      return await validateDirectory(target, expectedVersion: expectedVersion);
    } catch (_) {
      await target.delete(recursive: true);
      rethrow;
    }
  }

  static Future<OfflineMapManifest> validateDirectory(
    Directory directory, {
    int? expectedVersion,
  }) async {
    final json = jsonDecode(
      await File(p.join(directory.path, 'manifest.json')).readAsString(),
    ) as Map<String, dynamic>;
    final manifest = OfflineMapManifest.fromJson(json);
    if (manifest.layers.isEmpty ||
        !manifest.layers.any((l) => l.id == 'base') ||
        manifest.sha256.isEmpty ||
        manifest.bounds.length != 4 ||
        manifest.bounds[0] >= manifest.bounds[2] ||
        manifest.bounds[1] >= manifest.bounds[3] ||
        (expectedVersion != null && manifest.version != expectedVersion)) {
      throw const FormatException(
        'Manifest bản đồ không hợp lệ hoặc sai phiên bản.',
      );
    }
    final requiredFiles = {
      ...manifest.layers.map((l) => l.file),
      if (manifest.geojson.routes.isNotEmpty) manifest.geojson.routes,
      if (manifest.geojson.milestones.isNotEmpty) manifest.geojson.milestones,
      json['style']?.toString() ?? 'style.json',
    };
    for (final name in requiredFiles) {
      if (!manifest.sha256.containsKey(name)) {
        throw FormatException('Manifest thiếu checksum cho $name.');
      }
    }
    for (final entry in manifest.sha256.entries) {
      final file = File(safePath(directory.path, entry.key));
      final actual = (await sha256.bind(file.openRead()).first).toString();
      if (actual != entry.value.toLowerCase())
        throw FormatException('File bị hỏng: ${entry.key}.');
    }
    for (final layer in manifest.layers) {
      final db = await openDatabase(
        safePath(directory.path, layer.file),
        readOnly: true,
        singleInstance: false,
      );
      try {
        final integrity = await db.rawQuery('PRAGMA quick_check');
        final count =
            Sqflite.firstIntValue(
              await db.rawQuery(
                'SELECT COUNT(*) FROM tiles WHERE length(tile_data) > 0',
              ),
            ) ??
            0;
        if (integrity.first.values.first != 'ok' || count == 0) {
          throw FormatException('Lớp ${layer.id} không có tile bản đồ hợp lệ.');
        }
        await db.rawQuery('SELECT name, value FROM metadata');
      } finally {
        await db.close();
      }
    }
    return manifest;
  }
}
