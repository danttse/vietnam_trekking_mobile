import 'package:flutter/material.dart';

class AppThemeViewModel extends ChangeNotifier {
  static final AppThemeViewModel _instance = AppThemeViewModel._internal();
  factory AppThemeViewModel() => _instance;
  AppThemeViewModel._internal();

  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setDarkMode(bool value) {
    if (_isDarkMode != value) {
      _isDarkMode = value;
      notifyListeners();
    }
  }
}
