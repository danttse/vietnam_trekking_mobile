import 'package:flutter/material.dart';

/// Widget hiển thị trạng thái empty / error / offline với retry.
class TrekkingEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? retryLabel;
  final VoidCallback? onRetry;

  const TrekkingEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.retryLabel,
    this.onRetry,
  });

  factory TrekkingEmptyState.empty({
    String title = 'Chưa có dữ liệu',
    String? subtitle,
    VoidCallback? onRetry,
  }) =>
      TrekkingEmptyState(
        icon: Icons.inbox_outlined,
        title: title,
        subtitle: subtitle,
        retryLabel: 'Làm mới',
        onRetry: onRetry,
      );

  factory TrekkingEmptyState.error({
    String? message,
    VoidCallback? onRetry,
  }) =>
      TrekkingEmptyState(
        icon: Icons.error_outline_rounded,
        title: 'Đã xảy ra lỗi',
        subtitle: message,
        retryLabel: 'Thử lại',
        onRetry: onRetry,
      );

  factory TrekkingEmptyState.offline({VoidCallback? onRetry}) =>
      TrekkingEmptyState(
        icon: Icons.wifi_off_rounded,
        title: 'Không có kết nối',
        subtitle: 'Dữ liệu được tải từ bộ nhớ cục bộ',
        retryLabel: 'Thử lại',
        onRetry: onRetry,
      );

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13, color: cs.onSurfaceVariant),
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryLabel ?? 'Thử lại'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
