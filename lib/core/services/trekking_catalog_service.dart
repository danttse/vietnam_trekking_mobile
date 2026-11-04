import 'package:dio/dio.dart';

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../features/journey/data/models/journey_model.dart';
import '../network/dio_client.dart';
import '../models/catalog_page.dart';
import 'auth_event_bus.dart';
import 'token_storage.dart';
import 'offline_store.dart';
import 'journey_tracking_service.dart';
import '../../features/route/data/models/route_model.dart';

/// Public trekking catalog, using the same authenticated client as journeys.
class TrekkingCatalogService {
  final bool cacheEnabled;
  final Dio dio;
  final Dio checkinDio;
  final OfflineStore offline;
  TrekkingCatalogService({
    Dio? client,
    Dio? checkinClient,
    OfflineStore? store,
    this.cacheEnabled = true,
  }) : offline = store ?? OfflineStore.instance,
       checkinDio =
           checkinClient ??
           DioClient.createCheckinDio(
             tokenStorage: const SecureTokenStorage(),
             eventBus: AuthEventBus(),
           ),
       dio =
           client ??
           DioClient.createTrekkingDio(
             tokenStorage: const SecureTokenStorage(),
             eventBus: AuthEventBus(),
           );

  Future<dynamic> getCatalog(String path) async {
    try {
      final response = await dio.get(path);
      final data = response.data['data'];
      if (cacheEnabled) await offline.cache(path, data);
      return data;
    } on DioException catch (e) {
      if (!cacheEnabled || !OfflineStore.canUseCache(e)) rethrow;
      final cached = await offline.read(path);
      if (cached == null) rethrow;
      return cached;
    }
  }

  /// One bounded page for Explore. Geometry and milestones load on detail only.
  Future<CatalogPage> getCatalogPage(
    String path, {
    String? query,
    String? region,
    String? sort,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await dio.get(
      path,
      queryParameters: {
        'summary': 'true',
        'page': page,
        'limit': limit,
        if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
        if (region != null) 'region': region,
        if (sort != null) 'sort': sort,
      },
    );
    return CatalogPage.fromJson(
      Map<String, dynamic>.from(response.data['data'] as Map),
    );
  }

  Future<List<Map<String, dynamic>>> getPlaces({
    String? query,
    String? region,
    String? sort,
    bool includeRoutes = false,
    int? maxItems,
  }) async {
    if (maxItems != null && maxItems < 1) {
      throw ArgumentError.value(maxItems, 'maxItems', 'Must be positive');
    }
    final parameters = {
      if (query != null && query.isNotEmpty) 'q': query,
      if (region != null) 'region': region,
      if (sort != null) 'sort': sort,
      if (includeRoutes) 'includeRoutes': 'true',
      if (maxItems != null) 'limit': maxItems.toString(),
    };
    final resource = Uri(
      path: '/places',
      queryParameters: parameters.isEmpty ? null : parameters,
    ).toString();
    try {
      final items = <Map<String, dynamic>>[];
      var page = 1;
      while (true) {
        final response = await dio.get(
          '/places',
          queryParameters: {
            if (query != null && query.isNotEmpty) 'q': query,
            if (region != null) 'region': region,
            if (sort != null) 'sort': sort,
            if (includeRoutes) 'includeRoutes': 'true',
            'page': page,
            'limit': maxItems != null && maxItems < 100 ? maxItems : 100,
          },
        );
        final data = response.data['data'] as Map;
        final batch = (data['items'] as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        items.addAll(batch);
        if (maxItems != null && items.length >= maxItems) {
          items.removeRange(maxItems, items.length);
          break;
        }
        if (batch.isEmpty || items.length >= (data['total'] as num).toInt())
          break;
        page++;
      }
      if (cacheEnabled) await offline.cache(resource, items);
      return items;
    } on DioException catch (e) {
      if (!cacheEnabled || !OfflineStore.canUseCache(e)) rethrow;
      final cached = await offline.read(resource);
      if (cached == null) rethrow;
      return (cached as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
  }

  Future<List<RouteModel>> getRoutes(
    String placeId, {
    Map<String, dynamic>? place,
  }) async {
    final metadata = place ?? await getPlace(placeId);
    if (cacheEnabled) await offline.cache('/places/$placeId', metadata);
    final routes = await getCatalog('/places/$placeId/routes') as List;
    return routes
        .map((e) => parseRoute(Map<String, dynamic>.from(e as Map), metadata))
        .toList();
  }

  Future<Map<String, dynamic>> getPlace(String placeId) async =>
      Map<String, dynamic>.from(await getCatalog('/places/$placeId') as Map);
  Future<RouteModel> getRoute(String routeId) async {
    final route = Map<String, dynamic>.from(
      await getCatalog('/routes/$routeId') as Map,
    );
    final place = await getPlace(route['trekkingPlaceId'].toString());
    return parseRoute(route, place);
  }

  Future<List<Map<String, dynamic>>> getMilestones(String routeId) async {
    final path = '/routes/$routeId/milestones';
    List data;
    try {
      data = await getCatalog(path) as List;
    } on DioException catch (e) {
      // Historical journeys may refer to a disabled route. Its cached
      // milestones remain viewable; auth failures must still propagate.
      if (e.response?.statusCode != 404 || !cacheEnabled) rethrow;
      final cached = await offline.read(path);
      if (cached == null) rethrow;
      data = cached as List;
    }
    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<JourneyModel> parseJourney(
    Map<String, dynamic> json, {
    RouteModel? route,
  }) async {
    final resolvedRoute = route ?? await _journeyRoute(json);
    return JourneyModel.fromJson(json, route: resolvedRoute);
  }

  Future<RouteModel> _journeyRoute(Map<String, dynamic> journey) async {
    final routeId = journey['trekkingRouteId'].toString();
    final placeId = journey['trekkingPlaceId'].toString();
    if (journey['route'] is Map) {
      final route = Map<String, dynamic>.from(journey['route'] as Map);
      final place = journey['place'] is Map
          ? Map<String, dynamic>.from(journey['place'] as Map)
          : <String, dynamic>{};
      if (cacheEnabled) {
        if (place.isNotEmpty) await offline.cache('/places/$placeId', place);
        await offline.cache('/routes/$routeId', route);
      }
      return parseRoute(route, place);
    }
    try {
      return await getRoute(routeId);
    } on DioException catch (e) {
      if (!OfflineStore.canUseCache(e) && e.response?.statusCode != 404)
        rethrow;
      // One unavailable catalog entry must not hide the user's other trips.
      final cachedRoute = cacheEnabled
          ? await offline.read('/routes/$routeId')
          : null;
      final cachedPlace = cacheEnabled
          ? await offline.read('/places/$placeId')
          : null;
      return parseRoute(
        cachedRoute is Map
            ? Map<String, dynamic>.from(cachedRoute)
            : {
                'trekkingRouteId': routeId,
                'trekkingPlaceId': placeId,
                'name':
                    journey['routeName'] ?? 'Tuyến đường không còn khả dụng',
              },
        cachedPlace is Map ? Map<String, dynamic>.from(cachedPlace) : {},
      );
    }
  }

  Future<void> syncPending() =>
      offline.sync(trekking: dio, checkin: checkinDio);

  Future<List<JourneyModel>> getJourneys() async {
    final owner = await offline.requireOwner();
    try {
      await syncPending();
      final journeys = <Map<String, dynamic>>[];
      var page = 1;
      while (true) {
        final response = await dio.get(
          '/journeys',
          queryParameters: {'page': page, 'limit': 100},
          options: Options(extra: {'offlineOwner': owner}),
        );
        final data = response.data['data'] as Map;
        final batch = (data['items'] as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        journeys.addAll(batch);
        if (batch.isEmpty || journeys.length >= (data['total'] as num).toInt())
          break;
        page++;
      }
      if (await offline.requireOwner() != owner)
        throw StateError('Tài khoản đã thay đổi.');
      await offline.cacheJourneys(journeys, owner);
    } on DioException catch (e) {
      if (!OfflineStore.canUseCache(e)) rethrow;
    }
    final result = await Future.wait(
      (await offline.journeys(owner)).map((j) => parseJourney(j)),
    );
    if (await offline.requireOwner() != owner)
      throw StateError('Tài khoản đã thay đổi.');
    return result;
  }

  Future<JourneyModel> createJourney(
    Map<String, dynamic> body,
    RouteModel route,
  ) async {
    final owner = await offline.requireOwner();
    final id = await offline.createJourney(body);
    await syncPending();
    final failure = await offline.operationError(id);
    if (failure != null) throw StateError(failure);
    final json = Map<String, dynamic>.from(
      await offline.read('/journeys/$id', owner: owner) as Map,
    );
    return parseJourney(json, route: route);
  }

  Future<JourneyModel> getJourney(String id) async {
    final owner = await offline.requireOwner();
    await syncPending();
    var ref = id;
    try {
      ref = await offline.localJourneyId(id);
    } on StateError {
      // A server journey can also be opened before the list has been loaded.
    }
    var snapshot = await offline.read('/journeys/$ref', owner: owner);
    final serverId = snapshot is Map
        ? snapshot['serverJourneyId'] ??
              ((snapshot['offlineSyncStatus'] ?? 'SYNCED') == 'SYNCED'
                  ? snapshot['journeyId']
                  : null)
        : id;
    if (serverId != null &&
        RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(serverId.toString())) {
      try {
        final data = (await dio.get(
          '/journeys/$serverId',
          options: Options(extra: {'offlineOwner': owner}),
        )).data['data'];
        if (await offline.requireOwner() != owner)
          throw StateError('Tài khoản đã thay đổi.');
        await offline.cacheJourneys([
          Map<String, dynamic>.from(data as Map),
        ], owner);
        ref = await offline.localJourneyId(serverId.toString());
        snapshot = await offline.read('/journeys/$ref', owner: owner);
      } on DioException catch (e) {
        if (!OfflineStore.canUseCache(e) || snapshot == null) rethrow;
      }
    }
    if (snapshot is! Map)
      throw StateError('Không tìm thấy hành trình trên thiết bị.');
    final result = await parseJourney(Map<String, dynamic>.from(snapshot));
    if (await offline.requireOwner() != owner)
      throw StateError('Tài khoản đã thay đổi.');
    return result;
  }

  Future<JourneyStatus> transitionJourney(
    String journeyId,
    String action, {
    Map<String, dynamic> body = const {},
  }) async {
    final owner = await offline.requireOwner();
    final id = await offline.transition(journeyId, action, body: body);
    await syncPending();
    final failure = await offline.operationError(id);
    if (failure != null) throw StateError(failure);
    final ref = await offline.localJourneyId(journeyId);
    final data = await offline.read('/journeys/$ref', owner: owner) as Map;
    return JourneyStatus.values.firstWhere(
      (s) => s.name.toUpperCase() == data['status'],
    );
  }

  Future<Map<String, dynamic>> checkIn(
    String journeyId,
    Map<String, dynamic> body,
  ) async {
    final id = await offline.checkin(journeyId, body);
    final saved = (await offline.checkins(journeyId))
        .firstWhere((c) => c['clientCheckinId'] == id);
    _syncInBackground();
    return saved;
  }

  Future<void> completeJourneyAfterCheckin(String journeyId) async {
    await JourneyTrackingService.instance.flush();
    await offline.transition(journeyId, 'complete');
    _syncInBackground();
  }

  void _syncInBackground() {
    unawaited(
      syncPending().catchError((Object e) {
        debugPrint('[OfflineSync] $e');
      }),
    );
  }

  Future<List<Map<String, dynamic>>> getJourneyCheckins(
    String journeyId,
  ) async {
    final owner = await offline.requireOwner();
    final ref = await offline.localJourneyId(journeyId);
    final snapshot = await offline.read('/journeys/$ref', owner: owner) as Map;
    final serverId =
        snapshot['serverJourneyId'] ??
        ((snapshot['offlineSyncStatus'] ?? 'SYNCED') == 'SYNCED'
            ? snapshot['journeyId']
            : null);
    if (serverId != null) {
      try {
        final data =
            (await checkinDio.get('/checkins/journeys/$serverId')).data['data']
                as List;
        await offline.cacheCheckins(journeyId, data);
      } on DioException catch (e) {
        if (!OfflineStore.canUseCache(e)) rethrow;
      }
    }
    return offline.checkins(journeyId);
  }

  static RouteModel parseRoute(
    Map<String, dynamic> json,
    Map<String, dynamic> place,
  ) {
    return RouteModel.fromJson(json, place: place);
  }
}
