import 'package:flutter/material.dart';
import '../../../core/widgets/app_bar/app_top_bar.dart';
import '../../../core/widgets/cards/post_card.dart';
import '../data/models/post_model.dart';
import '../viewmodels/community_view_model.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  late final CommunityViewModel _viewModel;
  static const List<String> _tabs = ['Bài viết', 'Nhóm', 'Cá nhân'];

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

  Widget _buildFilterChips(ColorScheme colorScheme) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _tabs.length,
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
                _tabs[index],
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
                    'Ẩn bài viết này',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    'Bớt nhìn thấy các bài viết tương tự trên bảng tin',
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
                        content: const Text('Đã ẩn bài viết'),
                        action: SnackBarAction(
                          label: 'Hoàn tác',
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
                    'Ẩn tất cả từ ${post.authorName ?? "người này"}',
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
                  title: const Text(
                    'Báo cáo bài viết',
                    style: TextStyle(fontSize: 15, color: Colors.redAccent),
                  ),
                  onTap: () {
                    Navigator.pop(modalContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cảm ơn bạn đã gửi báo cáo. Chúng tôi sẽ xem xét nội dung này.'),
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
              title: 'TrekViệt',
              icon: Icons.notifications_none_outlined,
              onClickIcon: () {
              },
            ),
            const SizedBox(height: 8),
            // Tab bar
            ListenableBuilder(
              listenable: _viewModel,
              builder: (context, _) => _buildFilterChips(colorScheme),
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
                            'Chưa có bài viết nào',
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
                        onComment: () {},
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
            onPressed: () {},
            child: const Icon(Icons.add, size: 28),
          ),
        ),
      ),
    );
  }
}
