import 'package:flutter/material.dart';
import 'features/auth/views/login_screen.dart';
import 'app/theme/app_theme.dart';

void main() {
  runApp(const VietnamTrekkingApp());
}

class VietnamTrekkingApp extends StatelessWidget {
  const VietnamTrekkingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const LoginScreen(),
    );
  }
}
