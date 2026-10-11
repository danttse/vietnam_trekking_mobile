import 'package:flutter/material.dart';

import '../../home/data/datasources/province_sample_data.dart';
import '../../../core/services/trekking_catalog_service.dart';
import '../../../core/network/api_error_handler.dart';
import '../../route/data/models/route_model.dart';
import '../data/models/journey_model.dart';

class CreateNewJourneyViewModel extends ChangeNotifier {
  final TextEditingController journeyNameController = TextEditingController();
  final TextEditingController startedAtController = TextEditingController();
  final TextEditingController completedAtController = TextEditingController();
  final TextEditingController participantCountController =
      TextEditingController(text: '1');
  final TextEditingController descriptionController = TextEditingController();

  RouteModel? _selectedRoute;
  String _selectedProvince = 'Lào Cai';
  bool _isCheckInFeatureEnabled = true;
  bool _isLoading = false;

  late final List<String> _provinces;
  List<RouteModel> _routes = [];
  List<Map<String, dynamic>> _places = [];
  final TrekkingCatalogService _catalog;
  bool _loadingPlaces = false;
  String? error;
  bool _disposed = false;
  final String _clientJourneyId =
      'journey_${DateTime.now().microsecondsSinceEpoch}';

  Future<void> loadRoutes() async {
    _loadingPlaces = true;
    if (!_disposed) notifyListeners();
    try {
      _places = await _catalog.getPlaces();
      error = null;
    } catch (e) {
      error = ApiErrorHandler.handle(e);
    } finally {
      _loadingPlaces = false;
      if (!_disposed) notifyListeners();
    }
  }

  CreateNewJourneyViewModel({
    TrekkingCatalogService? catalog,
    bool autoLoad = true,
  }) : _catalog = catalog ?? TrekkingCatalogService() {
    final now = DateTime.now();
    startedAtController.text =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    final endDate = now.add(const Duration(days: 2));
    completedAtController.text =
        '${endDate.day.toString().padLeft(2, '0')}/${endDate.month.toString().padLeft(2, '0')}/${endDate.year}';

    if (autoLoad) loadRoutes();
    _provinces = ProvinceData.provinces.map((p) => p.name).toList();
    if (_provinces.isNotEmpty && !_provinces.contains(_selectedProvince)) {
      _selectedProvince = _provinces.first;
    }
  }

  RouteModel? get selectedRoute => _selectedRoute;
  List<RouteModel> get routes => _routes;
  List<Map<String, dynamic>> get places => _places;
  bool get loadingPlaces => _loadingPlaces;
  String? get selectedPlaceName => _places
      .where((p) => p['trekkingPlaceId'] == _selectedRoute?.trekkingPlaceId)
      .firstOrNull?['name']
      ?.toString();
  String get selectedProvince => _selectedProvince;
  bool get isCheckInFeatureEnabled => _isCheckInFeatureEnabled;
  List<String> get provinces => _provinces;
  bool get isLoading => _isLoading;

  void setRoute(RouteModel route) {
    _selectedRoute = route;
    _routes = [route];
    error = null;
    if (route.province != null && _provinces.contains(route.province)) {
      _selectedProvince = route.province!;
    }
    notifyListeners();
  }

  void setProvince(String? value) {
    if (value != null && value != _selectedProvince) {
      _selectedProvince = value;
      notifyListeners();
    }
  }

  void setCheckInFeatureEnabled(bool value) {
    if (_isCheckInFeatureEnabled != value) {
      _isCheckInFeatureEnabled = value;
      notifyListeners();
    }
  }

  Future<JourneyModel?> submit() async {
    if (_isLoading) return null;
    error = null;
    final route = _selectedRoute;
    if (route == null) {
      error = 'Vui lòng chọn địa điểm rồi chọn cung đường.';
      notifyListeners();
      return null;
    }

    final participantCount = int.tryParse(
      participantCountController.text.trim(),
    );
    DateTime? parseDate(String text) {
      final parts = text.split('/');
      if (parts.length != 3) return null;
      final day = int.tryParse(parts[0]),
          month = int.tryParse(parts[1]),
          year = int.tryParse(parts[2]);
      if (day == null || month == null || year == null) return null;
      final date = DateTime(year, month, day);
      return date.day == day && date.month == month && date.year == year
          ? date
          : null;
    }

    final plannedStart = parseDate(startedAtController.text);
    final plannedEnd = parseDate(completedAtController.text);
    if (participantCount == null ||
        participantCount < 1 ||
        plannedStart == null ||
        plannedEnd == null ||
        plannedEnd.isBefore(plannedStart)) {
      error = 'Kiểm tra ngày bắt đầu, ngày kết thúc và số người tham gia (ít nhất 1).';
      notifyListeners();
      return null;
    }
    _isLoading = true;
    notifyListeners();

    try {
      final journey = await _catalog.createJourney({
        'clientJourneyId': _clientJourneyId,
        'trekkingPlaceId': route.trekkingPlaceId,
        'trekkingRouteId': route.routeId,
        'name': journeyNameController.text.trim().isEmpty
            ? route.name
            : journeyNameController.text.trim(),
        'participantCount': participantCount,
        'note': descriptionController.text.trim(),
        'plannedStartAt': plannedStart.toUtc().toIso8601String(),
        'plannedEndAt': plannedEnd.toUtc().toIso8601String(),
      }, route);
      error = null;
      return journey;
    } catch (e) {
      error = ApiErrorHandler.handle(e);
      return null;
    } finally {
      if (!_disposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    journeyNameController.dispose();
    startedAtController.dispose();
    completedAtController.dispose();
    participantCountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
