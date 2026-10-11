import 'package:dio/dio.dart';

import '../network/dio_client.dart';
import '../models/rank_model.dart';
import '../models/xp_history_model.dart';
import 'auth_event_bus.dart';
import 'token_storage.dart';
import 'offline_store.dart';

class UserApiService {
  final bool cacheEnabled;
  final Dio auth;
  final Dio trekking;
  final Dio checkin;

  UserApiService({
    Dio? authClient,
    Dio? trekkingClient,
    Dio? checkinClient,
    this.cacheEnabled = true,
  }) : auth =
           authClient ??
           DioClient.createDio(
             tokenStorage: const SecureTokenStorage(),
             eventBus: AuthEventBus(),
           ),
       trekking =
           trekkingClient ??
           DioClient.createTrekkingDio(
             tokenStorage: const SecureTokenStorage(),
             eventBus: AuthEventBus(),
           ),
       checkin =
           checkinClient ??
           DioClient.createCheckinDio(
             tokenStorage: const SecureTokenStorage(),
             eventBus: AuthEventBus(),
           );

  Future<dynamic> _privateGet(Dio client, String path) async {
    if (!cacheEnabled) return (await client.get(path)).data['data'];
    final store = OfflineStore.instance;
    final owner = await store.ownerProvider();
    if (owner == null) return (await client.get(path)).data['data'];
    try {
      final data = (await client.get(path)).data['data'];
      if (await store.requireOwner() != owner) {
        throw StateError('Tài khoản đã thay đổi.');
      }
      await store.cache('/account$path', data, owner: owner);
      return data;
    } on DioException catch (e) {
      if (!OfflineStore.canUseCache(e)) rethrow;
      final data = await store.read('/account$path', owner: owner);
      if (data == null) rethrow;
      return data;
    }
  }

  Future<Map<String, dynamic>> getProfile() async =>
      Map<String, dynamic>.from((await _privateGet(auth, '/users/me')) as Map);

  Future<UserRankProfile> getRankProfile() async => UserRankProfile.fromJson(
    Map<String, dynamic>.from(
      (await _privateGet(auth, '/gamification/me')) as Map,
    ),
  );

  Future<RankProgress> getRankProgress() async => RankProgress.fromJson(
    Map<String, dynamic>.from(
      (await _privateGet(auth, '/gamification/me/progress')) as Map,
    ),
  );

  Future<List<RankDefinition>> getRanks() async =>
      ((await auth.get('/gamification/ranks')).data['data'] as List)
          .map(
            (rank) =>
                RankDefinition.fromJson(Map<String, dynamic>.from(rank as Map)),
          )
          .toList()
        ..sort((a, b) => a.level.compareTo(b.level));

  Future<XpHistoryPage> getXpHistory({String? cursor, int limit = 20}) async {
    final response = await auth.get(
      '/gamification/me/xp-history',
      queryParameters: {'limit': limit, if (cursor != null) 'cursor': cursor},
    );
    return XpHistoryPage.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<String> updateBio(String bio) async {
    final response = await auth.patch('/users/me/bio', data: {'bio': bio});
    return response.data['data']['bio'] as String? ?? '';
  }

  Future<String> uploadAvatar(String path) async {
    final body = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(path),
    });
    final response = await auth.post(
      '/users/me/avatar',
      data: body,
      options: Options(contentType: 'multipart/form-data'),
    );
    return response.data['data']['avatarUrl'] as String;
  }

  Future<Map<String, dynamic>> getStatistics() async =>
      Map<String, dynamic>.from(
        (await _privateGet(trekking, '/journeys/statistics')) as Map,
      );

  Future<Map<String, dynamic>> getProvinceVisits() async =>
      Map<String, dynamic>.from(
        await _privateGet(checkin, '/visits/provinces/me') as Map,
      );

  Future<List<Map<String, dynamic>>> getBadges() async {
    final badges = <Map<String, dynamic>>[];
    for (var page = 1; ; page++) {
      final data =
          (await trekking.get(
                '/badges',
                queryParameters: {'page': page, 'limit': 100},
              )).data['data']
              as Map;
      final items = (data['items'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      badges.addAll(items);
      if (items.isEmpty || badges.length >= (data['total'] as num)) {
        return badges;
      }
    }
  }

  Future<List<Map<String, dynamic>>> getEarnedBadges() async =>
      ((await _privateGet(trekking, '/badges/me')) as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

  Future<List<Map<String, dynamic>>> getRecentPlaces() async =>
      ((await _privateGet(checkin, '/visits/places/me/recent')) as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
}
