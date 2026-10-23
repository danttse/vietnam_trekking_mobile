import 'package:flutter/material.dart';

import '../../../core/models/rank_model.dart';
import '../../../l10n/app_localizations.dart';
import 'rank_widgets.dart';

class RankPromotionDialog extends StatelessWidget {
  final UserRankProfile profile;
  const RankPromotionDialog({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    return AlertDialog(
      scrollable: true,
      backgroundColor: colors.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(l10n.rankPromotionTitle, textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RankEmblem(rank: profile.rank, size: 96),
          const SizedBox(height: 20),
          Text(
            l10n.rankPromoted(profile.rank.name, profile.rank.level),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.primary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(l10n.rankPromotionMessage, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Text(
            '${rankNumber(context, profile.totalXp)} XP',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.rankPromotionContinue),
          ),
        ),
      ],
    );
  }
}
