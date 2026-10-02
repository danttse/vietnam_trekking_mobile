import 'package:flutter/material.dart';
import '../data/datasources/comment_sample_data.dart';
import '../data/models/comment_model.dart';
import '../data/models/comment_thread_model.dart';

class CommentViewModel extends ChangeNotifier {
  final String postId;

  CommentViewModel({required this.postId}) {
    loadComments();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<CommentModel> _comments = [];
  List<CommentModel> get comments => _comments;

  List<CommentThreadModel> _threads = [];
  List<CommentThreadModel> get threads => _threads;

  CommentModel? _replyingToComment;
  CommentModel? get replyingToComment => _replyingToComment;

  final TextEditingController textController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  Future<void> loadComments() async {
    _isLoading = true;
    notifyListeners();

    // Lấy dữ liệu mẫu từ CommentSampleData theo postId
    final data = CommentSampleData.getCommentsByPostId(postId);
    _comments = data.isNotEmpty ? List.from(data) : List.from(CommentSampleData.getSampleComments());
    _buildThreads();

    _isLoading = false;
    notifyListeners();
  }

  void _buildThreads() {
    final rootComments = _comments.where((c) => c.isRoot).toList();
    final replies = _comments.where((c) => !c.isRoot).toList();

    _threads = rootComments.map((root) {
      final threadReplies = replies.where((r) => r.rootCommentId == root.id).toList();
      threadReplies.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return CommentThreadModel(
        rootComment: root,
        replies: threadReplies,
        isSeeMore: false,
      );
    }).toList();
  }

  void toggleSeeMore(String rootCommentId) {
    final index = _threads.indexWhere((t) => t.rootComment.id == rootCommentId);
    if (index != -1) {
      final current = _threads[index];
      _threads[index] = current.copyWith(isSeeMore: !current.isSeeMore);
      notifyListeners();
    }
  }

  void toggleLike(String commentId) {
    final index = _comments.indexWhere((c) => c.id == commentId);
    if (index != -1) {
      final comment = _comments[index];
      final newIsLiked = !comment.isLiked;
      final newLikeCount = newIsLiked ? comment.likeCount + 1 : comment.likeCount - 1;

      _comments[index] = comment.copyWith(
        isLiked: newIsLiked,
        likeCount: newLikeCount < 0 ? 0 : newLikeCount,
      );

      _updateCommentInThreads(_comments[index]);
      notifyListeners();
    }
  }

  void _updateCommentInThreads(CommentModel updatedComment) {
    for (int i = 0; i < _threads.length; i++) {
      if (_threads[i].rootComment.id == updatedComment.id) {
        _threads[i] = _threads[i].copyWith(rootComment: updatedComment);
        return;
      }
      final replyIndex = _threads[i].replies.indexWhere((r) => r.id == updatedComment.id);
      if (replyIndex != -1) {
        final newReplies = List<CommentModel>.from(_threads[i].replies);
        newReplies[replyIndex] = updatedComment;
        _threads[i] = _threads[i].copyWith(replies: newReplies);
        return;
      }
    }
  }

  void setReplyingTo(CommentModel? comment) {
    _replyingToComment = comment;
    notifyListeners();
    if (comment != null) {
      focusNode.requestFocus();
    }
  }

  void cancelReplying() {
    _replyingToComment = null;
    notifyListeners();
  }

  void sendComment({
    String currentUserId = 'current_user_id',
    String currentUserName = 'Tôi',
    String? currentUserAvatar,
  }) {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    final target = _replyingToComment;

    final newComment = CommentModel(
      id: 'cmt_${DateTime.now().millisecondsSinceEpoch}',
      postId: postId,
      userId: currentUserId,
      userName: currentUserName,
      userAvatar: currentUserAvatar,
      content: text,
      parentCommentId: target?.id,
      rootCommentId: target == null ? null : (target.rootCommentId ?? target.id),
      replyToUserName: target?.userName,
      createdAt: DateTime.now(),
    );

    _comments.add(newComment);

    if (newComment.isRoot) {
      _threads.insert(
        0,
        CommentThreadModel(rootComment: newComment, replies: [], isSeeMore: false),
      );
    } else {
      final threadIndex = _threads.indexWhere((t) => t.rootComment.id == newComment.rootCommentId);
      if (threadIndex != -1) {
        final updatedReplies = List<CommentModel>.from(_threads[threadIndex].replies)..add(newComment);
        _threads[threadIndex] = _threads[threadIndex].copyWith(
          replies: updatedReplies,
          isSeeMore: true,
        );
      }
    }

    textController.clear();
    _replyingToComment = null;
    focusNode.unfocus();
    notifyListeners();
  }

  @override
  void dispose() {
    textController.dispose();
    focusNode.dispose();
    super.dispose();
  }
}
