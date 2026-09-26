import 'package:flutter/material.dart';

class AppDraggableSheet extends StatelessWidget {
  final String title;
  final Widget Function(BuildContext context, ScrollController scrollController) contentBuilder;
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;

  const AppDraggableSheet({
    super.key,
    required this.title,
    required this.contentBuilder,
    this.initialChildSize = 0.6,
    this.minChildSize = 0.35,
    this.maxChildSize = 0.9,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: initialChildSize,
      minChildSize: minChildSize,
      maxChildSize: maxChildSize,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 50,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(height: 0.5, color: Colors.grey),
                Expanded(
                  child: contentBuilder(context, scrollController),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
