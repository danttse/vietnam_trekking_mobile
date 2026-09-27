/// Generic wrapper for all API responses.
///
/// API responses follow the shape:
///   { "success": true,  "data": { ... } }
///   { "success": false, "message": "..." }
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;

  const ApiResponse({
    required this.success,
    this.data,
    this.message,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final rawData = json['data'];
    return ApiResponse<T>(
      success: json['success'] as bool,
      data: rawData != null
          ? fromJsonT(rawData as Map<String, dynamic>)
          : null,
      message: json['message'] as String?,
    );
  }
}
