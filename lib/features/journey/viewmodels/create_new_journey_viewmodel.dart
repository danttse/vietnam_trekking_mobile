import 'package:flutter/material.dart';
import '../../home/data/datasources/province_sample_data.dart';
import '../../route/data/datasources/route_sample_data.dart';
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
  late final List<RouteModel> _routes;

  CreateNewJourneyViewModel() {
    final now = DateTime.now();
    startedAtController.text =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    final endDate = now.add(const Duration(days: 2));
    completedAtController.text =
        '${endDate.day.toString().padLeft(2, '0')}/${endDate.month.toString().padLeft(2, '0')}/${endDate.year}';

    _routes = RouteSampleData.getSampleRoutes();
    _provinces = ProvinceData.provinces.map((p) => p.name).toList();
    if (_provinces.isNotEmpty && !_provinces.contains(_selectedProvince)) {
      _selectedProvince = _provinces.first;
    }
  }

  RouteModel? get selectedRoute => _selectedRoute;
  List<RouteModel> get routes => _routes;
  String get selectedProvince => _selectedProvince;
  bool get isCheckInFeatureEnabled => _isCheckInFeatureEnabled;
  List<String> get provinces => _provinces;
  bool get isLoading => _isLoading;

  void setRoute(RouteModel route) {
    _selectedRoute = route;
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
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    final route = _selectedRoute ?? (_routes.isNotEmpty ? _routes.first : null);
    if (route == null) {
      _isLoading = false;
      notifyListeners();
      return null;
    }

    final participantCount =
        int.tryParse(participantCountController.text.trim()) ?? 1;

    DateTime? plannedStart;
    DateTime? plannedEnd;
    try {
      final startParts = startedAtController.text.split('/');
      if (startParts.length == 3) {
        plannedStart = DateTime(
          int.parse(startParts[2]),
          int.parse(startParts[1]),
          int.parse(startParts[0]),
        );
      }
    } catch (_) {}

    try {
      final endParts = completedAtController.text.split('/');
      if (endParts.length == 3) {
        plannedEnd = DateTime(
          int.parse(endParts[2]),
          int.parse(endParts[1]),
          int.parse(endParts[0]),
        );
      }
    } catch (_) {}

    final newJourney = JourneyModel(
      journeyId: 'jn_${DateTime.now().millisecondsSinceEpoch}',
      name: journeyNameController.text.trim().isNotEmpty
          ? journeyNameController.text.trim()
          : route.name,
      route: route,
      plannedStartAt: plannedStart ?? DateTime.now(),
      plannedEndAt: plannedEnd,
      participantCount: participantCount,
      note: descriptionController.text.trim().isNotEmpty
          ? descriptionController.text.trim()
          : null,
      status: JourneyStatus.planned,
    );

    _isLoading = false;
    notifyListeners();
    return newJourney;
  }

  @override
  void dispose() {
    journeyNameController.dispose();
    startedAtController.dispose();
    completedAtController.dispose();
    participantCountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
