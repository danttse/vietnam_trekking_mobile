import 'package:flutter/foundation.dart';

import '../../../core/services/auth_event_bus.dart';
import '../../../core/services/token_storage.dart';
import '../data/province_model.dart';
import '../data/recent_place_visited_model.dart';
import '../data/datasources/province_sample_data.dart';
import '../data/exceptions/province_exception.dart';
import '../repository/province_visit_repository.dart';
import '../repository/province_visit_repository_impl.dart';

class HomeViewModel extends ChangeNotifier {
  final ProvinceVisitRepository _repository;

  // ── State ─────────────────────────────────────────────────────────────────

  List<Province> provinces = List<Province>.from(ProvinceData.provinces);

  bool _isLoadingProvinces = false;
  String? _provincesError;

  bool get isLoadingProvinces => _isLoadingProvinces;
  String? get provincesError => _provincesError;

  List<RecentPlace> recentPlaces = [
    const RecentPlace(name: 'Núi Bà Đen', lastVisited: '19/9'),
    const RecentPlace(name: 'Tháp Nghinh Phong', lastVisited: '17/11'),
  ];

  int? _hoveredPathIndex;

  // ── Constructor ───────────────────────────────────────────────────────────

  HomeViewModel({required this._repository}) {
    loadProvinces();
  }

  // ── Factory (tự khởi tạo dependencies) ───────────────────────────────────

  factory HomeViewModel.create() {
    final tokenStorage = const SecureTokenStorage();
    final eventBus = AuthEventBus();
    final repository = ProvinceVisitRepositoryImpl.create(
      tokenStorage: tokenStorage,
      eventBus: eventBus,
    );
    return HomeViewModel(repository: repository);
  }

  // ── Computed getters ──────────────────────────────────────────────────────

  int? get hoveredPathIndex => _hoveredPathIndex;

  Province? get hoveredProvince {
    final index = _hoveredPathIndex;
    if (index == null) return null;
    for (final province in provinces) {
      if (province.pathIndex == index) return province;
    }
    return null;
  }

  List<Province> get visitedProvinces =>
      provinces.where((p) => p.isVisited).toList();

  List<Province> get checkedInProvinces =>
      provinces.where((p) => p.isCheckedIn).toList();

  List<Province> get getListNorthernProvinces =>
      provinces.where((p) => p.region == Province.mienBac).toList();

  List<Province> get getListCentralnProvinces =>
      provinces.where((p) => p.region == Province.mienTrung).toList();

  List<Province> get getListSouththernProvinces =>
      provinces.where((p) => p.region == Province.mienNam).toList();

  // ── API calls ─────────────────────────────────────────────────────────────

  /// Tải danh sách 34 tỉnh với trạng thái visit của user từ server.
  ///
  /// Khi thành công: cập nhật [provinces] từ API (isVisited / isCheckedIn thực).
  /// Khi thất bại: giữ nguyên static data fallback, set [provincesError] để UI
  /// có thể hiển thị thông báo nếu muốn.
  Future<void> loadProvinces() async {
    _isLoadingProvinces = true;
    _provincesError = null;
    notifyListeners();

    try {
      final apiProvinces = await _repository.getMyProvinceVisits();

      // Merge dữ liệu API (isVisited, isCheckedIn) với static data (area, population)
      // dùng static map để lookup nhanh theo id (= code từ backend)
      final staticMap = {for (final p in ProvinceData.provinces) p.id: p};

      provinces = apiProvinces.map((apiProvince) {
        final staticProvince = staticMap[apiProvince.id];
        if (staticProvince != null) {
          // Giữ area/population từ static, lấy isVisited/isCheckedIn từ API
          return staticProvince.copyWith(
            isVisited: apiProvince.isVisited,
            isCheckedIn: apiProvince.isCheckedIn,
          );
        }
        return apiProvince;
      }).toList();
    } on ProvinceException catch (e) {
      _provincesError = e.message;
      if (kDebugMode) {
        debugPrint('[HomeViewModel] loadProvinces error: $e');
      }
      // Giữ fallback static data — không clear provinces
    } catch (e) {
      _provincesError = 'Không thể tải dữ liệu bản đồ. Vui lòng thử lại';
      if (kDebugMode) {
        debugPrint('[HomeViewModel] loadProvinces unexpected error: $e');
      }
    } finally {
      _isLoadingProvinces = false;
      notifyListeners();
    }
  }

  /// Reload lại danh sách tỉnh từ server (dùng cho pull-to-refresh).
  Future<void> refreshProvinces() => loadProvinces();

  // ── Local state updates ───────────────────────────────────────────────────

  void addRecentPlace(RecentPlace place) {
    recentPlaces.insert(0, place);
    notifyListeners();
  }

  void toggleProvinceVisited(String provinceId) {
    final index = provinces.indexWhere((p) => p.id == provinceId);
    if (index == -1) return;
    final current = provinces[index];
    provinces[index] = current.copyWith(isVisited: !current.isVisited);
    notifyListeners();
  }

  /// Cập nhật local state sau khi PATCH API thành công.
  /// Được gọi bởi [SelectProvinceSheet] sau khi server đã xác nhận.
  void updateVisitedProvinces(Set<String> visitedIds) {
    for (int i = 0; i < provinces.length; i++) {
      final p = provinces[i];
      final shouldBeVisited = visitedIds.contains(p.id);
      if (p.isVisited != shouldBeVisited) {
        provinces[i] = p.copyWith(isVisited: shouldBeVisited);
      }
    }
    notifyListeners();
  }

  void setHoveredPath(int? pathIndex) {
    if (_hoveredPathIndex == pathIndex) return;
    _hoveredPathIndex = pathIndex;
    notifyListeners();
  }

  // ── Repository accessor (cho SelectProvinceSheet) ─────────────────────────

  /// Trả về repository để SelectProvinceSheet gọi PATCH API.
  ProvinceVisitRepository get repository => _repository;

  /// Lấy backend ObjectId (provinceId) từ code tỉnh (snake_case).
  ///
  /// Chỉ có giá trị sau khi [loadProvinces] đã hoàn thành ít nhất một lần.
  /// Nếu không tìm thấy (chưa load hoặc code sai) → trả về null.
  String? getServerIdForCode(String code) {
    final repo = _repository;
    if (repo is ProvinceVisitRepositoryImpl) {
      return repo.getServerIdForCode(code);
    }
    return null;
  }

  /// Gọi PATCH API để đánh dấu/bỏ đánh dấu một tỉnh, rồi cập nhật local.
  ///
  /// [provinceCode] là id tỉnh phía frontend (= code snake_case từ backend).
  /// [visited] = true → tick, false → bỏ tick.
  /// Throws [ProvinceException] nếu server trả lỗi.
  Future<void> setProvinceManualMark({
    required String provinceCode,
    required bool visited,
  }) async {
    final serverId = getServerIdForCode(provinceCode);
    if (serverId == null) {
      if (kDebugMode) {
        debugPrint(
          '[HomeViewModel] setProvinceManualMark: no serverId for "$provinceCode"',
        );
      }
      return;
    }
    await _repository.setProvinceManualMark(
      serverProvinceId: serverId,
      visited: visited,
    );
    // Cập nhật local state ngay sau khi server xác nhận
    final index = provinces.indexWhere((p) => p.id == provinceCode);
    if (index != -1) {
      provinces[index] = provinces[index].copyWith(isVisited: visited);
      notifyListeners();
    }
  }
}
