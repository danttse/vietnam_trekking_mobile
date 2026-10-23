import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/services/trekking_catalog_service.dart';
import '../../../core/network/api_error_handler.dart';
import '../data/models/explore_place_model.dart';
import '../../route/data/models/route_model.dart';
import '../data/models/popular_trail_model.dart';

/// One source for chip order, labels and the backend region parameter.
enum ExploreFilter {
  all('Tất cả', null),
  popular('Phổ biến', null),
  north('Miền Bắc', 'NORTH'),
  central('Miền Trung', 'CENTRAL'),
  south('Miền Nam', 'SOUTH');

  final String label;
  final String? region;

  const ExploreFilter(this.label, this.region);
}

class ExploreViewModel extends ChangeNotifier {
  final TrekkingCatalogService _service;
  ExploreViewModel({TrekkingCatalogService? service, bool autoLoad = true})
    : _service = service ?? TrekkingCatalogService() {
    if (autoLoad) load();
  }
  String _searchQuery = '';
  ExploreFilter _selectedFilter = ExploreFilter.all;
  bool isLoading = false;
  String? error;
  String? routesError;
  bool _disposed = false;
  int _request = 0;
  Timer? _debounce;
  List<ExplorePlaceModel> _places = [];
  List<PopularTrailModel> _trails = [];
  String get searchQuery => _searchQuery;
  int get selectedRegion => _selectedFilter.index;
  ExploreFilter get selectedFilter => _selectedFilter;
  List<ExplorePlaceModel> get featuredPlaces => _places.take(5).toList();
  List<PopularTrailModel> get popularTrails => _trails;
  List<ExplorePlaceModel> get recommendedPlaces => _places;

  void setSearchQuery(String value) {
    _searchQuery = value.trim();
    _request++;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), load);
    notifyListeners();
  }

  Future<void> setRegion(int index) async {
    if (index < 0 || index >= ExploreFilter.values.length) return;
    final filter = ExploreFilter.values[index];
    if (filter == _selectedFilter) return;
    _selectedFilter = filter;
    _debounce?.cancel();
    await load();
  }

  Future<void> load() async {
    final request = ++_request;
    final filter = _selectedFilter;
    final query = _searchQuery;
    isLoading = true;
    error = null;
    routesError = null;
    notifyListeners();
    try {
      final places = await _service.getPlaces(
        query: query,
        region: filter.region,
      );
      final routes = <List<RouteModel>>[];
      String? routeFailure;
      // Bound concurrent route calls while preserving the server's place order.
      for (var start = 0; start < places.length; start += 6) {
        if (_disposed || request != _request) return;
        routes.addAll(
          await Future.wait(
            places.skip(start).take(6).map((p) async {
              try {
                return await _service.getRoutes(
                  p['trekkingPlaceId'].toString(),
                  place: p,
                );
              } catch (e) {
                routeFailure = ApiErrorHandler.handle(e);
                return <RouteModel>[];
              }
            }),
          ),
        );
      }
      if (_disposed || request != _request) return;
      routesError = routeFailure;
      _places = places.map((p) {
        final images = p['images'] as List? ?? [];
        return ExplorePlaceModel(
          id: p['trekkingPlaceId'].toString(),
          name: p['name'] as String? ?? '',
          province: (p['address'] ?? '').toString(),
          elevation: p['elevationMeters'] == null
              ? '—'
              : '${p['elevationMeters']} m',
          difficulty: (p['difficulty'] ?? '').toString(),
          rating: (p['ratingAverage'] as num? ?? 0).toDouble(),
          reviewCount: (p['ratingCount'] as num? ?? 0).toInt(),
          distance: '',
          duration: p['averageDurationMinutes'] == null
              ? '—'
              : '${p['averageDurationMinutes']} phút',
          imageUrl: images.isEmpty ? '' : images.first.toString(),
        );
      }).toList();
      if (filter == ExploreFilter.popular) {
        _places.sort((a, b) => b.rating.compareTo(a.rating));
      }
      _trails = routes
          .expand((r) => r)
          .map(
            (r) => PopularTrailModel(
              id: r.routeId,
              name: r.name,
              location: r.province ?? '',
              length: '${r.distanceKm.toStringAsFixed(1)} km',
              duration: '${r.estimatedDuration.inMinutes} phút',
              difficulty: r.difficulty.name,
              rating: 0,
              imageUrl: r.imageUrl ?? '',
            ),
          )
          .toList();
    } catch (e) {
      if (_disposed || request != _request) return;
      error = ApiErrorHandler.handle(e);
      _places = [];
      _trails = [];
    } finally {
      if (!_disposed && request == _request) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _debounce?.cancel();
    super.dispose();
  }
}
