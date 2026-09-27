// ─── App Configuration ────────────────────────────────────────────────────────

/// Static configuration for the application.
///
/// [baseUrl] is read from the `API_BASE_URL` compile-time environment variable,
/// which can be injected via `--dart-define=API_BASE_URL=<url>`.
/// Falls back to the Android emulator host (`10.0.2.2`) when not set.
class AppConfig {
  // Prevents instantiation.
  const AppConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/api/v1',
  );

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
