class ResetTokenResponse {
  final String resetToken;

  const ResetTokenResponse({required this.resetToken});

  factory ResetTokenResponse.fromJson(Map<String, dynamic> json) {
    return ResetTokenResponse(
      resetToken: json['resetToken'] as String,
    );
  }
}
