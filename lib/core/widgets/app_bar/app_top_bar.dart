import 'package:flutter/material.dart';

class AppTopBar extends StatelessWidget {
  final String title;
  final IconData? icon;
  final VoidCallback? onClickIcon;

  const AppTopBar({
    super.key,
    required this.title,
    this.icon,
    this.onClickIcon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      child: Padding(padding: EdgeInsetsGeometry.symmetric(vertical: 8,horizontal: 16),
      child: 
      Stack(
        alignment: Alignment.centerLeft,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold
            
            )
          ),
          if (icon != null)
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: onClickIcon ?? () => Navigator.of(context).maybePop(),
                child: Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
              ),
            ),
        ]
      ),
      )
    );
  }
}
