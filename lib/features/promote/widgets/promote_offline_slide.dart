import 'package:flutter/material.dart';
import 'package:vietnam_trekking_mobile/core/widgets/cards/profile_setting_item.dart';
import 'package:vietnam_trekking_mobile/features/promote/widgets/promote_slide_scaffold.dart';
import 'package:vietnam_trekking_mobile/l10n/app_localizations.dart';

class PromoteOfflineSlide extends StatelessWidget {
  const PromoteOfflineSlide({super.key});

  Widget _buildItemCard({
    required BuildContext context,
    required Widget child,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PromoteSlideScaffold(
      title: l10n.promoteOfflineTitle,
      description: l10n.promoteOfflineDesc,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 50),
          _buildItemCard(
            context: context,
            child: ProfileSettingItem(
              mainTitle: l10n.promoteOfflineMapTitle,
              subTitle: l10n.promoteOfflineMapSubtitle,
              icon: Icons.download_rounded,
              trailing: const SizedBox.shrink(),
            ),
          ),
          const SizedBox(height: 12),
          _buildItemCard(
            context: context,
            child: ProfileSettingItem(
              mainTitle: l10n.promoteOfflineFavoriteTitle,
              subTitle: l10n.promoteOfflineFavoriteSubtitle,
              icon: Icons.favorite_border_rounded,
              trailing: const SizedBox.shrink(),
            ),
          ),
          const SizedBox(height: 12),
          _buildItemCard(
            context: context,
            child: ProfileSettingItem(
              mainTitle: l10n.promoteOfflineGpsTitle,
              subTitle: l10n.promoteOfflineGpsSubtitle,
              icon: Icons.location_on_outlined,
              trailing: const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}
