import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/network/api_error_handler.dart';
import '../data/datasources/social_api.dart';

Widget communityAvatar(String? url, String name, {double radius = 24}) =>
    CircleAvatar(
      radius: radius,
      backgroundImage: url != null && url.isNotEmpty ? NetworkImage(url) : null,
      child: url == null || url.isEmpty
          ? Text(name.isEmpty ? 'T' : name[0])
          : null,
    );

String conversationTitle(Json chat, String? me) => chat['kind'] == 'GROUP'
    ? chat['name'] as String
    : (chat['members'] as List)
              .where((m) => m['userId'] != me)
              .map((m) => m['name'] as String)
              .firstOrNull ??
          'Tin nhắn';

Widget simpleAvatar(String? avatarUrl, {double radius = 20}) {
  if (avatarUrl != null && avatarUrl.isNotEmpty) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: NetworkImage(avatarUrl),
      onBackgroundImageError: (_, _) {},
    );
  }
  return CircleAvatar(
    radius: radius,
    child: Icon(Icons.person, size: radius),
  );
}

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
