import 'comment_model.dart';

class CommentThreadModel {
  final CommentModel rootComment;
  final List<CommentModel> replies;
  final bool isSeeMore;

  CommentThreadModel({
    required this.rootComment,
    List<CommentModel>? replies,
    this.isSeeMore = false,
  }) : replies = replies ?? const [];

  bool get isRoot => rootComment.parentCommentId == null;

  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(rootComment.createdAt);

    if (diff.inSeconds < 60) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút';
    if (diff.inHours < 24) return '${diff.inHours} giờ';
    if (diff.inDays == 1) return 'Hôm qua';
    if (diff.inDays < 7) return '${diff.inDays} ngày';
    return '${rootComment.createdAt.day}/${rootComment.createdAt.month}/${rootComment.createdAt.year}';
  }

  CommentThreadModel copyWith({
    CommentModel? rootComment,
    List<CommentModel>? replies,
    bool? isSeeMore,
  }) {
    return CommentThreadModel(
      rootComment: rootComment ?? this.rootComment,
      replies: replies ?? this.replies,
      isSeeMore: isSeeMore ?? this.isSeeMore,
    );
  }
}

typedef CommentThreadViewModel = CommentThreadModel;