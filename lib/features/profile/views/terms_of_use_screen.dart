import 'package:flutter/material.dart';
import '../../../core/widgets/app_bar/app_top_bar_with_back.dart';
import '../../../l10n/app_localizations.dart';

class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  Widget _buildSection({
    required BuildContext context,
    required String number,
    required String title,
    required String content,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$number.  ',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                TextSpan(
                  text: title,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            AppTopBarWithBack(
              title: l10n.termsOfUseTitle,
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.termsLastUpdated,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      context: context,
                      number: '1',
                      title: l10n.termsSection1Title,
                      content: l10n.termsSection1Content,
                    ),
                    _buildSection(
                      context: context,
                      number: '2',
                      title: l10n.termsSection2Title,
                      content: l10n.termsSection2Content,
                    ),
                    _buildSection(
                      context: context,
                      number: '3',
                      title: l10n.termsSection3Title,
                      content: l10n.termsSection3Content,
                    ),
                    _buildSection(
                      context: context,
                      number: '4',
                      title: l10n.termsSection4Title,
                      content: l10n.termsSection4Content,
                    ),
                    _buildSection(
                      context: context,
                      number: '5',
                      title: l10n.termsSection5Title,
                      content: l10n.termsSection5Content,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
