import 'package:flutter/material.dart';

import '../../../core/widgets/app_bar/app_top_bar_with_back.dart';
import '../../../core/widgets/cards/comment_thread_item.dart';
import '../../../l10n/app_localizations.dart';
import '../data/models/post_model.dart';
import '../viewmodels/comment_viewmodel.dart';
import '../data/models/comment_model.dart';
import 'community_action_dialogs.dart';

class ShowCommentScreen extends StatefulWidget {
  final PostModel post;
  final CommentViewModel? viewModel;

  const ShowCommentScreen({super.key, required this.post, this.viewModel});

  @override
  State<ShowCommentScreen> createState() => _ShowCommentScreenState();
}

class _ShowCommentScreenState extends State<ShowCommentScreen> {
  late final CommentViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    final targetPostId = widget.post.postId;
    _viewModel =
        widget.viewModel ??
        CommentViewModel(
          postId: targetPostId,
          postAuthorId: widget.post.authorId,
        );
  }

  @override
  void dispose() {
    if (widget.viewModel == null) _viewModel.dispose();
    super.dispose();
  }

  Future<void> _edit(CommentModel comment) => showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => EditCommunityCommentDialog(
      content: comment.content,
      onSave: (text) async {
        final saved = await _viewModel.editComment(comment, text);
        return saved
            ? null
            : (_viewModel.actionError ?? 'Không thể lưu bình luận.');
      },
    ),
  );

  Future<void> _delete(CommentModel comment) async {
    if (!await confirmCommunityDelete(
      context,
      title: 'Xóa bình luận?',
      message: 'Nội dung bình luận sẽ bị xóa. Các phản hồi vẫn được giữ lại.',
    )) {
      return;
    }
    if (!mounted) return;
    final deleted = await _viewModel.deleteComment(comment);
    if (!mounted || deleted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_viewModel.actionError ?? 'Không thể xóa bình luận.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: Column(
          children: [
            AppTopBarWithBack(
              title: l10n.commentsTitle,
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: ListenableBuilder(
                listenable: _viewModel,
                builder: (context, _) {
                  if (_viewModel.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (_viewModel.error != null) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_viewModel.error!, textAlign: TextAlign.center),
                          TextButton(
                            onPressed: _viewModel.loadComments,
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    );
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
                            color: colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.noCommentsYet,
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.beFirstToComment,
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.7,
                              ),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: _viewModel.loadComments,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                      itemCount: threads.length,
                      itemBuilder: (context, index) {
                        final thread = threads[index];
                        return CommentThreadItem(
                          commentThread: thread,
                          canEdit: _viewModel.canEdit,
                          canDelete: _viewModel.canDelete,
                          onEdit: _edit,
                          onDelete: _delete,
                          onLike: (comment) =>
                              _viewModel.toggleLike(comment.id),
                          onReply: (comment) =>
                              _viewModel.setReplyingTo(comment),
                          onTapSeeMore: () =>
                              _viewModel.toggleSeeMore(thread.rootComment.id),
                        );
                      },
                    ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.reply, size: 16, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.replyingTo(replying.userName),
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
                          enabled: !_viewModel.isSending,
                          maxLength: 2000,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            hintText: replying != null
                                ? l10n.replyToHint(replying.userName)
                                : l10n.writeCommentHint,
                            errorText: _viewModel.actionError,
                            hintStyle: TextStyle(
                              color: colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.6,
                              ),
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
                    icon: Icon(Icons.send_rounded, color: colorScheme.primary),
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
