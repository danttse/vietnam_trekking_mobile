import 'package:flutter/material.dart';

import '../viewmodels/social_view_model.dart';
import 'community_people.dart';
import 'conversation_screen.dart';
import 'create_group_screen.dart';

export 'conversation_screen.dart';
export 'create_group_screen.dart';
export 'group_details_screen.dart';

class CommunityMessages extends StatelessWidget {
  final SocialViewModel model;

  const CommunityMessages({super.key, required this.model});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: model,

    builder: (context, _) => RefreshIndicator(
      onRefresh: model.load,

      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),

        padding: const EdgeInsets.all(16),

        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Tin nhắn',

                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),

              IconButton(
                tooltip: 'Tin nhắn mới',

                onPressed: () => Navigator.push(
                  context,

                  MaterialPageRoute(builder: (_) => const PeopleSearchScreen()),
                ),

                icon: const Icon(Icons.edit_square),
              ),

              IconButton(
                tooltip: 'Tạo nhóm',

                onPressed: () async {
                  final id = await Navigator.push<String>(
                    context,

                    MaterialPageRoute(
                      builder: (_) => CreateGroupScreen(api: model.api),
                    ),
                  );

                  if (id != null && context.mounted) {
                    await Navigator.push(
                      context,

                      MaterialPageRoute(
                        builder: (_) => ConversationScreen(
                          conversationId: id,

                          api: model.api,
                        ),
                      ),
                    );

                    await model.load();
                  }
                },

                icon: const Icon(Icons.group_add_outlined),
              ),
            ],
          ),

          const Text(
            'Nhắn tin trực tiếp hoặc cùng nhau lên kế hoạch cho chuyến đi.',
          ),

          const SizedBox(height: 16),

          if (model.loading) const Center(child: CircularProgressIndicator()),

          if (model.error != null)
            Column(
              children: [
                Text(model.error!),

                TextButton(onPressed: model.load, child: const Text('Thử lại')),
              ],
            ),

          if (!model.loading &&
              model.error == null &&
              model.conversations.isEmpty)
            const Padding(
              padding: EdgeInsets.all(28),

              child: Text(
                'Chưa có hội thoại. Tìm người bằng email hoặc QR để bắt đầu.',
              ),
            ),

          for (final c in model.conversations)
            Card(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,

              child: ListTile(
                leading: c['kind'] == 'GROUP'
                    ? const CircleAvatar(child: Icon(Icons.groups_outlined))
                    : () {
                        final other = (c['members'] as List)
                            .where((m) => m['userId'] != model.me?['userId'])
                            .firstOrNull;

                        return simpleAvatar(
                          other?['avatarUrl'] as String?,
                          radius: 20,
                        );
                      }(),

                title: Text(
                  conversationTitle(c, model.me?['userId'] as String?),

                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,
                ),

                subtitle: Text(
                  c['disabled'] == true
                      ? 'Nhóm đang tạm ngưng'
                      : c['kind'] == 'GROUP'
                      ? '${(c['members'] as List).length} thành viên'
                      : 'Tin nhắn cá nhân',
                ),

                trailing: (c['unreadCount'] as int) > 0
                    ? Badge(label: Text('${c['unreadCount']}'))
                    : const Icon(Icons.chevron_right),

                onTap: () async {
                  await Navigator.push(
                    context,

                    MaterialPageRoute(
                      builder: (_) => ConversationScreen(
                        conversationId: c['conversationId'] as String,

                        api: model.api,
                      ),
                    ),
                  );

                  await model.load(silent: true);
                },
              ),
            ),

          if (model.page < model.totalPages)
            TextButton(
              onPressed: model.loading ? null : () => model.load(more: true),

              child: const Text('Xem thêm hội thoại'),
            ),
        ],
      ),
    ),
  );
}
