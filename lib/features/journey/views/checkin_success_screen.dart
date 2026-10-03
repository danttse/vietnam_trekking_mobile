import 'package:flutter/material.dart';
import '../data/models/milestone_model.dart';
import 'widgets/trekking_button.dart';

/// Màn hình "Check-in thành công!" với badge + stats.
class CheckinSuccessScreen extends StatelessWidget {
  final MilestoneModel milestone;
  final Map<String, dynamic> checkinResult;

  const CheckinSuccessScreen({
    super.key,
    required this.milestone,
    required this.checkinResult,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final badgeName = checkinResult['badgeName'] as String? ??
        'Nhà chinh phục ${milestone.name}';
    final badgeDesc = checkinResult['badgeDescription'] as String? ??
        'Mở khóa danh hiệu';
    final xpGained = checkinResult['xpGained'] as int? ?? 1;
    final altReached =
        checkinResult['altitudeReached'] as num? ??
            milestone.altitude ??
            1000;
    final totalCheckins =
        checkinResult['totalCheckins'] as int? ?? 0;
    final totalMilestones =
        checkinResult['totalMilestones'] as int? ?? 63;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),

              // ── Success icon ──────────────────────────────────────────
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: const Color(0xFF4CAF50), width: 2),
                ),
                child: const Icon(Icons.landscape_outlined,
                    color: Color(0xFF4CAF50), size: 48),
              ),

              const SizedBox(height: 20),
              Text(
                'CHÚC MỪNG!',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF4CAF50),
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Check-in thành công!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bạn đã hoàn thành đánh dấu mốc chinh phục đỉnh ${milestone.name} huyền thoại.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13, color: cs.onSurfaceVariant),
              ),

              const SizedBox(height: 28),

              // ── Badge earned ──────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFE8620A)
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8620A)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.military_tech,
                          color: Color(0xFFE8620A), size: 26),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'HUY HIỆU ĐẠT ĐƯỢC',
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFE8620A),
                                letterSpacing: 0.5),
                          ),
                          const SizedBox(height: 3),
                          Text(badgeName,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: cs.onSurface)),
                          Text(badgeDesc,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: cs.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Stats row ─────────────────────────────────────────────
              Row(
                children: [
                  _StatChip(
                      value: '+$xpGained',
                      label: 'Huy hiệu mới'),
                  const SizedBox(width: 10),
                  _StatChip(
                      value: '${altReached.toInt()}m',
                      label: 'Độ cao tới đó'),
                  const SizedBox(width: 10),
                  _StatChip(
                      value: '$totalCheckins / $totalMilestones',
                      label: 'Tỉnh đã chinh phục'),
                ],
              ),

              const Spacer(),

              // ── CTAs ──────────────────────────────────────────────────
              TrekkingPrimaryButton(
                label: 'Tiếp tục hành trình',
                onPressed: () {
                  // Pop back to journey detail (pop 2 screens)
                  Navigator.of(context)
                    ..pop()
                    ..pop();
                },
              ),
              const SizedBox(height: 10),
              TrekkingSecondaryButton(
                label: '☆  Đánh giá địa điểm',
                onPressed: () => Navigator.of(context).pop(),
                borderColor:
                    cs.onSurface.withValues(alpha: 0.2),
                textColor: cs.onSurface,
              ),
              const SizedBox(height: 10),
              TrekkingSecondaryButton(
                label: 'Chia sẻ thành tích',
                onPressed: () {},
                borderColor:
                    cs.onSurface.withValues(alpha: 0.2),
                textColor: cs.onSurfaceVariant,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String value;
  final String label;
  const _StatChip({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface)),
            const SizedBox(height: 2),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 9, color: cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
