import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import 'mbtiles_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LayerConfig: zoom range + format cho mỗi layer (hard-coded từ dữ liệu thực)
// ─────────────────────────────────────────────────────────────────────────────

class LayerConfig {
  final String id;
  final String format;   // 'pbf' | 'png' | 'jpg'
  final bool isGzipped;  // tile_data đã gzip sẵn
  final int minZoom;
  final int maxZoom;
  final int tileSize;

  const LayerConfig({
    required this.id,
    required this.format,
    required this.isGzipped,
    required this.minZoom,
    required this.maxZoom,
    this.tileSize = 256,
  });

  bool get isVector => format == 'pbf';
}

// ─────────────────────────────────────────────────────────────────────────────
// LocalTileServer
// ─────────────────────────────────────────────────────────────────────────────

/// HTTP tile server chạy trên `127.0.0.1:<port>`.
///
/// Luôn convert XYZ → TMS trước khi query SQLite:
///   `tmsY = (1 << z) - 1 - xyzY`
///
/// Vector PBF gzip: trả nguyên bytes với
///   Content-Type: `application/vnd.mapbox-vector-tile`
///   Content-Encoding: `gzip`
/// (KHÔNG gzip lại)
///
/// Raster: trả bytes với image/png hoặc image/jpeg.
class LocalTileServer {
  static const int _defaultPort = 7777;

  final MBTilesRegistry registry;
  final int port;

  HttpServer? _server;

  /// LayerConfig đã detect, keyed by layerId
  final Map<String, LayerConfig> _configs = {};

  LocalTileServer({required this.registry, this.port = _defaultPort});

  bool get isRunning => _server != null;
  String get baseUrl => 'http://127.0.0.1:$port';

  LayerConfig? configOf(String layerId) => _configs[layerId];
  bool isVector(String layerId) => _configs[layerId]?.isVector ?? false;

  /// Glyph URL template cho MapLibre style `glyphs` field
  String get glyphsUrl => '$baseUrl/fonts/{fontstack}/{range}.pbf';

  /// URL template cho MapLibre style source tiles array.
  /// Vector → .pbf extension, Raster → .png
  String tileUrl(String layerId) {
    final ext = isVector(layerId) ? 'pbf' : 'png';
    return '$baseUrl/tiles/$layerId/{z}/{x}/{y}.$ext';
  }

  // ───────────────────────────────────────────────────────────────────────────
  // LIFECYCLE
  // ───────────────────────────────────────────────────────────────────────────

  Future<void> start() async {
    if (_server != null) return;

    await _detectAllConfigs();

    final router = Router();
    router.get('/health', (_) => Response.ok('ok', headers: _cors()));
    router.get('/tiles/<layerId>/<z>/<x>/<y>', _handleTile);
    // Glyph endpoint: /fonts/{fontstack}/{range}.pbf
    // fontstack được URL-encode (dấu cách → %20 hoặc +)
    router.get('/fonts/<fontstack>/<range>', _handleGlyph);

    final handler = Pipeline()
        .addMiddleware(_corsMiddleware())
        .addHandler(router.call);

    _server = await shelf_io.serve(
      handler,
      InternetAddress.loopbackIPv4,
      port,
      shared: true,
    );
    _server!.idleTimeout = const Duration(seconds: 60);

    debugPrint('[TileServer] started → $baseUrl');
    for (final c in _configs.values) {
      debugPrint('[TileServer] layer=${c.id} fmt=${c.format} '
          'gzip=${c.isGzipped} zoom=${c.minZoom}-${c.maxZoom}');
    }
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
    _configs.clear();
  }

  // ───────────────────────────────────────────────────────────────────────────
  // FORMAT + ZOOM DETECTION
  // ───────────────────────────────────────────────────────────────────────────

  Future<void> _detectAllConfigs() async {
    // Đọc từng layer đang có trong registry
    for (final layerId in ['base', 'contours', 'hillshade']) {
      final repo = registry.get(layerId);
      if (repo == null || !repo.isOpen) continue;

      final fmt = await repo.getTileFormat();
      final minZ = await repo.getMinZoom() ?? _defaultMinZoom(layerId);
      final maxZ = await repo.getMaxZoom() ?? _defaultMaxZoom(layerId);

      _configs[layerId] = LayerConfig(
        id: layerId,
        format: fmt,
        isGzipped: fmt == 'pbf',
        minZoom: minZ,
        maxZoom: maxZ,
        tileSize: 256,
      );

      debugPrint('[TileServer] detected $layerId: '
          'fmt=$fmt zoom=$minZ-$maxZ gzip=${fmt == "pbf"}');
    }
  }

  int _defaultMinZoom(String layerId) {
    if (layerId == 'contours') return 10;
    if (layerId == 'hillshade') return 12;
    return 0;
  }

  int _defaultMaxZoom(String layerId) {
    if (layerId == 'hillshade') return 12;
    return 14;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TILE HANDLER
  // ───────────────────────────────────────────────────────────────────────────

  Future<Response> _handleTile(
    Request req,
    String layerId,
    String zStr,
    String xStr,
    String yStr,
  ) async {
    // Strip extension (.pbf / .png / .jpg / .mvt)
    final yClean = yStr
        .replaceAll('.pbf', '')
        .replaceAll('.png', '')
        .replaceAll('.jpg', '')
        .replaceAll('.mvt', '');

    final z = int.tryParse(zStr);
    final x = int.tryParse(xStr);
    final y = int.tryParse(yClean);

    if (z == null || x == null || y == null) {
      return Response.badRequest(
          body: 'Invalid tile coords: $zStr/$xStr/$yStr');
    }

    final repo = registry.get(layerId);
    if (repo == null || !repo.isOpen) {
      debugPrint('[TileServer] $layerId not loaded → 404');
      return Response.notFound('Layer "$layerId" not available');
    }

    final cfg = _configs[layerId];

    try {
      // XYZ → TMS (bắt buộc vì MBTiles dùng TMS scheme)
      final tmsY = (1 << z) - 1 - y;

      final tileData = await repo.getTileRaw(zoom: z, x: x, tmsY: tmsY);

      final label = layerId.toUpperCase();
      if (tileData == null || tileData.isEmpty) {
        debugPrint('[$label] xyz=$z/$x/$y → tmsY=$tmsY → 404');
        return Response(204, headers: _cors());
      }

      debugPrint('[$label] xyz=$z/$x/$y → tmsY=$tmsY → '
          'found bytes=${tileData.length} '
          'gzip=${cfg?.isGzipped ?? false}');

      final headers = <String, String>{
        ..._cors(),
        'Cache-Control': 'public, max-age=86400',
      };

      final isVec = cfg?.isVector ?? false;
      if (isVec) {
        headers['Content-Type'] = 'application/vnd.mapbox-vector-tile';
        if (cfg?.isGzipped ?? false) {
          headers['Content-Encoding'] = 'gzip';
        }
      } else {
        headers['Content-Type'] =
            (cfg?.format == 'jpg') ? 'image/jpeg' : 'image/png';
      }

      return Response.ok(tileData, headers: headers);
    } catch (e, st) {
      debugPrint('[TileServer] ERROR $layerId $z/$x/$y: $e\n$st');
      return Response.internalServerError(body: 'Tile error: $e');
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // GLYPH HANDLER
  // ───────────────────────────────────────────────────────────────────────────

  /// Phục vụ glyph PBF từ Flutter asset bundle.
  /// Asset path: assets/offline_maps/glyphs/Noto Sans Regular/{range}.pbf
  /// MapLibre request: /fonts/Noto%20Sans%20Regular/{range}.pbf
  Future<Response> _handleGlyph(
    Request req,
    String fontstack,
    String rangeFile,
  ) async {
    // Decode URL-encoded fontstack, normalize về "Noto Sans Regular"
    final decoded = Uri.decodeComponent(fontstack);
    // Chỉ hỗ trợ Noto Sans Regular — fallback nếu font khác được request
    final assetFont = 'Noto Sans Regular';

    // Strip .pbf extension nếu có trong rangeFile
    final range = rangeFile.replaceAll('.pbf', '');

    final assetPath =
        'assets/offline_maps/glyphs/$assetFont/$range.pbf';

    debugPrint('[GlyphServer] request fontstack="$decoded" range="$range" '
        '→ asset="$assetPath"');

    try {
      final byteData = await rootBundle.load(assetPath);
      final bytes = byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      );
      debugPrint('[GlyphServer] served $range.pbf (${bytes.length} bytes)');
      return Response.ok(
        bytes,
        headers: {
          ..._cors(),
          'Content-Type': 'application/x-protobuf',
          'Cache-Control': 'public, max-age=86400',
        },
      );
    } catch (e) {
      // Range không tồn tại trong asset → trả 204 (MapLibre bỏ qua gracefully)
      debugPrint('[GlyphServer] 204 – range $range not in asset: $e');
      return Response(204, headers: _cors());
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // HELPERS
  // ───────────────────────────────────────────────────────────────────────────

  Map<String, String> _cors() => {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, OPTIONS',
      };

  Middleware _corsMiddleware() => (Handler inner) => (Request req) async {
        if (req.method == 'OPTIONS') {
          return Response.ok('', headers: _cors());
        }
        return inner(req);
      };
}
