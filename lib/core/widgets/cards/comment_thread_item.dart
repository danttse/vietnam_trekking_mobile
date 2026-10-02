import 'package:flutter/material.dart';
import '../../../features/community/data/models/comment_model.dart';
import '../../../features/community/data/models/comment_thread_model.dart';
import 'comment_item.dart';

class CommentThreadItem extends StatelessWidget {
  final CommentThreadModel commentThread;
  final Function(CommentModel) onReply;
  final Function(CommentModel) onLike;
  final VoidCallback? onTapSeeMore;

  const CommentThreadItem({
    super.key,
    required this.commentThread,
    required this.onReply,
    required this.onLike,
    this.onTapSeeMore,

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
            onLike: () => onLike(commentThread.rootComment),
            onReply: () => onReply(commentThread.rootComment),
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