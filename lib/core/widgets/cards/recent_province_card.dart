import 'package:flutter/material.dart';
import '../../../features/auth/data/models/province_model.dart';

class RecentProvinceCard extends StatelessWidget {
  final Province province;

  const RecentProvinceCard({
    super.key,
    required this.province,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 72,
      height: 64,
      padding: const EdgeInsets.all(6),

      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 24,
            height: 24,

            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
            ),

            child: const Icon(
              Icons.location_on,
              size: 14,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 3),
          // Tên tỉnh
          Text(
            province.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          Text(
            province.lastVisit ?? '',
            style: TextStyle(
              fontSize: 8,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}