import 'package:flutter/material.dart';

class RegisterViewModel extends ChangeNotifier {
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;
  bool _isAgreeToTerms = false;
  bool _isLoading = false;

  bool get isPasswordObscured => _isPasswordObscured;
  bool get isConfirmPasswordObscured => _isConfirmPasswordObscured;
  bool get isAgreeToTerms => _isAgreeToTerms;
  bool get isLoading => _isLoading;

  void togglePasswordVisibility() {
    _isPasswordObscured = !_isPasswordObscured;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordObscured = !_isConfirmPasswordObscured;
    notifyListeners();
  }

  void toggleAgreeToTerms(bool? value) {
    _isAgreeToTerms = value ?? !_isAgreeToTerms;
    notifyListeners();
  }

  Future<void> register(String name, String email, String password, String confirmPassword) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 1500));

    _isLoading = false;
    notifyListeners();
    print('Đăng ký thành công với: $email');
  }
}