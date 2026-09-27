/// Exception thrown by [AuthRepository] when an authentication-related error occurs.
///
/// Each exception carries an [errorCode] for programmatic handling and a
/// human-readable [message] (typically in Vietnamese) for display in the UI.
class AuthException implements Exception {
  /// Predefined error codes for all authentication failure scenarios.
  static const String validationError = 'VALIDATION_ERROR';
  static const String unauthorized = 'UNAUTHORIZED';
  static const String forbidden = 'FORBIDDEN';
  static const String tooManyRequests = 'TOO_MANY_REQUESTS';
  static const String serverError = 'SERVER_ERROR';
  static const String networkError = 'NETWORK_ERROR';
  static const String unknownError = 'UNKNOWN_ERROR';

  final String errorCode;
  final String message;

  const AuthException({required this.errorCode, required this.message});

  @override
  String toString() => 'AuthException(errorCode: $errorCode, message: $message)';
}
