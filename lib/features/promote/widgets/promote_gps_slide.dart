import 'package:flutter/material.dart';
import 'package:vietnam_trekking_mobile/core/widgets/cards/card_home_stats.dart';
import 'package:vietnam_trekking_mobile/features/promote/widgets/promote_slide_scaffold.dart';
import 'package:vietnam_trekking_mobile/l10n/app_localizations.dart';

class PromoteGpsSlide extends StatelessWidget {
  const PromoteGpsSlide({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return PromoteSlideScaffold(
      title: l10n.promoteGpsTitle,
      description: l10n.promoteGpsDesc,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.promoteGpsRecording,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1 / 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/images/static_map_example.webp',
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: colorScheme.surfaceContainerHigh,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.map_outlined,
                          size: 48,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CardHomeStats(
                    title: l10n.promoteGpsDistance,
                    value: '8.4 km',
                    icon: Icons.straighten_rounded,
                    iconColor: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CardHomeStats(
                    title: l10n.promoteGpsElevation,
                    value: '1,420 m',
                    icon: Icons.trending_up_rounded,
                    iconColor: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CardHomeStats(
                    title: l10n.promoteGpsSpeed,
                    value: '3.2 km/h',
                    icon: Icons.speed_rounded,
                    iconColor: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
