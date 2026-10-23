/// Request model cho bước 1 của luồng đăng ký.
/// Validates: Requirements 5.1, 5.3
class RegisterRequest {
  final String displayName;
  final String email;
  final String password;

  const RegisterRequest({
    required this.displayName,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'displayName': displayName,
        'email': email,
        'password': password,
      };
}
