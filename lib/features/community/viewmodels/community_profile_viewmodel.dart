import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../../core/network/api_error_handler.dart';
import '../../../core/services/auth_event_bus.dart';
import '../data/datasources/community_realtime.dart';
import '../data/datasources/community_remote_datasource.dart';
import '../data/datasources/social_api.dart';
import '../data/models/post_model.dart';

class CommunityProfileViewModel extends ChangeNotifier {
  final String? userId;
  final SocialApi api;
  final bool realtimeEnabled;

  CommunityRealtime? _realtime;
  StreamSubscription<AuthEvent>? _auth;
  Timer? _refreshTimer;
  int _epoch = 0;
  bool _disposed = false;

  Json? person;
  List<PostModel> posts = [];
  String? error;
  bool loading = false;
  bool busy = false;
  int page = 0;
  int totalPages = 1;

  CommunityProfileViewModel({
    this.userId,
    SocialApi? api,
    this.realtimeEnabled = true,
  }) : api = api ?? SocialApi() {
    _init();
  }

  void _init() {
    _auth = AuthEventBus().stream.listen((_) {
      if (_disposed) return;
      _epoch++;
      _realtime?.dispose();
      _refreshTimer?.cancel();
      person = null;
      posts = [];
      loading = false;
      notifyListeners();
    });

    if (realtimeEnabled) {
      _realtime = CommunityRealtime(
        onEvent: (event) {
          if (event['type'] == 'ready' || event['postId'] != null) {
            _refreshTimer?.cancel();
            _refreshTimer = Timer(const Duration(milliseconds: 300), load);
          }
        },
      )..connect();
    }

    load();
  }

  Future<void> load({bool more = false}) async {
    if (_disposed || (more && loading)) return;
    final currentEpoch = ++_epoch;
    loading = true;
    error = null;
    notifyListeners();

    try {
      final profile = await api.get(
        userId == null ? '/people/me' : '/people/$userId',
      );
      if (_disposed || currentEpoch != _epoch) return;

      final result = await CommunityRemoteDataSource(api.dio).getPosts(
        userId: profile['userId'] as String,
        page: more ? page + 1 : 1,
      );

      if (!_disposed && currentEpoch == _epoch) {
        person = profile;
        posts = more ? [...posts, ...result.items] : result.items;
        page = result.page;
        totalPages = result.totalPages;
      }
    } catch (e) {
      if (!_disposed && currentEpoch == _epoch) {
        error = ApiErrorHandler.handle(e);
        person = null;
        posts = [];
      }
    } finally {
      if (!_disposed && currentEpoch == _epoch) {
        loading = false;
        notifyListeners();
      }
    }
  }

  Future<void> updateBio(String bio) async {
    if (busy || _disposed) return;
    busy = true;
    notifyListeners();
    try {
      await api.patch('/people/me', {'bio': bio});
      await load();
    } finally {
      if (!_disposed) {
        busy = false;
        notifyListeners();
      }
    }
  }

  Future<void> regenerateQr() async {
    if (busy || _disposed) return;
    busy = true;
    notifyListeners();
    try {
      await api.post('/people/me/qr');
      await load();
    } finally {
      if (!_disposed) {
        busy = false;
        notifyListeners();
      }
    }
  }

  Future<Json> createDirectConversation() async {
    if (person == null) throw StateError('Chua co thong tin nguoi dung.');
    busy = true;
    notifyListeners();
    try {
      return await api.post(
        '/conversations/direct',
        {'userId': person!['userId']},
      );
    } finally {
      if (!_disposed) {
        busy = false;
        notifyListeners();
      }
    }
  }

  Future<void> toggleReaction(PostModel post) async {
    final source = CommunityRemoteDataSource(api.dio);
    if (post.isLiked) {
      await source.unlikePost(post.postId);
    } else {
      await source.likePost(post.postId);
    }
    await load();
  }

  Future<void> deletePost(String postId) async {
    await CommunityRemoteDataSource(api.dio).deletePost(postId);
    await load();
  }

  @override
  void dispose() {
    _disposed = true;
    _epoch++;
    _refreshTimer?.cancel();
    _realtime?.dispose();
    _auth?.cancel();
    super.dispose();
  }
}
