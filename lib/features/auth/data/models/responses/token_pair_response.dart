class TokenPairResponse {
  final String accessToken;
  final String refreshToken;

  const TokenPairResponse({
    required this.accessToken,
    required this.refreshToken,
  });

  factory TokenPairResponse.fromJson(Map<String, dynamic> json) {
    return TokenPairResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }
}
