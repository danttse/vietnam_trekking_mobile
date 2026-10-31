import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:vietnam_trekking_mobile/core/services/auth_event_bus.dart';
import 'package:vietnam_trekking_mobile/features/community/data/datasources/community_attachment_datasource.dart';
import 'package:vietnam_trekking_mobile/features/community/data/models/post_model.dart';
import 'package:vietnam_trekking_mobile/features/community/viewmodels/create_new_post_viewmodel.dart';
import 'package:vietnam_trekking_mobile/features/community/viewmodels/community_view_model.dart';
import 'package:vietnam_trekking_mobile/features/community/viewmodels/comment_viewmodel.dart';

import 'community_api_test.dart' show source, post, page, comment;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('composer shares a server journey privately and automatically uses its place', () async {
    final vm = CreateNewPostViewModel(
      dataSource: source((r) {
        expect(r.data, containsPair('type', 'JOURNEY_SHARE'));
        expect(r.data, containsPair('journeyId', 'journey-server'));
        expect(r.data, containsPair('trekkingPlaceId', 'place-server'));
        expect(r.data, containsPair('visibility', 'PRIVATE'));
        return {
          'data': {
            ...post('created'),
            ...Map<String, dynamic>.from(r.data as Map),
          },
        };
      }),
    );
    addTearDown(vm.dispose);
    vm.selectJourney(
      const CommunityAttachment(
        id: 'journey-server',
        name: 'Fansipan',
        placeId: 'place-server',
      ),
    );
    vm.setVisibility('PRIVATE');
    vm.contentController.text = 'Chuyến đi của tôi';
    expect((await vm.submitPost())!.journeyId, 'journey-server');
  });

  test('editing preserves image URLs and does not resend unchanged attachment fields', () async {
    final existing = PostModel.fromJson({
      ...post('existing'),
      'type': 'JOURNEY_SHARE',
      'journeyId': 'j',
      'trekkingPlaceId': 'p',
    });
    final vm = CreateNewPostViewModel(
      editingPost: existing,
      dataSource: source((r) {
        expect(r.method, 'PUT');
        expect(r.path, '/posts/existing');
        expect(r.data['images'], existing.images);
        expect(r.data.containsKey('journeyId'), isFalse);
        expect(r.data.containsKey('trekkingPlaceId'), isFalse);
        expect(r.data.containsKey('type'), isFalse);
        return {
          'data': {...post('existing'), 'content': r.data['content']},
        };
      }),
    );
    addTearDown(vm.dispose);
    vm.contentController.text = 'Nội dung đã sửa';
    expect((await vm.submitPost())!.content, 'Nội dung đã sửa');
  });

  test(
    'removing journey resets type and explicitly clears both links',
    () async {
      final existing = PostModel.fromJson({
        ...post('existing'),
        'type': 'JOURNEY_SHARE',
        'journeyId': 'j',
        'trekkingPlaceId': 'p',
      });
      final vm = CreateNewPostViewModel(
        editingPost: existing,
        dataSource: source((r) {
          expect(r.data, containsPair('journeyId', null));
          expect(r.data, containsPair('trekkingPlaceId', null));
          expect(r.data, containsPair('type', 'NORMAL'));
          return {'data': post('existing')};
        }),
      );
      addTearDown(vm.dispose);
      vm.selectJourney(null);
      await vm.submitPost();
    },
  );

  test(
    'image-only post cannot be saved after all images are removed',
    () async {
      final vm = CreateNewPostViewModel(
        editingPost: PostModel.fromJson({...post('p'), 'content': ''}),
        dataSource: source(
          (_) => throw StateError('Should not send invalid draft'),
        ),
      );
      addTearDown(vm.dispose);
      vm.removeExistingImage(0);
      expect(await vm.submitPost(), isNull);
      expect(vm.errorMessage, isNotNull);
    },
  );

  test('hide author filters every current and subsequently fetched post, with undo', () async {
    var extra = false;
    final vm = CommunityViewModel(
      dataSource: source(
        (_) => page([
          post('a'),
          {...post('b'), 'authorId': 'other'},
          if (extra) post('c'),
        ]),
      ),
      ownerProvider: () async => 'owner',
      realtimeEnabled: false,
      autoLoad: false,
    );
    addTearDown(vm.dispose);
    await vm.loadPosts();
    vm.hideAuthor('owner');
    extra = true;
    await vm.loadPosts(silent: true);
    expect(vm.posts.map((p) => p.postId), ['b']);
    vm.unhideAuthor('owner');
    expect(vm.posts, hasLength(3));
  });

  test('failed reaction preserves feed and exposes an action error', () async {
    final vm = CommunityViewModel(
      dataSource: source(
        (r) => r.method == 'POST'
            ? {
                '_status': 403,
                'error': {'message': 'Forbidden'},
              }
            : page([post('p')]),
      ),
      ownerProvider: () async => 'owner',
      realtimeEnabled: false,
      autoLoad: false,
    );
    addTearDown(vm.dispose);
    await vm.loadPosts();
    await vm.toggleLike('p');
    expect(vm.posts.single.postId, 'p');
    expect(vm.error, isNull);
    expect(vm.actionError, isNotNull);
  });

  test(
    'post author can delete, but cannot edit, another user comment',
    () async {
      var deleted = false;
      final vm = CommentViewModel(
        postId: 'post',
        postAuthorId: 'owner',
        ownerProvider: () async => 'owner',
        realtimeEnabled: false,
        autoLoad: false,
        dataSource: source((r) {
          if (r.method == 'DELETE') {
            deleted = true;
            return {'success': true};
          }
          return page([
            {
              ...comment('c', deleted: deleted),
              'authorId': deleted ? null : 'other',
            },
          ]);
        }),
      );
      addTearDown(vm.dispose);
      await vm.loadComments();
      final item = vm.comments.single;
      expect(vm.canEdit(item), isFalse);
      expect(vm.canDelete(item), isTrue);
      expect(await vm.editComment(item, 'hijack'), isFalse);
      expect(await vm.deleteComment(item), isTrue);
      expect(vm.comments.single.deleted, isTrue);
    },
  );

  test(
    'editing own comment persists new content and retains its thread',
    () async {
      var content = 'before';
      final vm = CommentViewModel(
        postId: 'post',
        ownerProvider: () async => 'owner',
        realtimeEnabled: false,
        autoLoad: false,
        dataSource: source((r) {
          if (r.method == 'PUT') {
            content = r.data['content'] as String;
            return {
              'data': {...comment('c'), 'content': content},
            };
          }
          return page([
            {...comment('c'), 'content': content},
          ]);
        }),
      );
      addTearDown(vm.dispose);
      await vm.loadComments();
      expect(await vm.editComment(vm.comments.single, '  after  '), isTrue);
      expect(vm.threads.single.rootComment.content, 'after');
    },
  );

  test(
    'logout invalidates an in-flight owner lookup before any feed request',
    () async {
      final owner = Completer<String?>();
      var calls = 0;
      final vm = CommunityViewModel(
        dataSource: source((_) {
          calls++;
          return page([post('p')]);
        }),
        ownerProvider: () => owner.future,
        realtimeEnabled: false,
        autoLoad: false,
      );
      addTearDown(vm.dispose);
      final load = vm.loadPosts();
      AuthEventBus().fire(AuthEvent.loggedOut);
      await Future<void>.delayed(Duration.zero);
      owner.complete('owner');
      await load;
      expect(calls, 0);
      expect(vm.posts, isEmpty);
      expect(vm.isLoading, isFalse);
    },
  );

  test(
    'late comment send after logout cannot restore text, threads or identities',
    () async {
      final response = Completer<Map<String, dynamic>>();
      final vm = CommentViewModel(
        postId: 'post',
        ownerProvider: () async => 'owner',
        realtimeEnabled: false,
        autoLoad: false,
        dataSource: source(
          (r) => r.method == 'POST' ? response.future : page([]),
        ),
      );
      addTearDown(vm.dispose);
      await vm.loadComments();
      vm.textController.text = 'draft';
      final sending = vm.sendComment();
      await Future<void>.delayed(Duration.zero);
      AuthEventBus().fire(AuthEvent.loggedOut);
      await Future<void>.delayed(Duration.zero);
      response.complete({'data': comment('late')});
      await sending;
      expect(vm.textController.text, isEmpty);
      expect(vm.comments, isEmpty);
    },
  );

  test('attachment picker reads paginated server records and only sends place search to catalog', () async {
    final queries = <Map<String, dynamic>>[];
    final api = source((r) {
      queries.add(r.queryParameters);
      return page([
        r.path == '/journeys'
            ? {'journeyId': 'j', 'name': 'Trip', 'trekkingPlaceId': 'p'}
            : {'trekkingPlaceId': 'p', 'name': 'Fansipan'},
      ]);
    });
    final attachments = CommunityAttachmentDataSource(api.dio);
    expect(
      (await attachments.load(
        journeys: false,
        query: ' Fansipan ',
      )).items.single.id,
      'p',
    );
    expect(queries.last['q'], 'Fansipan');
    expect(
      (await attachments.load(
        journeys: true,
        query: 'ignored',
      )).items.single.placeId,
      'p',
    );
    expect(queries.last.containsKey('q'), isFalse);
  });
}
