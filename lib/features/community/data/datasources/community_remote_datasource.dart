import 'package:dio/dio.dart';
import '../models/post_model.dart';

/// Remote datasource for Community Service API calls.
/// 
/// ⚠️ NOTE: Community Service backend is NOT YET IMPLEMENTED.
/// This datasource is prepared for future integration.
/// Until backend is ready, use PostSampleData and CommentSampleData as fallback.
class CommunityRemoteDataSource {
  final Dio _dio;

  const CommunityRemoteDataSource(this._dio);

  // ── POSTS ─────────────────────────────────────────────────────────────────

  /// GET /posts
  /// List community posts with pagination and optional filters
  Future<PaginatedPostsResponse> getPosts({
    int page = 1,
    int limit = 20,
    String? userId,
    String? type, // 'JOURNEY_SHARE' | 'BADGE_SHARE' | 'GENERAL'
  }) async {
    final resp = await _dio.get(
      '/posts',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (userId != null) 'userId': userId,
        if (type != null) 'type': type,
      },
    );
    return PaginatedPostsResponse.fromJson(_unwrap(resp.data));
  }

  /// GET /posts/:id
  /// Get single post details
  /// 
  /// TODO: Add fromJson to PostModel when backend is ready
  Future<dynamic> getPost(String postId) async {
    final resp = await _dio.get('/posts/$postId');
    return _unwrap(resp.data);
  }

  /// POST /posts
  /// Create a new post
  /// 
  /// TODO: Add fromJson to PostModel when backend is ready
  Future<dynamic> createPost({
    required String content,
    String? type,
    String? journeyId,
    List<String>? images,
  }) async {
    final resp = await _dio.post(
      '/posts',
      data: {
        'content': content,
        if (type != null) 'type': type,
        if (journeyId != null) 'journeyId': journeyId,
        if (images != null && images.isNotEmpty) 'images': images,
      },
    );
    return _unwrap(resp.data);
  }

  /// PUT /posts/:id
  /// Update post content
  /// 
  /// TODO: Add fromJson to PostModel when backend is ready
  Future<dynamic> updatePost(String postId, String content) async {
    final resp = await _dio.put(
      '/posts/$postId',
      data: {'content': content},
    );
    return _unwrap(resp.data);
  }

  /// DELETE /posts/:id
  /// Delete a post (soft delete)
  Future<void> deletePost(String postId) async {
    await _dio.delete('/posts/$postId');
  }

  /// POST /posts/:id/like
  /// Like a post (toggle)
  Future<void> likePost(String postId) async {
    await _dio.post('/posts/$postId/like');
  }

  /// DELETE /posts/:id/like
  /// Unlike a post
  Future<void> unlikePost(String postId) async {
    await _dio.delete('/posts/$postId/like');
  }

  // ── COMMENTS ──────────────────────────────────────────────────────────────

  /// GET /posts/:postId/comments
  /// Get comments for a post
  /// 
  /// TODO: Add fromJson to CommentModel when backend is ready
  Future<List<dynamic>> getComments(String postId) async {
    final resp = await _dio.get('/posts/$postId/comments');
    return _unwrapList(resp.data);
  }

  /// POST /posts/:postId/comments
  /// Add a comment to a post
  /// 
  /// TODO: Add fromJson to CommentModel when backend is ready
  Future<dynamic> createComment({
    required String postId,
    required String content,
    String? parentCommentId, // For nested replies
  }) async {
    final resp = await _dio.post(
      '/posts/$postId/comments',
      data: {
        'content': content,
        if (parentCommentId != null) 'parentCommentId': parentCommentId,
      },
    );
    return _unwrap(resp.data);
  }

  /// PUT /comments/:commentId
  /// Update comment content
  /// 
  /// TODO: Add fromJson to CommentModel when backend is ready
  Future<dynamic> updateComment(String commentId, String content) async {
    final resp = await _dio.put(
      '/comments/$commentId',
      data: {'content': content},
    );
    return _unwrap(resp.data);
  }

  /// DELETE /comments/:commentId
  /// Delete a comment (soft delete)
  Future<void> deleteComment(String commentId) async {
    await _dio.delete('/comments/$commentId');
  }

  /// POST /comments/:commentId/like
  /// Like a comment (toggle)
  Future<void> likeComment(String commentId) async {
    await _dio.post('/comments/$commentId/like');
  }

  /// DELETE /comments/:commentId/like
  /// Unlike a comment
  Future<void> unlikeComment(String commentId) async {
    await _dio.delete('/comments/$commentId/like');
  }

  // ── HELPERS ───────────────────────────────────────────────────────────────

  Map<String, dynamic> _unwrap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['data'] as Map<String, dynamic>? ?? {};
    }
    return {};
  }

  List<Map<String, dynamic>> _unwrapList(dynamic data) {
    if (data is Map<String, dynamic>) {
      final items = data['data'];
      if (items is List) {
        return items.map((e) => e as Map<String, dynamic>).toList();
      }
      // Pagination response format
      if (items is Map<String, dynamic> && items.containsKey('items')) {
        final list = items['items'] as List?;
        if (list != null) {
          return list.map((e) => e as Map<String, dynamic>).toList();
        }
      }
    }
    return [];
  }
}

/// Paginated posts response
class PaginatedPostsResponse {
  final List<PostModel> items;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const PaginatedPostsResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory PaginatedPostsResponse.fromJson(Map<String, dynamic> json) {
    // TODO: Add fromJson to PostModel when backend is ready
    // For now, return empty list
    return PaginatedPostsResponse(
      items: [],
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
    );
  }
}
