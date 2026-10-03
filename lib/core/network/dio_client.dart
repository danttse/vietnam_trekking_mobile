import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../services/auth_event_bus.dart';
import '../services/token_storage.dart';
import 'interceptors/token_interceptor.dart';

/// Factory tạo các Dio client cho từng service.
///
/// Mỗi service có base URL khác nhau — trekking (3003), checkin (3002),
/// auth gateway (3000) — tất cả đều share cùng TokenInterceptor.
class DioClient {
  DioClient._();

  /// Tạo Dio client cho **Trekking Service** (port 3003).
  /// Dùng cho: /journeys, /routes, /places, /contributions, /badges
  static Dio createTrekkingDio({
    required TokenStorage tokenStorage,
    required AuthEventBus eventBus,
  }) {
    return _createDio(
      baseUrl: AppConfig.trekkingBaseUrl,
      tokenStorage: tokenStorage,
      eventBus: eventBus,
    );
  }

  /// Tạo Dio client cho **Checkin Service** (port 3002).
  /// Dùng cho: /checkins, /visits, /journeys (checkin context)
  static Dio createCheckinDio({
    required TokenStorage tokenStorage,
    required AuthEventBus eventBus,
  }) {
    return _createDio(
      baseUrl: AppConfig.checkinBaseUrl,
      tokenStorage: tokenStorage,
      eventBus: eventBus,
    );
  }

  /// Tạo Dio client cho **API Gateway / Auth Service** (port 3000).
  /// Dùng cho: /auth/login, /auth/refresh, /auth/me
  static Dio createDio({
    required TokenStorage tokenStorage,
    required AuthEventBus eventBus,
  }) {
    return _createDio(
      baseUrl: AppConfig.baseUrl,
      tokenStorage: tokenStorage,
      eventBus: eventBus,
    );
  }

  static Dio _createDio({
    required String baseUrl,
    required TokenStorage tokenStorage,
    required AuthEventBus eventBus,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
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
