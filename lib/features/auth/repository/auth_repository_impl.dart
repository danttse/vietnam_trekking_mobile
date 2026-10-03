import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/network/api_response.dart';
import '../../../core/services/token_storage.dart';
import '../data/exceptions/auth_exception.dart';
import '../data/models/requests/login_request.dart';
import '../data/models/requests/register_request.dart';
import '../data/models/requests/reset_password_request.dart';
import '../data/models/requests/verify_otp_request.dart';
import '../data/models/responses/auth_response.dart';
import '../data/models/responses/otp_sent_response.dart';
import '../data/models/responses/reset_token_response.dart';
import '../data/models/responses/user_dto.dart';
import 'auth_repository.dart';

/// Concrete implementation of [AuthRepository] that communicates with the
/// API Gateway over HTTP using Dio and maps all [DioException]s to
/// typed [AuthException]s.
///
/// Validates: Requirements 4.1, 4.2, 5.1, 5.4, 6.1, 6.4, 6.5,
///            7.1, 7.2, 7.3, 7.5, 8.1–8.8
class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  const AuthRepositoryImpl({
    required this._dio,
    required TokenStorage tokenStorage,
  })  : _tokenStorage = tokenStorage;

  // ── Error mapping ──────────────────────────────────────────────────────────

  /// Converts a [DioException] into an [AuthException] with a Vietnamese
  /// user-facing message.
  ///
  /// Mapping rules (Requirement 8):
  /// - HTTP 400  → VALIDATION_ERROR  (message from response or fallback)
  /// - HTTP 401  → UNAUTHORIZED
  /// - HTTP 403  → FORBIDDEN         (message from response or fallback)
  /// - HTTP 429  → TOO_MANY_REQUESTS
  /// - HTTP 500, 503 → SERVER_ERROR
  /// - connectionTimeout / receiveTimeout / connectionError → NETWORK_ERROR
  /// - anything else → UNKNOWN_ERROR
  Never _handleError(DioException e) {
    // Debug logging — Requirement 8.7
    if (kDebugMode) {
      final url = e.requestOptions.uri.toString();
      final status = e.response?.statusCode;
      final msg = e.message ?? e.response?.data?.toString() ?? 'unknown';
      debugPrint('[AuthRepository] Error — URL: $url | status: $status | $msg');
    }

    // Network / timeout errors (no HTTP response)
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      throw AuthException(
        errorCode: AuthException.networkError,
        message: 'Không có kết nối mạng. Vui lòng kiểm tra lại',
      );
    }

    final statusCode = e.response?.statusCode;

    // Try to extract a message from the response body.
    String? responseMessage() {
      try {
        final data = e.response?.data;
        if (data is Map<String, dynamic>) {
          return data['message'] as String?;
        }
      } catch (_) {}
      return null;
    }

    switch (statusCode) {
      case 400:
        throw AuthException(
          errorCode: AuthException.validationError,
          message: responseMessage() ??
              'Dữ liệu không hợp lệ. Vui lòng kiểm tra lại',
        );
      case 401:
        throw AuthException(
          errorCode: AuthException.unauthorized,
          message: 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại',
        );
      case 403:
        throw AuthException(
          errorCode: AuthException.forbidden,
          message: responseMessage() ?? 'Truy cập bị từ chối',
        );
      case 429:
        throw AuthException(
          errorCode: AuthException.tooManyRequests,
          message: 'Quá nhiều yêu cầu. Vui lòng thử lại sau 30 giây',
        );
      case 500:
      case 503:
        throw AuthException(
          errorCode: AuthException.serverError,
          message: 'Máy chủ đang gặp sự cố. Vui lòng thử lại sau',
        );
      default:
        throw AuthException(
          errorCode: AuthException.unknownError,
          message: 'Đã có lỗi không xác định. Vui lòng thử lại',
        );
    }
  }

  // ── Repository methods ──────────────────────────────────────────────────────

  /// POST /auth/login
  /// Returns [AuthResponse] on success; throws [AuthException] on failure.
  /// Validates: Requirements 4.1, 4.2
  @override
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: request.toJson(),
      );
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        AuthResponse.fromJson,
      ).data!;
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  /// POST /auth/register
  /// Returns [OtpSentResponse] on success; throws [AuthException] on failure.
  /// Validates: Requirements 5.1
  @override
  Future<OtpSentResponse> register(RegisterRequest request) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: request.toJson(),
      );
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        OtpSentResponse.fromJson,
      ).data!;
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  /// POST /auth/verify-email
  /// Returns [AuthResponse] on success; throws [AuthException] on failure.
  /// Validates: Requirements 5.4
  @override
  Future<AuthResponse> verifyEmail(VerifyOtpRequest request) async {
    try {
      final response = await _dio.post(
        '/auth/verify-email',
        data: request.toJson(),
      );
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        AuthResponse.fromJson,
      ).data!;
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  /// POST /auth/resend-verification-otp
  /// Returns [OtpSentResponse] on success; throws [AuthException] on failure.
  /// Validates: Requirements 5.4
  @override
  Future<OtpSentResponse> resendVerificationOtp(String email) async {
    try {
      final response = await _dio.post(
        '/auth/resend-verification-otp',
        data: {'email': email},
      );
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        OtpSentResponse.fromJson,
      ).data!;
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  /// POST /auth/forgot-password
  /// Returns [OtpSentResponse] on success; throws [AuthException] on failure.
  /// Validates: Requirements 6.1
  @override
  Future<OtpSentResponse> forgotPassword(String email) async {
    try {
      final response = await _dio.post(
        '/auth/forgot-password',
        data: {'email': email},
      );
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        OtpSentResponse.fromJson,
      ).data!;
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  /// POST /auth/verify-reset-otp
  /// Returns [ResetTokenResponse] on success; throws [AuthException] on failure.
  /// Validates: Requirements 6.4
  @override
  Future<ResetTokenResponse> verifyResetOtp(VerifyOtpRequest request) async {
    try {
      final response = await _dio.post(
        '/auth/verify-reset-otp',
        data: request.toJson(),
      );
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        ResetTokenResponse.fromJson,
      ).data!;
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  /// POST /auth/reset-password
  /// Returns void on success; throws [AuthException] on failure.
  /// Validates: Requirements 6.5
  @override
  Future<void> resetPassword(ResetPasswordRequest request) async {
    try {
      await _dio.post(
        '/auth/reset-password',
        data: request.toJson(),
      );
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  /// POST /auth/logout  (fail-safe)
  ///
  /// Always sends the request with [refreshToken] in the body (if available).
  /// The Authorization header is automatically attached by [TokenInterceptor].
  ///
  /// If the request fails due to a network error or HTTP 5xx, the method
  /// still clears local tokens and returns successfully (local logout).
  ///
  /// Validates: Requirements 7.1, 7.2, 7.3, 7.5
  @override
  Future<void> logout({String? refreshToken}) async {
    try {
      await _dio.post(
        '/auth/logout',
        data: refreshToken != null ? {'refreshToken': refreshToken} : {},
      );
    } on DioException catch (e) {
      final type = e.type;
      final statusCode = e.response?.statusCode;

      // Network errors and server errors are tolerated — log and fall through.
      final isNetworkError = type == DioExceptionType.connectionTimeout ||
          type == DioExceptionType.receiveTimeout ||
          type == DioExceptionType.connectionError;
      final isServerError = statusCode != null && statusCode >= 500;

      if (!isNetworkError && !isServerError) {
        // Non-tolerated error (e.g. 400, 401, 403) — still clear tokens,
        // then surface the error to the caller.
        await _tokenStorage.clearTokens();
        _handleError(e);
      }

      // Network / 5xx: log in debug mode but continue to local logout.
      if (kDebugMode) {
        final url = e.requestOptions.uri.toString();
        final status = e.response?.statusCode;
        debugPrint(
          '[AuthRepository] logout failed (fail-safe) — URL: $url | status: $status',
        );
      }
    }

    // Always clear local tokens (Requirement 7.2, 7.3).
    await _tokenStorage.clearTokens();
  }

  /// GET /users/me
  /// Returns [UserDto] for the currently authenticated user.
  @override
  Future<UserDto> getMe() async {
    try {
      final response = await _dio.get('/users/me');
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        UserDto.fromJson,
      ).data!;
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  /// PATCH /users/me/bio
  @override
  Future<UserDto> updateBio(String bio) async {
    try {
      final response = await _dio.patch(
        '/users/me/bio',
        data: {'bio': bio},
      );
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        UserDto.fromJson,
      ).data!;
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  /// POST /users/me/avatar  (multipart/form-data)
  @override
  Future<UserDto> uploadAvatar(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(filePath, filename: 'avatar.jpg'),
      });
      final response = await _dio.post(
        '/users/me/avatar',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        UserDto.fromJson,
      ).data!;
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  /// PATCH /users/me/password
  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _dio.patch(
        '/users/me/password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
    } on DioException catch (e) {
      _handleError(e);
    }
  }
}
