import 'package:flutter/material.dart';
import '../../../features/journey/data/models/journey_group_model.dart';
import '../../../features/journey/data/models/journey_model.dart';
import 'journey_card.dart';

class JourneyGroupCard extends StatelessWidget {
  final JourneyGroupModel group;
  final Function(JourneyModel)? onJourneyTap;
  final String? languageCode;

  const JourneyGroupCard({
    super.key,
    required this.group,
    this.onJourneyTap,
    this.languageCode,
  });

  @override
  Widget build(BuildContext context) {
    final lang = languageCode ?? Localizations.localeOf(context).languageCode;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              group.formatMonthYear(lang),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: group.journeys
              .map(
                (journey) => Column(
                  children: [
                    JourneyCard(
                      journey: journey,
                      onTap: () => onJourneyTap?.call(journey),
                    ),
                    if (journey != group.journeys.last) const SizedBox(height: 6),
                  ],
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
