import 'dart:convert';
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vietnam_trekking_mobile/core/network/interceptors/token_interceptor.dart';
import 'package:vietnam_trekking_mobile/core/services/auth_event_bus.dart';
import 'package:vietnam_trekking_mobile/core/services/offline_store.dart';
import 'package:vietnam_trekking_mobile/core/services/token_storage.dart';
import 'package:vietnam_trekking_mobile/features/auth/views/session_gate.dart';

import 'offline_store_test.dart' show TestAdapter, reply;

class MemoryTokens implements TokenStorage {
  String? access, refresh;
  int clears = 0;
  MemoryTokens(this.access, this.refresh);
  @override
  Future<String?> getAccessToken() async => access;
  @override
  Future<String?> getRefreshToken() async => refresh;
  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    access = accessToken;
    refresh = refreshToken;
  }

  @override
  Future<void> clearTokens() async {
    clears++;
    access = null;
    refresh = null;
  }
}

String token(String owner) =>
    'header.${base64Url.encode(utf8.encode(jsonEncode({'userId': owner, 'exp': 1})))}.signature';

void main() {
  test('late 401 reuses tokens refreshed by another API client', () async {
    final tokens = MemoryTokens(token('user-a'), 'refresh');
    final client = Dio(BaseOptions(baseUrl: 'http://tests'));
    final refresh = Dio(BaseOptions(baseUrl: 'http://tests'));
    var refreshes = 0;
    client.httpClientAdapter = TestAdapter((r) async {
      if (r.extra['authRetried'] != true) {
        await tokens.saveTokens(
          accessToken: '${token('user-a')}-new',
          refreshToken: 'rotated',
        );
        return reply({}, status: 401);
      }
      expect(r.headers['Authorization'], 'Bearer ${token('user-a')}-new');
      return reply({});
    });
    refresh.httpClientAdapter = TestAdapter((r) async {
      refreshes++;
      return reply({}, status: 401);
    });
    client.interceptors.add(
      TokenInterceptor(
        tokenStorage: tokens,
        eventBus: AuthEventBus(),
        dio: client,
        refreshClient: refresh,
      ),
    );
    await client.get('/journeys');
    expect(refreshes, 0);
    expect(tokens.clears, 0);
    client.close();
    refresh.close();
  });

  test(
    'old account 401 cannot refresh or clear the new account session',
    () async {
      final tokens = MemoryTokens(token('user-a'), 'refresh-a');
      final client = Dio(BaseOptions(baseUrl: 'http://tests'));
      final refresh = Dio(BaseOptions(baseUrl: 'http://tests'));
      var refreshes = 0;
      client.httpClientAdapter = TestAdapter((r) async {
        await tokens.saveTokens(
          accessToken: token('user-b'),
          refreshToken: 'refresh-b',
        );
        return reply({}, status: 401);
      });
      refresh.httpClientAdapter = TestAdapter((r) async {
        refreshes++;
        return reply({}, status: 401);
      });
      client.interceptors.add(
        TokenInterceptor(
          tokenStorage: tokens,
          eventBus: AuthEventBus(),
          dio: client,
          refreshClient: refresh,
        ),
      );
      await expectLater(
        client.get('/journeys'),
        throwsA(
          isA<DioException>().having(
            (e) => e.type,
            'type',
            DioExceptionType.cancel,
          ),
        ),
      );
      expect(refreshes, 0);
      expect(tokens.clears, 0);
      expect(tokens.refresh, 'refresh-b');
      client.close();
      refresh.close();
    },
  );

  test('different API clients share one rotating refresh token', () async {
    final tokens = MemoryTokens(token('user-a'), 'shared-refresh');
    final refresh = Dio(BaseOptions(baseUrl: 'http://tests'));
    final gate = Completer<void>();
    var refreshes = 0;
    refresh.httpClientAdapter = TestAdapter((r) async {
      refreshes++;
      await gate.future;
      return reply({
        'accessToken': '${token('user-a')}-new',
        'refreshToken': 'rotated-refresh',
      });
    });
    final clients = List.generate(3, (_) {
      final client = Dio(BaseOptions(baseUrl: 'http://tests'));
      client.httpClientAdapter = TestAdapter(
        (r) async =>
            reply({}, status: r.extra['authRetried'] == true ? 200 : 401),
      );
      client.interceptors.add(
        TokenInterceptor(
          tokenStorage: tokens,
          eventBus: AuthEventBus(),
          dio: client,
          refreshClient: refresh,
        ),
      );
      return client;
    });
    final requests = Future.wait(clients.map((c) => c.get('/journeys')));
    await Future<void>.delayed(const Duration(milliseconds: 50));
    gate.complete();
    await requests;
    expect(refreshes, 1);
    expect(tokens.clears, 0);
    for (final client in clients) {
      client.close();
    }
    refresh.close();
  });

  test(
    'validation failure on replay does not log out a refreshed session',
    () async {
      final tokens = MemoryTokens(token('user-a'), 'refresh');
      final client = Dio(BaseOptions(baseUrl: 'http://tests'));
      final refresh = Dio(BaseOptions(baseUrl: 'http://tests'));
      client.httpClientAdapter = TestAdapter(
        (r) async =>
            reply({}, status: r.extra['authRetried'] == true ? 422 : 401),
      );
      refresh.httpClientAdapter = TestAdapter(
        (r) async => reply({
          'accessToken': token('user-a'),
          'refreshToken': 'new-refresh',
        }),
      );
      client.interceptors.add(
        TokenInterceptor(
          tokenStorage: tokens,
          eventBus: AuthEventBus(),
          dio: client,
          refreshClient: refresh,
        ),
      );
      await expectLater(
        client.post('/journeys'),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'status',
            422,
          ),
        ),
      );
      expect(tokens.clears, 0);
      expect(tokens.refresh, 'new-refresh');
      client.close();
      refresh.close();
    },
  );

  test('saved session can reopen local data after access-token expiry; logout disables reopening', () async {
    final tokens = MemoryTokens(token('user-a'), 'refresh');
    expect(await SessionGate.hasStoredSession(tokens), isTrue);
    await tokens.clearTokens();
    expect(await SessionGate.hasStoredSession(tokens), isFalse);
    expect(
      await SessionGate.hasStoredSession(MemoryTokens('invalid', 'refresh')),
      isFalse,
    );
  });

  for (final serverError in [false, true]) {
    test(
      'refresh ${serverError ? '503' : 'network failure'} preserves device session and allows SQLite fallback',
      () async {
        final tokens = MemoryTokens(token('user-a'), 'refresh');
        final client = Dio(BaseOptions(baseUrl: 'http://tests'));
        final refresh = Dio(BaseOptions(baseUrl: 'http://tests'));
        client.httpClientAdapter = TestAdapter(
          (r) async => reply({}, status: 401),
        );
        refresh.httpClientAdapter = TestAdapter((r) async {
          if (serverError) return reply({}, status: 503);
          throw DioException(
            requestOptions: r,
            type: DioExceptionType.connectionError,
          );
        });
        client.interceptors.add(
          TokenInterceptor(
            tokenStorage: tokens,
            eventBus: AuthEventBus(),
            dio: client,
            refreshClient: refresh,
          ),
        );
        await expectLater(
          client.get('/journeys'),
          throwsA(
            isA<DioException>().having(
              OfflineStore.canUseCache,
              'uses cache',
              isTrue,
            ),
          ),
        );
        expect(tokens.clears, 0);
        expect(await SessionGate.hasStoredSession(tokens), isTrue);
        client.close();
        refresh.close();
      },
    );
  }

  test('invalid refresh token expires the session instead of falling back as an authenticated user', () async {
    final tokens = MemoryTokens(token('user-a'), 'refresh');
    final client = Dio(BaseOptions(baseUrl: 'http://tests'));
    final refresh = Dio(BaseOptions(baseUrl: 'http://tests'));
    client.httpClientAdapter = TestAdapter((r) async => reply({}, status: 401));
    refresh.httpClientAdapter = TestAdapter(
      (r) async => reply({}, status: 401),
    );
    client.interceptors.add(
      TokenInterceptor(
        tokenStorage: tokens,
        eventBus: AuthEventBus(),
        dio: client,
        refreshClient: refresh,
      ),
    );
    await expectLater(
      client.get('/journeys'),
      throwsA(
        isA<DioException>().having(
          OfflineStore.canUseCache,
          'uses cache',
          isFalse,
        ),
      ),
    );
    expect(tokens.clears, 1);
    client.close();
    refresh.close();
  });

  test('replay checks the current account and preserves its idempotency key through refresh', () async {
    final tokens = MemoryTokens(token('user-a'), 'refresh');
    final client = Dio(BaseOptions(baseUrl: 'http://tests'));
    final refresh = Dio(BaseOptions(baseUrl: 'http://tests'));
    var requests = 0;
    client.httpClientAdapter = TestAdapter((r) async {
      requests++;
      expect(r.headers['Idempotency-Key'], 'journey-1');
      return reply({}, status: requests == 1 ? 401 : 200);
    });
    refresh.httpClientAdapter = TestAdapter(
      (r) async => reply({
        'accessToken': token('user-a'),
        'refreshToken': 'new-refresh',
      }),
    );
    client.interceptors.add(
      TokenInterceptor(
        tokenStorage: tokens,
        eventBus: AuthEventBus(),
        dio: client,
        refreshClient: refresh,
      ),
    );
    await client.post(
      '/journeys',
      options: Options(
        headers: {'Idempotency-Key': 'journey-1'},
        extra: {'offlineOwner': 'user-a'},
      ),
    );
    expect(requests, 2);
    tokens.access = token('user-b');
    await expectLater(
      client.post(
        '/journeys',
        options: Options(extra: {'offlineOwner': 'user-a'}),
      ),
      throwsA(
        isA<DioException>().having(
          (e) => e.type,
          'cancel',
          DioExceptionType.cancel,
        ),
      ),
    );
    expect(requests, 2);
    client.close();
    refresh.close();
  });

  test(
    'a second 401 after refresh terminates instead of refreshing forever',
    () async {
      final tokens = MemoryTokens(token('user-a'), 'refresh');
      final client = Dio(BaseOptions(baseUrl: 'http://tests'));
      final refresh = Dio(BaseOptions(baseUrl: 'http://tests'));
      var refreshes = 0;
      client.httpClientAdapter = TestAdapter(
        (r) async => reply({}, status: 401),
      );
      refresh.httpClientAdapter = TestAdapter((r) async {
        refreshes++;
        return reply({
          'accessToken': token('user-a'),
          'refreshToken': 'new-refresh',
        });
      });
      client.interceptors.add(
        TokenInterceptor(
          tokenStorage: tokens,
          eventBus: AuthEventBus(),
          dio: client,
          refreshClient: refresh,
        ),
      );
      await expectLater(client.get('/journeys'), throwsA(isA<DioException>()));
      expect(refreshes, 1);
      expect(tokens.clears, 1);
      client.close();
      refresh.close();
    },
  );
}
