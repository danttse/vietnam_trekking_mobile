import 'package:flutter/material.dart';
import '../../../features/community/data/models/comment_model.dart';

class CommentItem extends StatelessWidget {
  final CommentModel comment;
  final VoidCallback? onLike;
  final VoidCallback? onReply;
  final VoidCallback? onUserTap;
  final bool isReply;

  const CommentItem({
    super.key,
    required this.comment,
    this.onLike,
    this.onReply,
    this.onUserTap,
    this.isReply = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        left: isReply ? 48.0 : 16.0,
        right: 16.0,
        top: 5.0,
        bottom: 5.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onUserTap,
            child: CircleAvatar(
              radius: isReply ? 14 : 18,
              backgroundColor: colorScheme.surfaceContainerHighest,
              backgroundImage: comment.userAvatar != null && comment.userAvatar!.isNotEmpty
                  ? NetworkImage(comment.userAvatar!)
                  : null,
              child: comment.userAvatar == null || comment.userAvatar!.isEmpty
                  ? Text(
                      comment.userName.isNotEmpty ? comment.userName[0].toUpperCase() : 'U',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: isReply ? 12 : 14,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      comment.userName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      comment.timeAgo,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.9),
                      fontSize: 13.5,
                      height: 1.35,
                    ),
                    children: [
                      if (comment.replyToUserName != null) ...[
                        TextSpan(
                          text: '@${comment.replyToUserName} ',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      TextSpan(text: comment.content),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    InkWell(
                      onTap: onLike,
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                        child: Row(
                          children: [
                            Icon(
                              comment.isLiked ? Icons.favorite : Icons.favorite_border,
                              size: 19,
                              color: Colors.redAccent,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              comment.likeCount > 0
                                  ? '${comment.likeCount} Thích'
                                  : 'Thích',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: comment.isLiked ? FontWeight.w600 : FontWeight.w400,
                                color: comment.isLiked ? colorScheme.onSurface: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    InkWell(
                      onTap: onReply,
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                        child: Text(
                          'Phản hồi',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w400,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    if (comment.userId == 'current_user_id') ...[
                      const SizedBox(width: 16),
                      InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                          child: Text(
                            'Xóa',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w400,
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(width: 16),
                      InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                          child: Text(
                            'Báo cáo',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w400,
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}