import 'package:flutter/material.dart';

class EditTextAuthCustom extends StatelessWidget {
  final String label;
  final String? hintText;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextEditingController controller;

  const EditTextAuthCustom({
    super.key,
    required this.label,
    this.hintText,
    this.obscureText = false,
    required this.controller,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border:Border.all(color: colorScheme.onSurfaceVariant),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
              border: InputBorder.none,
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              suffixIcon: suffixIcon,
              suffixIconConstraints: suffixIcon != null
                  ? const BoxConstraints(minHeight: 48, minWidth: 48)
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}