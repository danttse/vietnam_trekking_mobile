import 'package:flutter/material.dart';

import '../../../core/widgets/app_bar/app_top_bar_with_back.dart';
import '../../../core/widgets/buttons/btn_login_style.dart';
import '../../../core/widgets/buttons/btn_outline_style.dart';
import '../../../l10n/app_localizations.dart';
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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppTopBarWithBack(
              title: l10n?.groupCreateTitle ?? 'Tạo nhóm trekking',
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  TextField(
                    controller: name,
                    maxLength: 100,
                    decoration: InputDecoration(
                      labelText: l10n?.groupNameLabel ?? 'Tên nhóm',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(l10n?.groupMaxMembersHint ?? 'Tối đa 10 thành viên cho nhóm thường'),
                  const SizedBox(height: 12),
                  BtnOutlineStyle(
                    text: l10n?.groupAddByEmailOrQr ?? 'Thêm bằng Email/QR',
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
                        tooltip: l10n?.unselect ?? 'Bỏ chọn',
                        icon: const Icon(Icons.close),
                        onPressed: busy
                            ? null
                            : () => setState(() => selected.remove(p['userId'])),
                      ),
                    ),
                  const SizedBox(height: 20),
                  BtnLoginPrimary(
                    text: busy
                        ? (l10n?.groupCreating ?? 'Đang tạo nhóm...')
                        : (l10n?.groupCreateButton ?? 'Tạo nhóm'),
                    isLoading: busy,
                    onPressed: busy
                        ? null
                        : () async {
                            if (name.text.trim().isEmpty || selected.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    l10n?.groupNameAndMemberRequired ??
                                        'Vui lòng nhập tên nhóm và chọn ít nhất 1 thành viên',
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
}
