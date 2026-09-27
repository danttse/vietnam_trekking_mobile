import 'package:flutter/material.dart';

class AppTopBarWithBack extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;

  const AppTopBarWithBack({
    super.key,
    required this.title,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height:44,
      child: Padding(padding: EdgeInsetsGeometry.symmetric(vertical: 4,horizontal: 8),
      child: 
      Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).colorScheme.onSurface
              )
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: 
            InkWell(
              onTap: onBack ?? () => Navigator.of(context).maybePop(),
              child: 
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.navigate_before,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 15,
                  ),
                )
            )
          )
        ]
      ),
      )
    );
  }
}
