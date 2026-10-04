import 'package:flutter/material.dart';

class ProfileProvinceProgressBar extends StatelessWidget {
  final String title;
  final int current;
  final int total;
  final String unit;
  final Color? progressColor;
  final Color? trackColor;

  const ProfileProvinceProgressBar({
    super.key,
    this.title = 'Bản đồ tỉnh thành',
    required this.current,
    this.total = 34,
    this.unit = '',
    this.progressColor,
    this.trackColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveProgressColor = progressColor ?? colorScheme.primary;
    final effectiveTrackColor = trackColor ?? colorScheme.surfaceContainerHighest;

    final double progress = total > 0 ? (current / total).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              '$current / $total $unit',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: effectiveProgressColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 6,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: effectiveTrackColor,
              valueColor: AlwaysStoppedAnimation<Color>(effectiveProgressColor),
            ),
          ),
        ),
      ],
    );
  }
}
