import 'package:flutter/material.dart';

import '../../../features/community/data/models/comment_model.dart';

class CommentItem extends StatelessWidget {
  final CommentModel comment;
  final VoidCallback? onLike, onReply, onUserTap, onEdit, onDelete;
  final bool isReply;
  const CommentItem({
    super.key,
    required this.comment,
    this.onLike,
    this.onReply,
    this.onUserTap,
    this.onEdit,
    this.onDelete,
    this.isReply = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final avatar = comment.userAvatar;
    return Padding(
      padding: EdgeInsets.only(left: isReply ? 40 : 0, top: 8, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: comment.deleted ? null : onUserTap,
            child: CircleAvatar(
              radius: isReply ? 14 : 18,
              backgroundImage: avatar != null && avatar.isNotEmpty
                  ? NetworkImage(avatar)
                  : null,
              child: avatar == null || avatar.isEmpty
                  ? Text(comment.userName.isEmpty ? 'T' : comment.userName[0])
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        comment.userName,
                        style: theme.textTheme.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(comment.timeAgo, style: theme.textTheme.bodySmall),
                    if (!comment.deleted &&
                        (onEdit != null || onDelete != null))
                      PopupMenuButton<String>(
                        tooltip: 'Tùy chọn bình luận',
                        onSelected: (value) {
                          if (value == 'edit') onEdit?.call();
                          if (value == 'delete') onDelete?.call();
                        },
                        itemBuilder: (_) => [
                          if (onEdit != null)
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Sửa bình luận'),
                            ),
                          if (onDelete != null)
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Xóa bình luận'),
                            ),
                        ],
                      ),
                  ],
                ),
                Text(
                  comment.content,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: comment.deleted
                        ? colors.onSurfaceVariant
                        : colors.onSurface,
                    fontStyle: comment.deleted
                        ? FontStyle.italic
                        : FontStyle.normal,
                  ),
                ),
                if (!comment.deleted)
                  Wrap(
                    spacing: 12,
                    children: [
                      TextButton.icon(
                        onPressed: onLike,
                        icon: Icon(
                          comment.isLiked
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Colors.redAccent,
                          size: 18,
                        ),
                        label: Text(
                          comment.likeCount > 0
                              ? '${comment.likeCount} Thích'
                              : 'Thích',
                        ),
                      ),
                      TextButton(
                        onPressed: onReply,
                        child: const Text('Phản hồi'),
                      ),
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
