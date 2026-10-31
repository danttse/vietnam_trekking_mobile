import 'dart:async';

import 'package:flutter/material.dart';

import '../data/datasources/community_remote_datasource.dart';
import '../data/datasources/community_realtime.dart';
import '../data/models/post_model.dart';
import '../../../core/network/api_error_handler.dart';
import '../../../core/services/offline_store.dart';
import '../../../core/services/auth_event_bus.dart';

class CommunityViewModel extends ChangeNotifier {
  final CommunityRemoteDataSource _dataSource;
  final Future<String?> Function() _ownerProvider;
  CommunityRealtime? _realtime;
  StreamSubscription<AuthEvent>? _authSubscription;
  Timer? _refresh;
  bool _disposed = false;
  int _generation = 0;
  int _selectedTab = 0, _page = 0, _totalPages = 1;
  List<PostModel> _posts = [];
  final Set<String> _hiddenPostIds = {}, _liking = {};
  final Set<String> _hiddenAuthorIds = {}, _deleting = {};
  bool _isLoading = false, _isLoadingMore = false;
  String? _error;
  String? _owner;
  String? _actionError;
  bool _sessionEnded = false;

  CommunityViewModel({
    CommunityRemoteDataSource? dataSource,
    Future<String?> Function()? ownerProvider,
    bool realtimeEnabled = true,
    bool autoLoad = true,
  }) : _dataSource = dataSource ?? CommunityRemoteDataSource(),
       _ownerProvider = ownerProvider ?? OfflineStore.currentOwner {
    _authSubscription = AuthEventBus().stream.listen((_) {
      _generation++;
      _sessionEnded = true;
      _owner = null;
      _isLoading = false;
      _isLoadingMore = false;
      _posts = [];
      _realtime?.dispose();
      _refresh?.cancel();
      _emit();
    });
    if (autoLoad) loadPosts();
    if (realtimeEnabled) {
      _realtime = CommunityRealtime(
        onEvent: (event) {
          if (event['conversationId'] != null) return;
          _refresh?.cancel();
          _refresh = Timer(
            const Duration(milliseconds: 300),
            () => loadPosts(silent: true),
          );
        },
      )..connect();
    }
  }

  int get selectedTab => _selectedTab;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _page < _totalPages;
  String? get error => _error;
  String? get actionError => _actionError;
  bool ownsPost(PostModel post) => _owner != null && post.authorId == _owner;
  Set<String> get hiddenPostIds => Set.unmodifiable(_hiddenPostIds);
  List<PostModel> get posts => _posts
      .where(
        (p) =>
            !_hiddenPostIds.contains(p.postId) &&
            !_hiddenAuthorIds.contains(p.authorId),
      )
      .toList();

  void _emit() {
    if (!_disposed) notifyListeners();
  }

  void setTab(int index) {
    if (_selectedTab == index) return;
    _selectedTab = index;
    if (index == 1) {
      _emit();
      return;
    }
    _posts = [];
    loadPosts();
  }

  Future<void> loadPosts({bool silent = false}) async {
    if (_disposed || _sessionEnded) return;
    final generation = ++_generation;
    final tab = _selectedTab;
    _isLoading = !silent;
    _error = null;
    _emit();
    try {
      _owner = await _ownerProvider();
      if (_disposed || _sessionEnded || generation != _generation) return;
      if (tab == 2 && _owner == null) {
        throw StateError('Vui lòng đăng nhập.');
      }
      // A realtime invalidation refreshes every currently loaded page, keeping
      // pagination intact when reactions arrive while browsing older posts.
      final pageCount = silent ? _page.clamp(1, 10000) : 1;
      final loaded = <PostModel>[];
      int totalPages = 0, lastPage = 0;
      for (var page = 1; page <= pageCount; page++) {
        final response = await _dataSource.getPosts(
          page: page,
          userId: tab == 2 ? _owner : null,
          type: tab == 1 ? 'JOURNEY_SHARE' : null,
        );
        if (_disposed || generation != _generation) return;
        loaded.addAll(response.items);
        totalPages = response.totalPages;
        lastPage = page;
        if (page >= totalPages) break;
      }
      _posts = loaded;
      _page = lastPage;
      _totalPages = totalPages;
    } catch (e) {
      if (_disposed || generation != _generation) return;
      _error = ApiErrorHandler.handle(e);
      // A failed refresh must not keep a post visible after an access change.
      _posts = [];
    } finally {
      if (generation == _generation) {
        _isLoading = false;
        _emit();
      }
    }
  }

  Future<void> loadMore() async {
    if (_disposed ||
        _sessionEnded ||
        _isLoading ||
        _isLoadingMore ||
        !hasMore) {
      return;
    }
    final generation = _generation;
    _isLoadingMore = true;
    _emit();
    try {
      final response = await _dataSource.getPosts(
        page: _page + 1,
        userId: _selectedTab == 2 ? _owner : null,
        type: _selectedTab == 1 ? 'JOURNEY_SHARE' : null,
      );
      if (_disposed || generation != _generation) return;
      final ids = _posts.map((p) => p.postId).toSet();
      _posts.addAll(response.items.where((p) => ids.add(p.postId)));
      _page = response.page;
      _totalPages = response.totalPages;
    } catch (e) {
      if (generation == _generation) _error = ApiErrorHandler.handle(e);
    } finally {
      _isLoadingMore = false;
      _emit();
    }
  }

  Future<void> toggleLike(String postId) async {
    if (_disposed || _sessionEnded) return;
    if (!_liking.add(postId)) return;
    final post = _posts.where((p) => p.postId == postId).firstOrNull;
    if (post == null) {
      _liking.remove(postId);
      return;
    }
    try {
      _actionError = null;
      if (post.isLiked) {
        await _dataSource.unlikePost(postId);
      } else {
        await _dataSource.likePost(postId);
      }
      await loadPosts(silent: true);
    } catch (e) {
      _actionError = ApiErrorHandler.handle(e);
      _emit();
    } finally {
      _liking.remove(postId);
    }
  }

  void hidePost(String id) {
    _hiddenPostIds.add(id);
    _emit();
  }

  void unhidePost(String id) {
    _hiddenPostIds.remove(id);
    _emit();
  }

  void addPost(PostModel post) {
    loadPosts(silent: true);
  }

  void hideAuthor(String id) {
    _hiddenAuthorIds.add(id);
    _emit();
  }

  void unhideAuthor(String id) {
    _hiddenAuthorIds.remove(id);
    _emit();
  }

  Future<bool> deletePost(PostModel post) async {
    if (_disposed ||
        _sessionEnded ||
        !ownsPost(post) ||
        !_deleting.add(post.postId)) {
      return false;
    }
    _actionError = null;
    try {
      await _dataSource.deletePost(post.postId);
      if (_disposed || _sessionEnded) return false;
      // Invalidate any older fetch that could resurrect the removed post.
      _generation++;
      _posts.removeWhere((p) => p.postId == post.postId);
      await loadPosts(silent: true);
      return true;
    } catch (e) {
      _actionError = ApiErrorHandler.handle(e);
      _emit();
      return false;
    } finally {
      _deleting.remove(post.postId);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    _refresh?.cancel();
    _realtime?.dispose();
    _authSubscription?.cancel();
    super.dispose();
  }
}
