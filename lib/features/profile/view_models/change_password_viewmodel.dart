import 'package:flutter/material.dart';

class ChangePasswordViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool _isCurrentPasswordObscured = true;
  bool _isNewPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get isCurrentPasswordObscured => _isCurrentPasswordObscured;
  bool get isNewPasswordObscured => _isNewPasswordObscured;
  bool get isConfirmPasswordObscured => _isConfirmPasswordObscured;
  String? get errorMessage => _errorMessage;

  void toggleCurrentPasswordVisibility() {
    _isCurrentPasswordObscured = !_isCurrentPasswordObscured;
    notifyListeners();
  }

  void toggleNewPasswordVisibility() {
    _isNewPasswordObscured = !_isNewPasswordObscured;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordObscured = !_isConfirmPasswordObscured;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _errorMessage = null;

    if (currentPassword.trim().isEmpty ||
        newPassword.trim().isEmpty ||
        confirmPassword.trim().isEmpty) {
      _errorMessage = 'Vui lòng nhập đầy đủ thông tin';
      notifyListeners();
      return false;
    }

    if (newPassword.length < 6) {
      _errorMessage = 'Mật khẩu phải có ít nhất 6 ký tự';
      notifyListeners();
      return false;
    }

    if (newPassword != confirmPassword) {
      _errorMessage = 'Mật khẩu xác nhận không khớp';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Giả lập gọi API đổi mật khẩu
      await Future.delayed(const Duration(milliseconds: 1000));
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
