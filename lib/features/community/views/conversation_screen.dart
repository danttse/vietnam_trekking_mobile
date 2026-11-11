import 'dart:async';

import 'package:flutter/material.dart';

import '../data/datasources/social_api.dart';
import '../viewmodels/conversation_view_model.dart';
import 'community_helpers.dart';
import 'community_profile_screen.dart';
import 'group_details_screen.dart';

class ConversationScreen extends StatefulWidget {
  final String conversationId;

  final SocialApi? api;

  final ConversationViewModel? viewModel;

  const ConversationScreen({
    super.key,

    required this.conversationId,

    this.api,

    this.viewModel,
  });

  @override
  State<ConversationScreen> createState() => _ConversationState();
}

class _ConversationState extends State<ConversationScreen> {
  late final model =
      widget.viewModel ??
      ConversationViewModel(id: widget.conversationId, api: widget.api);

  final draft = TextEditingController();

  @override
  void dispose() {
    if (widget.viewModel == null) model.dispose();

    draft.dispose();

    super.dispose();
  }

  Future<void> manage() async {
    final left = await Navigator.push<bool>(
      context,

      MaterialPageRoute(
        builder: (_) => GroupDetailsScreen(
          id: widget.conversationId,

          api: model.api,

          me: model.ownerId!,
        ),
      ),
    );

    if (!mounted) return;

    if (left == true) {
      Navigator.pop(context);

      return;
    }

    await model.load(silent: true);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: model,

    builder: (context, _) {
      final chat = model.conversation;

      return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              if (chat != null && chat['kind'] != 'GROUP') ...[
                () {
                  final other = (chat['members'] as List)
                      .where((m) => m['userId'] != model.ownerId)
                      .firstOrNull;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),

                    child: simpleAvatar(
                      other?['avatarUrl'] as String?,
                      radius: 16,
                    ),
                  );
                }(),
              ],

              Expanded(
                child: Text(
                  chat == null
                      ? 'Tin nhắn'
                      : conversationTitle(chat, model.ownerId),

                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          actions: [
            if (chat != null)
              IconButton(
                tooltip: chat['kind'] == 'GROUP'
                    ? 'Thông tin nhóm'
                    : 'Trang cá nhân',

                icon: const Icon(Icons.info_outline),

                onPressed: () {
                  if (chat['kind'] == 'GROUP') {
                    manage();
                  } else {
                    final other = (chat['members'] as List).firstWhere(
                      (m) => m['userId'] != model.ownerId,
                    );

                    Navigator.push(
                      context,

                      MaterialPageRoute(
                        builder: (_) => CommunityProfileScreen(
                          userId: other['userId'] as String,
                        ),
                      ),
                    );
                  }
                },
              ),
          ],
        ),

        body: Column(
          children: [
            if (model.error != null)
              Padding(
                padding: const EdgeInsets.all(12),

                child: Column(
                  children: [
                    Text(model.error!),

                    TextButton(
                      onPressed: model.load,

                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),

            if (model.loading) const LinearProgressIndicator(),

            if (chat?['disabled'] == true)
              const Padding(
                padding: EdgeInsets.all(12),

                child: Text('Nhóm đang tạm ngưng bởi quản trị viên.'),
              ),

            Expanded(
              child: ListView.builder(
                reverse: true,

                padding: const EdgeInsets.all(16),

                itemCount: model.messages.length + 1,

                itemBuilder: (context, index) {
                  if (index == model.messages.length) {
                    return model.nextBefore != null
                        ? TextButton(
                            onPressed: model.loading
                                ? null
                                : () => model.load(older: true),

                            child: const Text('Tin nhắn cũ hơn'),
                          )
                        : const SizedBox(height: 12);
                  }

                  final m = model.messages[model.messages.length - 1 - index];

                  final own = m['senderId'] == model.ownerId;

                  final sender = (chat?['members'] as List? ?? [])
                      .where((u) => u['userId'] == m['senderId'])
                      .firstOrNull;

                  // Component tin nhan kem avatar

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),

                    child: Row(
                      mainAxisAlignment: own
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,

                      crossAxisAlignment: CrossAxisAlignment.end,

                      children: [
                        if (!own)
                          InkWell(
                            onTap: () => Navigator.push(
                              context,

                              MaterialPageRoute(
                                builder: (_) => CommunityProfileScreen(
                                  userId: m['senderId'] as String,
                                ),
                              ),
                            ),

                            child: Padding(
                              padding: const EdgeInsets.only(
                                right: 8,
                                bottom: 2,
                              ),

                              child: simpleAvatar(
                                sender?['avatarUrl'] as String?,
                                radius: 16,
                              ),
                            ),
                          ),

                        Flexible(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.sizeOf(context).width * .75,
                            ),

                            child: GestureDetector(
                              onLongPress: m['deleted'] == true
                                  ? null
                                  : () async {
                                      final choice =
                                          await showModalBottomSheet<String>(
                                            context: context,

                                            builder: (c) => SafeArea(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,

                                                children: [
                                                  if (own)
                                                    ListTile(
                                                      title: const Text(
                                                        'Thu hồi tin nhắn',
                                                      ),

                                                      onTap: () =>
                                                          Navigator.pop(
                                                            c,
                                                            'delete',
                                                          ),
                                                    ),

                                                  if (!own)
                                                    ListTile(
                                                      title: const Text(
                                                        'Báo cáo tin nhắn',
                                                      ),

                                                      onTap: () =>
                                                          Navigator.pop(
                                                            c,
                                                            'report',
                                                          ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          );

                                      if (!context.mounted) return;

                                      try {
                                        if (choice == 'delete') {
                                          await model.api.delete(
                                            '/conversations/${widget.conversationId}/messages/${m['messageId']}',
                                          );

                                          await model.load(silent: true);
                                        }

                                        if (!context.mounted) return;

                                        if (choice == 'report') {
                                          final reason = await socialText(
                                            context,

                                            'Lý do báo cáo',

                                            description: 'Nội dung tin nhắn này sẽ được gửi kèm lý do tới quản trị viên.',
                                          );

                                          if (reason == null) return;

                                          await model.api.post(
                                            '/conversations/${widget.conversationId}/messages/${m['messageId']}/report',

                                            {'reason': reason},
                                          );

                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Đã gửi báo cáo đến quản trị viên.',
                                                    ),
                                                  ),
                                                );
                                          }
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          socialError(context, e);
                                        }
                                      }
                                    },

                              child: Container(
                                padding: const EdgeInsets.all(12),

                                decoration: BoxDecoration(
                                  color: own
                                      ? Theme.of(context)
                                            .colorScheme
                                            .primaryContainer
                                      : Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerHighest,

                                  borderRadius: BorderRadius.circular(16),
                                ),

                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  mainAxisSize: MainAxisSize.min,

                                  children: [
                                    if (!own)
                                      InkWell(
                                        onTap: () => Navigator.push(
                                          context,

                                          MaterialPageRoute(
                                            builder: (_) =>
                                                CommunityProfileScreen(
                                                  userId:
                                                      m['senderId'] as String,
                                                ),
                                          ),
                                        ),

                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 4,
                                          ),

                                          child: Text(
                                            sender?['name'] as String? ??
                                                'Thành viên cũ',

                                            style: Theme.of(context)
                                                .textTheme
                                                .labelMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ),
                                      ),

                                    Text(
                                      m['deleted'] == true
                                          ? 'Tin nhắn đã được thu hồi'
                                          : m['content'] as String,

                                      style: TextStyle(
                                        fontStyle: m['deleted'] == true
                                            ? FontStyle.italic
                                            : FontStyle.normal,
                                      ),
                                    ),

                                    const SizedBox(height: 2),

                                    Text(
                                      DateTime.tryParse(
                                                m['createdAt'] as String,
                                              )
                                              ?.toLocal()
                                              .toString()
                                              .substring(0, 16) ??
                                          '',

                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            if (model.sendError != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),

                child: Text(
                  '${model.sendError}\nNội dung vẫn được giữ. Bấm gửi để thử lại.',

                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),

            SafeArea(
              top: false,

              child: Padding(
                padding: const EdgeInsets.all(12),

                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,

                  children: [
                    Expanded(
                      child: TextField(
                        controller: draft,

                        enabled:
                            !model.sending &&
                            chat != null &&
                            chat['disabled'] != true,

                        minLines: 1,

                        maxLines: 5,

                        maxLength: 4000,

                        decoration: const InputDecoration(
                          hintText: 'Nhập tin nhắn…',

                          border: OutlineInputBorder(),

                          counterText: '',
                        ),
                      ),
                    ),

                    IconButton(
                      tooltip: 'Gửi tin nhắn',

                      onPressed:
                          model.sending ||
                              chat == null ||
                              chat['disabled'] == true
                          ? null
                          : () async {
                              if (await model.send(draft.text) && mounted) {
                                draft.clear();
                              }
                            },

                      icon: model.sending
                          ? const SizedBox(
                              width: 22,

                              height: 22,

                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send_rounded),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
