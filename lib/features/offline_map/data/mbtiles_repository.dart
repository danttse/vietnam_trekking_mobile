import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

/// Đọc tile PNG/PBF từ file MBTiles (SQLite).
///
/// MBTiles lưu tile theo TMS scheme: Y axis bị đảo ngược so với XYZ (slippy map).
/// Công thức convert:  yTms = (1 << zoom) - 1 - yXyz
///
/// Cách dùng:
///   final repo = MBTilesRepository(path: '/data/.../ba-den.mbtiles');
///   await repo.open();
///   final bytes = await repo.getTile(zoom: 14, x: 13490, y: 7050);
///   await repo.close();
class MBTilesRepository {
  final String path;

  Database? _db;

  MBTilesRepository({required this.path});

  bool get isOpen => _db != null;

  // -------------------------------------------------------------------------
  // LIFECYCLE
  // -------------------------------------------------------------------------

  Future<void> open() async {
    if (_db != null) return;
    _db = await openDatabase(
      path,
      readOnly: true,
      // Không gọi onCreate / onUpgrade – chỉ đọc
    );
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  // -------------------------------------------------------------------------
  // TILE ACCESS  (XYZ coordinates vào, TMS convert nội bộ)
  // -------------------------------------------------------------------------

  /// Lấy tile data theo XYZ (slippy map). TMS Y tự động convert nội bộ.
  Future<List<int>?> getTile({
    required int zoom,
    required int x,
    required int y,
  }) async {
    _assertOpen();
    final yTms = _xyzToTms(zoom, y);
    return _queryTile(zoom, x, yTms);
  }

  /// Lấy tile data với tmsY đã tính sẵn từ bên ngoài (dùng bởi tile server).
  Future<List<int>?> getTileRaw({
    required int zoom,
    required int x,
    required int tmsY,
  }) async {
    _assertOpen();
    return _queryTile(zoom, x, tmsY);
  }

  Future<List<int>?> _queryTile(int zoom, int x, int tmsY) async {
    final rows = await _db!.rawQuery(
      'SELECT tile_data FROM tiles '
      'WHERE zoom_level = ? AND tile_column = ? AND tile_row = ?',
      [zoom, x, tmsY],
    );
    if (rows.isEmpty) return null;
    final blob = rows.first['tile_data'];
    if (blob == null) return null;
    if (blob is List<int>) return blob;
    // sqflite có thể trả Uint8List – cast an toàn
    return (blob as List).cast<int>();
  }

  // -------------------------------------------------------------------------
  // METADATA
  // -------------------------------------------------------------------------

  /// Đọc toàn bộ metadata từ bảng `metadata`
  Future<Map<String, String>> getMetadata() async {
    _assertOpen();
    final rows = await _db!.rawQuery('SELECT name, value FROM metadata');
    return {
      for (final r in rows)
        (r['name'] as String): (r['value'] as String? ?? ''),
    };
  }

  /// Đọc bounds từ metadata: [minLng, minLat, maxLng, maxLat]
  Future<List<double>?> getBounds() async {
    final meta = await getMetadata();
    final raw = meta['bounds'];
    if (raw == null || raw.isEmpty) return null;
    final parts = raw.split(',').map((s) => double.tryParse(s.trim())).toList();
    if (parts.any((v) => v == null)) return null;
    return parts.cast<double>();
  }

  Future<int?> getMinZoom() async {
    final meta = await getMetadata();
    return int.tryParse(meta['minzoom'] ?? '');
  }

  Future<int?> getMaxZoom() async {
    final meta = await getMetadata();
    return int.tryParse(meta['maxzoom'] ?? '');
  }

  /// Detect tile format từ metadata: 'png', 'jpg', 'pbf', 'webp'
  /// Trả về 'png' nếu không xác định được.
  Future<String> getTileFormat() async {
    final meta = await getMetadata();
    final fmt = (meta['format'] ?? '').toLowerCase().trim();
    debugPrint('[MBTiles] $path → metadata format: "$fmt"');
    if (fmt == 'png' || fmt == 'jpg' || fmt == 'jpeg' ||
        fmt == 'pbf' || fmt == 'webp') {
      return fmt;
    }

    // Fallback: đọc magic bytes tile đầu tiên
    _assertOpen();
    final rows = await _db!.rawQuery('SELECT tile_data FROM tiles LIMIT 1');
    if (rows.isNotEmpty) {
      final blob = rows.first['tile_data'];
      // sqflite trả Uint8List – convert an toàn
      final bytes = blob is List<int>
          ? blob
          : (blob as List).map((e) => (e as int) & 0xFF).toList();

      if (bytes.length >= 4) {
        final b0 = bytes[0] & 0xFF;
        final b1 = bytes[1] & 0xFF;
        final b2 = bytes[2] & 0xFF;
        final b3 = bytes[3] & 0xFF;
        debugPrint('[MBTiles] $path → magic bytes: '
            '${b0.toRadixString(16).padLeft(2,"0")} '
            '${b1.toRadixString(16).padLeft(2,"0")} '
            '${b2.toRadixString(16).padLeft(2,"0")} '
            '${b3.toRadixString(16).padLeft(2,"0")}');

        // PNG: 89 50 4E 47
        if (b0 == 0x89 && b1 == 0x50 && b2 == 0x4E && b3 == 0x47) {
          return 'png';
        }
        // JPEG: FF D8 FF
        if (b0 == 0xFF && b1 == 0xD8 && b2 == 0xFF) return 'jpg';
        // GZip (compressed PBF): 1F 8B
        if (b0 == 0x1F && b1 == 0x8B) return 'pbf';
        // WebP: 52 49 46 46 (RIFF)
        if (b0 == 0x52 && b1 == 0x49 && b2 == 0x46 && b3 == 0x46) {
          return 'webp';
        }
      }
    }
    debugPrint('[MBTiles] $path → format unknown, defaulting to png');
    return 'png';
  }

  // -------------------------------------------------------------------------
  // HELPERS
  // -------------------------------------------------------------------------

  /// TMS Y = (2^zoom - 1) - XYZ_Y
  static int _xyzToTms(int zoom, int yXyz) => (1 << zoom) - 1 - yXyz;

  void _assertOpen() {
    if (_db == null) {
      throw StateError('MBTilesRepository is not open. Call open() first.');
    }
  }
}

// ---------------------------------------------------------------------------
// Registry quản lý nhiều MBTilesRepository cùng lúc
// ---------------------------------------------------------------------------

/// Quản lý lifecycle của nhiều file MBTiles một lúc.
class MBTilesRegistry {
  final Map<String, MBTilesRepository> _repos = {};

  /// Mở (nếu chưa) và trả về repository cho [layerId].
  Future<MBTilesRepository> open(String layerId, String absolutePath) async {
    if (!_repos.containsKey(layerId)) {
      final repo = MBTilesRepository(path: absolutePath);
      await repo.open();
      _repos[layerId] = repo;
    }
    return _repos[layerId]!;
  }

  MBTilesRepository? get(String layerId) => _repos[layerId];

  Future<void> closeAll() async {
    for (final repo in _repos.values) {
      await repo.close();
    }
    _repos.clear();
  }

  bool get hasAll =>
      _repos.containsKey('base') &&
      _repos.containsKey('contours') &&
      _repos.containsKey('hillshade');
}
