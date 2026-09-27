import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../config/app_config.dart';
import '../../services/auth_event_bus.dart';
import '../../services/token_storage.dart';

/// Dio interceptor that:
/// - Attaches `Authorization: Bearer <token>` to every outgoing request
///   (Requirement 2.4)
/// - Logs request method + URL in debug mode (Requirement 2.9)
/// - Logs response status code in debug mode (Requirement 2.9)
/// - Handles 401 responses by transparently refreshing the token pair
///   (Requirements 2.5, 2.6)
/// - Queues concurrent 401s so only one refresh call is made (Requirement 2.8)
/// - On refresh failure: clears stored tokens and fires [AuthEvent.authExpired]
///   (Requirement 2.7)
class TokenInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;
  final AuthEventBus _eventBus;

  /// The same [Dio] instance used by the app so that retried requests share
  /// the same base options (base URL, timeouts, etc.) but do NOT re-enter
  /// this interceptor and cause infinite refresh loops.
  final Dio _dio;

  bool _isRefreshing = false;

  /// Queue of requests that arrived while a refresh was in-flight.
  final List<({RequestOptions options, ErrorInterceptorHandler handler})>
      _queue = [];

  TokenInterceptor({
    required this._tokenStorage,
    required AuthEventBus eventBus,
    required this._dio,
  })  : _eventBus = eventBus;

  // ── onRequest ─────────────────────────────────────────────────────────────

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Debug log (Requirement 2.9)
    if (kDebugMode) {
      debugPrint(
        '[TokenInterceptor] → ${options.method} ${options.uri}',
      );
    }

    // Attach access token if available (Requirement 2.4)
    final accessToken = await _tokenStorage.getAccessToken();
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    handler.next(options);
  }

  // ── onResponse ────────────────────────────────────────────────────────────

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    // Debug log (Requirement 2.9)
    if (kDebugMode) {
      debugPrint(
        '[TokenInterceptor] ← ${response.statusCode} '
        '${response.requestOptions.uri}',
      );
    }

    handler.next(response);
  }

  // ── onError ───────────────────────────────────────────────────────────────

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    final requestPath = err.requestOptions.path;

    // Only intercept 401s that are not the refresh endpoint itself
    // (Requirement 2.5)
    if (statusCode == 401 && !requestPath.contains('/auth/refresh')) {
      await _handleRefresh(err, handler);
      return;
    }

    handler.next(err);
  }

  // ── _handleRefresh ────────────────────────────────────────────────────────

  /// Attempts to refresh the token pair.
  ///
  /// If a refresh is already in-flight, the request is enqueued and retried
  /// once the ongoing refresh completes (Requirement 2.8).
  Future<void> _handleRefresh(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (_isRefreshing) {
      // Enqueue and wait (Requirement 2.8)
      _queue.add((options: err.requestOptions, handler: handler));
      return;
    }

    _isRefreshing = true;

    try {
      final refreshToken = await _tokenStorage.getRefreshToken();

      if (refreshToken == null) {
        // No refresh token — treat as an expired session immediately
        throw DioException(
          requestOptions: err.requestOptions,
          error: 'No refresh token available',
        );
      }

      // Call the refresh endpoint using a separate Dio instance to avoid
      // re-entering this interceptor (Requirement 2.5)
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: AppConfig.baseUrl,
          connectTimeout: AppConfig.connectTimeout,
          receiveTimeout: AppConfig.receiveTimeout,
        ),
      );

      final refreshResponse = await refreshDio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      // Parse new tokens from { "success": true, "data": { ... } }
      final data =
          refreshResponse.data['data'] as Map<String, dynamic>;
      final newAccessToken = data['accessToken'] as String;
      final newRefreshToken = data['refreshToken'] as String;

      // Persist new tokens (Requirement 2.6, 3.4)
      await _tokenStorage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );

      if (kDebugMode) {
        debugPrint('[TokenInterceptor] Token refreshed successfully.');
      }

      // Drain the queue with the new token (Requirement 2.8)
      await _processQueue(newAccessToken);

      // Retry the original request with the new token (Requirement 2.6)
      final retryOptions = err.requestOptions;
      retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';
      final retryResponse = await _dio.fetch(retryOptions);
      handler.resolve(retryResponse);
    } catch (_) {
      // Refresh failed — clear tokens, fire event, drain queue with null
      // (Requirement 2.7)
      await _tokenStorage.clearTokens();
      _eventBus.fire(AuthEvent.authExpired);

      if (kDebugMode) {
        debugPrint(
          '[TokenInterceptor] Token refresh failed. Session expired.',
        );
      }

      await _processQueue(null);
      handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }

  // ── _processQueue ─────────────────────────────────────────────────────────

  /// Retries all queued requests with [newAccessToken], or rejects them if
  /// [newAccessToken] is `null` (refresh failed).
  Future<void> _processQueue(String? newAccessToken) async {
    final pending = List.of(_queue);
    _queue.clear();

    for (final item in pending) {
      if (newAccessToken != null) {
        // Retry with the new token
        item.options.headers['Authorization'] = 'Bearer $newAccessToken';
        try {
          final response = await _dio.fetch(item.options);
          item.handler.resolve(response);
        } catch (e) {
          if (e is DioException) {
            item.handler.reject(e);
          } else {
            item.handler.reject(
              DioException(requestOptions: item.options, error: e),
            );
          }
        }
      } else {
        // Reject all queued requests
        item.handler.next(
          DioException(
            requestOptions: item.options,
            error: 'Session expired — token refresh failed',
            type: DioExceptionType.badResponse,
          ),
        );
      }
    }
  }
}
