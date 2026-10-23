import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/services/auth_event_bus.dart';
import '../../../core/services/token_storage.dart';
import '../../auth/data/exceptions/auth_exception.dart';
import '../../auth/repository/auth_repository_impl.dart';

class ChangePasswordViewModel extends ChangeNotifier {
  late final AuthRepositoryImpl _repository;

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

  ChangePasswordViewModel() {
    final tokenStorage = const SecureTokenStorage();
    final eventBus = AuthEventBus();
    final dio = DioClient.createDio(tokenStorage: tokenStorage, eventBus: eventBus);
    _repository = AuthRepositoryImpl(dio: dio, tokenStorage: tokenStorage);
  }

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

    // ── Validation ────────────────────────────────────────────────────────
    if (currentPassword.trim().isEmpty ||
        newPassword.trim().isEmpty ||
        confirmPassword.trim().isEmpty) {
      _errorMessage = 'Vui lòng nhập đầy đủ thông tin';
      notifyListeners();
      return false;
    }

    if (newPassword.length < 6) {
      _errorMessage = 'Mật khẩu mới phải có ít nhất 6 ký tự';
      notifyListeners();
      return false;
    }

    if (newPassword != confirmPassword) {
      _errorMessage = 'Mật khẩu xác nhận không khớp';
      notifyListeners();
      return false;
    }

    if (currentPassword == newPassword) {
      _errorMessage = 'Mật khẩu mới phải khác mật khẩu hiện tại';
      notifyListeners();
      return false;
    }

    // ── API call ──────────────────────────────────────────────────────────
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _isLoading = false;
      _errorMessage = e.message;
      if (kDebugMode) debugPrint('[ChangePasswordVM] ${e.message}');
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Đã có lỗi xảy ra. Vui lòng thử lại';
      if (kDebugMode) debugPrint('[ChangePasswordVM] $e');
      notifyListeners();
      return false;
    }
  }
}
