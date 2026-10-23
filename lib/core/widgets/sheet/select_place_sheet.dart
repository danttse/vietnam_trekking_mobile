import 'package:flutter/material.dart';

import '../../../features/explore/data/models/explore_place_model.dart';
import '../../services/trekking_catalog_service.dart';
import '../cards/recommended_place_card.dart';
import 'app_draggable_sheet.dart';

class SelectPlaceSheet extends StatefulWidget {
  final List<Map<String, dynamic>>? places;
  final Map<String, dynamic>? selectedPlace;
  final ValueChanged<Map<String, dynamic>> onPlaceSelected;
  final TrekkingCatalogService? catalog;
  final bool useListView;

  const SelectPlaceSheet({
    super.key,
    this.places,
    this.selectedPlace,
    required this.onPlaceSelected,
    this.catalog,
    this.useListView = false,
  });

  @override
  State<SelectPlaceSheet> createState() => _SelectPlaceSheetState();
}

class _SelectPlaceSheetState extends State<SelectPlaceSheet> {
  late final TrekkingCatalogService _catalog;
  List<Map<String, dynamic>> _places = [];
  String _query = '';
  bool _loading = false;
  String? _error;
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

  Widget _buildSearchBar(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _search,
        textInputAction: TextInputAction.search,
        onChanged: (v) => setState(() => _query = v.trim()),
        decoration: InputDecoration(
          hintText: 'Tìm địa điểm',
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

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final filteredPlaces = _places.where((p) {
      final name = (p['name'] ?? '').toString().toLowerCase();
      final province = (p['province'] ?? p['address'] ?? '')
          .toString()
          .toLowerCase();
      final q = _query.toLowerCase();
      return name.contains(q) || province.contains(q);
    }).toList();

    return AppDraggableSheet(
      title: 'Chọn địa điểm',
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      contentBuilder: (context, scrollController) => Column(
        children: [
          _buildSearchBar(colors),
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
                          onPressed: _loadPlaces,
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  )
                : filteredPlaces.isEmpty
                ? const Center(child: Text('Chưa có địa điểm.'))
                : widget.useListView
                ? ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: filteredPlaces.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final place = filteredPlaces[index];
                      final placeId =
                          (place['trekkingPlaceId'] ?? place['_id'] ?? '')
                              .toString();
                      final selectedId = widget.selectedPlace != null
                          ? (widget.selectedPlace!['trekkingPlaceId'] ??
                                    widget.selectedPlace!['_id'] ??
                                    '')
                                .toString()
                          : '';
                      final isSelected =
                          selectedId.isNotEmpty && selectedId == placeId;
                      final explorePlace = _toExplorePlace(place);

                      return RecommendedPlaceCard(
                        place: explorePlace,
                        isSelected: isSelected,
                        onTap: () => widget.onPlaceSelected(place),
                      );
                    },
                  )
                : SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Column(
                      children: filteredPlaces.map((place) {
                        final placeId =
                            (place['trekkingPlaceId'] ?? place['_id'] ?? '')
                                .toString();
                        final selectedId = widget.selectedPlace != null
                            ? (widget.selectedPlace!['trekkingPlaceId'] ??
                                      widget.selectedPlace!['_id'] ??
                                      '')
                                  .toString()
                            : '';
                        final isSelected =
                            selectedId.isNotEmpty && selectedId == placeId;
                        final explorePlace = _toExplorePlace(place);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: RecommendedPlaceCard(
                            place: explorePlace,
                            isSelected: isSelected,
                            onTap: () => widget.onPlaceSelected(place),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
