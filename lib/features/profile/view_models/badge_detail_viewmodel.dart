import 'package:flutter/material.dart';

import '../data/models/badge_model.dart';

class BadgeDetailViewModel extends ChangeNotifier {
  late BadgeModel _currentBadge;
  late List<BadgeModel> _allBadges;

  BadgeDetailViewModel({BadgeModel? badge, List<BadgeModel>? allBadges}) {
    _allBadges = allBadges ?? (badge == null ? [] : [badge]);
    _currentBadge =
        badge ??
        (_allBadges.isEmpty
            ? BadgeModel(
                id: '',
                name: 'Chưa có huy hiệu',
                description: '',
                isUnlocked: false,
                currentProgress: 0,
                totalProgress: 0,
              )
            : _allBadges.first);
  }

  BadgeModel get currentBadge => _currentBadge;
  List<BadgeModel> get allBadges => _allBadges;

  List<BadgeModel> get recentOtherBadges {
    return _allBadges.where((b) => b.id != _currentBadge.id).take(3).toList();
  }

  void selectBadge(BadgeModel badge) {
    _currentBadge = badge;
    notifyListeners();
  }
}
