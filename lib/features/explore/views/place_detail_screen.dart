import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../journey/views/widgets/place_review_section.dart';
import '../../journey/data/repositories/journey_repository.dart';

import '../../../core/network/api_error_handler.dart';
import '../../../core/services/trekking_catalog_service.dart';
import '../../../core/widgets/cards/trekking_map_preview.dart';
import '../../route/data/models/route_model.dart';
import '../../route/view/route_detail_screen.dart';
import '../../offline_map/services/offline_map_storage_service.dart';

/// Place metadata and routes come from the API; the map uses installed MBTiles.
class PlaceDetailScreen extends StatefulWidget {
  final String placeId;
  final TrekkingCatalogService? service;
  final OfflineMapStorageService? mapStorage;
  final JourneyRepository? reviewRepository;

  const PlaceDetailScreen({
    super.key,
    required this.placeId,
    this.service,
    this.mapStorage,
    this.reviewRepository,
  });

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  late final TrekkingCatalogService _service;
  Map<String, dynamic>? _place;
  List<RouteModel> _routes = [];
  bool _loading = true;
  String? _error;
  int _mapRevision = 0;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? TrekkingCatalogService();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final place = await _service.getPlace(widget.placeId);
      final routes = await _service.getRoutes(widget.placeId, place: place);
      if (!mounted) return;
      setState(() {
        _place = place;
        _routes = routes;
      });
    } catch (e) {
      if (mounted) setState(() => _error = ApiErrorHandler.handle(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String? get _difficulty => switch (_place?['difficulty']) {
    'EASY' => 'Dễ',
    'MODERATE' => 'Trung bình',
    'HARD' => 'Khó',
    'EXPERT' => 'Rất khó',
    _ => null,
  };

  String _duration(num? minutes) {
    if (minutes == null || minutes <= 0) return '—';
    final value = minutes.round();
    if (value >= 1440) {
      final days = value / 1440;
      return '${days == days.roundToDouble() ? days.toInt() : days.toStringAsFixed(1)} ngày';
    }
    final hours = value ~/ 60;
    final remainder = value % 60;
    return hours == 0
        ? '$remainder phút'
        : '$hours giờ${remainder == 0 ? '' : ' $remainder phút'}';
  }

  Widget _hero(ColorScheme colors) {
    final urls = (_place?['images'] as List? ?? []).whereType<String>().where(
      (url) => url.trim().isNotEmpty,
    );
    final width = MediaQuery.sizeOf(context).width;
    final topInset = MediaQuery.paddingOf(context).top;
    return SizedBox(
      key: const ValueKey('place-hero'),
      width: double.infinity,
      height: (width * 0.72).clamp(240.0, 360.0) + topInset,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (urls.isNotEmpty)
            Image.network(
              urls.first,
              fit: BoxFit.cover,
              loadingBuilder: (_, child, progress) =>
                  progress == null ? child : _imagePlaceholder(colors),
              errorBuilder: (_, error, stack) => _imagePlaceholder(colors),
            )
          else
            _imagePlaceholder(colors),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0, 0.35, 0.6, 1],
                colors: [
                  Colors.black.withValues(alpha: 0.4),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.12),
                  Theme.of(context).brightness == Brightness.dark
                      ? colors.surface
                      : Colors.black87,
                ],
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _place?['name']?.toString() ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.2,
                    shadows: [Shadow(blurRadius: 8, color: Colors.black54)],
                  ),
                ),
                if ((_place?['address'] as String? ?? '').isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 15,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _place!['address'].toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder(ColorScheme colors) => ColoredBox(
    color: colors.surfaceContainerHighest,
    child: Center(
      child: Icon(
        Icons.terrain_outlined,
        size: 56,
        color: colors.onSurfaceVariant,
      ),
    ),
  );

  Widget _sectionTitle(String title, ColorScheme colors) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
        color: colors.onSurfaceVariant,
      ),
    ),
  );

  Widget _stat(String value, String label, IconData icon, ColorScheme colors) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 18, color: colors.primary),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(fontSize: 10, color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );

  Widget _routeCard(RouteModel route, ColorScheme colors) {
    final distance = route.distanceMeters > 0
        ? '${route.distanceKm.toStringAsFixed(1)} km'
        : 'Chưa có cự ly';
    final duration = _duration(route.estimatedDuration.inMinutes);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: colors.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.3)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => RouteDetailScreen(
                  route: route,
                  mapStorage: widget.mapStorage,
                ),
              ),
            );
            if (mounted) setState(() => _mapRevision++);
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.route_outlined,
                    size: 21,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        route.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '$distance${duration == '—' ? '' : ' · $duration'}',
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: colors.onSurfaceVariant,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(ColorScheme colors) {
    final elevation = _place?['elevationMeters'] as num?;
    final rating = (_place?['ratingAverage'] as num? ?? 0).toDouble();
    final reviewCount = (_place?['ratingCount'] as num? ?? 0).toInt();
    final description = (_place?['description'] as String? ?? '').trim();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star_rounded, size: 18, color: Colors.amber),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  reviewCount == 0
                      ? 'Chưa có đánh giá'
                      : '${rating.toStringAsFixed(1)} ($reviewCount đánh giá)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _stat(
                '${_routes.length}',
                'Cung đường',
                Icons.route_outlined,
                colors,
              ),
              const SizedBox(width: 8),
              _stat(
                _duration(_place?['averageDurationMinutes'] as num?),
                'Thời gian',
                Icons.schedule_outlined,
                colors,
              ),
              const SizedBox(width: 8),
              _stat(
                elevation == null ? '—' : '${elevation.round()} m',
                'Độ cao',
                Icons.terrain_outlined,
                colors,
              ),
            ],
          ),
          const SizedBox(height: 28),
          _sectionTitle('GIỚI THIỆU', colors),
          Text(
            description.isEmpty ? 'Địa điểm chưa có mô tả.' : description,
            style: TextStyle(
              fontSize: 13,
              height: 1.65,
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 28),
          _sectionTitle('CUNG ĐƯỜNG (${_routes.length})', colors),
          if (_routes.isEmpty)
            Text(
              'Địa điểm chưa có cung đường.',
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
            ),
          for (final route in _routes) _routeCard(route, colors),
          const SizedBox(height: 18),
          _sectionTitle('BẢN ĐỒ LỘ TRÌNH', colors),
          TrekkingMapPreview(
            storage: widget.mapStorage,
            key: ValueKey('${widget.placeId}:$_mapRevision'),
            placeId: widget.placeId,
            placeName: _place?['name'] as String?,
            location: RouteModel.fromJson({
              'trekkingPlaceId': widget.placeId,
            }, place: _place ?? {}).startPoint,
          ),
          const SizedBox(height: 28),
          PlaceReviewSection(
            placeId: widget.placeId,
            repository: widget.reviewRepository,
            placeName: _place?['name'] as String?,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final colors = theme.colorScheme;
    final showPlace = !_loading && _error == null && _place != null;
    return Scaffold(
      backgroundColor: colors.surface,
      extendBodyBehindAppBar: showPlace,
      appBar: AppBar(
        backgroundColor: showPlace ? Colors.transparent : colors.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        systemOverlayStyle: showPlace || dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: IconButton(
            tooltip: 'Quay lại',
            onPressed: () => Navigator.of(context).maybePop(),
            style: IconButton.styleFrom(
              backgroundColor: showPlace
                  ? Colors.black.withValues(alpha: 0.35)
                  : colors.surfaceContainerHighest,
              foregroundColor: showPlace ? Colors.white : colors.onSurface,
            ),
            icon: const Icon(Icons.arrow_back_rounded, size: 22),
          ),
        ),
        actions: [
          if (showPlace && _difficulty != null)
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Chip(
                label: Text(_difficulty!),
                backgroundColor: colors.primary,
                side: BorderSide.none,
                labelStyle: TextStyle(
                  color: colors.onPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                visualDensity: VisualDensity.compact,
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_error!, textAlign: TextAlign.center),
                    TextButton(onPressed: _load, child: const Text('Thử lại')),
                  ],
                ),
              ),
            )
          : SafeArea(
              top: false,
              child: RefreshIndicator(
                onRefresh: _load,
                edgeOffset: MediaQuery.paddingOf(context).top + kToolbarHeight,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: _hero(colors)),
                    SliverToBoxAdapter(child: _content(colors)),
                  ],
                ),
              ),
            ),
    );
  }
}
