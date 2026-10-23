import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../data/local_tile_server.dart';

/// Xây dựng MapLibre GL style JSON hoàn toàn runtime, không cần internet.
///
/// Font: Noto Sans Regular, phục vụ qua local tile server.
/// Glyphs URL: http://127.0.0.1:7777/fonts/{fontstack}/{range}.pbf
///
/// Layer order (bottom → top):
///   1. background
///   2. base vector fills (landcover, water, landuse, building)
///   3. base vector lines (waterway, roads, paths, boundary)
///   4. hillshade raster
///   5. contour lines
///   6. contour labels (ele chia hết 100, zoom ≥ 13)
///   7. road labels (transportation_name)
///   8. place labels
///   9. mountain peak labels
///  10. trekking route (shadow + line)
///  11. milestones (circle + label)
class MapStyleBuilder {
  final LocalTileServer tileServer;
  final bool showHillshade;
  final bool showContours;
  final bool showRoute;
  final bool showMilestones;
  final Map<String, dynamic>? routeGeoJson;
  final Map<String, dynamic>? milestoneGeoJson;

  static const String _fontName = 'Noto Sans Regular';

  const MapStyleBuilder({
    required this.tileServer,
    this.showHillshade = true,
    this.showContours = true,
    this.showRoute = true,
    this.showMilestones = true,
    this.routeGeoJson,
    this.milestoneGeoJson,
  });

  MapStyleBuilder copyWith({
    bool? showHillshade,
    bool? showContours,
    bool? showRoute,
    bool? showMilestones,
    Map<String, dynamic>? routeGeoJson,
    Map<String, dynamic>? milestoneGeoJson,
  }) =>
      MapStyleBuilder(
        tileServer: tileServer,
        showHillshade: showHillshade ?? this.showHillshade,
        showContours: showContours ?? this.showContours,
        showRoute: showRoute ?? this.showRoute,
        showMilestones: showMilestones ?? this.showMilestones,
        routeGeoJson: routeGeoJson ?? this.routeGeoJson,
        milestoneGeoJson: milestoneGeoJson ?? this.milestoneGeoJson,
      );

  String build() {
    final style = jsonEncode(_buildMap());
    debugPrint('[MapStyleBuilder] style built, '
        'hillshade=$showHillshade contours=$showContours '
        'route=$showRoute milestones=$showMilestones');
    return style;
  }

  Map<String, dynamic> _buildMap() {
    final sources = <String, dynamic>{};
    final layers = <Map<String, dynamic>>[];

    final baseCfg = tileServer.configOf('base');
    final contourCfg = tileServer.configOf('contours');
    final hillCfg = tileServer.configOf('hillshade');

    // ── 1. Background ─────────────────────────────────────────────────────
    layers.add({
      'id': 'background',
      'type': 'background',
      'paint': {'background-color': '#f5f0e8'},
    });

    // ── 2 & 3. Base vector map ─────────────────────────────────────────────
    final baseIsVec = baseCfg?.isVector ?? false;
    final baseMin = baseCfg?.minZoom ?? 0;
    final baseMax = baseCfg?.maxZoom ?? 14;
    sources['base-source'] = baseIsVec
        ? {
            'type': 'vector',
            'tiles': [tileServer.tileUrl('base')],
            'minzoom': baseMin,
            'maxzoom': baseMax,
          }
        : {
            'type': 'raster',
            'tiles': [tileServer.tileUrl('base')],
            'tileSize': 256,
            'minzoom': baseMin,
            'maxzoom': baseMax,
          };

    if (baseIsVec) {
      _addVectorBaseFillLayers(layers);
      _addVectorBaseLineLayers(layers);
    } else {
      layers.add({
        'id': 'base-raster',
        'type': 'raster',
        'source': 'base-source',
        'paint': {'raster-opacity': 1.0},
      });
    }

    // ── 4. Hillshade ──────────────────────────────────────────────────────
    if (showHillshade && hillCfg != null) {
      sources['hillshade-source'] = {
        'type': 'raster',
        'tiles': [tileServer.tileUrl('hillshade')],
        'tileSize': hillCfg.tileSize,
        'minzoom': hillCfg.minZoom,
        'maxzoom': hillCfg.maxZoom, // native 12, MapLibre overzoom
      };
      layers.add({
        'id': 'hillshade-layer',
        'type': 'raster',
        'source': 'hillshade-source',
        'paint': {
          'raster-opacity': 0.4,
          'raster-brightness-min': 0.0,
          'raster-contrast': 0.05,
        },
      });
    }

    // ── 5. Contour lines ──────────────────────────────────────────────────
    if (showContours && contourCfg != null) {
      final contMin = contourCfg.minZoom;
      final contMax = contourCfg.maxZoom;
      final contUrl = tileServer.tileUrl('contours');

      if (contourCfg.isVector) {
        sources['contours-source'] = {
          'type': 'vector',
          'tiles': [contUrl],
          'minzoom': contMin,
          'maxzoom': contMax,
        };

        // Minor contours (mọi đường, không phải chia hết 100)
        layers.add({
          'id': 'contours-line-minor',
          'type': 'line',
          'source': 'contours-source',
          'source-layer': 'contour',
          'minzoom': contMin.toDouble(),
          'filter': [
            '!=',
            [
              '%',
              ['to-number', ['get', 'ele'], 0],
              100,
            ],
            0,
          ],
          'layout': {'line-join': 'round', 'line-cap': 'round'},
          'paint': {
            'line-color': '#c4a46b',
            'line-width': [
              'interpolate',
              ['linear'],
              ['zoom'],
              10, 0.3,
              14, 0.7,
            ],
            'line-opacity': 0.55,
          },
        });

        // Major contours (chia hết 100)
        layers.add({
          'id': 'contours-line-major',
          'type': 'line',
          'source': 'contours-source',
          'source-layer': 'contour',
          'minzoom': contMin.toDouble(),
          'filter': [
            '==',
            [
              '%',
              ['to-number', ['get', 'ele'], 0],
              100,
            ],
            0,
          ],
          'layout': {'line-join': 'round', 'line-cap': 'round'},
          'paint': {
            'line-color': '#a07840',
            'line-width': [
              'interpolate',
              ['linear'],
              ['zoom'],
              10, 0.6,
              14, 1.2,
            ],
            'line-opacity': 0.75,
          },
        });

        // ── 6. Contour labels (ele chia hết 100) ──────────────────────────
        layers.add({
          'id': 'contours-label',
          'type': 'symbol',
          'source': 'contours-source',
          'source-layer': 'contour',
          'minzoom': 13.0,
          'filter': [
            '==',
            [
              '%',
              ['to-number', ['get', 'ele'], 0],
              100,
            ],
            0,
          ],
          'layout': {
            'symbol-placement': 'line',
            'text-field': [
              'concat',
              ['to-string', ['get', 'ele']],
              'm',
            ],
            'text-size': 9.5,
            'text-font': [_fontName],
            'text-padding': 20.0,
            'text-max-angle': 25.0,
            'symbol-spacing': 350.0,
            'text-pitch-alignment': 'map',
            'text-rotation-alignment': 'map',
            'visibility': 'visible',
          },
          'paint': {
            'text-color': '#8a5a20',
            'text-halo-color': 'rgba(255,253,245,0.85)',
            'text-halo-width': 1.5,
          },
        });
      } else {
        // Fallback raster contours
        sources['contours-source'] = {
          'type': 'raster',
          'tiles': [contUrl],
          'tileSize': 256,
          'minzoom': contMin,
          'maxzoom': contMax,
        };
        layers.add({
          'id': 'contours-raster',
          'type': 'raster',
          'source': 'contours-source',
          'paint': {'raster-opacity': 0.7},
        });
      }
    }

    // ── 7. Road labels (transportation_name) ─────────────────────────────
    if (baseIsVec) {
      layers.add({
        'id': 'road-label',
        'type': 'symbol',
        'source': 'base-source',
        'source-layer': 'transportation_name',
        'minzoom': 12.0,
        'layout': {
          'symbol-placement': 'line',
          'text-field': [
            'coalesce',
            ['get', 'name:latin'],
            ['get', 'ref'],
          ],
          'text-size': [
            'interpolate',
            ['linear'],
            ['zoom'],
            12, 10.0,
            15, 12.0,
          ],
          'text-font': [_fontName],
          'text-padding': 5.0,
          'text-max-angle': 30.0,
          'text-pitch-alignment': 'viewport',
          'text-rotation-alignment': 'map',
          'symbol-avoid-edges': true,
          'visibility': 'visible',
        },
        'paint': {
          'text-color': '#504030',
          'text-halo-color': 'rgba(255,255,255,0.85)',
          'text-halo-width': 1.5,
        },
      });
    }

    // ── 8. Place labels ────────────────────────────────────────────────────
    if (baseIsVec) {
      layers.add({
        'id': 'place-label',
        'type': 'symbol',
        'source': 'base-source',
        'source-layer': 'place',
        'minzoom': 9.0,
        'layout': {
          'text-field': [
            'coalesce',
            ['get', 'name:latin'],
            ['get', 'name'],
          ],
          'text-size': [
            'interpolate',
            ['linear'],
            ['zoom'],
            9, 10.0,
            12, 13.0,
            14, 15.0,
          ],
          'text-font': [_fontName],
          'text-optional': true,
          'text-anchor': 'center',
          'symbol-sort-key': [
            '-',
            ['coalesce', ['get', 'rank'], 100],
          ],
          'visibility': 'visible',
        },
        'paint': {
          'text-color': '#383028',
          'text-halo-color': 'rgba(255,255,255,0.9)',
          'text-halo-width': 1.8,
        },
      });
    }

    // ── 9. Mountain peak labels ────────────────────────────────────────────
    if (baseIsVec) {
      layers.add({
        'id': 'peak-label',
        'type': 'symbol',
        'source': 'base-source',
        'source-layer': 'mountain_peak',
        'minzoom': 11.0,
        'layout': {
          'text-field': [
            'concat',
            ['coalesce', ['get', 'name:latin'], ['get', 'name'], ''],
            '\n',
            ['to-string', ['coalesce', ['get', 'ele'], '']],
            'm',
          ],
          'text-size': [
            'interpolate',
            ['linear'],
            ['zoom'],
            11, 11.0,
            14, 13.0,
          ],
          'text-font': [_fontName],
          'text-optional': true,
          'text-anchor': 'bottom',
          'text-offset': [0.0, -0.5],
          'icon-image': '',
          'visibility': 'visible',
        },
        'paint': {
          'text-color': '#5d4037',
          'text-halo-color': 'rgba(255,255,255,0.9)',
          'text-halo-width': 2.0,
        },
      });
    }

    // ── 10. Route ─────────────────────────────────────────────────────────
    if (showRoute && routeGeoJson != null) {
      sources['route-source'] = {
        'type': 'geojson',
        'data': routeGeoJson,
      };
      layers.add({
        'id': 'route-shadow',
        'type': 'line',
        'source': 'route-source',
        'layout': {'line-join': 'round', 'line-cap': 'round'},
        'paint': {
          'line-color': '#000000',
          'line-width': 6.0,
          'line-opacity': 0.15,
          'line-blur': 2.0,
        },
      });
      layers.add({
        'id': 'route-line',
        'type': 'line',
        'source': 'route-source',
        'layout': {'line-join': 'round', 'line-cap': 'round'},
        'paint': {
          'line-color': '#E53935',
          'line-width': 3.5,
          'line-opacity': 0.95,
        },
      });
    }

    // ── 11. Milestones ────────────────────────────────────────────────────
    if (showMilestones && milestoneGeoJson != null) {
      sources['milestone-source'] = {
        'type': 'geojson',
        'data': milestoneGeoJson,
      };
      layers.add({
        'id': 'milestone-circle-outer',
        'type': 'circle',
        'source': 'milestone-source',
        'paint': {
          'circle-radius': 13.0,
          'circle-color': '#ffffff',
          'circle-opacity': 0.9,
        },
      });
      layers.add({
        'id': 'milestone-circle',
        'type': 'circle',
        'source': 'milestone-source',
        'paint': {
          'circle-radius': 8.0,
          'circle-color': '#207335',
          'circle-stroke-width': 2.0,
          'circle-stroke-color': '#ffffff',
        },
      });
      layers.add({
        'id': 'milestone-label',
        'type': 'symbol',
        'source': 'milestone-source',
        'layout': {
          'text-field': [
            'concat',
            ['get', 'name'],
            '\n',
            ['to-string', ['coalesce', ['get', 'elevationM'], '']],
            'm',
          ],
          'text-size': 10.5,
          'text-font': [_fontName],
          'text-offset': [0.0, 1.8],
          'text-anchor': 'top',
          'text-optional': true,
          'text-max-width': 8.0,
          'visibility': 'visible',
        },
        'paint': {
          'text-color': '#1a4a2a',
          'text-halo-color': 'rgba(255,255,255,0.95)',
          'text-halo-width': 2.0,
        },
      });
    }

    return {
      'version': 8,
      'name': 'Ba Den Offline',
      // Glyph URL trỏ về local tile server – hoàn toàn offline
      'glyphs': tileServer.glyphsUrl,
      'sources': sources,
      'layers': layers,
    };
  }

  // ── Base vector fill layers ──────────────────────────────────────────────

  void _addVectorBaseFillLayers(List<Map<String, dynamic>> layers) {
    // Landcover
    layers.add({
      'id': 'base-landcover',
      'type': 'fill',
      'source': 'base-source',
      'source-layer': 'landcover',
      'paint': {
        'fill-color': [
          'match',
          ['get', 'class'],
          'wood', '#c8ddb8',
          'grass', '#d8e8c8',
          'farmland', '#e8e0c8',
          'wetland', '#c8d8d0',
          'scrub', '#d4d8c0',
          '#ddd8cc',
        ],
        'fill-opacity': 0.75,
      },
    });

    // Landuse
    layers.add({
      'id': 'base-landuse',
      'type': 'fill',
      'source': 'base-source',
      'source-layer': 'landuse',
      'paint': {
        'fill-color': [
          'match',
          ['get', 'class'],
          'residential', '#f0e8e0',
          'commercial', '#f0e0d8',
          'park', '#c8e0c0',
          'hospital', '#f0d8d8',
          'school', '#f0ecd8',
          '#e8e0d8',
        ],
        'fill-opacity': 0.5,
      },
    });

    // Water
    layers.add({
      'id': 'base-water',
      'type': 'fill',
      'source': 'base-source',
      'source-layer': 'water',
      'paint': {
        'fill-color': '#a8d0e8',
        'fill-opacity': 0.9,
      },
    });

    // Building
    layers.add({
      'id': 'base-building',
      'type': 'fill',
      'source': 'base-source',
      'source-layer': 'building',
      'minzoom': 13.0,
      'paint': {
        'fill-color': '#d8ccc0',
        'fill-outline-color': '#c0b8b0',
        'fill-opacity': 0.75,
      },
    });
  }

  // ── Base vector line layers ──────────────────────────────────────────────

  void _addVectorBaseLineLayers(List<Map<String, dynamic>> layers) {
    // Waterway
    layers.add({
      'id': 'base-waterway',
      'type': 'line',
      'source': 'base-source',
      'source-layer': 'waterway',
      'paint': {
        'line-color': '#80b8d8',
        'line-width': [
          'interpolate',
          ['linear'],
          ['zoom'],
          10, 0.5,
          14, 2.0,
        ],
      },
    });

    // Roads casing
    layers.add({
      'id': 'base-road-casing',
      'type': 'line',
      'source': 'base-source',
      'source-layer': 'transportation',
      'filter': [
        'all',
        ['!=', ['get', 'class'], 'path'],
        ['!=', ['get', 'class'], 'track'],
      ],
      'layout': {'line-join': 'round', 'line-cap': 'round'},
      'paint': {
        'line-color': '#c8b898',
        'line-width': [
          'interpolate',
          ['linear'],
          ['zoom'],
          10, 1.5,
          14, 5.0,
        ],
        'line-gap-width': 0.0,
      },
    });

    // Roads fill
    layers.add({
      'id': 'base-road-fill',
      'type': 'line',
      'source': 'base-source',
      'source-layer': 'transportation',
      'filter': [
        'all',
        ['!=', ['get', 'class'], 'path'],
        ['!=', ['get', 'class'], 'track'],
      ],
      'layout': {'line-join': 'round', 'line-cap': 'round'},
      'paint': {
        'line-color': '#f5ede0',
        'line-width': [
          'interpolate',
          ['linear'],
          ['zoom'],
          10, 0.8,
          14, 3.0,
        ],
      },
    });

    // Paths / tracks / trails
    layers.add({
      'id': 'base-path',
      'type': 'line',
      'source': 'base-source',
      'source-layer': 'transportation',
      'filter': [
        'any',
        ['==', ['get', 'class'], 'path'],
        ['==', ['get', 'class'], 'track'],
      ],
      'layout': {'line-join': 'round', 'line-cap': 'round'},
      'paint': {
        'line-color': '#c0a878',
        'line-width': 1.0,
        'line-dasharray': [2.0, 1.5],
      },
    });

    // Boundary
    layers.add({
      'id': 'base-boundary',
      'type': 'line',
      'source': 'base-source',
      'source-layer': 'boundary',
      'paint': {
        'line-color': '#c0b0a8',
        'line-width': 1.0,
        'line-dasharray': [4.0, 2.0],
      },
    });
  }
}
