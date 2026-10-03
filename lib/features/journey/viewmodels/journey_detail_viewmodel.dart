import 'package:flutter/material.dart';
import '../data/datasources/milestone_sample_data.dart';
import '../data/models/journey_model.dart';
import '../data/models/milestone_model.dart';

class JourneyDetailViewModel extends ChangeNotifier {
  final JourneyModel? _journey;

  bool _isDownloading = false;
  bool _isDownloaded = false;
  late List<MilestoneModel> _milestones;
  late JourneyStatus _status;

  JourneyDetailViewModel({JourneyModel? route}) : _journey = route {
    _status = _journey?.status ?? JourneyStatus.planned;
    _milestones = MilestoneSampleData.getMilestonesForRoute(
      _journey?.route.routeId ?? '',
    );
  }

  JourneyModel? get journey => _journey;
  JourneyStatus get journeyStatus => _status;
  bool get isDownloading => _isDownloading;
  bool get isDownloaded => _isDownloaded;
  List<MilestoneModel> get milestones => _milestones;

  void toggleJourneyStatus() {
    switch (_status) {
      case JourneyStatus.planned:
        _status = JourneyStatus.active;
        notifyListeners();
        break;
      case JourneyStatus.active:
        _status = JourneyStatus.paused;
        notifyListeners();
        break;
      case JourneyStatus.paused:
        _status = JourneyStatus.active;
        notifyListeners();
        break;
      default:
        break;
    }
  }

  String get journeyName => _journey?.name ?? 'Hành trình trekking';
  String get journeyLocation => _journey?.route.province ?? 'Việt Nam';

  String get journeyImageUrl =>
      _journey?.route.imageUrl ??
      'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=800';

  String get mapImageUrl =>
      'https://images.unsplash.com/photo-1524661135-423995f22d0b?w=800';

  String get distanceKm {
    final km = _journey?.statistics?.distanceKm ?? _journey?.route.distanceKm ?? 0;
    return km.truncateToDouble() == km
        ? km.toStringAsFixed(0)
        : km.toStringAsFixed(1);
  }

  String get maxElevationText =>
      '${_journey?.route.maxElevation.toInt() ?? 3143} m';

  String get estimatedDurationText {
    if (_journey == null) return '2 - 3 ngày';
    final days = _journey.route.estimatedDuration.inDays;
    return days > 1 ? '$days - ${days + 1} ngày' : '$days ngày';
  }

  int get checkedInCount => _milestones.where((m) => m.isCheckedIn).length;
  int get totalMilestoneCount => _milestones.length;

  Future<void> downloadOfflineMap() async {
    _isDownloading = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    _isDownloading = false;
    _isDownloaded = true;
    notifyListeners();
  }

  void checkIn(String milestoneId) {
    final index = _milestones.indexWhere((m) => m.id == milestoneId);
    if (index == -1) return;
    _milestones = List.from(_milestones);
    _milestones[index] = _milestones[index].copyWith(
      isCheckedIn: true,
      checkedInAt: DateTime.now(),
    );
    notifyListeners();
  }
}
