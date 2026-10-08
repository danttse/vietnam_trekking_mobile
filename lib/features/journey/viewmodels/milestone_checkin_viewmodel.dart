import 'package:flutter/material.dart';
import '../data/models/journey_model.dart';
import '../data/models/milestone_model.dart';

class MilestoneCheckinViewModel extends ChangeNotifier {
  MilestoneModel _milestone;
  final JourneyModel? journey;
  final String? _customMapImageUrl;

  bool _isLoading = false;
  late bool _isCheckedIn;
  final int _distanceMeters = 250;
  final int _allowedRadiusMeters = 500;

  MilestoneCheckinViewModel({
    required MilestoneModel milestone,
    this.journey,
    String? mapImageUrl,
  })  : _milestone = milestone,
        _customMapImageUrl = mapImageUrl {
    _isCheckedIn = milestone.isCheckedIn;
  }

  MilestoneModel get milestone => _milestone;
  bool get isLoading => _isLoading;
  bool get isCheckedIn => _isCheckedIn;
  int get distanceMeters => _distanceMeters;
  int get allowedRadiusMeters => _allowedRadiusMeters;
  bool get isWithinRange => _distanceMeters <= _allowedRadiusMeters;

  String get mapImageUrl {
    final customUrl = _customMapImageUrl;
    if (customUrl != null && customUrl.isNotEmpty) {
      return customUrl;
    }
    return journey?.route.imageUrl ??
        'https://images.unsplash.com/photo-1524661135-423995f22d0b?w=800';
  }

  String get destinationName {
    if (_milestone.name.isNotEmpty) {
      return _milestone.name;
    }
    return journey?.name ?? 'Điểm kiểm soát';
  }

  String get formattedAltitude {
    final alt = _milestone.altitude > 0
        ? _milestone.altitude
        : (journey?.route.maxElevation ?? 0);
    return alt.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }

  Future<bool> checkIn() async {
    if (_isLoading) return false;

    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    _milestone = _milestone.copyWith(
      isCheckedIn: true,
      checkedInAt: DateTime.now(),
    );
    _isCheckedIn = true;
    _isLoading = false;
    notifyListeners();

    return true;
  }
}
