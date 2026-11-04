import 'package:flutter/material.dart';

import '../data/datasources/social_api.dart';
import '../viewmodels/social_view_model.dart';
import '../viewmodels/conversation_view_model.dart';
import 'community_people.dart';

String conversationTitle(Json chat, String? me) => chat['kind'] == 'GROUP'
    ? chat['name'] as String
    : (chat['members'] as List)
              .where((m) => m['userId'] != me)
              .map((m) => m['name'] as String)
              .firstOrNull ??
          'Tin nhắn';

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
                leading: CircleAvatar(
                  child: Icon(
                    c['kind'] == 'GROUP'
                        ? Icons.groups_outlined
                        : Icons.person_outline,
                  ),
                ),
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

class CreateGroupScreen extends StatefulWidget {
  final SocialApi api;
  const CreateGroupScreen({super.key, required this.api});
  @override
  State<CreateGroupScreen> createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroupScreen> {
  final name = TextEditingController();
  final Map<String, Json> selected = {};
  bool busy = false;
  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Tạo nhóm trò chuyện')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        TextField(
          controller: name,
          maxLength: 100,
          decoration: const InputDecoration(
            labelText: 'Tên nhóm',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Tối đa 50 thành viên, bao gồm bạn.'),
        OutlinedButton.icon(
          onPressed: busy || selected.length >= 49
              ? null
              : () async {
                  final p = await Navigator.push<Json>(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          PeopleSearchScreen(select: true, api: widget.api),
                    ),
                  );
                  if (p != null && mounted && p['isMe'] != true) {
                    setState(() => selected[p['userId'] as String] = p);
                  }
                },
          icon: const Icon(Icons.person_add_outlined),
          label: const Text('Thêm bằng email / QR'),
        ),
        for (final p in selected.values)
          ListTile(
            leading: communityAvatar(
              p['avatarUrl'] as String?,
              p['name'] as String,
            ),
            title: Text(p['name'] as String),
            trailing: IconButton(
              tooltip: 'Bỏ chọn',
              icon: const Icon(Icons.close),
              onPressed: busy
                  ? null
                  : () => setState(() => selected.remove(p['userId'])),
            ),
          ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: busy
              ? null
              : () async {
                  if (name.text.trim().isEmpty || selected.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Nhập tên nhóm và chọn ít nhất một người.',
                        ),
                      ),
                    );
                    return;
                  }
                  setState(() => busy = true);
                  try {
                    final c = await widget.api.post('/conversations/groups', {
                      'name': name.text.trim(),
                      'memberIds': selected.keys.toList(),
                    });
                    if (context.mounted) {
                      Navigator.pop(context, c['conversationId'] as String);
                    }
                  } catch (e) {
                    if (context.mounted) socialError(context, e);
                  } finally {
                    if (mounted) setState(() => busy = false);
                  }
                },
          child: Text(busy ? 'Đang tạo…' : 'Tạo nhóm'),
        ),
      ],
    ),
  );
}

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
          title: Text(
            chat == null ? 'Tin nhắn' : conversationTitle(chat, model.ownerId),
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
                  return Align(
                    alignment: own
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.sizeOf(context).width * .8,
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
                                                    Navigator.pop(c, 'delete'),
                                              ),
                                            if (!own)
                                              ListTile(
                                                title: const Text(
                                                  'Báo cáo tin nhắn',
                                                ),
                                                onTap: () =>
                                                    Navigator.pop(c, 'report'),
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
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Đã gửi báo cáo đến quản trị viên.',
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                } catch (e) {
                                  if (context.mounted) socialError(context, e);
                                }
                              },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: own
                                ? Theme.of(context).colorScheme.primaryContainer
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
                                      builder: (_) => CommunityProfileScreen(
                                        userId: m['senderId'] as String,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    sender?['name'] as String? ??
                                        'Thành viên cũ',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium,
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
                              Text(
                                DateTime.tryParse(m['createdAt'] as String)
                                        ?.toLocal()
                                        .toString()
                                        .substring(0, 16) ??
                                    '',
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ],
                          ),
                        ),
                      ),
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

class GroupDetailsScreen extends StatefulWidget {
  final String id, me;
  final SocialApi api;
  const GroupDetailsScreen({
    super.key,
    required this.id,
    required this.me,
    required this.api,
  });
  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsState();
}

class _GroupDetailsState extends State<GroupDetailsScreen> {
  Json? chat;
  String? error;
  bool busy = false;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final c = await widget.api.get('/conversations/${widget.id}');
      if (mounted) setState(() => chat = c);
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    }
  }

  Future<void> action(Future<void> Function() fn) async {
    if (busy) return;
    setState(() => busy = true);
    try {
      await fn();
      await load();
    } catch (e) {
      if (mounted) socialError(context, e);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = chat;
    final own = c?['ownerId'] == widget.me;
    return Scaffold(
      appBar: AppBar(title: const Text('Thông tin nhóm')),
      body: c == null
          ? Center(
              child: error == null
                  ? const CircularProgressIndicator()
                  : Text(error!),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  c['name'] as String,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text('${(c['members'] as List).length}/50 thành viên'),
                if (busy) const LinearProgressIndicator(),
                if (own)
                  Wrap(
                    spacing: 8,
                    children: [
                      TextButton(
                        onPressed: busy
                            ? null
                            : () async {
                                final name = await socialText(
                                  context,
                                  'Đổi tên nhóm',
                                  initial: c['name'] as String,
                                  maxLength: 100,
                                );
                                if (name != null) {
                                  await action(() async {
                                    await widget.api.patch(
                                      '/conversations/${widget.id}',
                                      {'name': name},
                                    );
                                  });
                                }
                              },
                        child: const Text('Đổi tên'),
                      ),
                      TextButton(
                        onPressed: busy
                            ? null
                            : () async {
                                final p = await Navigator.push<Json>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PeopleSearchScreen(
                                      select: true,
                                      api: widget.api,
                                    ),
                                  ),
                                );
                                if (p != null) {
                                  await action(() async {
                                    await widget.api.post(
                                      '/conversations/${widget.id}/members',
                                      {'userId': p['userId']},
                                    );
                                  });
                                }
                              },
                        child: const Text('Thêm thành viên'),
                      ),
                    ],
                  ),
                for (final m in c['members'] as List)
                  ListTile(
                    leading: communityAvatar(
                      m['avatarUrl'] as String?,
                      m['name'] as String,
                    ),
                    title: Text(m['name'] as String),
                    subtitle: m['userId'] == c['ownerId']
                        ? const Text('Chủ nhóm')
                        : null,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CommunityProfileScreen(
                          userId: m['userId'] as String,
                        ),
                      ),
                    ),
                    trailing: own && m['userId'] != widget.me
                        ? PopupMenuButton<String>(
                            enabled: !busy,
                            onSelected: (value) async {
                              if (value == 'transfer') {
                                final ok = await showDialog<bool>(
                                  context: context,
                                  builder: (dialog) => AlertDialog(
                                    title: const Text('Chuyển quyền chủ nhóm?'),
                                    content: Text(
                                      'Trao quyền quản lý nhóm cho ${m['name']}.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(dialog),
                                        child: const Text('Hủy'),
                                      ),
                                      FilledButton(
                                        onPressed: () =>
                                            Navigator.pop(dialog, true),
                                        child: const Text('Chuyển quyền'),
                                      ),
                                    ],
                                  ),
                                );
                                if (ok == true) {
                                  await action(() async {
                                    await widget.api.patch(
                                      '/conversations/${widget.id}',
                                      {'ownerId': m['userId']},
                                    );
                                  });
                                }
                              } else {
                                await action(
                                  () => widget.api.delete(
                                    '/conversations/${widget.id}/members/${m['userId']}',
                                  ),
                                );
                              }
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(
                                value: 'transfer',
                                child: Text('Chuyển quyền chủ nhóm'),
                              ),
                              const PopupMenuItem(
                                value: 'remove',
                                child: Text('Mời ra khỏi nhóm'),
                              ),
                            ],
                          )
                        : null,
                  ),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: own || busy
                      ? null
                      : () async {
                          try {
                            await widget.api.delete(
                              '/conversations/${widget.id}/members/${widget.me}',
                            );
                            if (context.mounted) Navigator.pop(context, true);
                          } catch (e) {
                            if (context.mounted) socialError(context, e);
                          }
                        },
                  child: const Text('Rời nhóm'),
                ),
                if (own)
                  const Text(
                    'Chuyển quyền chủ nhóm cho một thành viên trước khi rời nhóm.',
                  ),
              ],
            ),
    );
  }
}
