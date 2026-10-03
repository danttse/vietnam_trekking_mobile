import 'package:flutter/material.dart';
import '../data/datasources/journey_sample_data.dart';
import '../data/models/journey_group_model.dart';
import '../data/models/journey_model.dart';

class JourneyViewModel extends ChangeNotifier {
  JourneyViewModel() {
    loadJourneys();
  }

  int _selectedTabIndex = 0;
  int get selectedTabIndex => _selectedTabIndex;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<JourneyModel> _completedJourneys = [];
  List<JourneyModel> _upcomingJourneys = [];

  List<JourneyGroupModel> _completedGroups = [];
  List<JourneyGroupModel> _upcomingGroups = [];

  List<JourneyModel> get currentJourneys =>
      _selectedTabIndex == 0 ? _completedJourneys : _upcomingJourneys;

  List<JourneyGroupModel> get currentGroups =>
      _selectedTabIndex == 0 ? _completedGroups : _upcomingGroups;

  int get currentTripsCount => currentJourneys.length;

  String get currentTotalDistanceText {
    final totalKm = currentJourneys.fold<double>(
      0.0,
      (sum, j) => sum + (j.statistics?.distanceKm ?? j.route.distanceKm),
    );
    final formatted = totalKm.truncateToDouble() == totalKm
        ? totalKm.toStringAsFixed(0)
        : totalKm.toStringAsFixed(1);
    return '$formatted km';
  }

  int get currentTotalParticipants => currentJourneys.fold<int>(
        0,
        (sum, j) => sum + j.participantCount,
      );

  String get tripBadgeText =>
      '${_completedJourneys.length + _upcomingJourneys.length} Chuyến đi';

  void setTab(int index) {
    if (_selectedTabIndex != index) {
      _selectedTabIndex = index;
      notifyListeners();
    }
  }

  void addJourney(JourneyModel journey) {
    if (journey.status == JourneyStatus.completed) {
      _completedJourneys.insert(0, journey);
      _completedGroups =
          JourneySampleData.groupJourneysByMonthYear(_completedJourneys);
      _selectedTabIndex = 0;
    } else {
      _upcomingJourneys.insert(0, journey);
      _upcomingGroups =
          JourneySampleData.groupJourneysByMonthYear(_upcomingJourneys);
      _selectedTabIndex = 1;
    }
    notifyListeners();
  }

  Future<void> loadJourneys() async {
    _isLoading = true;
    notifyListeners();

    _completedJourneys = JourneySampleData.getCompletedJourneys();
    _upcomingJourneys = JourneySampleData.getUpcomingJourneys();

    _completedGroups =
        JourneySampleData.groupJourneysByMonthYear(_completedJourneys);
    _upcomingGroups =
        JourneySampleData.groupJourneysByMonthYear(_upcomingJourneys);

    _isLoading = false;
    notifyListeners();
  }
}
