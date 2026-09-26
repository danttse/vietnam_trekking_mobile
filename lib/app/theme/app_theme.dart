import 'package:flutter/material.dart';
import '../app_fonts.dart';
class AppTheme {

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: AppFonts.primary,
      colorScheme:const ColorScheme.dark(
        surface: Color(0xFF010101),
        surfaceContainerHighest: Color(0xFF151515),
        surfaceContainerLow: Color(0xFFb9dbc0),
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
      fontFamily: AppFonts.primary,
      colorScheme: const ColorScheme.light(
        //surface: Color(0xFFe1e8e5),
        surface: Color(0xFFeff0f2),
        surfaceContainerHighest: Color(0xFFfcfcfc),
        surfaceContainerLow: Color(0xFFb9dbc0),
        onSurface: Color(0xFF207335),
        onSurfaceVariant: Color(0xFF375534),
        primary: Color(0xFF207335),
      ),
    );
  }
}