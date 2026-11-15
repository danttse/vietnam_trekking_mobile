import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../../core/services/auth_event_bus.dart';
import '../../../core/network/api_error_handler.dart';
import '../data/datasources/social_api.dart';
import '../data/datasources/community_realtime.dart';

class ConversationViewModel extends ChangeNotifier {
  final SocialApi api;
  final String id;
  CommunityRealtime? _socket;
  StreamSubscription<AuthEvent>? _auth;
  Timer? _refresh;
  bool _disposed = false, _ended = false;
  int _epoch = 0;
  bool loading = true, sending = false;
  String? error, sendError, ownerId;
  Json? conversation;
  List<Json> messages = [];
  int? nextBefore;
  String? _retryContent, _retryKey;
  ConversationViewModel({
    required this.id,
    SocialApi? api,
    bool realtime = true,
    bool autoLoad = true,
  }) : api = api ?? SocialApi() {
    _auth = AuthEventBus().stream.listen((_) {
      _epoch++;
      _ended = true;
      conversation = null;
      messages = [];
      ownerId = null;
      _socket?.dispose();
      _refresh?.cancel();
      loading = false;
      _emit();
    });
    if (realtime) {
      _socket = CommunityRealtime(
        onEvent: (e) {
          if (e['type'] == 'ready' ||
              (e['conversationId'] == id && e['type'] != 'conversation.read')) {
            _refresh?.cancel();
            _refresh = Timer(
              const Duration(milliseconds: 200),
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

  Future<void> load({bool silent = false, bool older = false}) async {
    if (_disposed || _ended || (older && (loading || nextBefore == null))) {
      return;
    }
    final epoch = ++_epoch;
    loading = !silent;
    error = null;
    _emit();
    try {
      final info = await Future.wait([
        api.get('/people/me'),
        api.get('/conversations/$id'),
      ]);
      if (_disposed || _ended || epoch != _epoch) return;
      final rows = <Json>[];
      int? before = older ? nextBefore : null;
      final minimum = !older && messages.isNotEmpty
          ? messages.first['sequence'] as int
          : null;
      do {
        final result = await api.get('/conversations/$id/messages', {
          'limit': 50,
          if (before != null) 'before': before,
        });
        if (_disposed || _ended || epoch != _epoch) return;
        rows.addAll((result['items'] as List).map((e) => Json.from(e as Map)));
        before = result['nextBefore'] as int?;
        // Refetch the loaded history on invalidation so recalled messages also disappear.
      } while (!older &&
          before != null &&
          minimum != null &&
          rows.last['sequence'] > minimum);
      conversation = info[1];
      ownerId = info[0]['userId'] as String;
      final unique = <String, Json>{
        for (final m in [if (older) ...messages, ...rows])
          m['messageId'] as String: m,
      };
      messages = unique.values.toList()
        ..sort(
          (a, b) => (a['sequence'] as int).compareTo(b['sequence'] as int),
        );
      nextBefore = before;
      final sequence = info[1]['sequence'] as int;
      if (sequence > (info[1]['readSequence'] as int)) {
        await api.post('/conversations/$id/read', {'sequence': sequence});
      }
    } catch (e) {
      if (epoch == _epoch && !_disposed) {
        error = ApiErrorHandler.handle(e);
        messages = [];
        conversation = null;
      }
    } finally {
      if (epoch == _epoch) {
        loading = false;
        _emit();
      }
    }
  }

  Future<bool> send(String content) async {
    if (_disposed || _ended || sending || content.trim().isEmpty) return false;
    if (_retryContent != content.trim()) {
      _retryContent = content.trim();
      _retryKey =
          '${DateTime.now().microsecondsSinceEpoch}_${Random.secure().nextInt(1 << 32)}';
    }
    final epoch = _epoch;
    sending = true;
    sendError = null;
    _emit();
    try {
      await api.post('/conversations/$id/messages', {
        'content': _retryContent,
        'clientMessageId': _retryKey,
      });
      if (_disposed || _ended) return false;
      _retryKey = null;
      _retryContent = null;
      await load(silent: true);
      return true;
    } catch (e) {
      if (!_disposed && !_ended && epoch <= _epoch) {
        sendError = ApiErrorHandler.handle(e);
      }
      return false;
    } finally {
      sending = false;
      _emit();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _epoch++;
    _auth?.cancel();
    _refresh?.cancel();
    _socket?.dispose();
    super.dispose();
  }
}
