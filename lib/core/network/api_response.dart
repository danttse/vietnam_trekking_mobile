/// Generic wrapper for all API responses.
///
/// Backend response shapes:
///   Success:   { "success": true,  "data": { ... }, "message": "..." }
///   Error:     { "success": false, "error": { "code": "...", "message": "...", "details": {} } }
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final ApiError? error;

  const ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final rawData = json['data'];
    ApiError? apiError;
    if (json['error'] != null && json['error'] is Map<String, dynamic>) {
      apiError = ApiError.fromJson(json['error'] as Map<String, dynamic>);
    }
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      data: rawData != null && rawData is Map<String, dynamic>
          ? fromJsonT(rawData)
          : null,
      message: json['message'] as String?,
      error: apiError,
    );
  }
}

/// Error trả về từ backend trong trường hợp thất bại.
class ApiError {
  final String code;
  final String message;
  final Map<String, dynamic>? details;

  const ApiError({
    required this.code,
    required this.message,
    this.details,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) => ApiError(
        code: json['code'] as String? ?? 'UNKNOWN_ERROR',
        message: json['message'] as String? ?? 'Đã có lỗi xảy ra',
        details: json['details'] as Map<String, dynamic>?,
      );

  /// Chuyển error code sang thông báo tiếng Việt thân thiện với người dùng.
  String get userMessage => _messageForCode(code, fallback: message);

  static String _messageForCode(String code, {required String fallback}) {
    const messages = {
      // Validation
      'VALIDATION_ERROR': 'Dữ liệu đầu vào không hợp lệ.',
      // Auth
      'UNAUTHORIZED': 'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.',
      'FORBIDDEN': 'Bạn không có quyền thực hiện thao tác này.',
      // Not found
      'NOT_FOUND': 'Không tìm thấy dữ liệu yêu cầu.',
      'PLACE_NOT_FOUND': 'Địa điểm không tồn tại hoặc đã ngừng hoạt động.',
      'ROUTE_NOT_FOUND': 'Tuyến đường không tồn tại hoặc đã ngừng hoạt động.',
      'MILESTONE_NOT_FOUND': 'Cột mốc không tồn tại.',
      'JOURNEY_NOT_FOUND': 'Hành trình không tồn tại.',
      'MARKER_NOT_FOUND': 'Điểm đánh dấu không tồn tại.',
      'REVIEW_NOT_FOUND': 'Đánh giá không tồn tại.',
      'CONTRIBUTION_NOT_FOUND': 'Đóng góp không tồn tại.',
      // Conflict
      'CONFLICT': 'Dữ liệu bị trùng lặp.',
      'MARKER_DUPLICATE': 'Điểm đánh dấu này đã được tạo trước đó.',
      'JOURNEY_ALREADY_COMPLETED': 'Hành trình đã hoàn thành, không thể thay đổi.',
      'CONTRIBUTION_ALREADY_REVIEWED': 'Đóng góp này đã được duyệt bởi quản trị viên khác.',
      'IDEMPOTENCY_CONFLICT': 'Yêu cầu đang được xử lý, vui lòng chờ.',
      'CHECKIN_ALREADY_EXISTS': 'Bạn đã check-in cột mốc này trong hành trình này rồi.',
      // State errors
      'JOURNEY_INVALID_STATE': 'Không thể thực hiện thao tác này với trạng thái hành trình hiện tại.',
      'JOURNEY_NOT_OWNER': 'Hành trình này không thuộc về bạn.',
      'MARKER_NOT_OWNER': 'Điểm đánh dấu này không thuộc về bạn.',
      'CONTRIBUTION_INVALID_STATE': 'Không thể thực hiện thao tác này với trạng thái đóng góp hiện tại.',
      // Checkin
      'CHECKIN_OUT_OF_RADIUS': 'Bạn đang ngoài vùng check-in. Hãy tiến gần hơn.',
      'GPS_ACCURACY_TOO_LOW': 'Độ chính xác GPS không đủ. Hãy ra ngoài trời và thử lại.',
      // Server
      'INTERNAL_ERROR': 'Máy chủ gặp sự cố. Vui lòng thử lại sau.',
    };
    return messages[code.toUpperCase()] ?? fallback;
  }

  @override
  String toString() => 'ApiError[$code]: $message';
}
