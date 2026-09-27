import 'package:flutter/material.dart';
import '../../../features/explore/data/models/popular_trail_model.dart';

class PopularTrailCard extends StatelessWidget {
  final PopularTrailModel trail;
  final VoidCallback? onTap;

  const PopularTrailCard({
    super.key,
    required this.trail,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                trail.imageUrl,
                width: 140,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 140,
                  height: 100,
                  color: colorScheme.surfaceContainerHigh,
                  child: Icon(
                    Icons.terrain,
                    size: 32,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              trail.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 3),
            Row(
              children: [
                Text(
                  trail.location,
                  style: TextStyle(
                    fontSize: 9,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  trail.length,
                  style: TextStyle(
                    fontSize: 9,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
