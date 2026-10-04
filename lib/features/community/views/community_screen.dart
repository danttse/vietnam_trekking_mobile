import 'package:flutter/material.dart';
import '../../../core/widgets/app_bar/app_top_bar.dart';
import '../../../core/widgets/cards/post_card.dart';
import '../../../l10n/app_localizations.dart';
import '../data/models/post_model.dart';
import '../viewmodels/community_view_model.dart';
import 'create_new_post_creen.dart';
import 'show_comment_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  late final CommunityViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = CommunityViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Widget _buildFilterChips(ColorScheme colorScheme, AppLocalizations l10n) {
    final tabs = [
      l10n.communityTabPosts,
      l10n.communityTabGroups,
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
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.w500,
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

  void _showPostOptions(BuildContext context, PostModel post) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surfaceContainerHighest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.visibility_off_outlined,
                      color: colorScheme.onSurface),
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
                  leading: Icon(Icons.person_off_outlined,
                      color: colorScheme.onSurface),
                  title: Text(
                    l10n.postHideAllFrom(post.authorName ?? l10n.thisPerson),
                    style: TextStyle(
                      fontSize: 15,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(modalContext);
                    _viewModel.hidePost(post.postId);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.flag_outlined, color: Colors.redAccent),
                  title: Text(
                    l10n.postReport,
                    style: const TextStyle(fontSize: 15, color: Colors.redAccent),
                  ),
                  onTap: () {
                    Navigator.pop(modalContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.postReportSuccess),
                      ),
                    );
                  },
                ),
              ],
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
              icon: Icons.notifications_none_outlined,
              onClickIcon: () {
              },
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
                  final posts = _viewModel.posts;
                  if (posts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.article_outlined,
                            size: 48,
                            color: colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.communityNoPosts,
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 4, bottom: 80),
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return PostCard(
                        post: post,
                        onLike: () => _viewModel.toggleLike(post.postId),
                        onComment: () =>
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ShowCommentScreen(post: post,),
                            ),
                          ),
                        onShare: () {},
                        onMoreOptions: () => _showPostOptions(context, post),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: Container(
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
              if (newPost != null) {
                _viewModel.addPost(newPost);
              }
            },
            child: const Icon(Icons.add, size: 28),
          ),
        ),
      ),
    );
  }
}
