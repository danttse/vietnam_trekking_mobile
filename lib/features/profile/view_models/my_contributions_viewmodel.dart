import 'package:flutter/foundation.dart';

import '../../journey/data/models/contribution_model.dart';
import '../../journey/data/repositories/journey_repository.dart';

class MyContributionsViewModel extends ChangeNotifier {
  final JourneyRepository _repository;

  int _selectedTabIndex = 0;
  bool _isLoading = false;
  String? _error;
  bool _disposed = false;

  List<ContributionModel> _allContributions = [];

  MyContributionsViewModel({JourneyRepository? repository})
      : _repository = repository ?? JourneyRepository();

  int get selectedTabIndex => _selectedTabIndex;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<ContributionModel> get submittedList => _allContributions
      .where((c) =>
          c.status == 'PENDING_REVIEW' ||
          c.status == 'DRAFT' ||
          c.status == 'NEEDS_REVISION')
      .toList();

  List<ContributionModel> get approvedList =>
      _allContributions.where((c) => c.status == 'APPROVED').toList();

  List<ContributionModel> get rejectedList =>
      _allContributions.where((c) => c.status == 'REJECTED').toList();

  List<ContributionModel> get currentList {
    switch (_selectedTabIndex) {
      case 0:
        return submittedList;
      case 1:
        return approvedList;
      case 2:
        return rejectedList;
      default:
        return submittedList;
    }
  }

  int get submittedCount => submittedList.length;
  int get approvedCount => approvedList.length;
  int get rejectedCount => rejectedList.length;

  void setTab(int index) {
    if (_selectedTabIndex == index) return;
    _selectedTabIndex = index;
    notifyListeners();
  }

  Future<void> loadContributions() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.getMyContributions();
      if (_disposed) return;

      // Merge and sort by createdAt descending
      final combined = [...response.routes, ...response.places];
      combined.sort((a, b) {
        final dateA = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final dateB = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return dateB.compareTo(dateA);
      });

      _allContributions = combined;
    } catch (e) {
      if (_disposed) return;
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (!_disposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
