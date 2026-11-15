import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/services/token_storage.dart';
import '../../../../core/services/auth_event_bus.dart';

/// Native WebSocket notifications invalidate REST data. Every ready event,
/// including after app resume, makes consumers refetch missed changes.
class CommunityRealtime with WidgetsBindingObserver {
  final TokenStorage tokens;
  final void Function(Map<String, dynamic>) onEvent;
  final String baseUrl;
  final Future<WebSocket> Function(Uri) _connector;
  final Duration retryDelay, authTimeout;
  final bool observeLifecycle;
  WebSocket? _socket;
  StreamSubscription<AuthEvent>? _authSubscription;
  Timer? _retry, _authentication;
  bool _disposed = false,
      _paused = false,
      _connecting = false,
      _observing = false;
  int _attempt = 0, _epoch = 0;

  CommunityRealtime({
    required this.onEvent,
    this.tokens = const SecureTokenStorage(),
    this.baseUrl = AppConfig.communityBaseUrl,
    Future<WebSocket> Function(Uri)? connector,
    this.retryDelay = const Duration(seconds: 1),
    this.authTimeout = const Duration(seconds: 8),
    this.observeLifecycle = true,
  }) : _connector = connector ?? ((uri) => WebSocket.connect(uri.toString()));

  Future<void> connect() async {
    if (_disposed || _paused || _connecting || _socket != null) return;
    if (observeLifecycle && !_observing) {
      WidgetsBinding.instance.addObserver(this);
      _observing = true;
    }
    _authSubscription ??= AuthEventBus().stream.listen((_) => dispose());
    _retry?.cancel();
    _retry = null;
    final epoch = _epoch;
    _connecting = true;
    bool abandoned = false;
    try {
      final token = await tokens.getAccessToken();
      if (_disposed || _paused || epoch != _epoch) return;
      if (token == null) {
        _scheduleRetry();
        return;
      }
      final base = Uri.parse(baseUrl);
      final uri = Uri(
        scheme: base.scheme == 'https' ? 'wss' : 'ws',
        host: base.host,
        port: base.hasPort ? base.port : null,
        path: '${base.path.replaceAll(RegExp(r'/$'), '')}/community/ws',
      );
      final pending = _connector(uri).then((socket) {
        if (abandoned || _disposed || _paused || epoch != _epoch) {
          socket.close();
        }
        return socket;
      });
      final socket = await pending.timeout(const Duration(seconds: 10));
      if (_disposed || _paused || epoch != _epoch) {
        socket.close();
        return;
      }
      // Never authenticate an in-flight connection for a previous account.
      if (await tokens.getAccessToken() != token) {
        socket.close();
        _scheduleRetry();
        return;
      }
      if (_disposed || _paused || epoch != _epoch) {
        socket.close();
        return;
      }
      _socket = socket;
      socket.pingInterval = const Duration(seconds: 25);
      _authentication = Timer(authTimeout, () => _disconnect(socket));
      socket.add(jsonEncode({'type': 'auth', 'token': token}));
      socket.listen(
        (raw) {
          if (_disposed ||
              epoch != _epoch ||
              _socket != socket ||
              raw is! String) {
            return;
          }
          try {
            final decoded = jsonDecode(raw);
            if (decoded is! Map || decoded['type'] is! String) return;
            final event = Map<String, dynamic>.from(decoded);
            if (event['type'] == 'ready') {
              _authentication?.cancel();
              _attempt = 0;
            }
            onEvent(event);
          } on FormatException {
            /* Malformed notifications cannot change REST state. */
          }
        },
        onDone: () => _disconnect(socket),
        onError: (_) => _disconnect(socket),
        cancelOnError: true,
      );
    } catch (_) {
      abandoned = true;
      if (epoch == _epoch) _scheduleRetry();
    } finally {
      if (epoch == _epoch) _connecting = false;
    }
  }

  void _disconnect(WebSocket socket) {
    if (_socket != socket) return;
    _socket = null;
    _authentication?.cancel();
    socket.close();
    if (!_disposed && socket.closeCode == 4401) onEvent({'type': 'reconnect'});
    _scheduleRetry();
  }

  void _scheduleRetry() {
    if (_disposed || _paused || _retry?.isActive == true) return;
    final delay = retryDelay * (1 << _attempt.clamp(0, 5));
    _attempt++;
    _retry = Timer(delay, () {
      _retry = null;
      connect();
    });
  }

  void suspend() {
    if (_disposed || _paused) return;
    _paused = true;
    _epoch++;
    _connecting = false;
    _retry?.cancel();
    _authentication?.cancel();
    final socket = _socket;
    _socket = null;
    socket?.close();
  }

  void resume() {
    if (_disposed) return;
    _paused = false;
    connect();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) resume();
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      suspend();
    }
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _epoch++;
    _retry?.cancel();
    _authentication?.cancel();
    _authSubscription?.cancel();
    _socket?.close();
    _socket = null;
    if (_observing) WidgetsBinding.instance.removeObserver(this);
  }
}
