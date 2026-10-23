import 'package:flutter/material.dart';

class SessionExpiredDialog extends StatelessWidget {
  final VoidCallback onSignIn;
  const SessionExpiredDialog({super.key, required this.onSignIn});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return PopScope(
      canPop: false,
      child: AlertDialog(
        scrollable: true,
        backgroundColor: cs.surfaceContainerHighest,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.lock_clock_outlined, color: cs.primary),
            const SizedBox(width: 12),
            const Expanded(child: Text('Phiên đã hết hạn')),
          ],
        ),
        content: Text(
          'Vui lòng đăng nhập lại để tiếp tục sử dụng ứng dụng.',
          style: TextStyle(color: cs.onSurface, height: 1.5),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onSignIn,
              child: const Text('Đăng nhập lại', textAlign: TextAlign.center),
            ),
          ),
        ],
      ),
    );
  }
}
