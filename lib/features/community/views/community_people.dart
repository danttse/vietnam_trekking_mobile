import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/network/api_error_handler.dart';
import '../../../core/widgets/app_bar/app_top_bar_with_back.dart';
import '../../../core/widgets/buttons/btn_login_style.dart';
import '../../../core/widgets/buttons/btn_outline_style.dart';
import '../data/datasources/social_api.dart';
import 'community_helpers.dart';
import 'community_profile_screen.dart';
import 'personal_qr_scanner.dart';

export 'community_helpers.dart';
export 'community_profile_screen.dart';
export 'personal_qr_scanner.dart';

class PeopleSearchScreen extends StatefulWidget {
  final bool select;
  final SocialApi? api;
  const PeopleSearchScreen({super.key, this.select = false, this.api});
  @override
  State<PeopleSearchScreen> createState() => _PeopleSearchState();
}

class _PeopleSearchState extends State<PeopleSearchScreen> {
  final input = TextEditingController();
  late final api = widget.api ?? SocialApi();
  Json? person;
  String? error;
  bool busy = false;
  Future<void> find(String value) async {
    if (busy) return;
    setState(() {
      busy = true;
      person = null;
      error = null;
    });
    try {
      final result = await api.get(
        '/people/discover',
        value.startsWith('trekviet://')
            ? {'qr': value.trim()}
            : {'email': value.trim()},
      );
      if (mounted) setState(() => person = result);
    } catch (e) {
      if (mounted) setState(() => error = ApiErrorHandler.handle(e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Column(
        children: [
          AppTopBarWithBack(
            title: widget.select ? 'Chọn thành viên' : 'Tìm người dùng',
            onBack: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Tìm bằng email đầy đủ hoặc mã QR cá nhân TrekViệt.',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: input,
                  maxLength: 254,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email hoặc nội dung QR',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: find,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    BtnLoginPrimary(
                      text: 'Tìm kiếm',
                      isLoading: busy,
                      onPressed: busy ? null : () => find(input.text),
                    ),
                    BtnOutlineStyle(
                      text: 'Quét QR',
                      icon: const Icon(Icons.qr_code_scanner),
                      onPressed: busy
                          ? null
                          : () async {
                              final qr = await Navigator.push<String>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PersonalQrScanner(),
                                ),
                              );
                              if (qr != null) {
                                input.text = qr;
                                await find(qr);
                              }
                            },
                    ),
                  ],
                ),
                if (busy)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                if (person != null)
                  Card(
                    child: ListTile(
                      leading: communityAvatar(
                        person!['avatarUrl'] as String?,
                        person!['name'] as String,
                      ),
                      title: Text(person!['name'] as String),
                      subtitle: Text(person!['bio'] as String),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        if (widget.select) {
                          Navigator.pop(context, person);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CommunityProfileScreen(
                                userId: person!['userId'] as String,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
