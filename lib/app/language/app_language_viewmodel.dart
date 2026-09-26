import 'package:flutter/material.dart';

class AppLanguageViewModel extends ChangeNotifier {
  static final AppLanguageViewModel _instance = AppLanguageViewModel._internal();
  factory AppLanguageViewModel() => _instance;
  AppLanguageViewModel._internal();

  Locale _currentLocale = const Locale('vi');

  Locale get currentLocale => _currentLocale;

  void changeLanguage(String languageCode) {
    if (_currentLocale.languageCode != languageCode) {
      _currentLocale = Locale(languageCode);
      notifyListeners();
    }
  }
}