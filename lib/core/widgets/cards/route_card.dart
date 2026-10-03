import 'package:flutter/material.dart';
import '../../../features/route/data/models/route_model.dart';

class RouteCard extends StatelessWidget {
  final RouteModel route;
  final VoidCallback? onTap;
  final bool isSelected;

  const RouteCard({
    super.key,
    required this.route,
    this.onTap,
    this.isSelected = false,
  });

  String _getDifficultyText(RouteDifficulty difficulty) {
    switch (difficulty) {
      case RouteDifficulty.easy:
        return 'DỄ';
      case RouteDifficulty.moderate:
        return 'TRUNG BÌNH';
      case RouteDifficulty.hard:
        return 'KHÓ';
      case RouteDifficulty.extreme:
        return 'CỰC KHÓ';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.12)
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: colorScheme.primary, width: 1.5)
              : Border.all(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.1),
                  width: 1,
                ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: route.imageUrl != null && route.imageUrl!.isNotEmpty
                  ? Image.network(
                      route.imageUrl!,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 72,
                        height: 72,
                        color: colorScheme.surfaceContainerHigh,
                        child: Icon(
                          Icons.terrain,
                          size: 24,
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                        ),
                      ),
                    )
                  : Container(
                      width: 72,
                      height: 72,
                      color: colorScheme.surfaceContainerHigh,
                      child: Icon(
                        Icons.terrain,
                        size: 24,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          route.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.check_circle,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (route.province != null && route.province!.isNotEmpty) ...[
                        Text(
                          route.province!,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Text(
                            '•',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                      Text(
                        '${route.distanceKm.toStringAsFixed(0)} km',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Text(
                          '•',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Text(
                        _getDifficultyText(route.difficulty),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
