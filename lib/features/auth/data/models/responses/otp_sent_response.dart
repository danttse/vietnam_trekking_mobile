class OtpSentResponse {
  final String message;
  final String expiresAt; // ISO 8601

  const OtpSentResponse({
    required this.message,
    required this.expiresAt,
  });

  factory OtpSentResponse.fromJson(Map<String, dynamic> json) {
    return OtpSentResponse(
      message: json['message'] as String,
      expiresAt: json['expiresAt'] as String,
    );
  }

  /// Returns the number of seconds until OTP expiry, minimum 0.
  int get secondsUntilExpiry {
    final expiry = DateTime.parse(expiresAt);
    final diff = expiry.difference(DateTime.now()).inSeconds;
    return diff > 0 ? diff : 0;
  }
}
