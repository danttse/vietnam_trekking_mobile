class PostModel {
  final String postId;
  final String authorId;
  final String? authorName;
  final String? authorAvatar;
  final String content;
  final List<String> images;
  final String type;
  final String? journeyId;
  final String? trekkingPlaceId;
  final String? trekPlaceName;
  final int reactionCount;
  final int commentCount;
  final bool isLiked;
  final String visibility;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const PostModel({
    required this.postId,
    required this.authorId,
    this.authorName,
    this.authorAvatar,
    required this.content,
    this.images = const [],
    this.type = 'NORMAL',
    this.journeyId,
    this.trekkingPlaceId,
    this.trekPlaceName,
    this.reactionCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
    this.visibility = 'PUBLIC',
    required this.createdAt,
    this.updatedAt,
  });

  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inSeconds < 60) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  factory PostModel.fromJson(Map<String, dynamic> json) => PostModel(
    postId: json['postId'] as String,
    authorId: json['authorId'] as String,
    authorName: json['authorName'] as String?,
    authorAvatar: json['authorAvatar'] as String?,
    content: json['content'] as String? ?? '',
    images: List<String>.from(json['images'] as List? ?? []),
    type: json['type'] as String? ?? 'NORMAL',
    journeyId: json['journeyId'] as String?,
    trekkingPlaceId: json['trekkingPlaceId'] as String?,
    trekPlaceName: json['trekPlaceName'] as String?,
    reactionCount: (json['reactionCount'] as num?)?.toInt() ?? 0,
    commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
    isLiked: json['isLiked'] == true,
    visibility: json['visibility'] as String? ?? 'PUBLIC',
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
  );

  PostModel copyWith({
    String? postId,
    String? authorId,
    String? authorName,
    String? authorAvatar,
    String? content,
    List<String>? images,
    String? type,
    String? journeyId,
    String? trekkingPlaceId,
    String? trekPlaceName,
    int? reactionCount,
    int? commentCount,
    bool? isLiked,
    String? visibility,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PostModel(
      postId: postId ?? this.postId,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      content: content ?? this.content,
      images: images ?? this.images,
      type: type ?? this.type,
      journeyId: journeyId ?? this.journeyId,
      trekkingPlaceId: trekkingPlaceId ?? this.trekkingPlaceId,
      trekPlaceName: trekPlaceName ?? this.trekPlaceName,
      reactionCount: reactionCount ?? this.reactionCount,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
      visibility: visibility ?? this.visibility,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
