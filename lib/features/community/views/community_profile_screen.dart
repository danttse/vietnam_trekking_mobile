import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/widgets/app_bar/app_top_bar_with_back.dart';
import '../../../core/widgets/buttons/btn_login_style.dart';
import '../../../core/widgets/buttons/btn_outline_style.dart';
import '../../../core/widgets/cards/post_card.dart';
import '../../../l10n/app_localizations.dart';
import '../data/datasources/social_api.dart';
import '../viewmodels/community_profile_viewmodel.dart';
import 'community_helpers.dart';
import 'community_messages.dart';
import 'create_new_post_screen.dart';
import 'show_comment_screen.dart';

class CommunityProfileScreen extends StatefulWidget {
  final String? userId;
  final bool embedded;
  final SocialApi? api;
  final bool realtimeEnabled;
  final CommunityProfileViewModel? viewModel;

  const CommunityProfileScreen({
    super.key,
    this.userId,
    this.embedded = false,
    this.api,
    this.realtimeEnabled = true,
    this.viewModel,
  });

  @override
  State<CommunityProfileScreen> createState() => _ProfileState();
}

class _ProfileState extends State<CommunityProfileScreen> {
  late final CommunityProfileViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel =
        widget.viewModel ??
        CommunityProfileViewModel(
          userId: widget.userId,
          api: widget.api,
          realtimeEnabled: widget.realtimeEnabled,
        );
  }

  @override
  void dispose() {
    if (widget.viewModel == null) {
      _viewModel.dispose();
    }
    super.dispose();
  }

  Future<void> qr() async {
    final value = _viewModel.person?['qr'] as String?;
    if (value == null) return;
    final l10n = AppLocalizations.of(context)!;
    await showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l10n.personalQrTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 220,
                height: 220,
                child: QrImageView(
                  data: value,
                  size: 220,
                  backgroundColor: Colors.white,
                ),
              ),
              Text(l10n.personalQrDesc),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              Navigator.pop(c);
            },
            child: Text(l10n.copyCodeButton),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(l10n.closeButton),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final p = _viewModel.person;
        final loading = _viewModel.loading;
        final error = _viewModel.error;
        final busy = _viewModel.busy;
        final posts = _viewModel.posts;
        final page = _viewModel.page;
        final totalPages = _viewModel.totalPages;

        final body = RefreshIndicator(
          onRefresh: _viewModel.load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 80),
            children: [
              if (loading && p == null)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(error),
                      TextButton(
                        onPressed: _viewModel.load,
                        child: Text(l10n.commonRetry),
                      ),
                    ],
                  ),
                ),
              if (p != null)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      communityAvatar(
                        p['avatarUrl'] as String?,
                        p['name'] as String,
                        radius: 42,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        p['name'] as String,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        (p['bio'] as String).isEmpty
                            ? l10n.noBioYet
                            : p['bio'] as String,
                        textAlign: TextAlign.center,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          l10n.userPostsCount((p['postCount'] as num?)?.toInt() ?? 0),
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ),
                      if (p['isMe'] == true)
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            BtnOutlineStyle(
                              text: l10n.aboutSection,
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: busy
                                  ? null
                                  : () async {
                                      final bio = await socialText(
                                        context,
                                        l10n.personalBio,
                                        initial: p['bio'] as String,
                                        maxLength: 500,
                                      );
                                      if (bio == null || !mounted) return;
                                      try {
                                        await _viewModel.updateBio(bio);
                                      } catch (e) {
                                        if (context.mounted) {
                                          socialError(context, e);
                                        }
                                      }
                                    },
                            ),
                            BtnOutlineStyle(
                              text: l10n.myQrCode,
                              icon: const Icon(Icons.qr_code),
                              onPressed: qr,
                            ),
                            TextButton(
                              onPressed: busy
                                  ? null
                                  : () async {
                                      final ok = await showDialog<bool>(
                                        context: context,
                                        builder: (c) => AlertDialog(
                                          title: Text(l10n.reissueQrDialogTitle),
                                          content: Text(
                                            l10n.reissueQrDialogMessage,
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(c),
                                              child: Text(l10n.cancelButton),
                                            ),
                                            FilledButton(
                                              onPressed: () =>
                                                  Navigator.pop(c, true),
                                              child: Text(l10n.reissueButton),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (ok != true || !mounted) return;
                                      try {
                                        await _viewModel.regenerateQr();
                                      } catch (e) {
                                        if (context.mounted) {
                                          socialError(context, e);
                                        }
                                      }
                                    },
                              child: Text(l10n.reissueButton),
                            ),
                          ],
                        )
                      else
                        BtnLoginPrimary(
                          text: l10n.sendMessageButton,
                        isLoading: busy,
                        onPressed: busy
                            ? null
                            : () async {
                                try {
                                  final chat = await _viewModel
                                      .createDirectConversation();
                                  if (context.mounted) {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ConversationScreen(
                                          conversationId:
                                              chat['conversationId'] as String,
                                          api: _viewModel.api,
                                        ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) socialError(context, e);
                                }
                              },
                      ),
                  ],
                ),
              ),
            for (final post in posts)
              PostCard(
                post: post,
                onShare: () async {
                  await Clipboard.setData(
                    ClipboardData(
                      text: [post.content, ...post.images].join('\n'),
                    ),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.postCopiedToClipboard)),
                    );
                  }
                },
                onLike: () async {
                  try {
                    await _viewModel.toggleReaction(post);
                  } catch (e) {
                    if (context.mounted) socialError(context, e);
                  }
                },
                onComment: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ShowCommentScreen(post: post),
                  ),
                ),
                onMoreOptions: p?['isMe'] == true
                    ? () async {
                        final choice = await showModalBottomSheet<String>(
                          context: context,
                          builder: (c) => SafeArea(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  title: Text(l10n.postEditAction),
                                  leading: const Icon(Icons.edit),
                                  onTap: () => Navigator.pop(c, 'edit'),
                                ),
                                ListTile(
                                  title: Text(l10n.postDeleteAction),
                                  leading: const Icon(Icons.delete_outline),
                                  onTap: () => Navigator.pop(c, 'delete'),
                                ),
                              ],
                            ),
                          ),
                        );
                        if (!context.mounted) return;
                        try {
                          if (choice == 'edit') {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CreateNewPostScreen(post: post),
                              ),
                            );
                            await _viewModel.load();
                          }
                          if (!context.mounted) return;
                          if (choice == 'delete') {
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (c) => AlertDialog(
                                title: Text(l10n.postDeleteTitle),
                                content: Text(
                                  l10n.postDeleteMessage,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(c),
                                    child: Text(l10n.cancelButton),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(c, true),
                                    child: Text(l10n.commonDelete),
                                  ),
                                ],
                              ),
                            );
                            if (ok == true) {
                              await _viewModel.deletePost(post.postId);
                            }
                          }
                        } catch (e) {
                          if (context.mounted) socialError(context, e);
                        }
                      }
                    : null,
              ),
            if (!loading && posts.isEmpty && p != null)
              Padding(
                padding: const EdgeInsets.all(28),
                child: Center(child: Text(l10n.communityNoPosts)),
              ),
            if (page < totalPages)
              TextButton(
                onPressed: loading ? null : () => _viewModel.load(more: true),
                child: Text(l10n.viewMorePosts),
              ),
          ],
        ),
      );

      return widget.embedded
          ? body
          : Scaffold(
              body: SafeArea(
                child: Column(
                  children: [
                    AppTopBarWithBack(
                      title: l10n.communityProfileTitle,
                      onBack: () => Navigator.of(context).maybePop(),
                    ),
                    Expanded(child: body),
                  ],
                ),
              ),
            );
      },
    );
  }
}
