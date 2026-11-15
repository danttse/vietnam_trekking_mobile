import 'package:flutter/material.dart';

import '../../../features/community/data/models/comment_model.dart';
import '../../../features/community/data/models/comment_thread_model.dart';
import 'comment_item.dart';

class CommentThreadItem extends StatelessWidget {
  final CommentThreadModel commentThread;
  final Function(CommentModel) onReply;
  final Function(CommentModel) onLike;
  final VoidCallback? onTapSeeMore;
  final bool Function(CommentModel)? canEdit, canDelete;
  final void Function(CommentModel)? onEdit, onDelete;

  const CommentThreadItem({
    super.key,
    required this.commentThread,
    required this.onReply,
    required this.onLike,
    this.onTapSeeMore,
    this.canEdit,
    this.canDelete,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommentItem(
            comment: commentThread.rootComment,
            onEdit: canEdit?.call(commentThread.rootComment) == true
                ? () => onEdit?.call(commentThread.rootComment)
                : null,
            onDelete: canDelete?.call(commentThread.rootComment) == true
                ? () => onDelete?.call(commentThread.rootComment)
                : null,
            onLike: () {
              if (!commentThread.rootComment.deleted) {
                onLike(commentThread.rootComment);
              }
            },
            onReply: () {
              if (!commentThread.rootComment.deleted) {
                onReply(commentThread.rootComment);
              }
            },
          ),
          const SizedBox(height: 2),
          if (commentThread.replies.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(left: 48.0),
              child: TextButton(
                onPressed: onTapSeeMore,
                child: Text(
                  commentThread.isSeeMore
                      ? 'Ẩn phản hồi'
                      : 'Xem thêm ${commentThread.replies.length} phản hồi',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
            if (commentThread.isSeeMore)
              ...commentThread.replies.map(
                (reply) => CommentItem(
                  comment: reply,
                  onEdit: canEdit?.call(reply) == true
                      ? () => onEdit?.call(reply)
                      : null,
                  onDelete: canDelete?.call(reply) == true
                      ? () => onDelete?.call(reply)
                      : null,
                  isReply: true,
                  onLike: () => onLike(reply),
                  onReply: () => onReply(reply),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
