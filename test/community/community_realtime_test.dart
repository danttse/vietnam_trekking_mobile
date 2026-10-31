import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:vietnam_trekking_mobile/core/services/token_storage.dart';
import 'package:vietnam_trekking_mobile/features/community/data/datasources/community_realtime.dart';

class MemoryTokens implements TokenStorage {
  String? token = 'first-access';
  @override
  Future<String?> getAccessToken() async => token;
  @override
  Future<String?> getRefreshToken() async => null;
  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    token = accessToken;
  }

  @override
  Future<void> clearTokens() async {
    token = null;
  }
}

void main() {
  late HttpServer server;
  final sockets = <WebSocket>[];
  late MemoryTokens tokens;
  CommunityRealtime? realtime;
  setUp(() async {
    tokens = MemoryTokens();
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  });
  tearDown(() async {
    realtime?.dispose();
    realtime = null;
    for (final socket in sockets) {
      await socket.close();
    }
    sockets.clear();
    await server.close(force: true);
  });
  String baseUrl() => 'http://127.0.0.1:${server.port}/api/v1';

  test('authenticates with first frame, ignores malformed events and reconnects with current token', () async {
    var connections = 0;
    final received = <String>[];
    final firstReady = Completer<void>(), secondReady = Completer<void>();
    server.listen((request) async {
      expect(request.uri.toString(), '/api/v1/community/ws');
      final socket = await WebSocketTransformer.upgrade(request);
      sockets.add(socket);
      connections++;
      socket.listen((raw) {
        received.add((jsonDecode(raw as String) as Map)['token'] as String);
        socket.add('[]');
        socket.add('not-json');
        socket.add('{"type":"ready"}');
      });
    });
    realtime = CommunityRealtime(
      baseUrl: baseUrl(),
      tokens: tokens,
      observeLifecycle: false,
      retryDelay: const Duration(milliseconds: 20),
      onEvent: (event) {
        if (event['type'] == 'ready') {
          if (!firstReady.isCompleted) {
            firstReady.complete();
          } else if (!secondReady.isCompleted) {
            secondReady.complete();
          }
        }
      },
    );
    await Future.wait([realtime!.connect(), realtime!.connect()]);
    await firstReady.future.timeout(const Duration(seconds: 3));
    expect(connections, 1);
    tokens.token = 'refreshed-access';
    await sockets.first.close(4401, 'Expired');
    await secondReady.future.timeout(const Duration(seconds: 3));
    expect(received, ['first-access', 'refreshed-access']);
  });

  test(
    'suspend/resume refetches through ready and dispose stops reconnecting',
    () async {
      final first = Completer<void>(), resumed = Completer<void>();
      var connections = 0;
      server.listen((request) async {
        final socket = await WebSocketTransformer.upgrade(request);
        sockets.add(socket);
        connections++;
        socket.listen((_) => socket.add('{"type":"ready"}'));
      });
      realtime = CommunityRealtime(
        baseUrl: baseUrl(),
        tokens: tokens,
        observeLifecycle: false,
        retryDelay: const Duration(milliseconds: 20),
        onEvent: (event) {
          if (event['type'] != 'ready') return;
          if (!first.isCompleted) {
            first.complete();
          } else if (!resumed.isCompleted) {
            resumed.complete();
          }
        },
      );
      await realtime!.connect();
      await first.future.timeout(const Duration(seconds: 3));
      realtime!.suspend();
      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(connections, 1);
      realtime!.resume();
      await resumed.future.timeout(const Duration(seconds: 3));
      expect(connections, 2);
      realtime!.dispose();
      await sockets.last.close();
      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(connections, 2);
    },
  );
}
