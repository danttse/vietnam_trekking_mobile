import '../../../route/data/datasources/route_sample_data.dart';
import '../../../route/data/models/route_model.dart';
import '../models/journey_group_model.dart';
import '../models/journey_model.dart';

class JourneySampleData {
  static List<JourneyModel>? _sampleJourneys;

  static List<JourneyModel> getSampleJourneys() {
    _sampleJourneys ??= _initialJourneys();
    return _sampleJourneys!;
  }

  static void addJourney(JourneyModel journey) {
    _sampleJourneys ??= _initialJourneys();
    _sampleJourneys!.insert(0, journey);
  }

  static void updateJourney(JourneyModel journey) {
    _sampleJourneys ??= _initialJourneys();
    final index = _sampleJourneys!.indexWhere((j) => j.journeyId == journey.journeyId);
    if (index != -1) {
      _sampleJourneys![index] = journey;
    } else {
      _sampleJourneys!.insert(0, journey);
    }
  }

  static JourneyModel getOrCreateJourneyForRoute(RouteModel? route) {
    final journeys = getSampleJourneys();
    if (route != null) {
      for (final j in journeys) {
        if (j.route.routeId == route.routeId || j.route.name == route.name) {
          return j;
        }
      }
    }

    final newJourney = JourneyModel(
      journeyId: 'jn_${DateTime.now().millisecondsSinceEpoch}',
      name: route?.name ?? 'Hành trình trekking',
      route: route ?? RouteSampleData.getSampleRoutes().first,
      startedAt: DateTime.now(),
      status: JourneyStatus.active,
    );
    addJourney(newJourney);
    return newJourney;
  }

  static List<JourneyModel> _initialJourneys() {
    final routes = RouteSampleData.getSampleRoutes();

    return [
      JourneyModel(
        journeyId: 'jn_001',
        name: 'Khám phá Hà Giang Loop',
        route: routes[1], // route_hagiang_01
        startedAt: DateTime(2025, 12, 12),
        completedAt: DateTime(2025, 12, 15),
        participantCount: 3,
        status: JourneyStatus.completed,
        statistics: const JourneyStatistics(
          distanceMeters: 120000,
          duration: Duration(hours: 72),
          elevationGain: 1500,
          maxAltitude: 2000,
          checkinCount: 12,
          markerCount: 25,
        ),
      ),
      JourneyModel(
        journeyId: 'jn_002',
        name: 'Chinh phục nóc nhà Fansipan',
        route: routes[0], // route_fansipan_01
        startedAt: DateTime(2025, 10, 20),
        completedAt: DateTime(2025, 10, 22),
        participantCount: 5,
        status: JourneyStatus.completed,
        statistics: const JourneyStatistics(
          distanceMeters: 28000,
          duration: Duration(hours: 36),
          elevationGain: 2100,
          maxAltitude: 3143,
          checkinCount: 8,
          markerCount: 14,
        ),
      ),
      JourneyModel(
        journeyId: 'jn_003',
        name: 'Săn mây Tà Xùa',
        route: routes[2], // route_taxua_01
        startedAt: DateTime(2025, 10, 5),
        completedAt: DateTime(2025, 10, 7),
        participantCount: 2,
        status: JourneyStatus.completed,
        statistics: const JourneyStatistics(
          distanceMeters: 16500,
          duration: Duration(hours: 28),
          elevationGain: 950,
          maxAltitude: 2865,
          checkinCount: 5,
          markerCount: 10,
        ),
      ),
      JourneyModel(
        journeyId: 'jn_004',
        name: 'Chinh phục Bạch Mộc Lương Tử',
        route: routes[3], // route_bachmoc_01
        plannedStartAt: DateTime(2026, 4, 15),
        plannedEndAt: DateTime(2026, 4, 17),
        participantCount: 3,
        status: JourneyStatus.planned,
      ),
      JourneyModel(
        journeyId: 'jn_005',
        name: 'Trekking Tà Năng Phan Dũng',
        route: routes[4], // route_tanang_01
        plannedStartAt: DateTime(2026, 5, 1),
        plannedEndAt: DateTime(2026, 5, 3),
        participantCount: 4,
        status: JourneyStatus.planned,
      ),
    ];
  }

  static List<JourneyModel> getCompletedJourneys() {
    return getSampleJourneys()
        .where((j) => j.status == JourneyStatus.completed)
        .toList();
  }

  static List<JourneyModel> getUpcomingJourneys() {
    return getSampleJourneys()
        .where((j) =>
            j.status == JourneyStatus.planned || j.status == JourneyStatus.active)
        .toList();
  }

  static List<JourneyGroupModel> groupJourneysByMonthYear(
      List<JourneyModel> journeys) {
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

      return JourneyGroupModel(
        date: date,
        journeys: list,
      );
    }).toList();
  }
}
