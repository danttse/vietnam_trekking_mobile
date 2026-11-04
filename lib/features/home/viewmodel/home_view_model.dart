import 'dart:async';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';

import '../../../core/services/offline_store.dart';
import '../../../core/services/user_api_service.dart';
import '../../../core/services/trekking_catalog_service.dart';
import '../../../core/network/api_error_handler.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets/feedback/app_snack_bar.dart';

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
  final UserApiService _userApi;
  final TrekkingCatalogService _catalog;
  final GlobalKey _captureKey = GlobalKey();

  // ── State ─────────────────────────────────────────────────────────────────

  List<Province> provinces = List<Province>.from(ProvinceData.provinces);

  bool _isLoadingProvinces = false;
  String? _provincesError;

  bool get isLoadingProvinces => _isLoadingProvinces;
  String? get provincesError => _provincesError;
  GlobalKey get captureKey => _captureKey;

  List<RecentPlace> recentPlaces = [];
  List<RecentPlace> explorePlaces = [];
  bool isLoadingPlaces = false;
  String? placesError;
  List<RecentPlace> get displayedPlaces =>
      recentPlaces.isNotEmpty ? recentPlaces : explorePlaces;
  double totalDistanceKm = 0;
  int completedTrips = 0;
  String? activityError;
  bool _disposed = false;
  bool _refreshingOffline = false;
  StreamSubscription<String>? _offlineSubscription;

  Future<void> refreshAfterSync(String owner) async {
    if (_disposed || _refreshingOffline || _isLoadingProvinces) return;
    if (await OfflineStore.currentOwner() != owner || _disposed) return;
    _refreshingOffline = true;
    try {
      await Future.wait([loadProvinces(), loadActivity()]);
    } finally {
      _refreshingOffline = false;
    }
  }

  Future<void> loadActivity() async {
    await Future.wait([_loadStatistics(), loadPlaces()]);
  }

  Future<void> _loadStatistics() async {
    try {
      final stats = await _userApi.getStatistics();
      if (_disposed) return;
      totalDistanceKm = (stats['totalDistanceMeters'] as num? ?? 0) / 1000;
      completedTrips = (stats['totalJourneys'] as num? ?? 0).toInt();
      activityError = null;
    } catch (_) {
      if (!_disposed) activityError = 'Không thể tải thống kê.';
    }
    if (!_disposed) notifyListeners();
  }

  Future<void> loadPlaces() async {
    if (_disposed || isLoadingPlaces) return;
    isLoadingPlaces = true;
    placesError = null;
    notifyListeners();
    try {
      List<Map<String, dynamic>> visits;
      try {
        visits = await _userApi.getRecentPlaces();
      } catch (e) {
        if (_isAuthFailure(e)) rethrow;
        _logPlacesFailure('recent visits', e);
        visits = [];
      }
      if (_disposed) return;
      final seen = <String>{};
      final recent = await Future.wait(
        visits
            .where((visit) {
              final id = visit['trekkingPlaceId']?.toString().trim();
              return id != null && id.isNotEmpty && seen.add(id);
            })
            .take(10)
            .map((visit) async {
              final id = visit['trekkingPlaceId'].toString().trim();
              try {
                final place = await _catalog.getPlace(id);
                final date = DateTime.tryParse(
                  visit['lastVisitedAt']?.toString() ?? '',
                )?.toLocal();
                return RecentPlace(
                  name: place['name'] as String? ?? '',
                  lastVisited: date == null ? '' : '${date.day}/${date.month}',
                  placeId: id,
                  imageUrl: _imageUrl(place),
                );
              } catch (e) {
                if (_isAuthFailure(e)) rethrow;
                _logPlacesFailure('recent place', e);
                return null;
              }
            }),
      );
      if (_disposed) return;
      recentPlaces = recent.whereType<RecentPlace>().toList();
      if (recentPlaces.isEmpty) {
        final places = await _catalog.getPlaces(maxItems: 10);
        if (_disposed) return;
        explorePlaces = places
            .take(10)
            .map(
              (place) => RecentPlace(
                name: place['name'] as String? ?? '',
                lastVisited: '',
                placeId: place['trekkingPlaceId'].toString(),
                imageUrl: _imageUrl(place),
              ),
            )
            .toList();
      } else {
        explorePlaces = [];
      }
    } catch (e) {
      _logPlacesFailure('load places', e);
      if (!_disposed) {
        placesError = e is DioException
            ? ApiErrorHandler.handle(e)
            : 'Không thể tải địa điểm. Vui lòng thử lại.';
      }
    } finally {
      isLoadingPlaces = false;
      if (!_disposed) notifyListeners();
    }
  }

  static bool _isAuthFailure(Object error) =>
      error is DioException &&
      (error.response?.statusCode == 401 ||
          error.response?.statusCode == 403 ||
          error.type == DioExceptionType.cancel);

  static void _logPlacesFailure(String stage, Object error) {
    if (!kDebugMode) return;
    if (error is DioException) {
      debugPrint(
        '[HomeViewModel] $stage: ${error.requestOptions.path} '
        'HTTP ${error.response?.statusCode}, ${error.type.name}',
      );
    } else {
      debugPrint('[HomeViewModel] $stage: ${error.runtimeType}');
    }
  }

  static String _imageUrl(Map<String, dynamic> place) {
    final images = place['images'] as List? ?? [];
    return images.isEmpty ? '' : images.first?.toString() ?? '';
  }

  @override
  void dispose() {
    _disposed = true;
    _offlineSubscription?.cancel();
    super.dispose();
  }

  int? _hoveredPathIndex;

  // ── Constructor ───────────────────────────────────────────────────────────

  HomeViewModel({
    required ProvinceVisitRepository repository,
    UserApiService? userApi,
    TrekkingCatalogService? catalog,
    bool autoLoad = true,
  }) : _repository = repository,
       _userApi = userApi ?? UserApiService(),
       _catalog = catalog ?? TrekkingCatalogService() {
    _offlineSubscription = OfflineStore.instance.changes.listen(
      refreshAfterSync,
    );
    if (autoLoad) {
      loadProvinces();
      loadActivity();
    }
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
      if (_disposed) return;

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
      if (!_disposed) notifyListeners();
    }
  }

  /// Reload lại danh sách tỉnh từ server (dùng cho pull-to-refresh).
  Future<void> refreshProvinces() => loadProvinces();

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
      if (!_disposed) notifyListeners();
    }
  }

  Future<void> captureAndSave([BuildContext? context]) async {
    final ctx = context ?? _captureKey.currentContext;
    if (ctx == null) return;
    try {
      final boundary =
          _captureKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      if (byteData == null) return;
      final byte = byteData.buffer.asUint8List();

      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        await Gal.requestAccess();
      }
      await Gal.putImageBytes(byte, name: 'vietnam_trekking_map');

      if (ctx.mounted) {
        AppSnackBar.showSuccess(ctx, 'Đã lưu ảnh vào Thư viện thành công!');
        Navigator.of(ctx).maybePop();
      }
    } catch (_) {
      if (ctx.mounted) {
        AppSnackBar.showError(ctx, 'Không thể lưu ảnh, vui lòng thử lại.');
      }
    }
  }
}
