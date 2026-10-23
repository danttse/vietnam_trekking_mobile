import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../config/app_config.dart';
import '../../services/auth_event_bus.dart';
import '../../services/token_storage.dart';
import '../../services/offline_store.dart';

typedef _Tokens = ({String accessToken, String refreshToken});

/// Shares rotating refresh tokens across API clients and guards account changes.
class TokenInterceptor extends Interceptor {
  static final Map<String, Future<_Tokens>> _refreshes = {};
  final TokenStorage _tokenStorage;
  final AuthEventBus _eventBus;
  final Dio _dio;
  final Dio? _refreshClient;

  TokenInterceptor({
    required TokenStorage tokenStorage,
    required AuthEventBus eventBus,
    required Dio dio,
    Dio? refreshClient,
  }) : _tokenStorage = tokenStorage,
       _eventBus = eventBus,
       _dio = dio,
       _refreshClient = refreshClient;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (kDebugMode) {
      debugPrint('[TokenInterceptor] → ${options.method} ${options.uri}');
    }
    final accessToken = await _tokenStorage.getAccessToken();
    final owner =
        options.extra['offlineOwner'] ?? options.extra['authRetriedOwner'];
    if (owner != null && OfflineStore.ownerFromToken(accessToken) != owner) {
      handler.reject(_accountChanged(options));
      return;
    }
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '[TokenInterceptor] ← ${response.statusCode} ${response.requestOptions.uri}',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 &&
        err.requestOptions.extra['skipAuthRefresh'] != true &&
        !err.requestOptions.path.contains('/auth/refresh') &&
        err.requestOptions.extra['authRetried'] != true) {
      await _handleRefresh(err, handler);
      return;
    }
    handler.next(err);
  }

  Future<void> _handleRefresh(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    String? retryRefresh;
    try {
      final currentAccess = await _tokenStorage.getAccessToken();
      final sentAuthorization =
          err.requestOptions.headers['Authorization'] as String?;
      final sentAccess = sentAuthorization?.replaceFirst('Bearer ', '');
      final sentOwner = OfflineStore.ownerFromToken(sentAccess);
      if (sentAccess != null &&
          (currentAccess == null ||
              (sentOwner != null &&
                  sentOwner != OfflineStore.ownerFromToken(currentAccess)))) {
        throw _accountChanged(err.requestOptions);
      }
      String access;
      // A late 401 can arrive after another client has already refreshed.
      if (currentAccess != null && currentAccess != sentAccess) {
        access = currentAccess;
        retryRefresh = await _tokenStorage.getRefreshToken();
      } else {
        final refresh = await _tokenStorage.getRefreshToken();
        if (refresh == null || refresh.isEmpty) {
          await _expireSession(refresh);
          handler.next(err);
          return;
        }
        final pending = _refreshes[refresh] ??= _refreshSession(refresh, err);
        _Tokens tokens;
        try {
          tokens = await pending;
        } finally {
          if (identical(_refreshes[refresh], pending)) {
            _refreshes.remove(refresh);
          }
        }
        access = tokens.accessToken;
        retryRefresh = tokens.refreshToken;
      }
      if (await _tokenStorage.getAccessToken() != access) {
        throw _accountChanged(err.requestOptions);
      }
      final options = err.requestOptions;
      options.extra['authRetried'] = true;
      options.extra['authRetriedOwner'] = OfflineStore.ownerFromToken(access);
      options.headers['Authorization'] = 'Bearer $access';
      handler.resolve(await _dio.fetch(options));
    } on DioException catch (e) {
      // Validation failures after refresh must retain the authenticated session.
      if (retryRefresh != null && e.response?.statusCode == 401) {
        await _expireSession(retryRefresh);
      }
      handler.next(_forOriginalRequest(e, err));
    } catch (_) {
      handler.next(err);
    }
  }

  Future<_Tokens> _refreshSession(
    String refreshToken,
    DioException original,
  ) async {
    final client =
        _refreshClient ??
        Dio(
          BaseOptions(
            baseUrl: AppConfig.baseUrl,
            connectTimeout: AppConfig.connectTimeout,
            receiveTimeout: AppConfig.receiveTimeout,
          ),
        );
    try {
      final response = await client.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      if (await _tokenStorage.getRefreshToken() != refreshToken) {
        throw _accountChanged(original.requestOptions);
      }
      final data = response.data['data'] as Map;
      final tokens = (
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
      );
      await _tokenStorage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
      return tokens;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 ||
          e.response?.statusCode == 401 ||
          e.response?.statusCode == 403) {
        await _expireSession(refreshToken);
      }
      rethrow;
    } finally {
      if (_refreshClient == null) client.close();
    }
  }

  Future<void> _expireSession(String? expectedRefresh) async {
    if (await _tokenStorage.getRefreshToken() != expectedRefresh) return;
    await _tokenStorage.clearTokens();
    _eventBus.fire(AuthEvent.authExpired);
  }

  DioException _accountChanged(RequestOptions options) => DioException(
    requestOptions: options,
    type: DioExceptionType.cancel,
    message: 'Phiên đăng nhập đã thay đổi.',
  );

  DioException _forOriginalRequest(DioException error, DioException original) =>
      DioException(
        requestOptions: original.requestOptions,
        type: error.type,
        response: error.response,
        message: error.message,
        error: error.error,
      );
}
