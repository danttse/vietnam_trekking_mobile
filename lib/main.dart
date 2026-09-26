import 'package:flutter/material.dart';
import 'features/auth/views/login_screen.dart';
import 'app/theme/app_theme.dart';
import 'app/theme/app_theme_viewmodel.dart';

void main() {
  runApp(const VietnamTrekkingApp());
}

class VietnamTrekkingApp extends StatefulWidget {
  const VietnamTrekkingApp({super.key});

  @override
  State<VietnamTrekkingApp> createState() => _VietnamTrekkingAppState();
}

class _VietnamTrekkingAppState extends State<VietnamTrekkingApp> {
  final AppThemeViewModel _themeViewModel = AppThemeViewModel();

  @override
  void initState() {
    super.initState();
    _themeViewModel.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _themeViewModel.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeViewModel.themeMode,
      home: const LoginScreen(),
    );
  }
}
