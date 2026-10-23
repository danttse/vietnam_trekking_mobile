import '../data/province_model.dart';

/// Interface cho tất cả thao tác với visited provinces trên checkin-service.
abstract class ProvinceVisitRepository {
  /// GET /visits/provinces/me
  ///
  /// Trả về danh sách 34 [Province] với trạng thái visit của user hiện tại.
  Future<List<Province>> getMyProvinceVisits();

  /// PATCH /visits/provinces/me/:provinceId
  ///
  /// Đánh dấu hoặc bỏ đánh dấu một tỉnh là đã đến (SELF_REPORTED).
  /// [serverProvinceId] là ObjectId từ backend (field `provinceId`).
  /// [visited] = true để tick, false để bỏ tick.
  Future<void> setProvinceManualMark({
    required String serverProvinceId,
    required bool visited,
  });
}
