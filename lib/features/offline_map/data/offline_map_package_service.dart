import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';

import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/offline_map_manifest.dart';
import 'offline_package_installer.dart';

/// Kết quả sau khi load package
class PackageLoadResult {
  final OfflineMapManifest manifest;
  final String extractDir; // thư mục đã giải nén
  final Map<String, bool> shaResults; // tên file → pass/fail

  const PackageLoadResult({
    required this.manifest,
    required this.extractDir,
    required this.shaResults,
  });

  bool get allShaVerified => shaResults.values.every((v) => v);
}

/// Service chịu trách nhiệm:
///  1. Copy ZIP từ asset → app storage
///  2. Giải nén ZIP
///  3. Đọc manifest.json
///  4. Verify SHA-256 cho từng MBTiles
class OfflineMapPackageService {
  static const String _assetZipPath = 'assets/offline_maps/ba-den-v1.zip';
  static const String _extractFolderName = 'offline_map_ba_den_v1';

  /// Đường dẫn thư mục đã giải nén, null nếu chưa load
  String? _extractDir;
  String? get extractDir => _extractDir;

  // -------------------------------------------------------------------------
  // PUBLIC API
  // -------------------------------------------------------------------------

  /// Load toàn bộ package. Có thể gọi lại để reset.
  Future<PackageLoadResult> loadPackage({
    bool forceReextract = false,
    String? packageDirectory,
  }) async {
    if (packageDirectory != null) {
      final manifest = await OfflinePackageInstaller.validateDirectory(
        Directory(packageDirectory),
      );
      _extractDir = packageDirectory;
      return PackageLoadResult(
        manifest: manifest,
        extractDir: packageDirectory,
        shaResults: {for (final name in manifest.sha256.keys) name: true},
      );
    }
    final dir = await _getExtractDir();
    _extractDir = dir.path;

    // Bước 1 & 2: copy + giải nén (bỏ qua nếu đã tồn tại và !forceReextract)
    final manifestFile = File(p.join(dir.path, 'manifest.json'));
    if (!manifestFile.existsSync() || forceReextract) {
      await _copyAndExtract(dir);
    }

    // Bước 3: đọc manifest
    final manifest = await _readManifest(dir);

    // Bước 4: verify SHA-256
    final shaResults = await _verifySha256(dir, manifest);

    return PackageLoadResult(
      manifest: manifest,
      extractDir: dir.path,
      shaResults: shaResults,
    );
  }

  /// Xóa toàn bộ package đã giải nén (dùng cho nút "Reset offline package")
  Future<void> resetPackage() async {
    final dir = await _getExtractDir();
    if (dir.existsSync()) {
      await dir.delete(recursive: true);
    }
    _extractDir = null;
  }

  // -------------------------------------------------------------------------
  // PRIVATE HELPERS
  // -------------------------------------------------------------------------

  Future<Directory> _getExtractDir() async {
    final base = await getApplicationDocumentsDirectory();
    return Directory(p.join(base.path, _extractFolderName));
  }

  Future<void> _copyAndExtract(Directory targetDir) async {
    // Tạo thư mục đích (xóa nếu cũ)
    if (targetDir.existsSync()) {
      await targetDir.delete(recursive: true);
    }
    await targetDir.create(recursive: true);

    // Load ZIP bytes từ asset
    final byteData = await rootBundle.load(_assetZipPath);
    final Uint8List zipBytes = byteData.buffer.asUint8List(
      byteData.offsetInBytes,
      byteData.lengthInBytes,
    );

    // Giải nén
    final archive = ZipDecoder().decodeBytes(zipBytes);
    for (final file in archive) {
      final filePath = OfflinePackageInstaller.safePath(
        targetDir.path,
        file.name,
      );
      if (file.isFile) {
        final outFile = File(filePath);
        await outFile.create(recursive: true);
        await outFile.writeAsBytes(file.content as List<int>);
      } else {
        await Directory(filePath).create(recursive: true);
      }
    }
  }

  Future<OfflineMapManifest> _readManifest(Directory dir) async {
    final file = File(p.join(dir.path, 'manifest.json'));
    if (!file.existsSync()) {
      throw StateError('manifest.json not found in extracted package');
    }
    final raw = await file.readAsString();
    // DEBUG: in ra manifest thật để biết schema — xóa sau khi fix xong
    return OfflineMapManifest.fromJsonString(raw);
  }

  Future<Map<String, bool>> _verifySha256(
    Directory dir,
    OfflineMapManifest manifest,
  ) async {
    final results = <String, bool>{};
    for (final entry in manifest.sha256.entries) {
      final fileName = entry.key;
      final expectedHex = entry.value;
      final file = File(p.join(dir.path, fileName));
      if (!file.existsSync()) {
        results[fileName] = false;
        continue;
      }
      final bytes = await file.readAsBytes();
      final actualHex = sha256.convert(bytes).toString();
      results[fileName] = actualHex == expectedHex;
    }
    return results;
  }

  /// Đọc nội dung file GeoJSON từ package đã giải nén
  Future<String> readGeoJson(String fileName) async {
    if (_extractDir == null) throw StateError('Package not loaded yet');
    final file = File(OfflinePackageInstaller.safePath(_extractDir!, fileName));
    if (!file.existsSync()) {
      throw FileSystemException('GeoJSON file not found', fileName);
    }
    return file.readAsString();
  }

  /// Parse GeoJSON thành Map (convenience helper)
  Future<Map<String, dynamic>> readGeoJsonAsMap(String fileName) async {
    final raw = await readGeoJson(fileName);
    return jsonDecode(raw) as Map<String, dynamic>;
  }
}
