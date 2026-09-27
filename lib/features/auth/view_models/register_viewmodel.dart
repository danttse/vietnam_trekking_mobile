import 'dart:async';
import 'package:flutter/foundation.dart';

import '../data/exceptions/auth_exception.dart';
import '../data/models/requests/register_request.dart';
import '../data/models/requests/verify_otp_request.dart';
import '../repository/auth_repository.dart';
import '../../../core/services/token_storage.dart';

/// ViewModel quản lý luồng đăng ký 2 bước (thông tin + xác minh OTP).
///
/// Validates: Requirements 5.1–5.11
class RegisterViewModel extends ChangeNotifier {
  final AuthRepository _repository;
  final TokenStorage _tokenStorage;

  // ── Step 1: Registration form state ────────────────────────────────────────

  bool _isLoading = false;
  String? _errorMessage;
  String? _savedEmail;
  bool _isOtpStep = false;

  // ── Step 1: UI helpers preserved for register_screen.dart ─────────────────

  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;
  bool _isAgreeToTerms = false;

  // ── Step 2: OTP verification state ─────────────────────────────────────────

  bool _isOtpLoading = false;
  String? _otpErrorMessage;
  bool _isOtpDisabled = false;
  int _otpSecondsRemaining = 0;
  Timer? _countdownTimer;

  // ── Constructor ─────────────────────────────────────────────────────────────

  RegisterViewModel({
    required this._repository,
    required TokenStorage tokenStorage,
  })  : _tokenStorage = tokenStorage;

  // ── Step 1 getters ──────────────────────────────────────────────────────────

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get savedEmail => _savedEmail;
  bool get isOtpStep => _isOtpStep;

  // ── UI helper getters ───────────────────────────────────────────────────────

  bool get isPasswordObscured => _isPasswordObscured;
  bool get isConfirmPasswordObscured => _isConfirmPasswordObscured;
  bool get isAgreeToTerms => _isAgreeToTerms;

  // ── Step 2 getters ──────────────────────────────────────────────────────────

  bool get isOtpLoading => _isOtpLoading;
  String? get otpErrorMessage => _otpErrorMessage;
  bool get isOtpDisabled => _isOtpDisabled;
  int get otpSecondsRemaining => _otpSecondsRemaining;

  // ── UI helper methods ───────────────────────────────────────────────────────

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

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ── Step 1: Register ────────────────────────────────────────────────────────

  /// Validates input and calls the repository to start registration.
  ///
  /// Returns `true` when the server accepts the request (HTTP 201) and the
  /// OTP countdown has started. Returns `false` on validation failure or any
  /// API error — [errorMessage] will contain a human-readable message.
  ///
  /// Validates: Requirements 5.1, 5.9, 5.10
  Future<bool> register({
    required String displayName,
    required String email,
    required String password,
    required String confirmPassword,
    required bool agreedToTerms,
  }) async {
    // ── Validation (Req 5.9, 5.10) ──────────────────────────────────────────
    final validationError = _validateRegistration(
      displayName: displayName,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      agreedToTerms: agreedToTerms,
    );
    if (validationError != null) {
      _errorMessage = validationError;
      notifyListeners();
      return false;
    }

    // ── Call repository ──────────────────────────────────────────────────────
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.register(
        RegisterRequest(
          displayName: displayName.trim(),
          email: email.trim(),
          password: password,
        ),
      );

      _savedEmail = email.trim();
      _isOtpStep = true;
      _isLoading = false;
      startCountdown(response.secondsUntilExpiry);
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _isLoading = false;
      _errorMessage = _mapRegisterError(e);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Đã có lỗi xảy ra. Vui lòng thử lại';
      if (kDebugMode) {
        debugPrint('[RegisterViewModel] Unexpected error during register: $e');
      }
      notifyListeners();
      return false;
    }
  }

  // ── Step 2: Verify email OTP ────────────────────────────────────────────────

  /// Submits the OTP code for verification.
  ///
  /// On success (HTTP 200): saves tokens to [TokenStorage] and returns `true`.
  /// On HTTP 400 with remaining-attempts pattern: sets [otpErrorMessage].
  /// On HTTP 429: disables OTP input and sets [otpErrorMessage].
  ///
  /// Validates: Requirements 5.3, 5.4, 5.5, 5.6, 5.11
  Future<bool> verifyEmail({
    required String email,
    required String otp,
  }) async {
    _isOtpLoading = true;
    _otpErrorMessage = null;
    notifyListeners();

    try {
      final authResponse = await _repository.verifyEmail(
        VerifyOtpRequest(email: email, otp: otp),
      );

      await _tokenStorage.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );

      stopCountdown();
      _isOtpLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _isOtpLoading = false;
      _handleOtpError(e);
      notifyListeners();
      return false;
    } catch (e) {
      _isOtpLoading = false;
      _otpErrorMessage = 'Đã có lỗi xảy ra. Vui lòng thử lại';
      if (kDebugMode) {
        debugPrint('[RegisterViewModel] Unexpected error during verifyEmail: $e');
      }
      notifyListeners();
      return false;
    }
  }

  // ── Step 2: Resend OTP ──────────────────────────────────────────────────────

  /// Requests a new OTP and restarts the countdown with the new expiry.
  ///
  /// Validates: Requirements 5.7
  Future<void> resendOtp(String email) async {
    _isOtpLoading = true;
    _otpErrorMessage = null;
    _isOtpDisabled = false;
    notifyListeners();

    try {
      final response = await _repository.resendVerificationOtp(email);

      stopCountdown();
      _isOtpLoading = false;
      startCountdown(response.secondsUntilExpiry);
      notifyListeners();
    } on AuthException catch (e) {
      _isOtpLoading = false;
      _otpErrorMessage = e.message;
      notifyListeners();
    } catch (e) {
      _isOtpLoading = false;
      _otpErrorMessage = 'Đã có lỗi xảy ra. Vui lòng thử lại';
      if (kDebugMode) {
        debugPrint('[RegisterViewModel] Unexpected error during resendOtp: $e');
      }
      notifyListeners();
    }
  }

  // ── Countdown timer ─────────────────────────────────────────────────────────

  /// Starts (or restarts) a 1-second countdown from [seconds].
  ///
  /// Validates: Requirements 5.2, 5.7
  void startCountdown(int seconds) {
    stopCountdown();
    _otpSecondsRemaining = seconds > 0 ? seconds : 0;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_otpSecondsRemaining <= 0) {
        timer.cancel();
        _countdownTimer = null;
      } else {
        _otpSecondsRemaining--;
      }
      notifyListeners();
    });
    notifyListeners();
  }

  /// Cancels the active countdown timer without resetting the remaining seconds.
  void stopCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  // ── Lifecycle ────────────────────────────────────────────────────────────────

  @override
  void dispose() {
    stopCountdown();
    super.dispose();
  }

  // ── Private helpers ─────────────────────────────────────────────────────────

  /// Returns a validation error message or `null` when all fields are valid.
  ///
  /// Validates: Requirements 5.9, 5.10
  String? _validateRegistration({
    required String displayName,
    required String email,
    required String password,
    required String confirmPassword,
    required bool agreedToTerms,
  }) {
    final trimmedName = displayName.trim();
    if (trimmedName.length < 2 || trimmedName.length > 100) {
      return 'Họ và tên phải từ 2 đến 100 ký tự';
    }

    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty || !_isValidEmail(trimmedEmail)) {
      return 'Email không hợp lệ';
    }
    if (trimmedEmail.length > 254) {
      return 'Email không được vượt quá 254 ký tự';
    }

    if (password.length < 6 || password.length > 128) {
      return 'Mật khẩu phải từ 6 đến 128 ký tự';
    }

    if (password != confirmPassword) {
      return 'Mật khẩu xác nhận không khớp';
    }

    if (!agreedToTerms) {
      return 'Vui lòng đồng ý với điều khoản dịch vụ';
    }

    return null;
  }

  /// Basic RFC 5321-compatible email format check.
  bool _isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9.!#$%&'
      r"'*+/=?^_`{|}~-]+"
      r'@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?'
      r'(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$',
    ).hasMatch(email);
  }

  /// Maps an [AuthException] from the register call to a UI-friendly message.
  String _mapRegisterError(AuthException e) {
    // Req 5.8: email already exists → 400 with specific message
    if (e.errorCode == AuthException.validationError) {
      final msg = e.message.toLowerCase();
      if (msg.contains('email') &&
          (msg.contains('tồn tại') ||
              msg.contains('đã được sử dụng') ||
              msg.contains('already'))) {
        return 'Email đã được sử dụng';
      }
      return e.message;
    }
    return e.message;
  }

  /// Handles OTP-related [AuthException]s per Req 5.5, 5.6, 5.11.
  void _handleOtpError(AuthException e) {
    if (e.errorCode == AuthException.tooManyRequests) {
      // Req 5.6: 429 — disable OTP input
      _isOtpDisabled = true;
      _otpErrorMessage = 'Vượt quá số lần thử. Vui lòng yêu cầu OTP mới';
      return;
    }

    if (e.errorCode == AuthException.validationError) {
      // Req 5.5: 400 with "Còn X lần thử" pattern
      final remainingMatch =
          RegExp(r'Còn (\d+) lần thử').firstMatch(e.message);
      if (remainingMatch != null) {
        _otpErrorMessage = 'OTP không đúng. Còn ${remainingMatch.group(1)} lần thử';
        return;
      }
      _otpErrorMessage = e.message;
      return;
    }

    // Req 5.11: other errors
    _otpErrorMessage = e.message.isNotEmpty
        ? e.message
        : 'Đã có lỗi xảy ra. Vui lòng thử lại';
  }
}
