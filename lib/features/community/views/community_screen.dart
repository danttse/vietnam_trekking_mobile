import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/widgets/app_bar/app_top_bar.dart';
import '../../../core/widgets/cards/post_card.dart';
import '../../../l10n/app_localizations.dart';
import '../data/models/post_model.dart';
import '../viewmodels/community_view_model.dart';
import 'create_new_post_creen.dart';
import 'show_comment_screen.dart';
import 'community_action_dialogs.dart';
import 'community_people.dart';
import 'community_messages.dart';
import '../viewmodels/social_view_model.dart';
import '../data/datasources/social_api.dart';

class CommunityScreen extends StatefulWidget {
  final CommunityViewModel? viewModel;
  final SocialApi? socialApi;
  final SocialViewModel? socialViewModel;
  final bool socialRealtimeEnabled;
  const CommunityScreen({
    super.key,
    this.viewModel,
    this.socialApi,
    this.socialViewModel,
    this.socialRealtimeEnabled = true,
  });

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  late final CommunityViewModel _viewModel;
  SocialViewModel? _social;
  int _profileRevision = 0;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? CommunityViewModel();
  }

  @override
  void dispose() {
    if (widget.viewModel == null) _viewModel.dispose();
    if (widget.socialViewModel == null) _social?.dispose();
    super.dispose();
  }

  Widget _buildFilterChips(ColorScheme colorScheme, AppLocalizations l10n) {
    final tabs = [
      l10n.communityTabPosts,
      'Tin nhắn',
      l10n.communityTabPersonal,
    ];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: tabs.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _viewModel.selectedTab == index;
          return InkWell(
            onTap: () => _viewModel.setTab(index),
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(
                tabs[index],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _editPost(PostModel post) async {
    final updated = await Navigator.push<PostModel>(
      context,
      MaterialPageRoute(builder: (_) => CreateNewPostCreen(post: post)),
    );
    if (mounted && updated != null) await _viewModel.loadPosts(silent: true);
  }

  Future<void> _deletePost(PostModel post) async {
    if (!await confirmCommunityDelete(
      context,
      title: 'Xóa bài viết?',
      message: 'Bài viết và nội dung bình luận sẽ bị xóa khỏi cộng đồng.',
    )) {
      return;
    }
    if (!mounted) return;
    final deleted = await _viewModel.deletePost(post);
    if (!mounted || deleted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_viewModel.actionError ?? 'Không thể xóa bài viết.'),
      ),
    );
  }

  Future<void> _likePost(String id) async {
    await _viewModel.toggleLike(id);
    if (!mounted || _viewModel.actionError == null) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(_viewModel.actionError!)));
  }

  Future<void> _copyPost(PostModel post) async {
    await Clipboard.setData(
      ClipboardData(text: [post.content, ...post.images].join('\n')),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã sao chép nội dung bài viết.')),
    );
  }

  void _showPostOptions(BuildContext context, PostModel post) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surfaceContainerHighest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_viewModel.ownsPost(post)) ...[
                    ListTile(
                      leading: const Icon(Icons.edit_outlined),
                      title: const Text('Sửa bài viết'),
                      onTap: () {
                        Navigator.pop(modalContext);
                        _editPost(post);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.delete_outline),
                      title: const Text('Xóa bài viết'),
                      onTap: () {
                        Navigator.pop(modalContext);
                        _deletePost(post);
                      },
                    ),
                  ],
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.3,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.visibility_off_outlined,
                      color: colorScheme.onSurface,
                    ),
                    title: Text(
                      l10n.postHideThis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      l10n.postHideSubtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(modalContext);
                      _viewModel.hidePost(post.postId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.postHiddenMessage),
                          action: SnackBarAction(
                            label: l10n.undo,
                            textColor: colorScheme.primary,
                            onPressed: () {
                              _viewModel.unhidePost(post.postId);
                            },
                          ),
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.person_off_outlined,
                      color: colorScheme.onSurface,
                    ),
                    title: Text(
                      l10n.postHideAllFrom(post.authorName ?? l10n.thisPerson),
                      style: TextStyle(
                        fontSize: 15,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(modalContext);
                      _viewModel.hideAuthor(post.authorId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            l10n.postHideAllFrom(
                              post.authorName ?? l10n.thisPerson,
                            ),
                          ),
                          action: SnackBarAction(
                            label: l10n.undo,
                            onPressed: () =>
                                _viewModel.unhideAuthor(post.authorId),
                          ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.flag_outlined,
                      color: Colors.redAccent,
                    ),
                    title: Text(
                      l10n.postReport,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.redAccent,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(modalContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Tính năng báo cáo bài viết chưa khả dụng.',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
            AppTopBar(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/images/img_app_logo_ver2.png',
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                ),
              ),
              title: l10n.appName,
              icon: Icons.person_search_outlined,
              onClickIcon: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PeopleSearchScreen(api: widget.socialApi),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Tab bar
            ListenableBuilder(
              listenable: _viewModel,
              builder: (context, _) => _buildFilterChips(colorScheme, l10n),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListenableBuilder(
                listenable: _viewModel,
                builder: (context, _) {
                  if (_viewModel.selectedTab == 1) {
                    _social ??=
                        widget.socialViewModel ??
                        SocialViewModel(api: widget.socialApi);
                    return CommunityMessages(model: _social!);
                  }
                  if (_viewModel.selectedTab == 2) {
                    return CommunityProfileScreen(
                      api: widget.socialApi,
                      realtimeEnabled: widget.socialRealtimeEnabled,
                      key: ValueKey(_profileRevision),
                      embedded: true,
                    );
                  }
                  final posts = _viewModel.posts;
                  if (_viewModel.isLoading && posts.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (_viewModel.error != null) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_viewModel.error!, textAlign: TextAlign.center),
                          TextButton(
                            onPressed: _viewModel.loadPosts,
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    );
                  }
                  if (posts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.article_outlined,
                            size: 48,
                            color: colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.communityNoPosts,
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 14,
                            ),
                          ),
                          TextButton(
                            onPressed: _viewModel.loadPosts,
                            child: const Text('Tải lại'),
                          ),
                        ],
                      ),
                    );
                  }
                  return NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification.metrics.extentAfter < 400) {
                        _viewModel.loadMore();
                      }
                      return false;
                    },
                    child: RefreshIndicator(
                      onRefresh: _viewModel.loadPosts,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(top: 4, bottom: 80),
                        itemCount: posts.length + (_viewModel.hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == posts.length) {
                            return TextButton(
                              onPressed: _viewModel.isLoadingMore
                                  ? null
                                  : _viewModel.loadMore,
                              child: Text(
                                _viewModel.isLoadingMore
                                    ? 'Đang tải...'
                                    : 'Xem thêm',
                              ),
                            );
                          }
                          final post = posts[index];
                          return PostCard(
                            post: post,
                            onAuthorTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CommunityProfileScreen(
                                  api: widget.socialApi,
                                  userId: post.authorId,
                                ),
                              ),
                            ),
                            onLike: () => _likePost(post.postId),
                            onComment: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ShowCommentScreen(post: post),
                                ),
                              );
                              if (mounted) {
                                await _viewModel.loadPosts(silent: true);
                              }
                            },
                            onShare: () => _copyPost(post),
                            onMoreOptions: () =>
                                _showPostOptions(context, post),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) => _viewModel.selectedTab == 1
              ? const SizedBox.shrink()
              : Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: FloatingActionButton(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: const CircleBorder(),
                    elevation: 4,
                    onPressed: () async {
                      final newPost = await Navigator.push<PostModel>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateNewPostCreen(),
                        ),
                      );
                      if (mounted && newPost != null) {
                        _viewModel.addPost(newPost);
                        setState(() => _profileRevision++);
                      }
                    },
                    child: const Icon(Icons.add, size: 28),
                  ),
                ),
        ),
      ),
    );
  }
}
