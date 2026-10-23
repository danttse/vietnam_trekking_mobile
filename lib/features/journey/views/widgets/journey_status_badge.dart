import 'package:flutter/material.dart';

/// Badge hiển thị trạng thái journey — bám sát màu từ UI design.
class JourneyStatusBadge extends StatelessWidget {
  final String status;
  final bool small;

  const JourneyStatusBadge({
    super.key,
    required this.status,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final cfg = _config(status);
    final fontSize = small ? 10.0 : 11.0;
    final hPad = small ? 8.0 : 10.0;
    final vPad = small ? 3.0 : 4.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: cfg.bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cfg.border, width: 1),
      ),
      child: Text(
        cfg.label,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: cfg.text,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  static _BadgeConfig _config(String status) {
    switch (status.toUpperCase()) {
      case 'PLANNED':
        return _BadgeConfig(
          label: 'Dự kiến',
          bg: const Color(0xFF1E3A5F).withValues(alpha: 0.8),
          border: const Color(0xFF4A90D9).withValues(alpha: 0.6),
          text: const Color(0xFF90C4F8),
        );
      case 'ACTIVE':
        return _BadgeConfig(
          label: 'Đang diễn ra',
          bg: const Color(0xFF1A3B2A).withValues(alpha: 0.9),
          border: const Color(0xFF4CAF50).withValues(alpha: 0.6),
          text: const Color(0xFF81C784),
        );
      case 'PAUSED':
        return _BadgeConfig(
          label: 'Đang tạm dừng',
          bg: const Color(0xFF3B2A0A).withValues(alpha: 0.9),
          border: const Color(0xFFFFA726).withValues(alpha: 0.6),
          text: const Color(0xFFFFB74D),
        );
      case 'COMPLETED':
        return _BadgeConfig(
          label: 'Đã hoàn thành',
          bg: const Color(0xFF1A2B1A).withValues(alpha: 0.9),
          border: const Color(0xFF207335).withValues(alpha: 0.6),
          text: const Color(0xFF66BB6A),
        );
      case 'CANCELLED':
        return _BadgeConfig(
          label: 'Đã hủy',
          bg: const Color(0xFF2B1A1A).withValues(alpha: 0.9),
          border: const Color(0xFFEF5350).withValues(alpha: 0.5),
          text: const Color(0xFFEF9A9A),
        );
      default:
        return _BadgeConfig(
          label: status,
          bg: Colors.grey.withValues(alpha: 0.2),
          border: Colors.grey.withValues(alpha: 0.4),
          text: Colors.grey,
        );
    }
  }
}

class _BadgeConfig {
  final String label;
  final Color bg;
  final Color border;
  final Color text;
  const _BadgeConfig(
      {required this.label,
      required this.bg,
      required this.border,
      required this.text});
}
