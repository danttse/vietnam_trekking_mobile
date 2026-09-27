class UserDto {
  final String userId;
  final String email;
  final String displayName;
  final String role;
  final String status;
  final String? avatarUrl;
  final String? emailVerifiedAt;

  const UserDto({
    required this.userId,
    required this.email,
    required this.displayName,
    required this.role,
    required this.status,
    this.avatarUrl,
    this.emailVerifiedAt,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      userId: json['userId'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      role: json['role'] as String,
      status: json['status'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      emailVerifiedAt: json['emailVerifiedAt'] as String?,
    );
  }
}
