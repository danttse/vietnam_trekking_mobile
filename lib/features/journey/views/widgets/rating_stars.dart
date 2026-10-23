import 'package:flutter/material.dart';

/// Widget hiển thị hoặc nhập rating 1–5 sao.
/// Nếu [onChanged] null → read-only mode.
class RatingStars extends StatelessWidget {
  final int rating;       // 0–5
  final double starSize;
  final Color activeColor;
  final Color inactiveColor;
  final void Function(int)? onChanged; // null = read-only

  const RatingStars({
    super.key,
    required this.rating,
    this.starSize = 28,
    this.activeColor = const Color(0xFFE8620A),
    this.inactiveColor = const Color(0xFF3A3A3A),
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < rating;
        return GestureDetector(
          onTap: onChanged != null ? () => onChanged!(i + 1) : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Icon(
              filled ? Icons.star_rounded : Icons.star_outline_rounded,
              size: starSize,
              color: filled ? activeColor : inactiveColor,
            ),
          ),
        );
      }),
    );
  }
}
