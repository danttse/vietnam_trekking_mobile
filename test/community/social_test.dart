import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:vietnam_trekking_mobile/core/services/auth_event_bus.dart';
import 'package:vietnam_trekking_mobile/features/community/data/datasources/social_api.dart';
import 'package:vietnam_trekking_mobile/features/community/viewmodels/conversation_view_model.dart';
import 'package:vietnam_trekking_mobile/features/community/viewmodels/social_view_model.dart';
import 'package:vietnam_trekking_mobile/features/community/views/community_people.dart';
import 'package:vietnam_trekking_mobile/features/community/views/community_messages.dart';

const alice = '507f1f77bcf86cd799439011';
const bob = '507f1f77bcf86cd799439012';
const chatId = '507f1f77bcf86cd799439021';
final me = <String, dynamic>{
  'userId': alice,
  'name': 'Lan',
  'avatarUrl': null,
  'bio': 'Yêu thiên nhiên',
  'postCount': 0,
  'isMe': true,
  'qr': 'trekviet://community/user/${'a' * 48}',
};
final chat = <String, dynamic>{
  'conversationId': chatId,
  'kind': 'DIRECT',
  'name': '',
  'ownerId': alice,
  'members': [
    {'userId': alice, 'name': 'Lan', 'avatarUrl': null},
    {'userId': bob, 'name': 'Minh', 'avatarUrl': null},
  ],
  'sequence': 2,
  'readSequence': 0,
  'unreadCount': 1,
  'disabled': false,
  'lastMessageAt': '2026-10-29T00:00:00Z',
};
Map<String, dynamic> msg(int seq, {bool deleted = false}) => {
  'messageId': 'message_$seq',
  'conversationId': chatId,
  'senderId': bob,
  'sequence': seq,
  'clientMessageId': 'client_$seq',
  'content': deleted ? '' : 'Tin nhắn $seq',
  'deleted': deleted,
  'createdAt': '2026-10-29T00:00:00Z',
};

class Adapter implements HttpClientAdapter {
  final FutureOr<Map<String, dynamic>> Function(RequestOptions) handle;
  Adapter(this.handle);
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? body,
    Future<void>? cancel,
  ) async => ResponseBody.fromString(
    jsonEncode({'success': true, 'data': await handle(options)}),
    200,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
  @override
  void close({bool force = false}) {}
}

SocialApi api(
  FutureOr<Map<String, dynamic>> Function(RequestOptions) handler,
) => SocialApi(
  Dio(BaseOptions(baseUrl: 'https://fixture.invalid/api/v1'))
    ..httpClientAdapter = Adapter(handler),
);
Map<String, dynamic> fallback(RequestOptions r) {
  if (r.path == '/posts') {
    return {'items': [], 'total': 0, 'page': 1, 'limit': 20, 'totalPages': 0};
  }
  if (r.path.contains('/people/')) return {...me};
  if (r.path.endsWith('/messages')) {
    return {
      'items': [msg(2), msg(1)],
      'nextBefore': null,
    };
  }
  if (r.path == '/community/conversations') {
    return {
      'items': [chat],
      'total': 1,
      'page': 1,
      'limit': 30,
      'totalPages': 1,
    };
  }
  return {...chat};
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'group creation selects discovered users and submits selected IDs',
    (tester) async {
      String? createdId;
      RequestOptions? sent;
      final client = api((r) {
        if (r.path.endsWith('/discover')) {
          return {...me, 'userId': bob, 'isMe': false, 'name': 'Minh'};
        }
        if (r.path.endsWith('/groups')) {
          sent = r;
          return {...chat, 'kind': 'GROUP'};
        }
        return fallback(r);
      });
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  createdId = await Navigator.push<String>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CreateGroupScreen(api: client),
                    ),
                  );
                },
                child: const Text('Mở tạo nhóm'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Mở tạo nhóm'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Trekking cuối tuần');
      await tester.tap(find.text('Thêm bằng email / QR'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'minh@example.com');
      await tester.tap(find.text('Tìm kiếm'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Minh'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tạo nhóm').last);
      await tester.pumpAndSettle();
      expect(sent?.data, {
        'name': 'Trekking cuối tuần',
        'memberIds': [bob],
      });
      expect(createdId, chatId);
    },
  );
  testWidgets('profile discards its pending response on logout', (
    tester,
  ) async {
    final pending = Completer<Map<String, dynamic>>();
    var postRequests = 0;
    final client = api((r) {
      if (r.path == '/posts') {
        postRequests++;
        return fallback(r);
      }
      return pending.future;
    });
    await tester.pumpWidget(
      MaterialApp(
        home: CommunityProfileScreen(api: client, realtimeEnabled: false),
      ),
    );
    await tester.pump();
    AuthEventBus().fire(AuthEvent.loggedOut);
    await tester.pump();
    pending.complete(me);
    await tester.pumpAndSettle();
    expect(find.text('Lan'), findsNothing);
    expect(postRequests, 0);
  });
  test('chat maps ordered history, marks read and paginates with the exclusive cursor', () async {
    final seen = <RequestOptions>[];
    final vm = ConversationViewModel(
      id: chatId,
      realtime: false,
      autoLoad: false,
      api: api((r) {
        seen.add(r);
        if (r.path.endsWith('/messages')) {
          return r.queryParameters['before'] == null
              ? {
                  'items': [msg(2)],
                  'nextBefore': 2,
                }
              : {
                  'items': [msg(1)],
                  'nextBefore': null,
                };
        }
        return fallback(r);
      }),
    );
    addTearDown(vm.dispose);
    await vm.load();
    expect(vm.messages.single['sequence'], 2);
    expect(seen.singleWhere((r) => r.path.endsWith('/read')).data, {
      'sequence': 2,
    });
    await vm.load(older: true);
    expect(vm.messages.map((m) => m['sequence']), [1, 2]);
    expect(
      seen
          .lastWhere((r) => r.path.endsWith('/messages'))
          .queryParameters['before'],
      2,
    );
  });
  test('failed sends retain the same client key on retry', () async {
    final keys = <String>[];
    final vm = ConversationViewModel(
      id: chatId,
      realtime: false,
      autoLoad: false,
      api: api((r) {
        if (r.method == 'POST' && r.path.endsWith('/messages')) {
          keys.add((r.data as Map)['clientMessageId'] as String);
          if (keys.length == 1) {
            throw DioException.connectionTimeout(
              timeout: const Duration(seconds: 1),
              requestOptions: r,
            );
          }
          return msg(3);
        }
        return fallback(r);
      }),
    );
    addTearDown(vm.dispose);
    await vm.load();
    expect(await vm.send('  Chào Minh  '), false);
    expect(vm.sendError, isNotNull);
    expect(await vm.send('  Chào Minh  '), true);
    expect(keys[0], keys[1]);
  });
  test(
    'logout discards an in-flight chat response and cached messages',
    () async {
      final pending = Completer<Map<String, dynamic>>();
      final vm = ConversationViewModel(
        id: chatId,
        realtime: false,
        autoLoad: false,
        api: api(
          (r) => r.path.endsWith('/messages') ? pending.future : fallback(r),
        ),
      );
      addTearDown(vm.dispose);
      final load = vm.load();
      await Future<void>.delayed(const Duration(milliseconds: 20));
      AuthEventBus().fire(AuthEvent.loggedOut);
      await Future<void>.delayed(Duration.zero);
      pending.complete({
        'items': [msg(2)],
        'nextBefore': null,
      });
      await load;
      expect(vm.messages, isEmpty);
      expect(vm.conversation, isNull);
      expect(vm.ownerId, isNull);
    },
  );
  test('silent invalidation refreshes tombstones in loaded history', () async {
    var deleted = false;
    final vm = ConversationViewModel(
      id: chatId,
      realtime: false,
      autoLoad: false,
      api: api(
        (r) => r.path.endsWith('/messages')
            ? {
                'items': [msg(2), msg(1, deleted: deleted)],
                'nextBefore': null,
              }
            : fallback(r),
      ),
    );
    addTearDown(vm.dispose);
    await vm.load();
    deleted = true;
    await vm.load(silent: true);
    expect(vm.messages.first['deleted'], true);
    expect(vm.messages.first['content'], '');
  });
  testWidgets(
    'email search sends exact query and displays server profile without mocks',
    (tester) async {
      RequestOptions? request;
      await tester.pumpWidget(
        MaterialApp(
          home: PeopleSearchScreen(
            api: api((r) {
              request = r;
              return {...me, 'isMe': false, 'name': 'Minh'};
            }),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), 'minh@example.com');
      await tester.tap(find.text('Tìm kiếm'));
      await tester.pumpAndSettle();
      expect(request!.queryParameters, {'email': 'minh@example.com'});
      expect(find.text('Minh'), findsOneWidget);
      expect(find.text('Quét QR'), findsOneWidget);
    },
  );
  testWidgets(
    'own profile shows managed QR and public profile shows message action',
    (tester) async {
      final client = api(fallback);
      await tester.pumpWidget(
        MaterialApp(
          home: CommunityProfileScreen(api: client, realtimeEnabled: false),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Giới thiệu'), findsOneWidget);
      expect(find.text('Cấp lại QR'), findsOneWidget);
      await tester.tap(find.text('QR của tôi'));
      await tester.pumpAndSettle();
      expect(find.byType(QrImageView), findsOneWidget);
      await tester.tap(find.text('Đóng'));
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(
        MaterialApp(
          home: CommunityProfileScreen(
            realtimeEnabled: false,
            userId: bob,
            api: api(
              (r) => r.path == '/posts'
                  ? fallback(r)
                  : {
                      ...me,
                      'userId': bob,
                      'isMe': false,
                      'name': 'Minh',
                      'qr': null,
                    },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Nhắn tin'), findsOneWidget);
      expect(find.text('QR của tôi'), findsNothing);
    },
  );
  testWidgets('conversation composer fits small width and keeps failed draft', (
    tester,
  ) async {
    tester.view.resetPhysicalSize();
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final vm = ConversationViewModel(
      id: chatId,
      realtime: false,
      autoLoad: false,
      api: api((r) {
        if (r.method == 'POST' && r.path.endsWith('/messages')) {
          throw DioException.connectionTimeout(
            timeout: const Duration(seconds: 1),
            requestOptions: r,
          );
        }
        return fallback(r);
      }),
    );
    addTearDown(vm.dispose);
    await tester.runAsync(() => vm.load());
    await tester.pumpWidget(
      MaterialApp(
        home: ConversationScreen(conversationId: chatId, viewModel: vm),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Giữ bản nháp');
    await tester.tap(find.byTooltip('Gửi tin nhắn'));
    await tester.pumpAndSettle();
    expect(find.text('Giữ bản nháp'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('messages list displays unread and new group controls', (
    tester,
  ) async {
    final vm = SocialViewModel(
      api: api(fallback),
      realtime: false,
      autoLoad: false,
    );
    addTearDown(vm.dispose);
    await tester.runAsync(() => vm.load());
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: CommunityMessages(model: vm)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Minh'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.byTooltip('Tạo nhóm'), findsOneWidget);
  });
}
