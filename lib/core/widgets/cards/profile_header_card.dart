import 'package:flutter/material.dart';

import '../user_avatar.dart';

class ProfileHeaderCard extends StatelessWidget {
  final String name;
  final bool isPro;
  final String memberSince;
  final String bio;
  final String? subTitle;
  final String? avatarUrl;
  final String? rankLabel;
  final bool isEdit;
  final VoidCallback? actionEdit;

  const ProfileHeaderCard({
    super.key,
    required this.name,
    this.isPro = true,
    required this.memberSince,
    required this.bio,
    this.subTitle,
    this.avatarUrl,
    this.rankLabel,
    this.isEdit = false,
    this.actionEdit,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        UserAvatar(imageUrl: avatarUrl),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isPro) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'PRO',
                        style: TextStyle(
                          color: colorScheme.surface,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                  if (isEdit) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: actionEdit,
                      child: Icon(
                        Icons.mode_edit_outline,
                        size: 18,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
              if (rankLabel != null) ...[
                const SizedBox(height: 6),
                Text(
                  rankLabel!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                memberSince,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              if ((subTitle ?? bio).isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  subTitle ?? bio,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
