import 'dart:convert';

import 'package:flutter/foundation.dart';

// ── TOP-LEVEL PARSE HELPERS ────────────────────────────────────────────────
// Đặt ở top-level để tất cả class trong file dùng được.

String _strField(Map<String, dynamic> j, String key, {String fallback = ''}) {
  final v = j[key];
  if (v == null) return fallback;
  return v.toString();
}

int _parseIntVal(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is String) {
    final clean = v.split('.').first.trim();
    return int.tryParse(clean) ?? 0;
  }
  return 0;
}

double _parseDoubleVal(dynamic v) {
  if (v == null) return 0.0;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0.0;
  return 0.0;
}

// ────────────────────────────────────────────────────────────────────────────

/// Mô tả một layer trong package (base / contours / hillshade)
class OfflineMapLayer {
  final String id;
  final String file;
  final String type; // 'raster' | 'vector'

  const OfflineMapLayer({
    required this.id,
    required this.file,
    required this.type,
  });

  factory OfflineMapLayer.fromJson(Map<String, dynamic> j) => OfflineMapLayer(
        id: _strField(j, 'id'),
        file: _strField(j, 'file'),
        type: _strField(j, 'type', fallback: 'raster'),
      );
}

/// Metadata cho GeoJSON bundled trong package
class OfflineMapGeoJsonRefs {
  final String routes;
  final String milestones;

  const OfflineMapGeoJsonRefs({
    required this.routes,
    required this.milestones,
  });

  factory OfflineMapGeoJsonRefs.fromJson(Map<String, dynamic> j) =>
      OfflineMapGeoJsonRefs(
        routes: _strField(j, 'routes', fallback: ''),
        milestones: _strField(j, 'milestones', fallback: ''),
      );
}

/// Toàn bộ metadata đọc từ manifest.json bên trong ba-den-v1.zip.
/// Parser tolerant: dùng fallback thay vì crash khi field null/thiếu/sai type.
class OfflineMapManifest {
  final String packageId;
  final int version;
  final String name;
  final String description;

  /// [minLng, minLat, maxLng, maxLat]
  final List<double> bounds;
  final int minZoom;
  final int maxZoom;
  final double centerLat;
  final double centerLng;

  final List<OfflineMapLayer> layers;
  final OfflineMapGeoJsonRefs geojson;

  /// Map từ tên file → SHA-256 hex string
  final Map<String, String> sha256;

  const OfflineMapManifest({
    required this.packageId,
    required this.version,
    required this.name,
    required this.description,
    required this.bounds,
    required this.minZoom,
    required this.maxZoom,
    required this.centerLat,
    required this.centerLng,
    required this.layers,
    required this.geojson,
    required this.sha256,
  });

  factory OfflineMapManifest.fromJson(Map<String, dynamic> j) {
    // Debug: in key list để biết schema thật của manifest
    debugPrint('[OfflineMapManifest] keys: ${j.keys.toList()}');

    // bounds: thử nhiều field name phổ biến
    final boundsRaw = j['bounds'] ?? j['bbox'] ?? j['extent'];
    final List<double> bounds;
    if (boundsRaw is List) {
      bounds = boundsRaw.map(_parseDoubleVal).toList();
    } else {
      bounds = [106.1, 11.35, 106.2, 11.45]; // fallback Bà Đen
    }

    // center
    double centerLat = 11.3975;
    double centerLng = 106.1467;
    final centerRaw = j['center'];
    if (centerRaw is List && centerRaw.length >= 2) {
      // MBTiles GeoJSON-style: [lng, lat] hoặc [lng, lat, zoom]
      centerLng = _parseDoubleVal(centerRaw[0]);
      centerLat = _parseDoubleVal(centerRaw[1]);
    } else {
      final lat = j['centerLat'] ?? j['center_lat'];
      final lng = j['centerLng'] ?? j['center_lng'];
      if (lat != null) centerLat = _parseDoubleVal(lat);
      if (lng != null) centerLng = _parseDoubleVal(lng);
    }

    // layers
    final layersRaw = j['layers'];
    final layers = layersRaw is List
        ? layersRaw
            .whereType<Map<String, dynamic>>()
            .map(OfflineMapLayer.fromJson)
            .toList()
        : <OfflineMapLayer>[];

    // geojson refs
    final geojsonRaw = j['geojson'];
    final geojson = geojsonRaw is Map<String, dynamic>
        ? OfflineMapGeoJsonRefs.fromJson(geojsonRaw)
        : const OfflineMapGeoJsonRefs(routes: '', milestones: '');

    // sha256
    final sha256Raw = j['sha256'] ?? j['checksums'] ?? j['hashes'];
    final sha256 = sha256Raw is Map
        ? Map<String, String>.from(
            sha256Raw.map((k, v) => MapEntry(k.toString(), v.toString())))
        : <String, String>{};

    return OfflineMapManifest(
      packageId: _strField(j, 'packageId',
          fallback: _strField(j, 'id', fallback: 'unknown')),
      version: _parseIntVal(j['version'] ?? j['mapVersion'] ?? 1),
      name: _strField(j, 'name',
          fallback: _strField(j, 'title', fallback: 'Bản đồ')),
      description: _strField(j, 'description',
          fallback: _strField(j, 'desc', fallback: '')),
      bounds: bounds,
      minZoom:
          _parseIntVal(j['minZoom'] ?? j['min_zoom'] ?? j['minzoom'] ?? 10),
      maxZoom:
          _parseIntVal(j['maxZoom'] ?? j['max_zoom'] ?? j['maxzoom'] ?? 16),
      centerLat: centerLat,
      centerLng: centerLng,
      layers: layers,
      geojson: geojson,
      sha256: sha256,
    );
  }

  factory OfflineMapManifest.fromJsonString(String raw) =>
      OfflineMapManifest.fromJson(jsonDecode(raw) as Map<String, dynamic>);

  OfflineMapLayer? layerById(String id) {
    try {
      return layers.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }
}
