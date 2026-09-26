import 'package:flutter/material.dart';
class ImageLoadCard extends StatelessWidget {
  final imageUrl;
  final VoidCallback? onTapRemove;
  const ImageLoadCard ({
    super.key,
    required this.imageUrl,
    this.onTapRemove
  });
  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme=Theme.of(context).colorScheme;
    return Container(
      width: 72,
      height: 72,
      margin: const EdgeInsets.only(right: 10),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: colorScheme.surfaceContainerHighest,
                    child: Icon(Icons.image, color: colorScheme.onSurfaceVariant),
                ),
              ),
            ),
          ),
        Positioned(
          top: 4,
          right: 4,
          child: InkWell(
            onTap: onTapRemove,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.close,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    ),);
  }
}