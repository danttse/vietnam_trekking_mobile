import 'package:flutter/material.dart';

class PromoteSlideScaffold extends StatelessWidget {
  final String title;
  final String description;
  final Widget child;

  const PromoteSlideScaffold({
    super.key,
    required this.title,
    required this.description,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}