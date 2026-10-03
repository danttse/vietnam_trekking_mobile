import 'package:flutter/foundation.dart';
import '../data/models/journey_model.dart';
import '../data/repositories/journey_repository.dart';

enum JourneyListTab { completed, upcoming }

class JourneyListViewModel extends ChangeNotifier {
  final JourneyRepository _repo;

  JourneyListViewModel({JourneyRepository? repo})
      : _repo = repo ?? JourneyRepository();

  // ── State ─────────────────────────────────────────────────────────────────
  JourneyListTab _tab = JourneyListTab.completed;
  JourneyListTab get tab => _tab;

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  List<JourneyModel> _completed = [];
  List<JourneyModel> _upcoming = [];

  List<JourneyModel> get completedJourneys => _completed;
  List<JourneyModel> get upcomingJourneys => _upcoming;

  List<JourneyModel> get current =>
      _tab == JourneyListTab.completed ? _completed : _upcoming;

  // Summary stats
  int get totalCompleted => _completed.length;
  double get totalDistanceKm {
    final total = _completed.fold<double>(
        0, (sum, j) => sum + j.distanceMeters / 1000);
    return total;
  }

  int get totalCheckins =>
      _completed.fold(0, (sum, j) => sum + j.checkinCount);

  int get upcomingCount => _upcoming.length;

  // ── Actions ───────────────────────────────────────────────────────────────

  void setTab(JourneyListTab tab) {
    if (_tab == tab) return;
    _tab = tab;
    notifyListeners();
  }

  Future<void> loadAll() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _repo.getJourneys(status: 'COMPLETED'),
        _repo.getJourneys(status: 'PLANNED'),
      ]);
      _completed = results[0];
      _upcoming = results[1];

      // Active + Paused cũng thuộc "sắp tới" / ongoing
      final active = await _repo.getJourneys(status: 'ACTIVE');
      final paused = await _repo.getJourneys(status: 'PAUSED');
      _upcoming = [...active, ...paused, ..._upcoming];
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => loadAll();
}
