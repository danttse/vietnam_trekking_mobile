import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/models/xp_history_model.dart';
import '../../../core/services/user_api_service.dart';
import '../../../core/services/auth_event_bus.dart';
import '../../../core/network/api_error_handler.dart';

class XpHistoryViewModel extends ChangeNotifier {
  final UserApiService _api;
  late final StreamSubscription<AuthEvent> _authSub;
  List<XpTransaction> items = [];
  String? nextCursor;
  String? error;
  bool isLoading = false;
  bool loaded = false;
  bool _retryRefresh = false;
  int _generation = 0;
  bool _disposed = false;

  XpHistoryViewModel({UserApiService? api}) : _api = api ?? UserApiService() {
    _authSub = AuthEventBus().stream.listen((_) {
      _generation++;
      items = [];
      nextCursor = null;
      error = null;
      loaded = false;
      _retryRefresh = false;
      isLoading = false;
      if (!_disposed) notifyListeners();
    });
  }

  Future<void> load({bool refresh = false}) async {
    if (_disposed || (isLoading && !refresh)) return;
    if (loaded && nextCursor == null && !refresh && error == null) return;
    final generation = ++_generation;
    final cursor = refresh || _retryRefresh ? null : nextCursor;
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final page = await _api.getXpHistory(cursor: cursor);
      if (_disposed || generation != _generation) return;
      final merged = cursor == null ? <XpTransaction>[] : [...items];
      final ids = merged.map((item) => item.id).toSet();
      merged.addAll(page.items.where((item) => ids.add(item.id)));
      items = merged;
      nextCursor = page.nextCursor;
      loaded = true;
      _retryRefresh = false;
    } catch (e) {
      if (!_disposed && generation == _generation) {
        _retryRefresh = cursor == null;
        error = ApiErrorHandler.handle(e);
      }
    } finally {
      if (!_disposed && generation == _generation) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    _authSub.cancel();
    super.dispose();
  }
}
