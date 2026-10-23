/// Request model cho bước 3 của luồng đặt lại mật khẩu.
/// Validates: Requirements 6.5
class ResetPasswordRequest {
  final String resetToken;
  final String newPassword;

  const ResetPasswordRequest({
    required this.resetToken,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
        'resetToken': resetToken,
        'newPassword': newPassword,
      };
}
