import 'package:flutter/foundation.dart';

import '../../../core/services/token_storage.dart';
import '../data/exceptions/auth_exception.dart';
import '../data/models/requests/google_signin_request.dart';
import '../data/models/requests/login_request.dart';
import '../repository/auth_repository.dart';
import '../services/google_signin_service.dart';

/// ViewModel cho màn hình đăng nhập.
///
/// Nhận [AuthRepository] và [TokenStorage] qua constructor injection.
/// Implements Requirements 4.1–4.9.
class LoginViewModel extends ChangeNotifier {
  final AuthRepository _repository;
  final TokenStorage _tokenStorage;
  final GoogleSignInService _googleSignInService;

  bool _isLoading = false;
  bool _isPasswordObscured = true;
  String? _errorMessage;

  LoginViewModel({
    required AuthRepository repository,
    required TokenStorage tokenStorage,
    GoogleSignInService? googleSignInService,
  }) : _repository = repository,
       _tokenStorage = tokenStorage,
       _googleSignInService = googleSignInService ?? GoogleSignInService();

  // ─── Getters ───────────────────────────────────────────────────────────────

  bool get isLoading => _isLoading;
  bool get isPasswordObscured => _isPasswordObscured;
  String? get errorMessage => _errorMessage;

  // ─── Public API ────────────────────────────────────────────────────────────

  /// Thực hiện đăng nhập với [email] và [password].
  ///
  /// Trả về `true` khi thành công (token đã lưu), `false` khi thất bại
  /// (khi đó [errorMessage] đã được set để View hiển thị).
  ///
  /// Requirement 4.8: validate trước khi gọi repo.
  /// Requirement 4.6: set [_isLoading] = true trong suốt quá trình call.
  Future<bool> login(String email, String password) async {
    // Bước 1: Validate — không gọi repo nếu dữ liệu không hợp lệ (Req 4.8)
    final validationError = _validate(email, password);
    if (validationError != null) {
      _errorMessage = validationError;
      notifyListeners();
      return false;
    }

    // Bước 2: Set loading state (Req 4.6)
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Bước 3: Gọi repository (Req 4.1)
      final response = await _repository.login(
        LoginRequest(email: email, password: password),
      );

      // Bước 4: Lưu token khi thành công (Req 4.2)
      await _tokenStorage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      // Bước 5: Map AuthException → thông báo tiếng Việt (Req 4.3–4.7, 4.9)
      _errorMessage = _mapAuthExceptionToMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      // Xử lý lỗi không mong đợi
      if (kDebugMode) {
        debugPrint('[LoginViewModel] Unexpected error: $e');
      }
      _errorMessage = 'Đã có lỗi xảy ra. Vui lòng thử lại';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Chuyển đổi trạng thái ẩn/hiện mật khẩu.
  void togglePasswordVisibility() {
    _isPasswordObscured = !_isPasswordObscured;
    notifyListeners();
  }

  /// Xóa thông báo lỗi hiện tại.
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Đăng nhập bằng Google
  ///
  /// Returns: `true` nếu đăng nhập thành công, `false` nếu thất bại hoặc user hủy
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Bước 1: Lấy Google ID Token
      final String? idToken = await _googleSignInService.signIn();

      if (idToken == null) {
        // User đã hủy sign-in
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Bước 2: Gửi ID Token đến backend để verify
      final response = await _repository.googleSignIn(
        GoogleSignInRequest(idToken: idToken),
      );

      // Bước 3: Lưu tokens từ backend
      await _tokenStorage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      // Map lỗi từ backend
      _errorMessage = _mapAuthExceptionToMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      // Lỗi từ Google Sign-In hoặc lỗi không mong đợi
      if (kDebugMode) {
        debugPrint('[LoginViewModel] Google Sign-In error: $e');
      }

      final errorMsg = e.toString().toLowerCase();
      if (errorMsg.contains('network') || errorMsg.contains('connection')) {
        _errorMessage = 'Không có kết nối mạng. Vui lòng kiểm tra lại';
      } else if (errorMsg.contains('cancel')) {
        // User đã hủy, không hiển thị lỗi
        _errorMessage = null;
      } else {
        _errorMessage = 'Đăng nhập Google thất bại. Vui lòng thử lại';
      }

      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ─── Private helpers ───────────────────────────────────────────────────────

  /// Validate email và password.
  ///
  /// Trả về thông báo lỗi nếu không hợp lệ, hoặc `null` nếu hợp lệ.
  /// Requirement 4.8.
  String? _validate(String email, String password) {
    if (email.trim().isEmpty) {
      return 'Vui lòng nhập email';
    }

    // Regex đơn giản kiểm tra định dạng email cơ bản
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email.trim())) {
      return 'Email không hợp lệ';
    }

    if (password.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }

    return null;
  }

  /// Map [AuthException.errorCode] → thông báo lỗi tiếng Việt.
  ///
  /// Requirement 4.3: UNAUTHORIZED → "Email hoặc mật khẩu không đúng"
  /// Requirement 4.4: FORBIDDEN + chưa xác minh → "Tài khoản chưa được xác minh email"
  /// Requirement 4.5: FORBIDDEN + bị khóa → "Tài khoản đã bị khóa"
  /// Requirement 4.7: NETWORK_ERROR → "Không có kết nối mạng..."
  /// Requirement 4.9: timeout (message chứa "timeout" hoặc errorCode phù hợp) → "Yêu cầu hết thời gian..."
  String _mapAuthExceptionToMessage(AuthException e) {
    switch (e.errorCode) {
      case AuthException.unauthorized:
        // Req 4.3
        return 'Email hoặc mật khẩu không đúng';

      case AuthException.forbidden:
        // Req 4.4 vs 4.5: phân biệt qua message từ server
        final msg = e.message.toLowerCase();
        if (msg.contains('xác minh') || msg.contains('verified')) {
          return 'Tài khoản chưa được xác minh email';
        }
        return 'Tài khoản đã bị khóa';

      case AuthException.networkError:
        // Req 4.7
        return 'Không có kết nối mạng. Vui lòng kiểm tra lại';

      case AuthException.serverError:
        // Req 4.9 — HTTP 408 được map thành SERVER_ERROR hoặc UNKNOWN_ERROR tuỳ implementation
        // Kiểm tra thêm message để xử lý timeout
        final msg = e.message.toLowerCase();
        if (msg.contains('timeout') || msg.contains('hết thời gian')) {
          return 'Yêu cầu hết thời gian. Vui lòng thử lại';
        }
        return e.message.isNotEmpty
            ? e.message
            : 'Đã có lỗi xảy ra. Vui lòng thử lại';

      case AuthException.unknownError:
        // Req 4.9: có thể là HTTP 408
        final msg = e.message.toLowerCase();
        if (msg.contains('timeout') || msg.contains('hết thời gian')) {
          return 'Yêu cầu hết thời gian. Vui lòng thử lại';
        }
        return e.message.isNotEmpty
            ? e.message
            : 'Đã có lỗi xảy ra. Vui lòng thử lại';

      case AuthException.validationError:
        return e.message.isNotEmpty
            ? e.message
            : 'Dữ liệu không hợp lệ. Vui lòng kiểm tra lại';

      default:
        return e.message.isNotEmpty
            ? e.message
            : 'Đã có lỗi xảy ra. Vui lòng thử lại';
    }
  }
}
