import 'dart:async';

// ─── Auth Events ──────────────────────────────────────────────────────────────

/// Events that can be broadcast on the [AuthEventBus].
enum AuthEvent {
  /// Fired when a token refresh attempt fails and the user session has expired.
  authExpired,
}

// ─── Auth Event Bus ───────────────────────────────────────────────────────────

/// A singleton broadcast stream bus for authentication-related events.
///
/// Consumers (e.g. the root widget) subscribe to [stream] to react to
/// session-expiry events and redirect the user to the login screen.
///
/// Usage:
/// ```dart
/// AuthEventBus().stream.listen((event) {
///   if (event == AuthEvent.authExpired) { /* navigate to login */ }
/// });
///
/// // Somewhere in TokenInterceptor:
/// AuthEventBus().fire(AuthEvent.authExpired);
/// ```
class AuthEventBus {
  // ── Singleton ─────────────────────────────────────────────────────────────

  static final AuthEventBus _instance = AuthEventBus._internal();

  factory AuthEventBus() => _instance;

  AuthEventBus._internal();

  // ── Stream ────────────────────────────────────────────────────────────────

  final StreamController<AuthEvent> _controller =
      StreamController<AuthEvent>.broadcast();

  /// Broadcast stream of [AuthEvent]s. Multiple listeners are supported.
  Stream<AuthEvent> get stream => _controller.stream;

  // ── API ───────────────────────────────────────────────────────────────────

  /// Adds [event] to the stream so all current listeners are notified.
  void fire(AuthEvent event) => _controller.add(event);

  /// Closes the underlying [StreamController].
  ///
  /// Call this only when the bus is no longer needed (e.g. during app teardown).
  void dispose() => _controller.close();
}
