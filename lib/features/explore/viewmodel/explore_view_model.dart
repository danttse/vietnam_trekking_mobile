import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/models/catalog_page.dart';
import '../../../core/network/api_error_handler.dart';
import '../../../core/services/trekking_catalog_service.dart';
import '../data/explore_cache_manager.dart';
import '../data/models/explore_place_model.dart';
import '../data/models/popular_trail_model.dart';

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
  final ExploreCacheManager _cache;
  ExploreViewModel({
    TrekkingCatalogService? service,
    ExploreCacheManager? cache,
    bool autoLoad = true,
  }) : _service = service ?? TrekkingCatalogService(),
       _cache = cache ?? ExploreCacheManager() {
    if (autoLoad) load();
  }
  String _searchQuery = '';
  ExploreFilter _selectedFilter = ExploreFilter.all;
  bool isLoading = false;
  bool isLoadingMorePlaces = false;
  bool isLoadingMoreTrails = false;
  bool hasMorePlaces = false;
  bool hasMoreTrails = false;
  String? error;
  String? routesError;
  bool _disposed = false;
  int _request = 0;
  int _placesPage = 0;
  int _trailsPage = 0;
  Timer? _debounce;
  List<ExplorePlaceModel> _places = [];
  List<PopularTrailModel> _trails = [];
  String get searchQuery => _searchQuery;
  int get selectedRegion => _selectedFilter.index;
  ExploreFilter get selectedFilter => _selectedFilter;
  List<ExplorePlaceModel> get featuredPlaces => _places.take(5).toList();
  List<PopularTrailModel> get popularTrails => _trails;
  List<ExplorePlaceModel> get recommendedPlaces => _places;
  bool _current(int request) => !_disposed && request == _request;

  void setSearchQuery(String value) {
    final query = value.trim();
    if (query == _searchQuery) return;
    _searchQuery = query;
    _request++;
    _clearLists();
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), load);
    notifyListeners();
  }

  Future<void> setRegion(int index) async {
    if (index < 0 || index >= ExploreFilter.values.length) return;
    final filter = ExploreFilter.values[index];
    if (filter == _selectedFilter) return;
    _selectedFilter = filter;
    _clearLists();
    await load();
  }

  void _clearLists() {
    _places = [];
    _trails = [];
    _placesPage = 0;
    _trailsPage = 0;
    hasMorePlaces = false;
    hasMoreTrails = false;
  }

  Future<void> refresh() => load(forceRefresh: true);

  Future<void> load({bool forceRefresh = false}) async {
    if (_disposed) return;
    _debounce?.cancel();
    final request = ++_request;
    isLoading = true;
    isLoadingMorePlaces = false;
    isLoadingMoreTrails = false;
    error = null;
    routesError = null;
    notifyListeners();
    await Future.wait([
      _loadPage(
        routes: false,
        page: 1,
        request: request,
        forceRefresh: forceRefresh,
      ),
      _loadPage(
        routes: true,
        page: 1,
        request: request,
        forceRefresh: forceRefresh,
      ),
    ]);
    if (_current(request)) {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMorePlaces() async {
    if (_disposed || isLoading || isLoadingMorePlaces || !hasMorePlaces) return;
    isLoadingMorePlaces = true;
    error = null;
    notifyListeners();
    final request = _request;
    await _loadPage(routes: false, page: _placesPage + 1, request: request);
    if (_current(request)) {
      isLoadingMorePlaces = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreTrails() async {
    if (_disposed || isLoading || isLoadingMoreTrails || !hasMoreTrails) return;
    isLoadingMoreTrails = true;
    routesError = null;
    notifyListeners();
    final request = _request;
    await _loadPage(routes: true, page: _trailsPage + 1, request: request);
    if (_current(request)) {
      isLoadingMoreTrails = false;
      notifyListeners();
    }
  }

  Future<void> _loadPage({
    required bool routes,
    required int page,
    required int request,
    bool forceRefresh = false,
  }) async {
    void apply(CatalogPage data) {
      if (!_current(request)) return;
      if (routes) {
        final items = data.items.map(_trail).toList();
        _trails = page == 1
            ? items
            : {
                for (final item in [..._trails, ...items]) item.id: item,
              }.values.toList();
        _trailsPage = data.page;
        hasMoreTrails = data.hasMore;
      } else {
        final items = data.items.map(_place).toList();
        _places = page == 1
            ? items
            : {
                for (final item in [..._places, ...items]) item.id: item,
              }.values.toList();
        _placesPage = data.page;
        hasMorePlaces = data.hasMore;
      }
      notifyListeners();
    }

    void failure(Object e) {
      if (!_current(request)) return;
      if (routes) {
        routesError = ApiErrorHandler.handle(e);
      } else {
        error = ApiErrorHandler.handle(e);
      }
      notifyListeners();
    }

    try {
      final data = await _cache.getPage(
        service: _service,
        path: routes ? '/routes' : '/places',
        query: _searchQuery,
        region: _selectedFilter.region,
        sort: routes || _selectedFilter == ExploreFilter.popular
            ? 'popular'
            : null,
        page: page,
        limit: routes ? 10 : 20,
        forceRefresh: forceRefresh,
        onCached: page == 1 ? apply : null,
        onRefreshError: failure,
      );
      apply(data);
    } catch (e) {
      failure(e);
    }
  }

  static ExplorePlaceModel _place(Map<String, dynamic> p) {
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
  }

  static PopularTrailModel _trail(Map<String, dynamic> r) => PopularTrailModel(
    id: r['trekkingRouteId'].toString(),
    name: r['name'] as String? ?? '',
    location: (r['province'] ?? r['placeName'] ?? '').toString(),
    length:
        '${((r['distanceMeters'] as num? ?? 0) / 1000).toStringAsFixed(1)} km',
    duration: '${r['estimatedDurationMinutes'] ?? 0} phút',
    difficulty: switch (r['difficulty']) {
      'EASY' => 'easy',
      'MODERATE' => 'moderate',
      'EXPERT' => 'extreme',
      _ => 'hard',
    },
    rating: (r['ratingAverage'] as num? ?? 0).toDouble(),
    imageUrl: r['imageUrl'] as String? ?? '',
  );

  @override
  void dispose() {
    _disposed = true;
    _debounce?.cancel();
    super.dispose();
  }
}
