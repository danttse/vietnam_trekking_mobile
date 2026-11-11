import 'package:flutter/material.dart';

import '../data/datasources/social_api.dart';
import 'community_people.dart';

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
