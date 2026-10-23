import 'package:flutter/material.dart';

import '../../../core/models/rank_model.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../../l10n/app_localizations.dart';

class HomeProfileButton extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final RankInfo? rank;
  final bool isLoading;
  final VoidCallback onTap;

  const HomeProfileButton({
    super.key,
    required this.name,
    this.avatarUrl,
    this.rank,
    this.isLoading = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final data = rank;
    final shortName = name.trim().split(RegExp(r'\s+')).last;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      shortName.isEmpty ? l10n.profileTitle : shortName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data == null
                          ? (isLoading
                                ? l10n.rankLoading
                                : l10n.rankUnavailable)
                          : l10n.rankLevel(data.level),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              UserAvatar(imageUrl: avatarUrl, size: 36),
            ],
          ),
        ),
      ),
    );
  }
}
