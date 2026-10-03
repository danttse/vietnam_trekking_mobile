import 'package:flutter/material.dart';
import '../../data/models/milestone_model.dart';

/// Timeline dọc hiển thị các điểm kiểm soát (milestones).
/// Mỗi item có: dot (màu theo trạng thái), đường kẻ nối, tên, mô tả.
class MilestoneTimeline extends StatelessWidget {
  final List<MilestoneModel> milestones;
  final void Function(MilestoneModel)? onCheckinTap;

  const MilestoneTimeline({
    super.key,
    required this.milestones,
    this.onCheckinTap,
  });

  @override
  Widget build(BuildContext context) {
    if (milestones.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Chưa có điểm kiểm soát',
            style: TextStyle(color: Colors.grey)),
      );
    }
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: milestones.length,
      itemBuilder: (context, i) => _MilestoneItem(
        milestone: milestones[i],
        isLast: i == milestones.length - 1,
        onCheckinTap: onCheckinTap,
      ),
    );
  }
}

class _MilestoneItem extends StatelessWidget {
  final MilestoneModel milestone;
  final bool isLast;
  final void Function(MilestoneModel)? onCheckinTap;

  const _MilestoneItem({
    required this.milestone,
    required this.isLast,
    this.onCheckinTap,
  });

  Color get _dotColor {
    if (milestone.isCheckedIn) return const Color(0xFF4CAF50);
    if (milestone.isCurrentLocation) return const Color(0xFFE8620A);
    return const Color(0xFF4A5568);
  }

  Color get _lineColor => milestone.isCheckedIn
      ? const Color(0xFF4CAF50)
      : const Color(0xFF2D3748);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isCheckedIn = milestone.isCheckedIn;
    final isCurrent = milestone.isCurrentLocation;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Timeline column ─────────────────────────────────────────────
          SizedBox(
            width: 32,
            child: Column(
              children: [
                const SizedBox(height: 4),
                // Dot
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _dotColor,
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: const Color(0xFFE8620A).withValues(alpha: 0.4),
                              blurRadius: 8,
                              spreadRadius: 2,
                            )
                          ]
                        : null,
                  ),
                  child: isCheckedIn
                      ? const Icon(Icons.check, size: 11, color: Colors.white)
                      : isCurrent
                          ? const Icon(Icons.person_pin_circle,
                              size: 11, color: Colors.white)
                          : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: _lineColor,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                    ),
                  ),
              ],
            ),
          ),
          // ── Content ─────────────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 16),
              child: GestureDetector(
                onTap: (!isCheckedIn && onCheckinTap != null)
                    ? () => onCheckinTap!(milestone)
                    : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      milestone.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isCheckedIn
                            ? const Color(0xFF4CAF50)
                            : isCurrent
                                ? const Color(0xFFE8620A)
                                : cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (milestone.altitude != null)
                      Text(
                        milestone.altitudeLabel,
                        style: TextStyle(
                          fontSize: 11,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    if (isCheckedIn)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          '• Hoàn thành',
                          style: TextStyle(
                            fontSize: 11,
                            color: const Color(0xFF4CAF50).withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    if (isCurrent && !isCheckedIn)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          '• Hiện tại của bạn',
                          style: TextStyle(
                            fontSize: 11,
                            color: const Color(0xFFE8620A).withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                    if (!isCheckedIn && !isCurrent)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          '• Chưa đến',
                          style: TextStyle(
                            fontSize: 11,
                            color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
