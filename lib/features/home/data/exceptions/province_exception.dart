/// Exception được throw bởi [ProvinceVisitRepository] khi gọi API thất bại.
class ProvinceException implements Exception {
  static const String networkError = 'NETWORK_ERROR';
  static const String unauthorized = 'UNAUTHORIZED';
  static const String serverError = 'SERVER_ERROR';
  static const String unknownError = 'UNKNOWN_ERROR';

  final String errorCode;
  final String message;

  const ProvinceException({
    required this.errorCode,
    required this.message,
  });

  @override
  String toString() => 'ProvinceException[$errorCode]: $message';
}
