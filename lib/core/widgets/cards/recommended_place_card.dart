import 'package:flutter/material.dart';

import '../../../features/explore/data/models/explore_place_model.dart';
import '../../../l10n/app_localizations.dart';

class RecommendedPlaceCard extends StatelessWidget {
  final ExplorePlaceModel place;
  final VoidCallback? onTap;
  final bool isSelected;

  const RecommendedPlaceCard({
    super.key,
    required this.place,
    this.onTap,
    this.isSelected = false,
  });

  String _formatDifficulty(String difficulty, AppLocalizations l10n) {
    switch (difficulty.trim().toUpperCase()) {
      case 'EASY':
        return l10n.difficultyEasy;
      case 'MODERATE':
        return l10n.difficultyModerate;
      case 'HARD':
        return l10n.difficultyHard;
      case 'EXTREME':
        return l10n.difficultyExtreme;
      case 'EXPERT':
        return l10n.difficultyExpert;
      default:
        return difficulty;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

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
              ? Border.all(color: colorScheme.primary, width: 1)
              : null,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                place.imageUrl,
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
                          place.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 13, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(
                            place.rating.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    place.province,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (place.distance.isNotEmpty ||
                      place.difficulty.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      [
                        place.distance,
                        _formatDifficulty(place.difficulty, l10n).toUpperCase(),
                      ].where((value) => value.isNotEmpty).join(' • '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
