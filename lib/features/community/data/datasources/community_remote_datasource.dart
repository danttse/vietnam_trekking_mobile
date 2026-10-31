import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/services/auth_event_bus.dart';
import '../../../../core/services/token_storage.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';

class CommunityRemoteDataSource {
  final Dio dio;

  CommunityRemoteDataSource([Dio? client])
    : dio =
          client ??
          DioClient.createCommunityDio(
            tokenStorage: const SecureTokenStorage(),
            eventBus: AuthEventBus(),
          );

  Future<PaginatedPostsResponse> getPosts({
    int page = 1,
    int limit = 20,
    String? userId,
    String? type,
  }) async {
    final response = await dio.get(
      '/posts',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (userId != null) 'userId': userId,
        if (type != null) 'type': type,
      },
    );
    return PaginatedPostsResponse.fromJson(_unwrap(response.data));
  }

  Future<PostModel> getPost(String id) async =>
      PostModel.fromJson(_unwrap((await dio.get('/posts/$id')).data));

  Future<PostModel> createPost({
    required String content,
    String type = 'NORMAL',
    String? journeyId,
    String? trekkingPlaceId,
    List<String> images = const [],
    String visibility = 'PUBLIC',
  }) async => PostModel.fromJson(
    _unwrap(
      (await dio.post(
        '/posts',
        data: {
          'content': content,
          'type': type,
          'images': images,
          'visibility': visibility,
          if (journeyId != null) 'journeyId': journeyId,
          if (trekkingPlaceId != null) 'trekkingPlaceId': trekkingPlaceId,
        },
      )).data,
    ),
  );

  Future<PostModel> updatePost(
    String id,
    String content, {
    List<String>? images,
    String? visibility,
    String? type,
    // Null explicitly clears an attachment when replaceLinks is true.
    bool replaceLinks = false,
    String? journeyId,
    String? trekkingPlaceId,
  }) async => PostModel.fromJson(
    _unwrap(
      (await dio.put(
        '/posts/$id',
        data: {
          'content': content,
          if (images != null) 'images': images,
          if (visibility != null) 'visibility': visibility,
          if (type != null) 'type': type,
          if (replaceLinks) 'journeyId': journeyId,
          if (replaceLinks) 'trekkingPlaceId': trekkingPlaceId,
        },
      )).data,
    ),
  );

  Future<void> deletePost(String id) async {
    await dio.delete('/posts/$id');
  }

  Future<void> likePost(String id) async {
    await dio.post('/posts/$id/like');
  }

  Future<void> unlikePost(String id) async {
    await dio.delete('/posts/$id/like');
  }

  Future<CommentPage> getComments(
    String postId, {
    int page = 1,
    int limit = 100,
  }) async {
    final data = _unwrap(
      (await dio.get(
        '/posts/$postId/comments',
        queryParameters: {'page': page, 'limit': limit},
      )).data,
    );
    return CommentPage(
      (data['items'] as List)
          .map(
            (e) => CommentModel.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList(),
      (data['totalPages'] as num).toInt(),
    );
  }

  Future<CommentModel> createComment({
    required String postId,
    required String content,
    String? parentCommentId,
  }) async => CommentModel.fromJson(
    _unwrap(
      (await dio.post(
        '/posts/$postId/comments',
        data: {
          'content': content,
          if (parentCommentId != null) 'parentCommentId': parentCommentId,
        },
      )).data,
    ),
  );

  Future<CommentModel> updateComment(String id, String content) async =>
      CommentModel.fromJson(
        _unwrap(
          (await dio.put('/comments/$id', data: {'content': content})).data,
        ),
      );
  Future<void> deleteComment(String id) async {
    await dio.delete('/comments/$id');
  }

  Future<void> likeComment(String id) async {
    await dio.post('/comments/$id/like');
  }

  Future<void> unlikeComment(String id) async {
    await dio.delete('/comments/$id/like');
  }

  Map<String, dynamic> _unwrap(dynamic value) =>
      Map<String, dynamic>.from((value as Map)['data'] as Map);
}

class CommentPage {
  final List<CommentModel> items;
  final int totalPages;
  const CommentPage(this.items, this.totalPages);
}

class PaginatedPostsResponse {
  final List<PostModel> items;
  final int total, page, limit, totalPages;
  const PaginatedPostsResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });
  factory PaginatedPostsResponse.fromJson(Map<String, dynamic> json) =>
      PaginatedPostsResponse(
        items: (json['items'] as List)
            .map((e) => PostModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        total: (json['total'] as num).toInt(),
        page: (json['page'] as num).toInt(),
        limit: (json['limit'] as num).toInt(),
        totalPages: (json['totalPages'] as num).toInt(),
      );
}
