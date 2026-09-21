import 'package:flutter/material.dart';

class LoginViewModel extends ChangeNotifier {
  bool _isPasswordObscured = true;
  bool _isLoading = false;

  bool get isPasswordObscured => _isPasswordObscured;
  bool get isLoading => _isLoading;

  void togglePasswordVisibility() {
    _isPasswordObscured = !_isPasswordObscured;
    notifyListeners();
  }
  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 1500));

    _isLoading = false;
    notifyListeners();
    print('Đăng nhập thành công với: $email');
  }
  void toggleForgotPassword() {
    
  }
}