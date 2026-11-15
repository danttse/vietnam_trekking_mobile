import 'package:flutter/foundation.dart';

import '../../../../core/database/database.dart';
import '../../services/offline_map_storage_service.dart';

class OfflineMapManagementViewModel extends ChangeNotifier {
  final OfflineMapStorageService _storageService;
  final CacheDao _cacheDao;
  final JourneyDao _journeyDao;

  bool _disposed = false;
  bool _isLoading = false;
  String? _error;
  String? _deletingMapId;
  List<DownloadedMap> _maps = [];
  StorageInfo? _storageInfo;
  final Map<String, String> _placeImages = {};

  // Lưu các Route ID và Place ID của các hành trình đang diễn ra
  final Set<String> _activeRouteIds = {};
  final Set<String> _activePlaceIds = {};

  OfflineMapManagementViewModel({
    OfflineMapStorageService? storageService,
    CacheDao? cacheDao,
    JourneyDao? journeyDao,
  })  : _storageService = storageService ?? OfflineMapStorageService(),
        _cacheDao = cacheDao ?? CacheDao(),
        _journeyDao = journeyDao ?? JourneyDao();

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get deletingMapId => _deletingMapId;
  List<DownloadedMap> get maps => List.unmodifiable(_maps);
  StorageInfo? get storageInfo => _storageInfo;
  int get mapCount => _maps.length;

  String? getPlaceImage(String mapId) => _placeImages[mapId];

  /// Kiểm tra xem bản đồ có thuộc hành trình đang đi (ACTIVE / PAUSED) không
  bool isMapInUse(DownloadedMap map) {
    if (map.scope == 'ROUTE' && map.trekkingRouteId != null) {
      if (_activeRouteIds.contains(map.trekkingRouteId)) return true;
    }
    if (map.trekkingPlaceId != null) {
      if (_activePlaceIds.contains(map.trekkingPlaceId)) return true;
    }
    return false;
  }

  Future<void> loadMaps() async {
    if (_disposed) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final downloaded = await _storageService.getAllDownloadedMaps();
      final info = await _storageService.getStorageInfo();

      // Kiểm tra các hành trình đang đi trong SQLite
      final activeJourneys = await _journeyDao.getJourneysByStatus('ACTIVE') +
          await _journeyDao.getJourneysByStatus('PAUSED');

      _activeRouteIds.clear();
      _activePlaceIds.clear();
      for (final j in activeJourneys) {
        if (j.trekkingRouteId.isNotEmpty) {
          _activeRouteIds.add(j.trekkingRouteId);
        }
        if (j.trekkingPlaceId.isNotEmpty) {
          _activePlaceIds.add(j.trekkingPlaceId);
        }
      }

      if (_disposed) return;
      _maps = downloaded;
      _storageInfo = info;

      // Tra cứu ảnh đại diện từ cached_places
      for (final map in _maps) {
        final placeId = map.trekkingPlaceId;
        if (placeId != null && placeId.isNotEmpty && !_placeImages.containsKey(map.mapId)) {
          try {
            final cached = await _cacheDao.getPlace(placeId);
            if (cached?.imageUrl != null && cached!.imageUrl!.isNotEmpty) {
              _placeImages[map.mapId] = cached.imageUrl!;
            }
          } catch (_) {
            // bỏ qua lỗi đọc ảnh cache
          }
        }
      }
    } catch (e) {
      if (!_disposed) {
        _error = 'Không thể tải danh sách bản đồ offline: $e';
      }
    } finally {
      if (!_disposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<bool> deleteMap(String mapId) async {
    if (_disposed || _deletingMapId != null) return false;

    // Ràng buộc bảo vệ: kiểm tra xem bản đồ có đang phục vụ hành trình đang đi không
    final map = _maps.cast<DownloadedMap?>().firstWhere(
      (m) => m?.mapId == mapId,
      orElse: () => null,
    );
    if (map != null && isMapInUse(map)) {
      _error = 'Bản đồ đang được sử dụng cho hành trình đang diễn ra, không thể xóa.';
      notifyListeners();
      return false;
    }

    _deletingMapId = mapId;
    _error = null;
    notifyListeners();

    try {
      await _storageService.deleteMap(mapId);
      _maps.removeWhere((m) => m.mapId == mapId);
      _placeImages.remove(mapId);
      _storageInfo = await _storageService.getStorageInfo();
      return true;
    } catch (e) {
      if (!_disposed) {
        _error = 'Lỗi khi xóa bản đồ offline: $e';
      }
      return false;
    } finally {
      if (!_disposed) {
        _deletingMapId = null;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
