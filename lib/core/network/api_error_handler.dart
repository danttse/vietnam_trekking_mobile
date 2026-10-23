import 'package:dio/dio.dart';
import 'api_response.dart';

/// Xử lý lỗi từ Dio và chuyển sang thông báo tiếng Việt.
///
/// Sử dụng ở Repository / ViewModel để parse DioException.
abstract class ApiErrorHandler {
  /// Parse DioException → thông báo lỗi tiếng Việt.
  static String handle(Object error) {
    if (error is DioException) {
      return _handleDioException(error);
    }
    return error.toString();
  }

  static String _handleDioException(DioException e) {
    // Thử parse error body theo format backend
    final apiError = _extractApiError(e);
    if (apiError != null) {
      return apiError.userMessage;
    }

    // Fallback theo HTTP status
    final status = e.response?.statusCode;
    if (status != null) {
      return _messageForStatus(status);
    }

    // Network-level errors
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Kết nối quá chậm. Vui lòng kiểm tra mạng và thử lại.';
      case DioExceptionType.connectionError:
        return 'Không thể kết nối máy chủ. Kiểm tra kết nối mạng.';
      case DioExceptionType.cancel:
        return 'Yêu cầu đã bị hủy.';
      case DioExceptionType.badResponse:
        return _messageForStatus(e.response?.statusCode ?? 500);
      default:
        return 'Đã xảy ra lỗi mạng. Vui lòng thử lại.';
    }
  }

  static ApiError? _extractApiError(DioException e) {
    try {
      final data = e.response?.data;
      if (data is Map<String, dynamic> &&
          data['error'] is Map<String, dynamic>) {
        return ApiError.fromJson(data['error'] as Map<String, dynamic>);
      }
    } catch (_) {}
    return null;
  }

  static String _messageForStatus(int status) {
    switch (status) {
      case 400:
        return 'Dữ liệu gửi lên không hợp lệ. Vui lòng kiểm tra lại.';
      case 401:
        return 'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.';
      case 403:
        return 'Bạn không có quyền thực hiện thao tác này.';
      case 404:
        return 'Không tìm thấy dữ liệu yêu cầu.';
      case 409:
        return 'Dữ liệu bị trùng lặp hoặc xung đột. Vui lòng thử lại.';
      case 422:
        return 'Thao tác không hợp lệ với trạng thái hiện tại.';
      case 429:
        return 'Quá nhiều yêu cầu. Vui lòng chờ một chút rồi thử lại.';
      case 500:
        return 'Máy chủ gặp sự cố. Vui lòng thử lại sau.';
      case 503:
        return 'Dịch vụ đang bảo trì. Vui lòng thử lại sau.';
      default:
        return 'Đã xảy ra lỗi (HTTP $status). Vui lòng thử lại.';
    }
  }
}

/// Map error code → thông báo tiếng Việt thân thiện.
abstract class ApiErrorMessages {
  static String forCode(String code, {required String fallback}) {
    return _messages[code.toUpperCase()] ?? fallback;
  }

  static const Map<String, String> _messages = {
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
}
