import 'package:flutter/material.dart';

import '../../../features/explore/data/models/explore_place_model.dart';
import '../../../features/route/data/models/route_model.dart';
import '../../services/trekking_catalog_service.dart';
import '../cards/recommended_place_card.dart';
import '../cards/route_card.dart';
import 'app_draggable_sheet.dart';
import 'select_place_sheet.dart';

export 'select_place_sheet.dart';

class SelectRouteSheet extends StatefulWidget {
  final List<RouteModel> routes;
  final List<Map<String, dynamic>>? places;
  final RouteModel? selectedRoute;
  final ValueChanged<RouteModel> onRouteSelected;
  final TrekkingCatalogService? catalog;
  final bool useListViewForPlaces;

  const SelectRouteSheet({
    super.key,
    required this.routes,
    this.places,
    this.selectedRoute,
    required this.onRouteSelected,
    this.catalog,
    this.useListViewForPlaces = false,
  });

  @override
  State<SelectRouteSheet> createState() => _SelectRouteSheetState();
}

class _SelectRouteSheetState extends State<SelectRouteSheet> {
  late final TrekkingCatalogService _catalog;
  List<Map<String, dynamic>> _places = [];
  List<RouteModel> _routes = [];
  Map<String, dynamic>? _place;
  String _query = '';
  bool _loading = false;
  String? _error;
  int _request = 0;
  final TextEditingController _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _catalog = widget.catalog ?? TrekkingCatalogService();
    if (widget.places?.isNotEmpty == true) {
      _places = widget.places!;
    } else {
      _loadPlaces();
    }
  }

  Future<void> _loadPlaces() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final places = await _catalog.getPlaces();
      if (mounted) setState(() => _places = places);
    } catch (_) {
      if (mounted) setState(() => _error = 'Không thể tải địa điểm.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openPlace(Map<String, dynamic> place) async {
    final request = ++_request;
    setState(() {
      _place = place;
      _routes = [];
      _loading = true;
      _error = null;
      _query = '';
      _search.clear();
    });
    try {
      final id = (place['trekkingPlaceId'] ?? place['_id']).toString();
      final routes = await _catalog.getRoutes(id, place: place);
      if (mounted && request == _request) setState(() => _routes = routes);
    } catch (_) {
      if (mounted && request == _request) {
        setState(() => _error = 'Không thể tải cung đường tại địa điểm này.');
      }
    } finally {
      if (mounted && request == _request) setState(() => _loading = false);
    }
  }

  void _back() {
    ++_request;
    setState(() {
      _place = null;
      _routes = [];
      _query = '';
      _error = null;
      _search.clear();
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  ExplorePlaceModel _toExplorePlace(Map<String, dynamic> place) {
    final images = place['images'] as List? ?? [];
    return ExplorePlaceModel(
      id: (place['trekkingPlaceId'] ?? place['_id'] ?? '').toString(),
      name: (place['name'] ?? '').toString(),
      province: (place['province'] ?? place['address'] ?? '').toString(),
      elevation: place['elevationMeters'] == null
          ? '—'
          : '${place['elevationMeters']} m',
      difficulty: (place['difficulty'] ?? '').toString(),
      rating:
          (place['ratingAverage'] as num? ?? (place['rating'] as num?) ?? 0)
              .toDouble(),
      reviewCount:
          (place['ratingCount'] as num? ?? (place['reviewCount'] as num?) ?? 0)
              .toInt(),
      distance: (place['distance'] ?? '').toString(),
      duration: place['averageDurationMinutes'] == null
          ? '—'
          : '${place['averageDurationMinutes']} phút',
      imageUrl: images.isEmpty ? '' : images.first.toString(),
    );
  }

  Widget _buildSearchBar(ColorScheme colorScheme, String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _search,
        textInputAction: TextInputAction.search,
        onChanged: (v) => setState(() => _query = v.trim()),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: ListenableBuilder(
            listenable: _search,
            builder: (context, _) {
              if (_search.text.isEmpty) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () {
                  _search.clear();
                  setState(() => _query = '');
                },
              );
            },
          ),
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildPlacesView(
    ScrollController scrollController,
    List<Map<String, dynamic>> places,
    ColorScheme colors,
  ) {
    if (widget.useListViewForPlaces) {
      return ListView.separated(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: places.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final place = places[index];
          final explorePlace = _toExplorePlace(place);
          return RecommendedPlaceCard(
            place: explorePlace,
            onTap: () => _openPlace(place),
          );
        },
      );
    }

    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: places.map((place) {
          final explorePlace = _toExplorePlace(place);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: RecommendedPlaceCard(
              place: explorePlace,
              onTap: () => _openPlace(place),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final places = _places.where((p) {
      final name = (p['name'] ?? '').toString().toLowerCase();
      final province = (p['province'] ?? p['address'] ?? '')
          .toString()
          .toLowerCase();
      final q = _query.toLowerCase();
      return name.contains(q) || province.contains(q);
    }).toList();

    final routes = _routes.where((r) {
      final name = r.name.toLowerCase();
      final province = (r.province ?? '').toLowerCase();
      final q = _query.toLowerCase();
      return name.contains(q) || province.contains(q);
    }).toList();

    return AppDraggableSheet(
      title: _place == null
          ? 'Chọn địa điểm'
          : 'Cung đường tại ${_place!['name']}',
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      contentBuilder: (context, scroll) => Column(
        children: [
          if (_place != null)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: TextButton.icon(
                  onPressed: _back,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Đổi địa điểm'),
                ),
              ),
            ),
          _buildSearchBar(
            colors,
            _place == null ? 'Tìm địa điểm' : 'Tìm cung đường',
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!),
                        TextButton(
                          onPressed: _place == null
                              ? _loadPlaces
                              : () => _openPlace(_place!),
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  )
                : (_place == null ? places.isEmpty : routes.isEmpty)
                ? Center(
                    child: Text(
                      _place == null
                          ? 'Chưa có địa điểm.'
                          : 'Địa điểm này chưa có cung đường.',
                    ),
                  )
                : _place == null
                ? _buildPlacesView(scroll, places, colors)
                : ListView.separated(
                    controller: scroll,
                    padding: const EdgeInsets.all(16),
                    itemCount: routes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => RouteCard(
                      route: routes[i],
                      isSelected:
                          widget.selectedRoute?.routeId == routes[i].routeId,
                      onTap: () {
                        widget.onRouteSelected(routes[i]);
                        Navigator.pop(context);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
