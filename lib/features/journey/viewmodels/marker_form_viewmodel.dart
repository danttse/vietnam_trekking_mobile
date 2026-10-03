import 'package:flutter/foundation.dart';
import '../data/models/marker_model.dart';
import '../data/repositories/journey_repository.dart';

enum MarkerFormState { idle, saving, success, error }

/// ViewModel cho form Đánh dấu cột mốc.
class MarkerFormViewModel extends ChangeNotifier {
  final JourneyRepository _repo;
  final String localJourneyId;
  final String userId;
  final MarkerModel? editingMarker; // null = create, non-null = edit

  MarkerFormViewModel({
    required this.localJourneyId,
    required this.userId,
    this.editingMarker,
    JourneyRepository? repo,
  }) : _repo = repo ?? JourneyRepository() {
    if (editingMarker != null) {
      name = editingMarker!.name;
      selectedType = editingMarker!.type;
      note = editingMarker!.note ?? '';
    }
  }

  // ── Form fields ───────────────────────────────────────────────────────────
  String name = '';
  String selectedType = 'OTHER';
  String note = '';
  List<String> mediaLocalPaths = [];

  // GPS injected from screen
  double? latitude;
  double? longitude;
  double? altitude;
  double? accuracy;

  // ── State ─────────────────────────────────────────────────────────────────
  MarkerFormState _state = MarkerFormState.idle;
  MarkerFormState get state => _state;

  String? _error;
  String? get error => _error;

  MarkerModel? savedMarker;

  bool get isEditing => editingMarker != null;
  bool get canSave =>
      name.trim().isNotEmpty && _state != MarkerFormState.saving;

  // ── Marker types list ─────────────────────────────────────────────────────
  static const List<Map<String, String>> markerTypes = [
    {'value': 'VIEWPOINT', 'label': 'Điểm ngắm cảnh', 'icon': '🏔️'},
    {'value': 'REST_POINT', 'label': 'Điểm nghỉ chân', 'icon': '🪑'},
    {'value': 'WATER_POINT', 'label': 'Nguồn nước', 'icon': '💧'},
    {'value': 'CAMP', 'label': 'Điểm cắm trại', 'icon': '⛺'},
    {'value': 'DANGER', 'label': 'Khu vực nguy hiểm', 'icon': '⚠️'},
    {'value': 'INTERSECTION', 'label': 'Ngã rẽ', 'icon': '🔀'},
    {'value': 'SUMMIT', 'label': 'Đỉnh núi', 'icon': '🗻'},
    {'value': 'LANDMARK', 'label': 'Cột mốc', 'icon': '📍'},
    {'value': 'PHOTO_SPOT', 'label': 'Điểm chụp ảnh', 'icon': '📸'},
    {'value': 'OTHER', 'label': 'Khác', 'icon': '📌'},
  ];

  void setType(String type) {
    selectedType = type;
    notifyListeners();
  }

  void addImage(String path) {
    mediaLocalPaths = [...mediaLocalPaths, path];
    notifyListeners();
  }

  void removeImage(String path) {
    mediaLocalPaths = mediaLocalPaths.where((p) => p != path).toList();
    notifyListeners();
  }

  void setLocation(double lat, double lng,
      {double? alt, double? acc}) {
    latitude = lat;
    longitude = lng;
    altitude = alt;
    accuracy = acc;
    notifyListeners();
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> save() async {
    if (!canSave || latitude == null) return;

    _state = MarkerFormState.saving;
    _error = null;
    notifyListeners();

    try {
      if (isEditing) {
        await _repo.updateMarker(
          editingMarker!.markerId,
          name: name.trim(),
          type: selectedType,
          note: note.trim().isEmpty ? null : note.trim(),
        );
        savedMarker = MarkerModel(
          markerId: editingMarker!.markerId,
          serverMarkerId: editingMarker!.serverMarkerId,
          localJourneyId: editingMarker!.localJourneyId,
          name: name.trim(),
          type: selectedType,
          note: note.trim().isEmpty ? null : note.trim(),
          latitude: editingMarker!.latitude,
          longitude: editingMarker!.longitude,
          altitude: editingMarker!.altitude,
          markedAt: editingMarker!.markedAt,
          syncStatus: editingMarker!.syncStatus,
          mediaLocalPaths: mediaLocalPaths,
        );
      } else {
        savedMarker = await _repo.createMarker(
          localJourneyId: localJourneyId,
          userId: userId,
          name: name.trim(),
          type: selectedType,
          latitude: latitude!,
          longitude: longitude!,
          altitude: altitude,
          accuracy: accuracy,
          note: note.trim().isEmpty ? null : note.trim(),
          mediaLocalPaths: mediaLocalPaths,
        );
      }
      _state = MarkerFormState.success;
    } catch (e) {
      _error = e.toString();
      _state = MarkerFormState.error;
    }
    notifyListeners();
  }
}
