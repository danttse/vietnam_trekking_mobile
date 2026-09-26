import 'package:flutter/material.dart';

class ProfileSettingItem extends StatelessWidget {
  final String mainTitle;
  final String? subTitle;
  final IconData icon;
  final VoidCallback? onTapAction;
  final Widget? trailing;

  const ProfileSettingItem({
    super.key,
    required this.mainTitle,
    this.subTitle,
    required this.icon,
    this.onTapAction,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTapAction,
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: colorScheme.onSurfaceVariant,
              size: 15,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mainTitle,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                if (subTitle?.isNotEmpty ?? false)
                  Text(
                    subTitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          trailing ?? Icon(
                  size: 14,
                  Icons.navigate_next,
                  color: Colors.grey.withValues(alpha: 0.8))
        ],
      ),
    );
  }
}