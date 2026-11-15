import 'package:dio/dio.dart';

import 'community_remote_datasource.dart';

typedef Json = Map<String, dynamic>;

class SocialApi {
  final Dio dio;
  SocialApi([Dio? client]) : dio = client ?? CommunityRemoteDataSource().dio;
  Future<Json> get(String path, [Json? query]) async =>
      Map<String, dynamic>.from(
        (await dio.get('/community$path', queryParameters: query)).data['data']
            as Map,
      );
  Future<Json> post(String path, [Json? body]) async =>
      Map<String, dynamic>.from(
        (await dio.post('/community$path', data: body ?? {})).data['data']
            as Map,
      );
  Future<Json> patch(String path, Json body) async => Map<String, dynamic>.from(
    (await dio.patch('/community$path', data: body)).data['data'] as Map,
  );
  Future<void> delete(String path) async {
    await dio.delete('/community$path');
  }
}
