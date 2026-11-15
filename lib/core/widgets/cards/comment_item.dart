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
    final contentLeftPadding = isReply ? 38.0 : 46.0;

    return Padding(
      padding: EdgeInsets.only(left: isReply ? 40 : 0, top: 8, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: comment.deleted ? null : onUserTap,
                child: CircleAvatar(
                  radius: isReply ? 14 : 18,
                  backgroundImage: avatar != null && avatar.isNotEmpty
                      ? NetworkImage(avatar)
                      : null,
                  child: avatar == null || avatar.isEmpty
                      ? Text(
                          comment.userName.isEmpty ? 'T' : comment.userName[0],
                          style: TextStyle(
                            fontSize: isReply ? 12 : 14,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  comment.userName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                comment.timeAgo,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              if (!comment.deleted &&
                  (onEdit != null || onDelete != null)) ...[
                const SizedBox(width: 4),
                SizedBox(
                  width: 24,
                  height: 24,
                  child: PopupMenuButton<String>(
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
                    padding: EdgeInsets.zero,
                    iconSize: 18,
                    icon: Icon(
                      Icons.more_vert,
                      size: 18,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ],
          ),
          Padding(
            padding: EdgeInsets.only(left: contentLeftPadding, top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Wrap(
                      spacing: 12,
                      children: [
                        TextButton.icon(
                          onPressed: onLike,
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            minimumSize: const Size(0, 32),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
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
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            minimumSize: const Size(0, 32),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Phản hồi'),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
