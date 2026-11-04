import 'package:flutter/material.dart';

Future<bool> confirmCommunityDelete(
  BuildContext context, {
  required String title,
  required String message,
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    ) ??
    false;

class EditCommunityCommentDialog extends StatefulWidget {
  final String content;
  final Future<String?> Function(String content) onSave;
  const EditCommunityCommentDialog({
    super.key,
    required this.content,
    required this.onSave,
  });
  @override
  State<EditCommunityCommentDialog> createState() =>
      _EditCommunityCommentDialogState();
}

class _EditCommunityCommentDialogState
    extends State<EditCommunityCommentDialog> {
  late final _controller = TextEditingController(text: widget.content);
  bool _saving = false;
  String? _error;
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_saving,
    child: AlertDialog(
      title: const Text('Sửa bình luận'),
      content: TextField(
        controller: _controller,
        enabled: !_saving,
        minLines: 2,
        maxLines: 6,
        maxLength: 2000,
        decoration: InputDecoration(errorText: _error),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: _saving
              ? null
              : () async {
                  if (_controller.text.trim().isEmpty) {
                    setState(() => _error = 'Vui lòng nhập nội dung.');
                    return;
                  }
                  setState(() {
                    _saving = true;
                    _error = null;
                  });
                  final error = await widget.onSave(_controller.text.trim());
                  if (!mounted) return;
                  setState(() {
                    _saving = false;
                    _error = error;
                  });
                  if (error == null && context.mounted) Navigator.pop(context);
                },
          child: Text(_saving ? 'Đang lưu...' : 'Lưu'),
        ),
      ],
    ),
  );
}
