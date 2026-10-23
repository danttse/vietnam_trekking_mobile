import 'package:flutter/material.dart';

class JourneyMiniGpsBar extends StatelessWidget {
  final bool trackReady;
  final bool isRecording;
  final bool isPaused;
  final bool isBacktracking;
  final bool hasPoints;
  final double distanceMeters;
  final int pointsCount;
  final int checkedMilestonesCount;
  final int totalMilestonesCount;
  final VoidCallback onTap;

  const JourneyMiniGpsBar({
    super.key,
    required this.trackReady,
    required this.isRecording,
    required this.isPaused,
    required this.isBacktracking,
    required this.hasPoints,
    required this.distanceMeters,
    required this.pointsCount,
    required this.checkedMilestonesCount,
    required this.totalMilestonesCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Positioned(
      left: 16,
      right: 16,
      bottom: MediaQuery.paddingOf(context).bottom + 16,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: cs.outline.withValues(alpha: 0.15),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: !trackReady
                        ? cs.outline
                        : isRecording
                        ? const Color(0xFF16A34A)
                        : isPaused
                        ? const Color(0xFFF59E0B)
                        : cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isBacktracking
                            ? 'Backtrack đang bật'
                            : isRecording
                            ? 'Đang ghi GPS'
                            : hasPoints
                            ? 'Đường đi đã lưu'
                            : 'GPS sẵn sàng',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${(distanceMeters / 1000).toStringAsFixed(2)} km · $pointsCount điểm · $checkedMilestonesCount/$totalMilestonesCount mốc',
                        style: TextStyle(
                          fontSize: 11,
                          color: cs.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: cs.surface.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.keyboard_arrow_up,
                    color: cs.onSurface,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
