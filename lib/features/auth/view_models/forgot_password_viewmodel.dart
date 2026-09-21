import 'package:flutter/material.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool _isOtpLoading = false;
  String? _otpErrorMessage;
  bool _isOtpVerified = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get hasError => _errorMessage != null;
  bool get isSuccess => _successMessage != null;

  bool get isOtpLoading => _isOtpLoading;
  String? get otpErrorMessage => _otpErrorMessage;
  bool get isOtpVerified => _isOtpVerified;

  bool isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegExp.hasMatch(email.trim());
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    _otpErrorMessage = null;
    notifyListeners();
  }

  Future<bool> sendResetPasswordEmail(String email) async {
    final trimmedEmail = email.trim();

    if (trimmedEmail.isEmpty) {
      _errorMessage = 'Vui lòng nhập địa chỉ email';
      _successMessage = null;
      notifyListeners();
      return false;
    }

    if (!isValidEmail(trimmedEmail)) {
      _errorMessage = 'Địa chỉ email không hợp lệ';
      _successMessage = null;
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 1500));

      _isLoading = false;
      _successMessage = 'Mã khôi phục đã được gửi về email: $trimmedEmail';
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Đã có lỗi xảy ra. Vui lòng thử lại sau.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyOtp(String otp) async {
    if (otp.length != 6) {
      _otpErrorMessage = 'Vui lòng nhập đủ 6 chữ số OTP';
      notifyListeners();
      return false;
    }

    _isOtpLoading = true;
    _otpErrorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 1000));
      _isOtpLoading = false;
      _isOtpVerified = true;
      _otpErrorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _isOtpLoading = false;
      _otpErrorMessage = 'Mã OTP không chính xác. Vui lòng thử lại.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(String email) => sendResetPasswordEmail(email);
  Future<bool> forgotPassword(String email) => sendResetPasswordEmail(email);
  Future<bool> sendOtp(String email) => sendResetPasswordEmail(email);
}