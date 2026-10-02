import 'package:flutter/material.dart';
import '../../../core/widgets/app_bar/app_top_bar_with_back.dart';
import '../../../core/widgets/cards/comment_thread_item.dart';
import '../data/models/post_model.dart';
import '../viewmodels/comment_viewmodel.dart';

class ShowCommentScreen extends StatefulWidget {
  final String postId;
  final PostModel post;

  const ShowCommentScreen({
    super.key,
    this.postId = 'post_001',
    required this.post,
  });

  @override
  State<ShowCommentScreen> createState() => _ShowCommentScreenState();
}

class _ShowCommentScreenState extends State<ShowCommentScreen> {
  late final CommentViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    final targetPostId = widget.post?.postId ?? widget.postId;
    _viewModel = CommentViewModel(postId: targetPostId);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: Column(
          children: [
            AppTopBarWithBack(
              title: "Bình luận",
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: ListenableBuilder(
                listenable: _viewModel,
                builder: (context, _) {
                  if (_viewModel.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final threads = _viewModel.threads;
                  if (threads.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 48,
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Chưa có bình luận nào',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Hãy là người đầu tiên bình luận!',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                    itemCount: threads.length,
                    itemBuilder: (context, index) {
                      final thread = threads[index];
                      return CommentThreadItem(
                        commentThread: thread,
                        onLike: (comment) => _viewModel.toggleLike(comment.id),
                        onReply: (comment) => _viewModel.setReplyingTo(comment),
                        onTapSeeMore: () => _viewModel.toggleSeeMore(thread.rootComment.id),
                      );
                    },
                  );
                },
              ),
            ),

            ListenableBuilder(
              listenable: _viewModel,
              builder: (context, _) {
                final replying = _viewModel.replyingToComment;
                if (replying == null) return const SizedBox.shrink();

                return Container(
                  color: colorScheme.surfaceContainerHighest,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.reply,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Đang trả lời ${replying.userName}',
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      InkWell(
                        onTap: _viewModel.cancelReplying,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ListenableBuilder(
                      listenable: _viewModel,
                      builder: (context, _) {
                        final replying = _viewModel.replyingToComment;
                        return TextField(
                          controller: _viewModel.textController,
                          focusNode: _viewModel.focusNode,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            hintText: replying != null
                                ? 'Trả lời @${replying.userName}...'
                                : 'Viết bình luận...',
                            hintStyle: TextStyle(
                              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                              fontSize: 14,
                            ),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest,
                          ),
                          onSubmitted: (_) => _viewModel.sendComment(),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      Icons.send_rounded,
                      color: colorScheme.primary,
                    ),
                    onPressed: () => _viewModel.sendComment(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
