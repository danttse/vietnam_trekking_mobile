import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../services/auth_event_bus.dart';
import '../services/token_storage.dart';
import 'interceptors/token_interceptor.dart';

/// Factory for creating a configured [Dio] HTTP client instance.
///
/// Configures [BaseOptions] from [AppConfig] (base URL, timeouts, headers)
/// and attaches a [TokenInterceptor] for automatic token attachment and
/// transparent token refresh.
///
/// Requirements: 2.1, 2.2, 2.3, 2.9
class DioClient {
  // Prevents instantiation — this class is a pure factory.
  DioClient._();

  /// Creates and configures a [Dio] instance with [TokenInterceptor] attached.
  ///
  /// - [tokenStorage]: used by [TokenInterceptor] to read/write tokens.
  /// - [eventBus]: used by [TokenInterceptor] to fire [AuthEvent.authExpired]
  ///   when a token refresh fails (Requirement 2.7).
  static Dio createDio({
    required TokenStorage tokenStorage,
    required AuthEventBus eventBus,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      TokenInterceptor(
        tokenStorage: tokenStorage,
        eventBus: eventBus,
        dio: dio,
      ),
    );

    return dio;
  }
}
