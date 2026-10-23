// ─── App Configuration ────────────────────────────────────────────────────────
//
// URL theo environment — inject qua --dart-define khi build/run:
//
//  LOCAL (Android Emulator):
//    flutter run \
//      --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1 \
//      --dart-define=TREKKING_BASE_URL=http://10.0.2.2:3003/api/v1 \
//      --dart-define=CHECKIN_BASE_URL=http://10.0.2.2:3002/api/v1
//
//  LOCAL (Thiết bị thật — thay IP LAN của máy):
//    flutter run \
//      --dart-define=API_BASE_URL=http://192.168.1.x:3000/api/v1 \
//      --dart-define=TREKKING_BASE_URL=http://192.168.1.x:3003/api/v1 \
//      --dart-define=CHECKIN_BASE_URL=http://192.168.1.x:3002/api/v1
//
//  DEV (server dev):
//    flutter run \
//      --dart-define=APP_ENV=dev \
//      --dart-define=API_BASE_URL=https://api-dev.trekviet.vn/api/v1 \
//      --dart-define=TREKKING_BASE_URL=https://trekking-dev.trekviet.vn/api/v1 \
//      --dart-define=CHECKIN_BASE_URL=https://checkin-dev.trekviet.vn/api/v1
//
//  PRODUCTION (Render):
//    flutter build apk \
//      --dart-define=APP_ENV=production \
//      --dart-define=API_BASE_URL=https://api-gateway-trekvn.onrender.com/api/v1 \
//      --dart-define=TREKKING_BASE_URL=https://api-gateway-trekvn.onrender.com/api/v1/trekking \
//      --dart-define=CHECKIN_BASE_URL=https://api-gateway-trekvn.onrender.com/api/v1/checkin
//
// Lưu ý: Tất cả các request đều đi qua API Gateway trên Render.
// Gateway sẽ proxy tới các microservices tương ứng.

/// Static configuration for the application.
class AppConfig {
  // Prevents instantiation.
  const AppConfig._();

  /// Environment: local | dev | production
  static const String env = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'local',
  );

  /// API Gateway — dùng cho tất cả API calls (auth, trekking, checkin)
  /// Gateway sẽ route đến đúng service dựa trên path prefix.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api-gateway-trekvn.onrender.com/api/v1',
  );

  /// Trekking Service — dùng cho /journeys, /routes, /places, /contributions
  /// Production: đi qua Gateway (same as baseUrl)
  /// Local: gọi trực tiếp service (http://10.0.2.2:3003/api/v1)
  static const String trekkingBaseUrl = String.fromEnvironment(
    'TREKKING_BASE_URL',
    defaultValue: 'https://api-gateway-trekvn.onrender.com/api/v1',
  );

  /// Checkin Service — dùng cho /checkins, /visits
  /// Production: đi qua Gateway (same as baseUrl)
  /// Local: gọi trực tiếp service (http://10.0.2.2:3002/api/v1)
  static const String checkinBaseUrl = String.fromEnvironment(
    'CHECKIN_BASE_URL',
    defaultValue: 'https://api-gateway-trekvn.onrender.com/api/v1',
  );

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// Download timeout dài hơn cho việc tải map MBTiles
  static const Duration downloadTimeout = Duration(minutes: 10);

  static bool get isLocal => env == 'local';
  static bool get isDev => env == 'dev';
  static bool get isProduction => env == 'production';
}
