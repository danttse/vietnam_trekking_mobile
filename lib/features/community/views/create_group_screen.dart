import 'package:flutter/material.dart';

import '../../../core/widgets/app_bar/app_top_bar_with_back.dart';
import '../../../core/widgets/buttons/btn_login_style.dart';
import '../../../core/widgets/buttons/btn_outline_style.dart';
import '../data/datasources/social_api.dart';
import 'community_people.dart';

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
    body: SafeArea(
      child: Column(
        children: [
          AppTopBarWithBack(
            title: 'Tạo nhóm trò chuyện',
            onBack: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: ListView(
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
                const SizedBox(height: 12),
                BtnOutlineStyle(
                  text: 'Thêm bằng email / QR',
                  icon: const Icon(Icons.person_add_outlined),
                  onPressed: busy || selected.length >= 49
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
                          if (p != null && mounted && p['isMe'] != true) {
                            setState(() => selected[p['userId'] as String] = p);
                          }
                        },
                ),
                const SizedBox(height: 12),
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
                BtnLoginPrimary(
                  text: busy ? 'Đang tạo…' : 'Tạo nhóm',
                  isLoading: busy,
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
                            final c = await widget.api.post(
                              '/conversations/groups',
                              {
                                'name': name.text.trim(),
                                'memberIds': selected.keys.toList(),
                              },
                            );

                            if (context.mounted) {
                              Navigator.pop(
                                context,
                                c['conversationId'] as String,
                              );
                            }
                          } catch (e) {
                            if (context.mounted) socialError(context, e);
                          } finally {
                            if (mounted) setState(() => busy = false);
                          }
                        },
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
