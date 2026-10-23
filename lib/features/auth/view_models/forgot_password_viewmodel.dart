import 'dart:async';

import 'package:flutter/material.dart';

import '../data/exceptions/auth_exception.dart';
import '../data/models/requests/reset_password_request.dart';
import '../data/models/requests/verify_otp_request.dart';
import '../repository/auth_repository.dart';

/// ViewModel cho luồng đặt lại mật khẩu 3 bước.
///
/// Bước 1 — Nhập email (sendForgotPassword / sendResetPasswordEmail)
/// Bước 2 — Nhập OTP   (verifyResetOtp / verifyOtp)
/// Bước 3 — Nhập mật khẩu mới (resetPassword / updateNewPassword)
///
/// Validates: Requirements 6.1–6.11
class ForgotPasswordViewModel extends ChangeNotifier {
  final AuthRepository _repository;

  // ── Step state ────────────────────────────────────────────────────────────

  /// 1 = email, 2 = OTP, 3 = new password
  int _currentStep = 1;

  /// Email được lưu sau khi gửi OTP thành công, dùng để gửi lại OTP.
  String? _savedEmail;

  /// Reset token nhận được sau khi xác minh OTP thành công.
  /// Chỉ lưu in-memory, KHÔNG lưu vào Token_Storage.
  String? _resetToken;

  // ── Loading / error state ─────────────────────────────────────────────────

  bool _isLoading = false;
  String? _errorMessage;

  // ── OTP countdown state ───────────────────────────────────────────────────

  bool _isOtpDisabled = false;
  int _otpSecondsRemaining = 0;
  Timer? _countdownTimer;

  // ── Password visibility (dùng bởi View cũ) ───────────────────────────────

  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  // ─────────────────────────────────────────────────────────────────────────
  // Constructor
  // ─────────────────────────────────────────────────────────────────────────

  ForgotPasswordViewModel({required this._repository});

  // ─────────────────────────────────────────────────────────────────────────
  // Getters
  // ─────────────────────────────────────────────────────────────────────────

  int get currentStep => _currentStep;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isOtpDisabled => _isOtpDisabled;
  int get otpSecondsRemaining => _otpSecondsRemaining;

  /// Tương thích với View cũ: bước 3 tương đương isOtpVerified = true.
  bool get isOtpVerified => _currentStep == 3;

  /// Tương thích với View cũ: OTP error = error message khi đang ở bước 2.
  String? get otpErrorMessage => _currentStep == 2 ? _errorMessage : null;

  bool get isPasswordObscured => _isPasswordObscured;
  bool get isConfirmPasswordObscured => _isConfirmPasswordObscured;

  // ─────────────────────────────────────────────────────────────────────────
  // Public API — new design spec methods
  // ─────────────────────────────────────────────────────────────────────────

  /// Bước 1: Gửi yêu cầu đặt lại mật khẩu.
  ///
  /// Trả về `true` khi thành công (chuyển sang bước 2 + khởi động đếm ngược).
  /// Trả về `false` và đặt [errorMessage] khi thất bại.
  Future<bool> sendForgotPassword(String email) async {
    final trimmedEmail = email.trim();

    if (!_validateEmail(trimmedEmail)) return false;

    _setLoading(true);
    _clearError();

    try {
      final response = await _repository.forgotPassword(trimmedEmail);
      _savedEmail = trimmedEmail;
      _currentStep = 2;
      _isOtpDisabled = false;
      _setLoading(false);
      startCountdown(response.secondsUntilExpiry > 0
          ? response.secondsUntilExpiry
          : 600);
      return true;
    } on AuthException catch (e) {
      _setLoading(false);
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _setLoading(false);
      _errorMessage = 'Đã có lỗi xảy ra. Vui lòng thử lại sau.';
      notifyListeners();
      return false;
    }
  }

  /// Bước 2: Xác minh OTP đặt lại mật khẩu.
  ///
  /// Trả về `true` khi thành công (lưu resetToken in-memory, chuyển bước 3).
  /// Trả về `false` và đặt [errorMessage] khi thất bại.
  Future<bool> verifyResetOtp(String otp) async {
    if (otp.length != 6) {
      _errorMessage = 'Vui lòng nhập đủ 6 chữ số OTP';
      notifyListeners();
      return false;
    }

    if (_savedEmail == null) {
      _errorMessage = 'Không tìm thấy email. Vui lòng thực hiện lại từ đầu.';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final response = await _repository.verifyResetOtp(
        VerifyOtpRequest(email: _savedEmail!, otp: otp),
      );
      _resetToken = response.resetToken;
      _currentStep = 3;
      stopCountdown();
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _setLoading(false);
      if (e.errorCode == AuthException.tooManyRequests) {
        // Req 6.10: vô hiệu hoá OTP input khi 429
        _isOtpDisabled = true;
      }
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _setLoading(false);
      _errorMessage = 'Đã có lỗi xảy ra. Vui lòng thử lại sau.';
      notifyListeners();
      return false;
    }
  }

  /// Bước 3: Đặt lại mật khẩu với resetToken đang giữ in-memory.
  ///
  /// Trả về `true` khi thành công (resetToken bị xoá, View nên điều hướng về LoginScreen).
  /// Trả về `false` và đặt [errorMessage] khi thất bại.
  ///
  /// Khi server trả 401 (resetToken hết hạn): xoá token, về bước 1,
  /// đặt thông báo "Phiên đặt lại mật khẩu đã hết hạn. Vui lòng thực hiện lại từ đầu".
  Future<bool> resetPassword(String newPassword, String confirmPassword) async {
    // Validation Req 6.9
    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      _errorMessage = 'Vui lòng nhập đầy đủ mật khẩu mới';
      notifyListeners();
      return false;
    }
    if (newPassword.length < 6) {
      _errorMessage = 'Mật khẩu phải có ít nhất 6 ký tự';
      notifyListeners();
      return false;
    }
    if (newPassword.length > 128) {
      _errorMessage = 'Mật khẩu không được vượt quá 128 ký tự';
      notifyListeners();
      return false;
    }
    if (newPassword != confirmPassword) {
      _errorMessage = 'Mật khẩu xác nhận không khớp';
      notifyListeners();
      return false;
    }

    if (_resetToken == null) {
      _errorMessage =
          'Phiên đặt lại mật khẩu đã hết hạn. Vui lòng thực hiện lại từ đầu';
      _currentStep = 1;
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      await _repository.resetPassword(
        ResetPasswordRequest(
          resetToken: _resetToken!,
          newPassword: newPassword,
        ),
      );
      _clearResetToken();
      _setLoading(false);
      return true; // View xử lý điều hướng về LoginScreen
    } on AuthException catch (e) {
      _setLoading(false);
      if (e.errorCode == AuthException.unauthorized) {
        // Req 6.8: resetToken hết hạn → bước 1
        _clearResetToken();
        _currentStep = 1;
        _errorMessage =
            'Phiên đặt lại mật khẩu đã hết hạn. Vui lòng thực hiện lại từ đầu';
      } else {
        _errorMessage = e.message;
      }
      notifyListeners();
      return false;
    } catch (_) {
      _setLoading(false);
      _errorMessage = 'Đã có lỗi xảy ra. Vui lòng thử lại sau.';
      notifyListeners();
      return false;
    }
  }

  /// Gửi lại OTP đặt lại mật khẩu bằng email đã lưu.
  Future<void> resendResetOtp() async {
    if (_savedEmail == null) return;
    await sendForgotPassword(_savedEmail!);
  }

  /// Khởi động đồng hồ đếm ngược [seconds] giây.
  void startCountdown(int seconds) {
    stopCountdown();
    _otpSecondsRemaining = seconds;
    notifyListeners();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_otpSecondsRemaining <= 0) {
        timer.cancel();
        _countdownTimer = null;
      } else {
        _otpSecondsRemaining--;
      }
      notifyListeners();
    });
  }

  /// Dừng đồng hồ đếm ngược.
  void stopCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Backward-compatible aliases (dùng bởi ForgotPasswordScreen hiện tại)
  // ─────────────────────────────────────────────────────────────────────────

  /// Alias → [sendForgotPassword]. Dùng bởi View cũ.
  Future<bool> sendResetPasswordEmail(String email) =>
      sendForgotPassword(email);

  /// Alias → [verifyResetOtp]. Dùng bởi View cũ (OtpDialog).
  Future<bool> verifyOtp(String otp) => verifyResetOtp(otp);

  /// Alias → [resetPassword]. Dùng bởi View cũ (bước đặt lại mật khẩu).
  Future<bool> updateNewPassword(
          String newPassword, String confirmPassword) =>
      resetPassword(newPassword, confirmPassword);

  /// Đảo ngược trạng thái ẩn/hiện mật khẩu mới.
  void togglePasswordVisibility() {
    _isPasswordObscured = !_isPasswordObscured;
    notifyListeners();
  }

  /// Đảo ngược trạng thái ẩn/hiện xác nhận mật khẩu.
  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordObscured = !_isConfirmPasswordObscured;
    notifyListeners();
  }

  /// Xoá thông báo lỗi.
  void clearMessages() {
    _clearError();
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Private helpers
  // ─────────────────────────────────────────────────────────────────────────

  /// Xoá resetToken khỏi bộ nhớ (không bao giờ ghi ra storage).
  void _clearResetToken() {
    _resetToken = null;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  bool _validateEmail(String email) {
    if (email.isEmpty) {
      _errorMessage = 'Vui lòng nhập địa chỉ email';
      notifyListeners();
      return false;
    }
    final emailRegExp = RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(email)) {
      _errorMessage = 'Địa chỉ email không hợp lệ';
      notifyListeners();
      return false;
    }
    return true;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void dispose() {
    stopCountdown();
    super.dispose();
  }
}
