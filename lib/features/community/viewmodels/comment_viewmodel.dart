import 'dart:async';

import 'package:flutter/material.dart';

import '../data/datasources/community_remote_datasource.dart';
import '../data/datasources/community_realtime.dart';
import '../data/models/comment_model.dart';
import '../data/models/comment_thread_model.dart';
import '../../../core/network/api_error_handler.dart';
import '../../../core/services/auth_event_bus.dart';
import '../../../core/services/offline_store.dart';

class CommentViewModel extends ChangeNotifier {
  final String postId;
  final CommunityRemoteDataSource _dataSource;
  final Future<String?> Function() _ownerProvider;
  final String? postAuthorId;
  CommunityRealtime? _realtime;
  StreamSubscription<AuthEvent>? _authSubscription;
  Timer? _refresh;
  bool _disposed = false, _isLoading = false, _isSending = false;
  int _generation = 0;
  String? _error;
  String? _actionError, _owner;
  bool _sessionEnded = false;
  List<CommentModel> _comments = [];
  List<CommentThreadModel> _threads = [];
  final Set<String> _expanded = {}, _liking = {};
  final Set<String> _mutating = {};
  CommentModel? _replyingToComment;
  final textController = TextEditingController();
  final focusNode = FocusNode();

  CommentViewModel({
    required this.postId,
    this.postAuthorId,
    Future<String?> Function()? ownerProvider,
    CommunityRemoteDataSource? dataSource,
    bool realtimeEnabled = true,
    bool autoLoad = true,
  }) : _dataSource = dataSource ?? CommunityRemoteDataSource(),
       _ownerProvider = ownerProvider ?? OfflineStore.currentOwner {
    _authSubscription = AuthEventBus().stream.listen((_) {
      _generation++;
      _sessionEnded = true;
      _owner = null;
      _isLoading = false;
      textController.clear();
      _replyingToComment = null;
      _comments = [];
      _threads = [];
      _refresh?.cancel();
      _realtime?.dispose();
      _emit();
    });
    if (autoLoad) loadComments();
    if (realtimeEnabled) {
      _realtime = CommunityRealtime(
        onEvent: (event) {
          if (event['type'] == 'ready' ||
              event['type'] == 'reconnect' ||
              event['postId'] == postId) {
            _refresh?.cancel();
            _refresh = Timer(
              const Duration(milliseconds: 200),
              () => loadComments(silent: true),
            );
          }
        },
      )..connect();
    }
  }

  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get error => _error;
  String? get actionError => _actionError;
  bool canEdit(CommentModel comment) =>
      !_sessionEnded &&
      !comment.deleted &&
      _owner != null &&
      comment.userId == _owner;
  bool canDelete(CommentModel comment) =>
      !_sessionEnded &&
      !comment.deleted &&
      _owner != null &&
      (comment.userId == _owner || postAuthorId == _owner);
  List<CommentModel> get comments => List.unmodifiable(_comments);
  List<CommentThreadModel> get threads => List.unmodifiable(_threads);
  CommentModel? get replyingToComment => _replyingToComment;
  void _emit() {
    if (!_disposed) notifyListeners();
  }

  Future<void> loadComments({bool silent = false}) async {
    if (_disposed || _sessionEnded) return;
    final generation = ++_generation;
    _isLoading = !silent;
    _error = null;
    _emit();
    try {
      _owner = await _ownerProvider();
      if (_disposed || generation != _generation) return;
      final comments = <CommentModel>[];
      // Read bounded server pages; preserve all parents for nested threads.
      var page = 1;
      while (true) {
        final response = await _dataSource.getComments(postId, page: page);
        if (_disposed || generation != _generation) return;
        comments.addAll(response.items);
        if (page >= response.totalPages) break;
        page++;
      }
      _comments = comments;
      _buildThreads();
    } catch (e) {
      if (_disposed || generation != _generation) return;
      _error = ApiErrorHandler.handle(e);
      _comments = [];
      _threads = [];
    } finally {
      if (generation == _generation) {
        _isLoading = false;
        _emit();
      }
    }
  }

  void _buildThreads() {
    _threads = _comments
        .where((c) => c.isRoot)
        .map(
          (root) => CommentThreadModel(
            rootComment: root,
            replies: _comments
                .where((c) => c.rootCommentId == root.id)
                .toList(),
            isSeeMore: _expanded.contains(root.id),
          ),
        )
        .toList();
  }

  void toggleSeeMore(String id) {
    if (!_expanded.add(id)) _expanded.remove(id);
    _buildThreads();
    _emit();
  }

  Future<void> toggleLike(String id) async {
    if (_disposed || _sessionEnded) return;
    final comment = _comments.where((c) => c.id == id).firstOrNull;
    if (comment == null || comment.deleted || !_liking.add(id)) return;
    try {
      _actionError = null;
      if (comment.isLiked) {
        await _dataSource.unlikeComment(id);
      } else {
        await _dataSource.likeComment(id);
      }
      await loadComments(silent: true);
    } catch (e) {
      _actionError = ApiErrorHandler.handle(e);
      _emit();
    } finally {
      _liking.remove(id);
    }
  }

  void setReplyingTo(CommentModel? comment) {
    if (comment?.deleted == true) return;
    _replyingToComment = comment;
    _emit();
    if (comment != null) focusNode.requestFocus();
  }

  void cancelReplying() {
    _replyingToComment = null;
    _emit();
  }

  Future<void> sendComment() async {
    if (_disposed || _sessionEnded) return;
    final text = textController.text.trim();
    if (text.isEmpty || _isSending) return;
    final target = _replyingToComment;
    _isSending = true;
    _actionError = null;
    _emit();
    try {
      await _dataSource.createComment(
        postId: postId,
        content: text,
        parentCommentId: target?.id,
      );
      if (_disposed || _sessionEnded) return;
      if (target != null) _expanded.add(target.rootCommentId ?? target.id);
      // Keep any new draft typed while this request was running.
      if (textController.text.trim() == text) textController.clear();
      _replyingToComment = null;
      await loadComments(silent: true);
    } catch (e) {
      _actionError = ApiErrorHandler.handle(e);
    } finally {
      _isSending = false;
      _emit();
    }
  }

  Future<bool> editComment(CommentModel comment, String content) async {
    final text = content.trim();
    if (_disposed || !canEdit(comment) || !_mutating.add(comment.id)) {
      return false;
    }
    _actionError = null;
    try {
      if (text.isEmpty || text.length > 2000) {
        throw StateError('Bình luận cần từ 1 đến 2.000 ký tự.');
      }
      await _dataSource.updateComment(comment.id, text);
      if (_disposed || _sessionEnded) return false;
      await loadComments(silent: true);
      return true;
    } catch (e) {
      _actionError = ApiErrorHandler.handle(e);
      _emit();
      return false;
    } finally {
      _mutating.remove(comment.id);
    }
  }

  Future<bool> deleteComment(CommentModel comment) async {
    if (_disposed || !canDelete(comment) || !_mutating.add(comment.id)) {
      return false;
    }
    _actionError = null;
    try {
      await _dataSource.deleteComment(comment.id);
      if (_disposed || _sessionEnded) return false;
      if (_replyingToComment?.id == comment.id) _replyingToComment = null;
      await loadComments(silent: true);
      return true;
    } catch (e) {
      _actionError = ApiErrorHandler.handle(e);
      _emit();
      return false;
    } finally {
      _mutating.remove(comment.id);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    _refresh?.cancel();
    _realtime?.dispose();
    _authSubscription?.cancel();
    textController.dispose();
    focusNode.dispose();
    super.dispose();
  }
}
