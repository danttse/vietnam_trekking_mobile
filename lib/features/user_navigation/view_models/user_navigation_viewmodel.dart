import 'package:flutter/material.dart';

/// ViewModel điều phối điều hướng dành riêng cho giao diện User
class UserNavigationViewModel extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  void goToHome() => setIndex(0);
  void goToExplore() => setIndex(1);
  void goToCommunity() => setIndex(2);
  void goToJourney() => setIndex(3);
  void goToProfile() => setIndex(4);
}
