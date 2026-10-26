import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/promote/views/promote_screen.dart';
import 'app/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// File test riêng để chạy màn Promote trực tiếp
/// Chạy lệnh: flutter run -t lib/test_promote_screen.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Reset flag để luôn hiển thị màn Promote khi chạy file này
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('has_seen_promote');
  
  runApp(const TestPromoteApp());
}

class TestPromoteApp extends StatelessWidget {
  const TestPromoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Test Promote Screen',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const PromoteScreen(),
    );
  }
}
