/// Request model dùng chung cho xác minh OTP.
/// Sử dụng ở bước 2 đăng ký (POST /auth/verify-email)
/// và bước 2 đặt lại mật khẩu (POST /auth/verify-reset-otp).
/// Validates: Requirements 5.3, 6.1, 6.3
class VerifyOtpRequest {
  final String email;
  final String otp;

  const VerifyOtpRequest({
    required this.email,
    required this.otp,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'otp': otp,
      };
}
