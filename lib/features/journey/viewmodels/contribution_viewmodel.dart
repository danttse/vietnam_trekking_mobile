import 'package:flutter/foundation.dart';
import '../data/models/contribution_model.dart';
import '../data/models/journey_model.dart';
import '../data/repositories/journey_repository.dart';

enum ContributionSubmitState { idle, submitting, success, error }

enum ContributionLoadState { idle, loading, loaded, error }

/// ViewModel cho luồng đóng góp cung đường sau khi hoàn thành hành trình.
///
/// Flow:
///   1. User complete journey → JourneyDetailScreen hiển thị dialog
///   2. User chọn "Đóng góp cung đường" → mở ContributionScreen
///   3. ContributionViewModel.submitRouteContribution() → POST /contributions/routes
///   4. Hiển thị kết quả + navigate về
class ContributionViewModel extends ChangeNotifier {
  final JourneyRepository _repo;
  final String userId;

  ContributionViewModel({
    required this.userId,
    JourneyRepository? repo,
  }) : _repo = repo ?? JourneyRepository();

  // ── Form state ────────────────────────────────────────────────────────────
  String proposedName = '';
  String description = '';
  String notes = '';
  List<String> selectedMarkerIds = []; // serverMarkerId list

  // ── Submit state ──────────────────────────────────────────────────────────
  ContributionSubmitState _submitState = ContributionSubmitState.idle;
  ContributionSubmitState get submitState => _submitState;

  String? _error;
  String? get error => _error;

  ContributionModel? submittedContribution;

  // ── Load state (lịch sử đóng góp) ────────────────────────────────────────
  ContributionLoadState _loadState = ContributionLoadState.idle;
  ContributionLoadState get loadState => _loadState;

  List<ContributionModel> _routeContributions = [];
  List<ContributionModel> get routeContributions => _routeContributions;

  List<ContributionModel> _placeContributions = [];
  List<ContributionModel> get placeContributions => _placeContributions;

  // ── Actions ───────────────────────────────────────────────────────────────

  void setProposedName(String v) {
    proposedName = v;
    notifyListeners();
  }

  void setDescription(String v) {
    description = v;
    notifyListeners();
  }

  void setNotes(String v) {
    notes = v;
    notifyListeners();
  }

  void toggleMarkerId(String markerId) {
    if (selectedMarkerIds.contains(markerId)) {
      selectedMarkerIds =
          selectedMarkerIds.where((id) => id != markerId).toList();
    } else {
      selectedMarkerIds = [...selectedMarkerIds, markerId];
    }
    notifyListeners();
  }

  bool get canSubmit =>
      proposedName.trim().isNotEmpty &&
      _submitState != ContributionSubmitState.submitting;

  /// Gửi route contribution từ Journey đã COMPLETED.
  ///
  /// [journey] phải có status == COMPLETED và serverJourneyId.
  Future<bool> submitRouteContribution(JourneyModel journey) async {
    if (!canSubmit) return false;

    final serverJourneyId = journey.journeyId;
    // journeyId là serverJourneyId vì journey đã COMPLETED + synced
    if (serverJourneyId.isEmpty) {
      _error = 'Hành trình chưa đồng bộ với server. Vui lòng thử lại sau.';
      notifyListeners();
      return false;
    }

    _submitState = ContributionSubmitState.submitting;
    _error = null;
    notifyListeners();

    try {
      final clientOperationId =
          'OP_ROUTE_${DateTime.now().microsecondsSinceEpoch.toRadixString(16)}';

      final request = SubmitRouteContributionRequest(
        sourceJourneyId: serverJourneyId,
        trekkingPlaceId: journey.trekkingPlaceId,
        proposedName: proposedName.trim(),
        description: description.trim().isEmpty ? null : description.trim(),
        notes: notes.trim().isEmpty ? null : notes.trim(),
        encodedPolyline: null, // nếu có từ GPS track — TODO kết nối
        statistics: {
          if (journey.distanceMeters > 0)
            'distanceMeters': journey.distanceMeters,
          if (journey.durationSeconds > 0)
            'durationSeconds': journey.durationSeconds,
          if (journey.elevationGain > 0)
            'elevationGain': journey.elevationGain,
          if (journey.maxAltitude != null) 'maxAltitude': journey.maxAltitude,
        },
        markerIds: selectedMarkerIds,
        clientOperationId: clientOperationId,
      );

      submittedContribution = await _repo.submitRouteContribution(
        request,
        userId: userId,
      );
      _submitState = ContributionSubmitState.success;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _submitState = ContributionSubmitState.error;
      notifyListeners();
      return false;
    }
  }

  /// Load lịch sử đóng góp của user.
  Future<void> loadMyContributions({String? status}) async {
    _loadState = ContributionLoadState.loading;
    _error = null;
    notifyListeners();
    try {
      final resp = await _repo.getMyContributions(status: status);
      _routeContributions = resp.routes;
      _placeContributions = resp.places;
      _loadState = ContributionLoadState.loaded;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _loadState = ContributionLoadState.error;
    }
    notifyListeners();
  }

  void reset() {
    proposedName = '';
    description = '';
    notes = '';
    selectedMarkerIds = [];
    _submitState = ContributionSubmitState.idle;
    _error = null;
    submittedContribution = null;
    notifyListeners();
  }
}
