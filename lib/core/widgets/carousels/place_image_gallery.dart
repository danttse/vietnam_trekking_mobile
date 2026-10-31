import 'package:flutter/material.dart';

import 'paged_carousel.dart';

class PlaceImageGallery extends StatelessWidget {
  final List<String> images;
  final Widget? foreground;
  final double indicatorBottom;
  const PlaceImageGallery({
    super.key,
    required this.images,
    this.foreground,
    this.indicatorBottom = 10,
  });

  @override
  Widget build(BuildContext context) {
    final urls = images
        .map((url) => url.trim())
        .where((url) => url.isNotEmpty)
        .toSet()
        .toList();
    final colors = Theme.of(context).colorScheme;
    Widget placeholder() => ColoredBox(
      color: colors.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.terrain_outlined,
          size: 56,
          color: colors.onSurfaceVariant,
        ),
      ),
    );
    return PagedCarousel(
      key: ValueKey(Object.hashAll(urls)),
      itemCount: urls.isEmpty ? 1 : urls.length,
      overlayIndicator: true,
      foreground: foreground,
      indicatorBottom: indicatorBottom,
      itemBuilder: (context, index) => urls.isEmpty
          ? placeholder()
          : Image.network(
              urls[index],
              fit: BoxFit.cover,
              loadingBuilder: (_, child, progress) =>
                  progress == null ? child : placeholder(),
              errorBuilder: (_, error, stack) => placeholder(),
            ),
    );
  }
}
