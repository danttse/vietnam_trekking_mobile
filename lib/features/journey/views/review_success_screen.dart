import 'package:flutter/material.dart';
import 'widgets/rating_stars.dart';
import 'widgets/trekking_button.dart';

/// Màn hình "Cảm ơn bạn!" sau khi gửi review thành công.
class ReviewSuccessScreen extends StatelessWidget {
  final int rating;
  final String? placeName;

  const ReviewSuccessScreen({
    super.key,
    required this.rating,
    this.placeName,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

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
                      color: const Color(0xFF4CAF50), width: 2.5),
                ),
                child: const Icon(Icons.check_rounded,
                    size: 52, color: Color(0xFF4CAF50)),
              ),

              const SizedBox(height: 28),
              Text(
                'Cảm ơn bạn!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Đánh giá của bạn đã được gửi thành công và sẽ giúp ích rất nhiều cho cộng đồng Trekker Việt Nam.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13, color: cs.onSurfaceVariant),
              ),

              const SizedBox(height: 32),

              // ── Rating summary ────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Text(
                      'ĐÁNH GIÁ CỦA BẠN',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurfaceVariant,
                          letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 12),
                    RatingStars(
                      rating: rating,
                      starSize: 30,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$rating/5 sao  •  ${placeName ?? 'Địa điểm'}',
                      style: TextStyle(
                          fontSize: 13, color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // ── CTAs ──────────────────────────────────────────────────
              TrekkingSecondaryButton(
                label: 'Xem đánh giá khác',
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 10),
              TrekkingPrimaryButton(
                label: 'Quay về trang chủ',
                onPressed: () {
                  // Pop all screens back to navigation root
                  Navigator.of(context).popUntil((r) => r.isFirst);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
