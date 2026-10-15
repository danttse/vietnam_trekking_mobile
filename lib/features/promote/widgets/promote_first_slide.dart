import 'package:flutter/material.dart';
import 'package:vietnam_trekking_mobile/l10n/app_localizations.dart';

class PromoteFirstSlide extends StatelessWidget {
  const PromoteFirstSlide({super.key});
  @override
  Widget build(BuildContext context) {
    final l10n=AppLocalizations.of(context)!;
    final colorScheme=Theme.of(context).colorScheme;
    return Stack(
      fit:StackFit.expand,
      children: [
        Image.asset(
          'assets/images/vietnam_landscape.webp',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: colorScheme.surfaceContainerHigh,
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
          ),
        ),
        Positioned(
        top:100,
        left:16,
        right: 16,
        child: 
          Column(
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/img_app_logo_ver1.png',
                    width: 60,
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.appName,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                l10n.appTagline,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          )
        )
      ],
    );
  }
}