import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/services/auth_event_bus.dart';
import '../../../core/network/api_error_handler.dart';
import '../data/datasources/social_api.dart';
import '../data/datasources/community_realtime.dart';

/// Account-bound REST state, invalidated by authenticated socket events.
/// A request begun before logout/dispose can never repopulate the view.
class SocialViewModel extends ChangeNotifier {
  final SocialApi api;
  CommunityRealtime? _socket;
  StreamSubscription<AuthEvent>? _auth;
  Timer? _refresh;
  bool _disposed = false, _ended = false;
  int _epoch = 0;
  bool loading = true;
  String? error;
  Json? me;
  List<Json> conversations = [];
  int page = 1, totalPages = 1;

  SocialViewModel({SocialApi? api, bool realtime = true, bool autoLoad = true})
    : api = api ?? SocialApi() {
    _auth = AuthEventBus().stream.listen((_) {
      _epoch++;
      _ended = true;
      me = null;
      conversations = [];
      loading = false;
      _socket?.dispose();
      _refresh?.cancel();
      _emit();
    });
    if (realtime) {
      _socket = CommunityRealtime(
        onEvent: (event) {
          if (event['type'] == 'ready' || event['conversationId'] != null) {
            _refresh?.cancel();
            _refresh = Timer(
              const Duration(milliseconds: 250),
              () => load(silent: true),
            );
          }
        },
      )..connect();
    }
    if (autoLoad) load();
  }
  void _emit() {
    if (!_disposed) notifyListeners();
  }

  Future<void> load({bool silent = false, bool more = false}) async {
    if (_disposed || _ended || (more && (loading || page >= totalPages))) {
      return;
    }
    final epoch = ++_epoch;
    loading = !silent;
    error = null;
    _emit();
    try {
      final results = await Future.wait([
        api.get('/people/me'),
        api.get('/conversations', {'page': more ? page + 1 : 1, 'limit': 30}),
      ]);
      if (_disposed || _ended || epoch != _epoch) return;
      me = results[0];
      final result = results[1];
      final rows = (result['items'] as List)
          .map((e) => Json.from(e as Map))
          .toList();
      conversations = more ? [...conversations, ...rows] : rows;
      page = result['page'] as int;
      totalPages = result['totalPages'] as int;
    } catch (e) {
      if (epoch == _epoch && !_disposed) error = ApiErrorHandler.handle(e);
    } finally {
      if (epoch == _epoch) {
        loading = false;
        _emit();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _epoch++;
    _refresh?.cancel();
    _auth?.cancel();
    _socket?.dispose();
    super.dispose();
  }
}
