import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;

import '../data/local_tile_server.dart';
import '../data/mbtiles_repository.dart';
import '../data/offline_map_package_service.dart';
import '../models/offline_map_manifest.dart';
import '../utils/map_style_builder.dart';

/// Trạng thái tổng hợp của offline map
enum OfflineMapStatus { idle, loading, ready, error }

/// OfflineMapManager: ChangeNotifier điều phối toàn bộ flow offline map.
///
/// Flow:
///  1. [initialize] → gọi OfflineMapPackageService.loadPackage()
///  2. Mở MBTiles qua MBTilesRegistry
///  3. Khởi động LocalTileServer
///  4. Build MapStyleBuilder
///  5. Notify UI
///
/// UI chỉ cần:
///   - Lắng nghe [status], [errorMessage]
///   - Đọc [styleString] → truyền vào MaplibreMap
///   - Toggle [showHillshade], [showContours], [showRoute], [showMilestones]
///   - Gọi [reset] để restart
class OfflineMapManager extends ChangeNotifier {
  // ── Dependencies ───────────────────────────────────────────────────────────
  final OfflineMapPackageService _packageService;
  late final MBTilesRegistry _registry;
  late final LocalTileServer _tileServer;

  OfflineMapManager({
    OfflineMapPackageService? packageService,
    MBTilesRegistry? registry,
    LocalTileServer? tileServer,
  }) : _packageService = packageService ?? OfflineMapPackageService() {
    _registry = registry ?? MBTilesRegistry();
    _tileServer = tileServer ?? LocalTileServer(registry: _registry, port: 0);
  }

  // Factory giải quyết circular dependency trong constructor default
  factory OfflineMapManager.create() {
    final registry = MBTilesRegistry();
    return OfflineMapManager(
      packageService: OfflineMapPackageService(),
      registry: registry,
      tileServer: LocalTileServer(registry: registry, port: 0),
    );
  }

  bool _disposed = false;
  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  // ── State ─────────────────────────────────────────────────────────────────
  OfflineMapStatus _status = OfflineMapStatus.idle;
  OfflineMapStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  OfflineMapManifest? _manifest;
  OfflineMapManifest? get manifest => _manifest;

  bool _packageLoaded = false;
  bool get packageLoaded => _packageLoaded;

  bool _shaVerified = false;
  bool get shaVerified => _shaVerified;

  bool _tileServerRunning = false;
  bool get tileServerRunning => _tileServerRunning;

  // GeoJSON data
  Map<String, dynamic>? _routeGeoJson;
  Map<String, dynamic>? get routeGeoJson => _routeGeoJson;

  Map<String, dynamic>? _milestoneGeoJson;
  Map<String, dynamic>? get milestoneGeoJson => _milestoneGeoJson;

  // Toggles
  bool _showHillshade = true;
  bool get showHillshade => _showHillshade;

  bool _showContours = true;
  bool get showContours => _showContours;

  bool _showRoute = true;
  bool get showRoute => _showRoute;

  bool _showMilestones = true;
  bool get showMilestones => _showMilestones;

  MapStyleBuilder? _styleBuilder;

  /// Style JSON để truyền vào MaplibreMap(styleString: ...)
  String? _downloadedStyle;
  String? get styleString {
    if (_downloadedStyle == null) return _styleBuilder?.build();
    final style = jsonDecode(_downloadedStyle!) as Map;
    for (final layer in style['layers'] as List) {
      final source = layer['source']?.toString() ?? '';
      final visible = source.contains('hillshade')
          ? _showHillshade
          : source.contains('contour')
          ? _showContours
          : source.contains('routes')
          ? _showRoute
          : source.contains('milestones')
          ? _showMilestones
          : true;
      if (!visible) {
        layer['layout'] = {...?layer['layout'] as Map?, 'visibility': 'none'};
      }
    }
    return jsonEncode(style);
  }

  bool get isReady => _status == OfflineMapStatus.ready;

  // ── INIT & RESET ──────────────────────────────────────────────────────────

  Future<void> initialize({String? packageDirectory}) async {
    if (_status == OfflineMapStatus.loading) return;

    _setStatus(OfflineMapStatus.loading);
    _errorMessage = null;

    try {
      // Bước 1-4: Load package (copy, extract, verify)
      final result = await _packageService.loadPackage(
        packageDirectory: packageDirectory,
      );
      _manifest = result.manifest;
      _packageLoaded = true;
      _shaVerified = result.allShaVerified;
      if (!_shaVerified)
        throw StateError('Checksum của gói bản đồ không hợp lệ.');
      notifyListeners();

      // Bước 5: Mở MBTiles
      // Nếu manifest có layers → dùng; không thì auto-detect từ sha256 keys
      final extractDir = result.extractDir;
      final layersToOpen = result.manifest.layers.isNotEmpty
          ? result.manifest.layers
                .map((l) => _LayerEntry(l.id, l.file))
                .toList()
          : _detectLayersFromSha256(result.manifest.sha256);

      for (final entry in layersToOpen) {
        final absPath = p.join(extractDir, entry.file);
        await _registry.open(entry.id, absPath);
      }
      notifyListeners();

      // Bước 6: Load GeoJSON
      // Thử đọc từ package đã giải nén, fallback đọc từ Flutter asset
      _routeGeoJson = await _loadGeoJson(
        packageService: _packageService,
        packageFileName: result.manifest.geojson.routes,
        assetPath: 'assets/offline_maps/ba-den-routes.geojson',
        allowAssetFallback: packageDirectory == null,
      );
      _milestoneGeoJson = await _loadGeoJson(
        packageService: _packageService,
        packageFileName: result.manifest.geojson.milestones,
        assetPath: 'assets/offline_maps/ba-den-milestones.geojson',
        allowAssetFallback: packageDirectory == null,
      );
      debugPrint(
        '[OfflineMapManager] route GeoJSON: '
        '${_routeGeoJson != null ? "loaded" : "null"}',
      );
      debugPrint(
        '[OfflineMapManager] milestone GeoJSON: '
        '${_milestoneGeoJson != null ? "loaded" : "null"}',
      );
      notifyListeners();

      // Bước 7: Khởi động tile server
      await _tileServer.start();
      _tileServerRunning = true;
      notifyListeners();

      // Bước 8: Build style
      _rebuildStyle();
      if (packageDirectory != null) {
        _downloadedStyle = await _bindDownloadedStyle(packageDirectory);
      }

      _setStatus(OfflineMapStatus.ready);
    } catch (e, st) {
      debugPrint('[OfflineMapManager] initialize error: $e\n$st');
      _errorMessage = e.toString();
      await _tileServer.stop();
      await _registry.closeAll();
      _setStatus(OfflineMapStatus.error);
    } finally {
      if (_disposed) {
        await _tileServer.stop();
        await _registry.closeAll();
      }
    }
  }

  Future<String> _bindDownloadedStyle(String directory) async {
    final raw = jsonDecode(
      await File(p.join(directory, 'manifest.json')).readAsString(),
    ) as Map;
    final style = jsonDecode(
      await File(p.join(directory, raw['style'] ?? 'style.json'))
          .readAsString(),
    ) as Map<String, dynamic>;
    final sources = style['sources'] as Map;
    for (final value in sources.values) {
      final source = value as Map;
      final url = source['url'];
      if (url is String && url.startsWith('mbtiles://')) {
        final fileName = url.substring('mbtiles://'.length);
        final layer = _manifest!.layers.firstWhere((l) => l.file == fileName);
        source.remove('url');
        source['tiles'] = [_tileServer.tileUrl(layer.id)];
        source['minzoom'] = _tileServer.configOf(layer.id)!.minZoom;
        source['maxzoom'] = _tileServer.configOf(layer.id)!.maxZoom;
      } else if (url != null || source.containsKey('tiles')) {
        throw StateError('Style có nguồn bản đồ ngoài gói offline.');
      }
      if (source['type'] == 'geojson' && source['data'] is String) {
        source['data'] = await _packageService.readGeoJsonAsMap(source['data']);
      }
    }
    if (style.containsKey('sprite'))
      throw StateError('Style có sprite ngoài gói offline.');
    style['glyphs'] = _tileServer.glyphsUrl;
    return jsonEncode(style);
  }

  Future<void> reset() async {
    _setStatus(OfflineMapStatus.loading);
    try {
      await _tileServer.stop();
      await _registry.closeAll();
      await _packageService.resetPackage();
    } finally {
      _packageLoaded = false;
      _shaVerified = false;
      _tileServerRunning = false;
      _manifest = null;
      _routeGeoJson = null;
      _milestoneGeoJson = null;
      _styleBuilder = null;
      _downloadedStyle = null;
      _errorMessage = null;
      _setStatus(OfflineMapStatus.idle);
    }
  }

  // ── TOGGLES ───────────────────────────────────────────────────────────────

  void toggleHillshade() {
    _showHillshade = !_showHillshade;
    _rebuildStyle();
    notifyListeners();
  }

  void toggleContours() {
    _showContours = !_showContours;
    _rebuildStyle();
    notifyListeners();
  }

  void toggleRoute() {
    _showRoute = !_showRoute;
    _rebuildStyle();
    notifyListeners();
  }

  void toggleMilestones() {
    _showMilestones = !_showMilestones;
    _rebuildStyle();
    notifyListeners();
  }

  // ── PRIVATE ───────────────────────────────────────────────────────────────

  void _rebuildStyle() {
    _styleBuilder = MapStyleBuilder(
      tileServer: _tileServer,
      showHillshade: _showHillshade,
      showContours: _showContours,
      showRoute: _showRoute,
      showMilestones: _showMilestones,
      routeGeoJson: _routeGeoJson,
      milestoneGeoJson: _milestoneGeoJson,
    );
  }

  void _setStatus(OfflineMapStatus s) {
    _status = s;
    notifyListeners();
  }

  /// Auto-detect layers từ sha256 keys khi manifest không có field 'layers'.
  /// Mapping tên file → layer id dựa trên convention đặt tên.
  List<_LayerEntry> _detectLayersFromSha256(Map<String, String> sha256) {
    final entries = <_LayerEntry>[];
    for (final fileName in sha256.keys.where(
      (name) => name.endsWith('.mbtiles'),
    )) {
      final lower = fileName.toLowerCase();
      final String layerId;
      if (lower.contains('hillshade')) {
        layerId = 'hillshade';
      } else if (lower.contains('contour')) {
        layerId = 'contours';
      } else {
        layerId = 'base';
      }
      entries.add(_LayerEntry(layerId, fileName));
      debugPrint(
        '[OfflineMapManager] auto-detected layer: $layerId → $fileName',
      );
    }
    return entries;
  }

  Future<void> close() async {
    await _tileServer.stop();
    await _registry.closeAll();
  }

  @override
  void dispose() {
    _disposed = true;
    _tileServer.stop();
    _registry.closeAll();
    super.dispose();
  }
}

/// Đơn giản hóa: cặp layerId + fileName để mở MBTiles.
class _LayerEntry {
  final String id;
  final String file;
  const _LayerEntry(this.id, this.file);
}

/// Load GeoJSON: thử từ package trước, fallback từ Flutter asset.
Future<Map<String, dynamic>?> _loadGeoJson({
  required OfflineMapPackageService packageService,
  required String packageFileName,
  required String assetPath,
  bool allowAssetFallback = true,
}) async {
  // 1. Thử đọc từ package đã giải nén
  if (packageFileName.isNotEmpty) {
    try {
      return await packageService.readGeoJsonAsMap(packageFileName);
    } catch (_) {
      debugPrint('[GeoJSON] "$packageFileName" not in package, trying asset');
    }
  }
  if (!allowAssetFallback) return null;
  // 2. Fallback: đọc từ Flutter asset bundle
  try {
    final raw = await rootBundle.loadString(assetPath);
    return jsonDecode(raw) as Map<String, dynamic>;
  } catch (e) {
    debugPrint('[GeoJSON] asset "$assetPath" also failed: $e');
    return null;
  }
}
