import 'package:flutter/material.dart';
class AppTheme {

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme:const ColorScheme.dark(
        surface: Color(0xFF0f1513),
        surfaceContainerHighest: Color(0xFF1a2320),
        onSurface: Color(0xFFf4f7f5),
        onSurfaceVariant: Color(0xFF90a396),
        primary: Color(0xFF207335),
      ),
    );
  }
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        surface: Color(0xFFf0f0f0),
        surfaceContainerHighest: Color(0xFFe7e7e7),
        onSurface: Color(0xFF207335),
        onSurfaceVariant: Color(0xFF375534),
        primary: Color(0xFF207335),
      ),
    );
  }
}