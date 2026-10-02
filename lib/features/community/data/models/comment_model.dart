class CommentModel {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String content;
  final String? parentCommentId;
  final String? rootCommentId;
  final String? replyToUserName;
  final int likeCount;
  final bool isLiked;
  final int replyCount;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.content,
    this.parentCommentId,
    this.rootCommentId,
    this.replyToUserName,
    this.likeCount = 0,
    this.isLiked = false,
    this.replyCount = 0,
    required this.createdAt,
  });

  bool get isRoot => parentCommentId == null;

  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inSeconds < 60) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút';
    if (diff.inHours < 24) return '${diff.inHours} giờ';
    if (diff.inDays == 1) return 'Hôm qua';
    if (diff.inDays < 7) return '${diff.inDays} ngày';
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  CommentModel copyWith({
    String? id,
    String? postId,
    String? userId,
    String? userName,
    String? userAvatar,
    String? content,
    String? parentCommentId,
    String? rootCommentId,
    String? replyToUserName,
    int? likeCount,
    bool? isLiked,
    int? replyCount,
    DateTime? createdAt,
  }) {
    return CommentModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      content: content ?? this.content,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      rootCommentId: rootCommentId ?? this.rootCommentId,
      replyToUserName: replyToUserName ?? this.replyToUserName,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
      replyCount: replyCount ?? this.replyCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}