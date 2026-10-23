class UserDto {
  final String userId;
  final String email;
  final String displayName;
  final String role;
  final String status;
  final String? avatarUrl;
  final String? emailVerifiedAt;
  final String? bio;

  const UserDto({
    required this.userId,
    required this.email,
    required this.displayName,
    required this.role,
    required this.status,
    this.avatarUrl,
    this.emailVerifiedAt,
    this.bio,
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
      bio: json['bio'] as String?,
    );
  }
}
