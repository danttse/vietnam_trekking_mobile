import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/network/api_error_handler.dart';
import '../../../core/widgets/cards/post_card.dart';
import '../data/datasources/social_api.dart';
import '../data/datasources/community_remote_datasource.dart';
import '../data/models/post_model.dart';
import '../data/datasources/community_realtime.dart';
import '../../../core/services/auth_event_bus.dart';
import 'community_messages.dart';
import 'show_comment_screen.dart';
import 'create_new_post_creen.dart';

Widget communityAvatar(String? url, String name, {double radius = 24}) =>
    CircleAvatar(
      radius: radius,
      backgroundImage: url != null && url.isNotEmpty ? NetworkImage(url) : null,
      child: url == null || url.isEmpty
          ? Text(name.isEmpty ? 'T' : name[0])
          : null,
    );
void socialError(BuildContext context, Object error) {
  if (context.mounted) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(ApiErrorHandler.handle(error))));
  }
}

Future<String?> socialText(
  BuildContext context,
  String title, {
  String initial = '',
  int maxLength = 1000,
  String? description,
}) async {
  final text = TextEditingController(text: initial);
  final result = await showDialog<String>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (description != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(description),
            ),
          TextField(
            controller: text,
            autofocus: true,
            maxLength: maxLength,
            minLines: 1,
            maxLines: 4,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: const Text('Hủy')),
        FilledButton(
          onPressed: () => Navigator.pop(c, text.text.trim()),
          child: const Text('Lưu'),
        ),
      ],
    ),
  );
  // The dialog route may still be animating with the controller attached.
  Future<void>.delayed(const Duration(milliseconds: 300), text.dispose);
  return result;
}

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
    appBar: AppBar(
      title: Text(widget.select ? 'Chọn thành viên' : 'Tìm người dùng'),
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Tìm bằng email đầy đủ hoặc mã QR cá nhân TrekViệt.'),
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
        Wrap(
          spacing: 12,
          children: [
            FilledButton.icon(
              onPressed: busy ? null : () => find(input.text),
              icon: const Icon(Icons.search),
              label: const Text('Tìm kiếm'),
            ),
            OutlinedButton.icon(
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
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Quét QR'),
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
              style: TextStyle(color: Theme.of(context).colorScheme.error),
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
  );
}

class PersonalQrScanner extends StatefulWidget {
  const PersonalQrScanner({super.key});
  @override
  State<PersonalQrScanner> createState() => _ScannerState();
}

class _ScannerState extends State<PersonalQrScanner> {
  final controller = MobileScannerController(formats: [BarcodeFormat.qrCode]);
  bool done = false;
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Quét QR cá nhân')),
    body: MobileScanner(
      controller: controller,
      onDetect: (capture) {
        final value = capture.barcodes
            .map((b) => b.rawValue)
            .whereType<String>()
            .firstOrNull;
        if (done || value == null) return;
        if (!RegExp(r'^trekviet://community/user/[a-f0-9]{48}$')
            .hasMatch(value)) {
          return;
        }
        done = true;
        Navigator.pop(context, value);
      },
      errorBuilder: (context, error) => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Không mở được camera. Hãy cấp quyền camera trong cài đặt hoặc quay lại nhập nội dung QR.',
          ),
        ),
      ),
    ),
  );
}

class CommunityProfileScreen extends StatefulWidget {
  final String? userId;
  final bool embedded;
  final SocialApi? api;
  final bool realtimeEnabled;
  const CommunityProfileScreen({
    super.key,
    this.userId,
    this.embedded = false,
    this.api,
    this.realtimeEnabled = true,
  });
  @override
  State<CommunityProfileScreen> createState() => _ProfileState();
}

class _ProfileState extends State<CommunityProfileScreen> {
  CommunityRealtime? _realtime;
  StreamSubscription<AuthEvent>? _auth;
  Timer? _refresh;
  int _epoch = 0;
  bool _ended = false;
  late final api = widget.api ?? SocialApi();
  Json? person;
  List<PostModel> posts = [];
  String? error;
  bool loading = false, busy = false;
  int page = 0, totalPages = 1;
  @override
  void initState() {
    super.initState();
    _auth = AuthEventBus().stream.listen((_) {
      _ended = true;
      _epoch++;
      _realtime?.dispose();
      _refresh?.cancel();
      if (mounted) {
        setState(() {
          person = null;
          posts = [];
          loading = false;
        });
      }
    });
    if (widget.realtimeEnabled) {
      _realtime = CommunityRealtime(
        onEvent: (event) {
          if (event['type'] == 'ready' || event['postId'] != null) {
            _refresh?.cancel();
            _refresh = Timer(const Duration(milliseconds: 300), load);
          }
        },
      )..connect();
    }
    load();
  }

  @override
  void dispose() {
    _epoch++;
    _refresh?.cancel();
    _realtime?.dispose();
    _auth?.cancel();
    super.dispose();
  }

  Future<void> load({bool more = false}) async {
    if (_ended || (more && loading)) return;
    final epoch = ++_epoch;
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final profile = await api.get(
        widget.userId == null ? '/people/me' : '/people/${widget.userId}',
      );
      if (!mounted || _ended || epoch != _epoch) return;
      final result = await CommunityRemoteDataSource(api.dio).getPosts(
        userId: profile['userId'] as String,
        page: more ? page + 1 : 1,
      );
      if (mounted && !_ended && epoch == _epoch) {
        setState(() {
          person = profile;
          posts = more ? [...posts, ...result.items] : result.items;
          page = result.page;
          totalPages = result.totalPages;
        });
      }
    } catch (e) {
      if (mounted && !_ended && epoch == _epoch) {
        setState(() {
          error = ApiErrorHandler.handle(e);
          person = null;
          posts = [];
        });
      }
    } finally {
      if (mounted && epoch == _epoch) setState(() => loading = false);
    }
  }

  Future<void> qr() async {
    final value = person?['qr'] as String?;
    if (value == null) return;
    await showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('QR cá nhân'),
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
              const Text(
                'Người khác quét mã này để xem trang cá nhân và nhắn tin cho bạn.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              Navigator.pop(c);
            },
            child: const Text('Sao chép mã'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = person;
    final body = RefreshIndicator(
      onRefresh: load,
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
                  Text(error!),
                  TextButton(onPressed: load, child: const Text('Thử lại')),
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
                        ? 'Chưa có giới thiệu.'
                        : p['bio'] as String,
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      '${p['postCount']} bài viết',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  if (p['isMe'] == true)
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: busy
                              ? null
                              : () async {
                                  final bio = await socialText(
                                    context,
                                    'Giới thiệu cá nhân',
                                    initial: p['bio'] as String,
                                    maxLength: 500,
                                  );
                                  if (bio == null || !mounted) return;
                                  setState(() => busy = true);
                                  try {
                                    await api.patch('/people/me', {'bio': bio});
                                    await load();
                                  } catch (e) {
                                    if (context.mounted) {
                                      socialError(context, e);
                                    }
                                  } finally {
                                    if (mounted) setState(() => busy = false);
                                  }
                                },
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Giới thiệu'),
                        ),
                        OutlinedButton.icon(
                          onPressed: qr,
                          icon: const Icon(Icons.qr_code),
                          label: const Text('QR của tôi'),
                        ),
                        TextButton(
                          onPressed: busy
                              ? null
                              : () async {
                                  final ok = await showDialog<bool>(
                                    context: context,
                                    builder: (c) => AlertDialog(
                                      title: const Text('Cấp lại QR?'),
                                      content: const Text(
                                        'Mã cũ sẽ ngừng hoạt động.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(c),
                                          child: const Text('Hủy'),
                                        ),
                                        FilledButton(
                                          onPressed: () =>
                                              Navigator.pop(c, true),
                                          child: const Text('Cấp lại'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (ok != true || !mounted) return;
                                  setState(() => busy = true);
                                  try {
                                    await api.post('/people/me/qr');
                                    await load();
                                  } catch (e) {
                                    if (context.mounted) {
                                      socialError(context, e);
                                    }
                                  } finally {
                                    if (mounted) setState(() => busy = false);
                                  }
                                },
                          child: const Text('Cấp lại QR'),
                        ),
                      ],
                    )
                  else
                    FilledButton.icon(
                      onPressed: busy
                          ? null
                          : () async {
                              setState(() => busy = true);
                              try {
                                final chat = await api.post(
                                  '/conversations/direct',
                                  {'userId': p['userId']},
                                );
                                if (context.mounted) {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ConversationScreen(
                                        conversationId:
                                            chat['conversationId'] as String,
                                        api: api,
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) socialError(context, e);
                              } finally {
                                if (mounted) setState(() => busy = false);
                              }
                            },
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text('Nhắn tin'),
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
                    const SnackBar(content: Text('Đã sao chép bài viết.')),
                  );
                }
              },
              onLike: () async {
                try {
                  final source = CommunityRemoteDataSource(api.dio);
                  if (post.isLiked) {
                    await source.unlikePost(post.postId);
                  } else {
                    await source.likePost(post.postId);
                  }
                  await load();
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
                                title: const Text('Sửa bài viết'),
                                leading: const Icon(Icons.edit),
                                onTap: () => Navigator.pop(c, 'edit'),
                              ),
                              ListTile(
                                title: const Text('Xóa bài viết'),
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
                              builder: (_) => CreateNewPostCreen(post: post),
                            ),
                          );
                          await load();
                        }
                        if (!context.mounted) return;
                        if (choice == 'delete') {
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (c) => AlertDialog(
                              title: const Text('Xóa bài viết?'),
                              content: const Text(
                                'Nội dung sẽ bị xóa và không thể khôi phục.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(c),
                                  child: const Text('Hủy'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(c, true),
                                  child: const Text('Xóa'),
                                ),
                              ],
                            ),
                          );
                          if (ok == true) {
                            await CommunityRemoteDataSource(api.dio)
                                .deletePost(post.postId);
                            await load();
                          }
                        }
                      } catch (e) {
                        if (context.mounted) socialError(context, e);
                      }
                    }
                  : null,
            ),
          if (!loading && posts.isEmpty && p != null)
            const Padding(
              padding: EdgeInsets.all(28),
              child: Center(child: Text('Chưa có bài viết hiển thị.')),
            ),
          if (page < totalPages)
            TextButton(
              onPressed: loading ? null : () => load(more: true),
              child: const Text('Xem thêm bài viết'),
            ),
        ],
      ),
    );
    return widget.embedded
        ? body
        : Scaffold(
            appBar: AppBar(title: const Text('Trang cá nhân cộng đồng')),
            body: body,
          );
  }
}
