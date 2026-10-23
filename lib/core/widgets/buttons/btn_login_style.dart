import 'package:flutter/material.dart';

class BtnLoginPrimary extends StatelessWidget {
  final String text;
  final bool isLoading;
  final VoidCallback? onPressed;

  const BtnLoginPrimary({
    super.key,
    required this.text,
    this.isLoading = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      // Allow translated labels and larger accessibility text to wrap.
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: isLoading
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: colorScheme.onSurfaceVariant,
                  ),
                )
              : Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: onPressed == null
                        ? colorScheme.onSurface.withValues(alpha: 0.38)
                        : colorScheme.onPrimary,
                  ),
                ),
        ),
      ),
    );
  }
}
