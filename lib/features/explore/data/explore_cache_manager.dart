import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/models/catalog_page.dart';
import '../../../core/services/trekking_catalog_service.dart';

class _Entry {
  final CatalogPage page;
  final DateTime fetchedAt;
  _Entry(this.page, this.fetchedAt);
}

/// Query/page-scoped RAM and SQLite snapshots. Expiry never deletes offline data.
class ExploreCacheManager {
  static const ttl = Duration(minutes: 10);
  static const _capacity = 80;
  final DateTime Function() now;
  final Map<String, _Entry> _memory = {};
  final Map<String, Future<CatalogPage>> _pending = {};
  ExploreCacheManager({DateTime Function()? clock})
    : now = clock ?? DateTime.now;

  Future<CatalogPage> getPage({
    required TrekkingCatalogService service,
    required String path,
    String? query,
    String? region,
    String? sort,
    int page = 1,
    int limit = 20,
    bool forceRefresh = false,
    void Function(CatalogPage)? onCached,
    void Function(Object)? onRefreshError,
  }) async {
    final group =
        '/explore-pages/v2/${Uri.encodeComponent(service.dio.options.baseUrl)}${Uri(path: path, queryParameters: {'q': query?.trim() ?? '', 'region': region ?? '', 'sort': sort ?? 'default', 'limit': '$limit'}).toString()}/page/';
    final key = '$group$page';
    var cached = _memory.remove(key);
    if (cached == null && service.cacheEnabled) {
      try {
        final snapshot = await service.offline.read(key);
        if (snapshot is Map) {
          cached = _Entry(
            CatalogPage.fromJson(
              Map<String, dynamic>.from(snapshot['data'] as Map),
            ),
            DateTime.parse(snapshot['fetchedAt'] as String),
          );
        }
      } catch (_) {
        /* Missing/corrupt SQLite data must not block the API. */
      }
    }
    if (cached != null) {
      _remember(key, cached);
      final age = now().difference(cached.fetchedAt);
      if (!forceRefresh && !age.isNegative && age < ttl) return cached.page;
      onCached?.call(cached.page);
    }
    final pending = _pending[key] ??= _fetch(
      service,
      key,
      group,
      path,
      query,
      region,
      sort,
      page,
      limit,
    );
    try {
      return await pending;
    } catch (e) {
      final canShowStale =
          e is DioException &&
          e.response?.statusCode != 401 &&
          e.response?.statusCode != 403 &&
          e.type != DioExceptionType.cancel;
      if (cached == null || !canShowStale) rethrow;
      onRefreshError?.call(e);
      return cached.page;
    } finally {
      if (identical(_pending[key], pending)) {
        _pending.remove(key);
      }
    }
  }

  Future<CatalogPage> _fetch(
    TrekkingCatalogService service,
    String key,
    String group,
    String path,
    String? query,
    String? region,
    String? sort,
    int page,
    int limit,
  ) async {
    final data = await service.getCatalogPage(
      path,
      query: query,
      region: region,
      sort: sort,
      page: page,
      limit: limit,
    );
    final fetchedAt = now();
    // A new first page establishes a new ordering; later old pages must reload.
    if (page == 1) {
      _memory.removeWhere(
        (other, _) => other.startsWith(group) && other != key,
      );
    }
    _remember(key, _Entry(data, fetchedAt));
    if (service.cacheEnabled) {
      try {
        if (page == 1) {
          await service.offline.invalidateExplorePages(group, key);
        }
        await service.offline.cache(key, {
          'data': data.toJson(),
          'fetchedAt': fetchedAt.toUtc().toIso8601String(),
        });
        await service.offline.pruneExplorePages(_capacity);
      } catch (_) {
        if (kDebugMode) {
          debugPrint('[ExploreCache] Could not persist catalog page');
        }
      }
    }
    return data;
  }

  void _remember(String key, _Entry value) {
    _memory.remove(key);
    _memory[key] = value;
    while (_memory.length > _capacity) {
      _memory.remove(_memory.keys.first);
    }
  }
}
