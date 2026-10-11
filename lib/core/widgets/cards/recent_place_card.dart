import 'package:flutter/material.dart';
import 'package:vietnam_trekking_mobile/features/home/data/recent_place_visited_model.dart';

class RecentProvinceCard extends StatelessWidget {
  final RecentPlace recentPlace;
  final VoidCallback? onTap;

  const RecentProvinceCard({super.key, required this.recentPlace, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: recentPlace.imageUrl.isEmpty
                      ? _placeholder(colorScheme)
                      : Image.network(
                          recentPlace.imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) =>
                              progress == null
                              ? child
                              : _placeholder(colorScheme),
                          errorBuilder: (_, _, _) => _placeholder(colorScheme),
                        ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                recentPlace.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  height: 1.2,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              if (recentPlace.lastVisited.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  recentPlace.lastVisited,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9,
                    height: 1.2,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder(ColorScheme colors) => ColoredBox(
    color: colors.primaryContainer,
    child: Icon(Icons.terrain, size: 22, color: colors.onPrimaryContainer),
  );
}
