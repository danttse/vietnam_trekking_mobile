import 'package:flutter/foundation.dart';
import '../data/models/journey_model.dart';
import '../data/models/route_model.dart';
import '../data/repositories/journey_repository.dart';

enum CreateJourneyState { idle, loadingRoutes, creating, success, error }

class CreateJourneyViewModel extends ChangeNotifier {
  final JourneyRepository _repo;

  CreateJourneyViewModel({JourneyRepository? repo})
      : _repo = repo ?? JourneyRepository();

  // ── Form state ────────────────────────────────────────────────────────────
  CreateJourneyState _state = CreateJourneyState.idle;
  CreateJourneyState get state => _state;

  String? _error;
  String? get error => _error;

  // Form fields
  String name = '';
  DateTime? plannedStartAt;
  DateTime? plannedEndAt;
  int? memberCount;
  String? notes;
  bool enableCheckin = true;

  // Route selection
  String? selectedRouteId;
  String? selectedPlaceId;
  String? selectedProvinceId;
  RouteModel? selectedRoute;

  // Available routes (từ cache/API)
  final List<RouteModel> _availableRoutes = [];
  List<RouteModel> get availableRoutes => _availableRoutes;

  // Created journey sau khi tạo thành công
  JourneyModel? createdJourney;

  // ── Actions ───────────────────────────────────────────────────────────────

  void selectRoute(RouteModel route) {
    selectedRoute = route;
    selectedRouteId = route.routeId;
    selectedPlaceId = route.trekkingPlaceId;
    notifyListeners();
  }

  Future<void> createJourney({String userId = 'local_user'}) async {
    if (name.trim().isEmpty) {
      _error = 'Vui lòng nhập tên chuyến đi';
      notifyListeners();
      return;
    }
    if (selectedRouteId == null || selectedPlaceId == null) {
      _error = 'Vui lòng chọn cung đường';
      notifyListeners();
      return;
    }

    _state = CreateJourneyState.creating;
    _error = null;
    notifyListeners();

    try {
      createdJourney = await _repo.createJourney(
        trekkingPlaceId: selectedPlaceId!,
        trekkingRouteId: selectedRouteId!,
        name: name.trim(),
        provinceId: selectedProvinceId,
        plannedStartAt: plannedStartAt,
        plannedEndAt: plannedEndAt,
        memberCount: memberCount,
        notes: notes?.trim(),
        enableCheckin: enableCheckin,
        userId: userId,
      );
      _state = CreateJourneyState.success;
    } catch (e) {
      _error = e.toString();
      _state = CreateJourneyState.error;
    }
    notifyListeners();
  }

  void resetError() {
    _error = null;
    _state = CreateJourneyState.idle;
    notifyListeners();
  }
}
