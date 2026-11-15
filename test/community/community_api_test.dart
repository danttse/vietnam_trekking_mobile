import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vietnam_trekking_mobile/features/community/data/datasources/community_remote_datasource.dart';
import 'package:vietnam_trekking_mobile/features/community/data/models/comment_model.dart';
import 'package:vietnam_trekking_mobile/features/community/viewmodels/community_view_model.dart';
import 'package:vietnam_trekking_mobile/features/community/viewmodels/comment_viewmodel.dart';
import 'package:vietnam_trekking_mobile/features/community/viewmodels/create_new_post_viewmodel.dart';

class CommunityAdapter implements HttpClientAdapter {
  final FutureOr<Map<String, dynamic>> Function(RequestOptions) handler;
  CommunityAdapter(this.handler);
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? stream,
    Future<void>? cancel,
  ) async {
    final data = await handler(options);
    final status = data.remove('_status') as int? ?? 200;
    return ResponseBody.fromString(
      jsonEncode(data),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

CommunityRemoteDataSource source(
  FutureOr<Map<String, dynamic>> Function(RequestOptions) handler,
) => CommunityRemoteDataSource(
  Dio(BaseOptions(baseUrl: 'https://fixture.invalid/api/v1'))
    ..httpClientAdapter = CommunityAdapter(handler),
);

Map<String, dynamic> post(String id, {bool liked = false}) => {
  'postId': id,
  'authorId': 'owner',
  'authorName': 'Lan',
  'content': 'Fansipan',
  'images': ['https://example.com/a.jpg'],
  'type': 'NORMAL',
  'reactionCount': liked ? 1 : 0,
  'commentCount': 0,
  'isLiked': liked,
  'visibility': 'PUBLIC',
  'createdAt': '2026-10-27T00:00:00Z',
};
Map<String, dynamic> page(
  List<Map<String, dynamic>> items, {
  int number = 1,
  int pages = 1,
}) => {
  'data': {
    'items': items,
    'total': items.length,
    'page': number,
    'limit': 20,
    'totalPages': pages,
  },
};
Map<String, dynamic> comment(
  String id, {
  String? parent,
  String? root,
  bool deleted = false,
}) => {
  'commentId': id,
  'postId': 'post',
  'authorId': deleted ? null : 'owner',
  'authorName': 'Lan',
  'content': deleted ? '' : 'Đẹp quá',
  'parentCommentId': parent,
  'rootCommentId': root,
  'deleted': deleted,
  'createdAt': '2026-10-27T00:00:00Z',
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'moderation tombstone keeps reply references and disables interaction',
    () {
      final hidden = CommentModel.fromJson({
        ...comment('hidden', parent: 'parent', root: 'root'),
        'hidden': true,
        'authorId': null,
        'content': '',
      });
      expect(hidden.content, 'Bình luận đã bị ẩn');
      expect(hidden.deleted, isTrue);
      expect(hidden.parentCommentId, 'parent');
      expect(hidden.rootCommentId, 'root');
      expect(hidden.userId, isEmpty);
      expect(
        CommentModel.fromJson({
          ...comment('gone', deleted: true),
          'hidden': true,
        }).content,
        'Bình luận đã bị xóa',
      );
    },
  );

  test(
    'feed parses backend posts and paginates without sample fallback',
    () async {
      final vm = CommunityViewModel(
        dataSource: source((r) {
          final number = r.queryParameters['page'] as int;
          return page([post('p$number')], number: number, pages: 2);
        }),
        ownerProvider: () async => 'owner',
        realtimeEnabled: false,
        autoLoad: false,
      );
      addTearDown(vm.dispose);
      await vm.loadPosts();
      expect(vm.posts.single.authorName, 'Lan');
      expect(vm.hasMore, isTrue);
      await vm.loadMore();
      expect(vm.posts.map((p) => p.postId), ['p1', 'p2']);
      expect(vm.hasMore, isFalse);
    },
  );

  test('personal tab uses authenticated owner and failed API shows error with no fake posts', () async {
    final queries = <Map<String, dynamic>>[];
    var fail = false;
    final vm = CommunityViewModel(
      dataSource: source((r) {
        queries.add(r.queryParameters);
        if (fail) {
          return {
            '_status': 503,
            'error': {'message': 'Unavailable'},
          };
        }
        return page([post('real-post')]);
      }),
      ownerProvider: () async => 'actual-user',
      realtimeEnabled: false,
      autoLoad: false,
    );
    addTearDown(vm.dispose);
    vm.setTab(2);
    await vm.loadPosts();
    expect(queries.last['userId'], 'actual-user');
    fail = true;
    await vm.loadPosts();
    expect(vm.posts, isEmpty);
    expect(vm.error, isNotNull);
  });

  test(
    'like/unlike persist desired state and refresh authoritative counters',
    () async {
      var liked = false;
      final methods = <String>[];
      final vm = CommunityViewModel(
        dataSource: source((r) {
          if (r.path.endsWith('/like')) {
            methods.add(r.method);
            liked = r.method == 'POST';
            return {'data': {}};
          }
          return page([post('real', liked: liked)]);
        }),
        ownerProvider: () async => 'owner',
        realtimeEnabled: false,
        autoLoad: false,
      );
      addTearDown(vm.dispose);
      await vm.loadPosts();
      await vm.toggleLike('real');
      expect(vm.posts.single.isLiked, isTrue);
      expect(vm.posts.single.reactionCount, 1);
      await vm.toggleLike('real');
      expect(methods, ['POST', 'DELETE']);
      expect(vm.posts.single.reactionCount, 0);
    },
  );

  test('comments read every page and preserve nested replies under deleted parents', () async {
    final vm = CommentViewModel(
      postId: 'post',
      ownerProvider: () async => 'owner',
      realtimeEnabled: false,
      autoLoad: false,
      dataSource: source((r) {
        if (r.queryParameters['page'] == 1) {
          return page([comment('root', deleted: true)], pages: 2);
        }
        return page(
          [comment('reply', parent: 'root', root: 'root')],
          number: 2,
          pages: 2,
        );
      }),
    );
    addTearDown(vm.dispose);
    await vm.loadComments();
    expect(vm.threads.single.rootComment.deleted, isTrue);
    expect(vm.threads.single.rootComment.content, 'Bình luận đã bị xóa');
    expect(vm.threads.single.replies.single.id, 'reply');
    vm.setReplyingTo(vm.threads.single.rootComment);
    expect(vm.replyingToComment, isNull);
  });

  test('failed comment submission retains the draft and never inserts a fake comment', () async {
    final vm = CommentViewModel(
      postId: 'post',
      ownerProvider: () async => 'owner',
      realtimeEnabled: false,
      autoLoad: false,
      dataSource: source(
        (r) => r.method == 'POST'
            ? {
                '_status': 403,
                'error': {'message': 'Forbidden'},
              }
            : page([]),
      ),
    );
    addTearDown(vm.dispose);
    await vm.loadComments();
    vm.textController.text = 'Giữ bản nháp';
    await vm.sendComment();
    expect(vm.textController.text, 'Giữ bản nháp');
    expect(vm.comments, isEmpty);
    expect(vm.actionError, isNotNull);
  });

  test('composer sends content and uses server identity/id instead of mock identity', () async {
    final vm = CreateNewPostViewModel(
      dataSource: source((r) {
        expect(r.path, '/posts');
        expect(r.data['content'], 'Chuyến đi mới');
        expect(r.data.containsKey('authorId'), isFalse);
        expect(r.data.containsKey('trekkingPlaceId'), isFalse);
        return {'data': post('server-id')};
      }),
    );
    addTearDown(vm.dispose);
    vm.contentController.text = '  Chuyến đi mới  ';
    final created = await vm.submitPost();
    expect(created!.postId, 'server-id');
    expect(created.authorId, 'owner');
  });

  test(
    'late feed responses after dispose cannot notify or replace state',
    () async {
      final pending = Completer<Map<String, dynamic>>();
      final vm = CommunityViewModel(
        dataSource: source((_) => pending.future),
        ownerProvider: () async => 'owner',
        realtimeEnabled: false,
        autoLoad: false,
      );
      final load = vm.loadPosts();
      vm.dispose();
      pending.complete(page([post('late')]));
      await load;
      expect(vm.posts, isEmpty);
    },
  );
}
