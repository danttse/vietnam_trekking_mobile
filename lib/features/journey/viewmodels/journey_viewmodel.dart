import 'dart:async';

import '../../../core/services/trekking_catalog_service.dart';
import '../../../core/network/api_error_handler.dart';

import 'package:flutter/material.dart';

import '../data/models/journey_group_model.dart';
import '../data/models/journey_model.dart';

class JourneyViewModel extends ChangeNotifier {
  final TrekkingCatalogService _api;
  JourneyViewModel({TrekkingCatalogService? catalog, bool autoLoad = true})
    : _api = catalog ?? TrekkingCatalogService() {
    _offlineSubscription = _api.offline.changes.listen((owner) async {
      if (!_disposed &&
          await _api.offline.ownerProvider() == owner &&
          !_disposed) {
        await loadJourneys();
      }
    });
    if (autoLoad) loadJourneys();
  }

  StreamSubscription<String>? _offlineSubscription;
  bool _disposed = false;
  String? error;
  @override
  void dispose() {
    _disposed = true;
    _offlineSubscription?.cancel();
    super.dispose();
  }

  int _selectedTabIndex = 0;
  int get selectedTabIndex => _selectedTabIndex;

  bool _isLoading = false;
  bool _reloadRequested = false;
  bool get isLoading => _isLoading;

  List<JourneyModel> _completedJourneys = [];
  List<JourneyModel> _upcomingJourneys = [];
  List<JourneyModel> _cancelledJourneys = [];

  List<JourneyGroupModel> _completedGroups = [];
  List<JourneyGroupModel> _upcomingGroups = [];
  List<JourneyGroupModel> _cancelledGroups = [];

  List<JourneyModel> get currentJourneys => switch (_selectedTabIndex) {
        0 => _completedJourneys,
        1 => _upcomingJourneys,
        _ => _cancelledJourneys,
      };

  List<JourneyGroupModel> get currentGroups => switch (_selectedTabIndex) {
        0 => _completedGroups,
        1 => _upcomingGroups,
        _ => _cancelledGroups,
      };

  int get currentTripsCount => currentJourneys.length;

  String get currentTotalDistanceText {
    final totalKm = currentJourneys.fold<double>(
      0.0,
      (sum, j) => sum + j.displayDistanceKm,
    );
    final formatted = totalKm.truncateToDouble() == totalKm
        ? totalKm.toStringAsFixed(0)
        : totalKm.toStringAsFixed(1);
    return '$formatted km';
  }

  int get currentTotalParticipants =>
      currentJourneys.fold<int>(0, (sum, j) => sum + j.participantCount);

  String get tripBadgeText =>
      '${_completedJourneys.length + _upcomingJourneys.length + _cancelledJourneys.length} Chuyến đi';

  void setTab(int index) {
    if (_selectedTabIndex != index) {
      _selectedTabIndex = index;
      notifyListeners();
    }
  }

  void addJourney(JourneyModel journey) {
    _completedJourneys.removeWhere(
      (j) =>
          j.journeyId == journey.journeyId ||
          journey.clientJourneyId != null &&
              j.clientJourneyId == journey.clientJourneyId,
    );
    _upcomingJourneys.removeWhere(
      (j) =>
          j.journeyId == journey.journeyId ||
          journey.clientJourneyId != null &&
              j.clientJourneyId == journey.clientJourneyId,
    );
    _cancelledJourneys.removeWhere(
      (j) =>
          j.journeyId == journey.journeyId ||
          journey.clientJourneyId != null &&
              j.clientJourneyId == journey.clientJourneyId,
    );
    if (journey.status == JourneyStatus.completed) {
      _completedJourneys.insert(0, journey);
      _selectedTabIndex = 0;
    } else if (journey.status == JourneyStatus.cancelled) {
      _cancelledJourneys.insert(0, journey);
      _selectedTabIndex = 2;
    } else {
      _upcomingJourneys.insert(0, journey);
      _selectedTabIndex = 1;
    }
    _completedGroups = groupJourneysByMonthYear(_completedJourneys);
    _upcomingGroups = groupJourneysByMonthYear(_upcomingJourneys);
    _cancelledGroups = groupJourneysByMonthYear(_cancelledJourneys);
    notifyListeners();
  }

  Future<void> loadJourneys() async {
    if (_disposed) return;
    if (_isLoading) {
      _reloadRequested = true;
      return;
    }
    _isLoading = true;
    notifyListeners();

    try {
      final journeys = await _api.getJourneys();
      if (_disposed) return;
      _completedJourneys = journeys
          .where((j) => j.status == JourneyStatus.completed)
          .toList();
      _upcomingJourneys = journeys
          .where(
            (j) =>
                j.status != JourneyStatus.completed &&
                j.status != JourneyStatus.cancelled,
          )
          .toList();
      _cancelledJourneys = journeys
          .where((j) => j.status == JourneyStatus.cancelled)
          .toList();
      _completedGroups = groupJourneysByMonthYear(_completedJourneys);
      _upcomingGroups = groupJourneysByMonthYear(_upcomingJourneys);
      _cancelledGroups = groupJourneysByMonthYear(_cancelledJourneys);
      error = null;
    } catch (e, stack) {
      if (_disposed) return;
      debugPrint('[JourneyViewModel] loadJourneys: $e\n$stack');
      error = 'Không thể tải hành trình. ${ApiErrorHandler.handle(e)}';
    }
    _isLoading = false;
    notifyListeners();
    if (_reloadRequested) {
      _reloadRequested = false;
      await loadJourneys();
    }
  }

  static List<JourneyGroupModel> groupJourneysByMonthYear(
    List<JourneyModel> journeys,
  ) {
    if (journeys.isEmpty) return [];

    final Map<String, List<JourneyModel>> map = {};
    final Map<String, DateTime> dateMap = {};

    for (final journey in journeys) {
      final date = journey.primaryDate;
      final key = '${date.year}_${date.month.toString().padLeft(2, '0')}';

      map.putIfAbsent(key, () => []).add(journey);
      dateMap.putIfAbsent(key, () => DateTime(date.year, date.month));
    }

    final sortedKeys = map.keys.toList()..sort((a, b) => b.compareTo(a));

    return sortedKeys.map((key) {
      final date = dateMap[key]!;
      final list = map[key]!
        ..sort((a, b) => b.primaryDate.compareTo(a.primaryDate));

      return JourneyGroupModel(date: date, journeys: list);
    }).toList();
  }
}
