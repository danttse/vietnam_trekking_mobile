import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/config/app_config.dart';
import '../../../core/services/auth_event_bus.dart';
import '../../../core/services/token_storage.dart';
import '../../../core/services/offline_store.dart';
import '../../../core/services/trekking_catalog_service.dart';
import '../../../core/network/dio_client.dart';
import '../data/province_model.dart';
import '../data/exceptions/province_exception.dart';
import 'province_visit_repository.dart';

/// Ánh xạ visitStatus từ backend sang trạng thái isVisited / isCheckedIn
/// của Province model phía frontend.
///
/// Backend trả về 3 trạng thái:
///   - UNVISITED   → isVisited=false, isCheckedIn=false
///   - SELF_REPORTED → isVisited=true,  isCheckedIn=false
///   - VERIFIED    → isVisited=true,  isCheckedIn=true
class ProvinceVisitRepositoryImpl implements ProvinceVisitRepository {
  final Dio _dio;
  final OfflineStore _offline;

  /// Map: snake_case code → backend ObjectId (provinceId)
  /// Được điền lần đầu khi gọi [getMyProvinceVisits].
  final Map<String, String> _codeToServerId = {};

  ProvinceVisitRepositoryImpl({required Dio dio, OfflineStore? store})
    : _dio = dio,
      _offline = store ?? OfflineStore.instance;

  // ── Factory ──────────────────────────────────────────────────────────────

  /// Tạo instance với Dio đã cấu hình sẵn TokenInterceptor trỏ đến
  /// checkin-service (AppConfig.checkinBaseUrl).
  factory ProvinceVisitRepositoryImpl.create({
    required TokenStorage tokenStorage,
    required AuthEventBus eventBus,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.checkinBaseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Dùng TokenInterceptor để tự động đính Bearer token vào mỗi request
    // (tái sử dụng cùng interceptor với auth-service)
    final authDio = DioClient.createDio(
      tokenStorage: tokenStorage,
      eventBus: eventBus,
    );
    for (final interceptor in authDio.interceptors) {
      dio.interceptors.add(interceptor);
    }

    return ProvinceVisitRepositoryImpl(dio: dio);
  }

  // ── ProvinceVisitRepository ───────────────────────────────────────────────

  /// GET /visits/provinces/me
  ///
  /// Backend trả về shape:
  /// ```json
  /// {
  ///   "success": true,
  ///   "data": {
  ///     "summary": { "totalProvinces": 34, ... },
  ///     "provinces": [
  ///       {
  ///         "provinceId": "<ObjectId>",
  ///         "code": "lam_dong",
  ///         "name": "Lâm Đồng",
  ///         "region": "SOUTH",
  ///         "visitStatus": "VERIFIED" | "SELF_REPORTED" | "UNVISITED",
  ///         "manualMarked": false,
  ///         "visitCount": 2,
  ///         "firstVisitedAt": "...",
  ///         "lastVisitedAt": "...",
  ///       }
  ///     ]
  ///   }
  /// }
  /// ```
  @override
  Future<List<Province>> getMyProvinceVisits() async {
    final owner = await _offline.requireOwner();
    try {
      await _offline.sync(
        trekking: TrekkingCatalogService().dio,
        checkin: _dio,
      );
      final data = (await _dio.get('/visits/provinces/me')).data['data'] as Map;
      if (await _offline.requireOwner() != owner)
        throw StateError('Tài khoản đã thay đổi.');
      await _offline.cacheProvinces(data['provinces'] as List, owner);
    } on DioException catch (e) {
      if (!OfflineStore.canUseCache(e)) _handleError(e);
      if (await _offline.read('/visits/provinces/me', owner: owner) == null)
        _handleError(e);
    }
    final items =
        await _offline.read('/visits/provinces/me', owner: owner) as List;
    _codeToServerId.clear();
    return items
        .map((p) => _mapToProvince(Map<String, dynamic>.from(p as Map)))
        .toList();
  }

  @override
  Future<void> setProvinceManualMark({
    required String serverProvinceId,
    required bool visited,
  }) async {
    final id = await _offline.markProvince(serverProvinceId, visited);
    try {
      await _offline.sync(
        trekking: TrekkingCatalogService().dio,
        checkin: _dio,
      );
      final error = await _offline.operationError(id);
      if (error != null) throw StateError(error);
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Trả về backend ObjectId (`provinceId`) cho một `code` tỉnh.
  /// Cần gọi [getMyProvinceVisits] trước để cache được điền.
  String? getServerIdForCode(String code) => _codeToServerId[code];

  Province _mapToProvince(Map<String, dynamic> map) {
    final code = map['code'] as String? ?? '';
    final serverId = map['provinceId'] as String? ?? '';
    final visitStatus = map['visitStatus'] as String? ?? 'UNVISITED';

    // Lưu cache code → serverId để dùng khi PATCH
    if (code.isNotEmpty && serverId.isNotEmpty) {
      _codeToServerId[code] = serverId;
    }

    // Ánh xạ region từ backend → frontend constant
    final regionRaw = map['region'] as String? ?? '';
    final region = _mapRegion(regionRaw);

    // Ánh xạ visitStatus → isVisited / isCheckedIn
    final isVisited =
        visitStatus == 'SELF_REPORTED' || visitStatus == 'VERIFIED';
    final isCheckedIn = visitStatus == 'VERIFIED';

    return Province(
      id: code, // dùng code (snake_case) làm id để match pathIndex
      name: map['name'] as String? ?? code,
      region: region,
      isVisited: isVisited,
      isCheckedIn: isCheckedIn,
    );
  }

  /// Map region enum từ backend sang constant của Province model.
  String _mapRegion(String region) {
    switch (region.toUpperCase()) {
      case 'NORTH':
        return Province.mienBac;
      case 'CENTRAL':
        return Province.mienTrung;
      case 'SOUTH':
        return Province.mienNam;
      default:
        // Fallback: thử map tiếng Việt trực tiếp
        if (region.contains('Bắc') || region.contains('bac')) {
          return Province.mienBac;
        }
        if (region.contains('Trung') || region.contains('trung')) {
          return Province.mienTrung;
        }
        return Province.mienNam;
    }
  }

  Never _handleError(DioException e) {
    if (kDebugMode) {
      debugPrint(
        '[ProvinceVisitRepository] Error — ${e.requestOptions.uri} '
        '| status: ${e.response?.statusCode} | ${e.message}',
      );
    }

    final isNetworkError =
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError;

    if (isNetworkError) {
      throw const ProvinceException(
        errorCode: ProvinceException.networkError,
        message: 'Không có kết nối mạng. Vui lòng kiểm tra lại',
      );
    }

    final status = e.response?.statusCode;
    if (status == 401) {
      throw const ProvinceException(
        errorCode: ProvinceException.unauthorized,
        message: 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại',
      );
    }
    if (status != null && status >= 500) {
      throw const ProvinceException(
        errorCode: ProvinceException.serverError,
        message: 'Máy chủ đang gặp sự cố. Vui lòng thử lại sau',
      );
    }

    throw const ProvinceException(
      errorCode: ProvinceException.unknownError,
      message: 'Đã có lỗi xảy ra. Vui lòng thử lại',
    );
  }
}
