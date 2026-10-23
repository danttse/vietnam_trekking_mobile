import 'dart:io';

import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../../../features/offline_map/services/offline_map_manager.dart';
import '../../../features/offline_map/services/offline_map_storage_service.dart';
import '../../../features/offline_map/utils/entity_map_style.dart';
import '../../../features/route/data/models/route_model.dart';
import '../../../features/route/viewmodel/download_offline_map_viewmodel.dart';

/// Renders installed place MBTiles and the selected route's live path.
class TrekkingMapPreview extends StatefulWidget {
  final String placeId;
  final String? placeName;
  final GeoPoint? location;
  final RouteModel? route;
  final bool expanded;
  final VoidCallback? onDownloaded;
  final OfflineMapStorageService? storage;
  const TrekkingMapPreview({
    super.key,
    required this.placeId,
    this.placeName,
    this.location,
    this.route,
    this.expanded = false,
    this.onDownloaded,
    this.storage,
  });

  @override
  State<TrekkingMapPreview> createState() => _TrekkingMapPreviewState();
}

class _TrekkingMapPreviewState extends State<TrekkingMapPreview> {
  final _manager = OfflineMapManager.create();
  late final _storage = widget.storage ?? OfflineMapStorageService();
  DownloadOfflineMapViewModel? _download;
  bool _loading = true;
  String? _error;
  String? _style;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
      _style = null;
    });
    try {
      final map = await _storage.findReadyMap(
        widget.route?.routeId ?? '',
        widget.placeId,
      );
      if (!mounted) return;
      if (map != null) {
        await _manager.close();
        if (!mounted) return;
        await _manager.initialize(
          packageDirectory: File(map.localPath).parent.path,
        );
        if (!mounted) return;
        if (!_manager.isReady) {
          throw StateError(
            _manager.errorMessage ?? 'Không thể đọc gói offline.',
          );
        }
        _style = entityMapStyle(
          _manager.styleString!,
          route: widget.route,
          location: widget.location,
        );
      }
    } catch (error) {
      if (mounted) {
        _error = error is StateError
            ? error.message
            : 'Không thể mở bản đồ offline trên thiết bị.';
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _downloadMap() async {
    if (_download != null) return;
    final download = DownloadOfflineMapViewModel(
      route: widget.route,
      placeId: widget.placeId,
      placeName: widget.placeName,
      autoStart: false,
      storage: _storage,
    );
    _download = download;
    void progress() {
      if (mounted) setState(() {});
    }

    download.addListener(progress);
    setState(() => _error = null);
    await download.startDownload();
    download.removeListener(progress);
    final completed = download.isCompleted;
    final error = download.error;
    download.dispose();
    _download = null;
    if (!mounted) return;
    if (completed) {
      widget.onDownloaded?.call();
      await _load();
    } else {
      setState(() => _error = error);
    }
  }

  @override
  void dispose() {
    _download?.cancelDownload();
    _manager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final manifest = _manager.manifest;
    final downloading = _download?.isRunning == true;
    final ready = _style != null && !_loading;
    return Container(
      height: widget.expanded ? null : 260,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.expanded ? 0 : 14),
        color: colors.surfaceContainerHighest,
        border: Border.all(color: colors.outlineVariant),
      ),
      child: ready
          ? Stack(
              children: [
                MapLibreMap(
                  key: ValueKey(_style),
                  styleString: _style!,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(manifest!.centerLat, manifest.centerLng),
                    zoom: ((manifest.minZoom + manifest.maxZoom) / 2)
                        .toDouble(),
                  ),
                  minMaxZoomPreference: MinMaxZoomPreference(
                    manifest.minZoom.toDouble(),
                    manifest.maxZoom.toDouble(),
                  ),
                  cameraTargetBounds: CameraTargetBounds(
                    LatLngBounds(
                      southwest: LatLng(manifest.bounds[1], manifest.bounds[0]),
                      northeast: LatLng(manifest.bounds[3], manifest.bounds[2]),
                    ),
                  ),
                  myLocationEnabled: false,
                  compassEnabled: widget.expanded,
                  scrollGesturesEnabled: widget.expanded,
                  rotateGesturesEnabled: widget.expanded,
                  tiltGesturesEnabled: widget.expanded,
                  zoomGesturesEnabled: widget.expanded,
                ),
                Positioned(
                  left: 8,
                  bottom: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surface.withValues(alpha: .9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      widget.route == null
                          ? 'Bản đồ offline của địa điểm'
                          : 'Bản đồ offline · ${widget.route!.name}',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                ),
                if (!widget.expanded)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: IconButton.filledTonal(
                      tooltip: 'Phóng to bản đồ',
                      icon: const Icon(Icons.fullscreen_rounded),
                      onPressed: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => Scaffold(
                              appBar: AppBar(
                                title: Text(
                                  widget.route?.name ??
                                      widget.placeName ??
                                      'Bản đồ offline',
                                ),
                              ),
                              body: TrekkingMapPreview(
                                placeId: widget.placeId,
                                placeName: widget.placeName,
                                location: widget.location,
                                route: widget.route,
                                storage: _storage,
                                expanded: true,
                              ),
                            ),
                          ),
                        );
                        if (mounted) await _load();
                      },
                    ),
                  ),
              ],
            )
          : Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_loading || downloading)
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        Icon(
                          Icons.map_outlined,
                          size: 32,
                          color: colors.onSurfaceVariant,
                        ),
                      const SizedBox(height: 10),
                      Text(
                        _loading
                            ? 'Đang mở bản đồ offline…'
                            : downloading
                            ? 'Đang tải bản đồ ${_download!.progressPercent}%'
                            : _error ?? 'Chưa tải bản đồ offline của địa điểm.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      if (!_loading && !downloading)
                        TextButton.icon(
                          onPressed: _downloadMap,
                          icon: const Icon(Icons.download_outlined),
                          label: const Text('Tải bản đồ offline'),
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
