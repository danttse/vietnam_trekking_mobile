import 'package:flutter/material.dart';
import '../data/models/badge_model.dart';

class BadgeDetailViewModel extends ChangeNotifier {
  late BadgeModel _currentBadge;
  late List<BadgeModel> _allBadges;

  BadgeDetailViewModel({
    BadgeModel? badge,
    List<BadgeModel>? allBadges,
  }) {
    _allBadges = allBadges ?? _defaultBadges;
    _currentBadge = badge ?? _allBadges.first;
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

  static final List<BadgeModel> _defaultBadges = [
    BadgeModel(
      id: 'badge_01',
      name: 'Nhà thám hiểm',
      description: 'Đã trekking qua trên 5 tỉnh thành khác nhau.',
      icon: Icons.military_tech_outlined,
      isUnlocked: true,
      achievedDate: '15/12/2025',
      currentProgress: 5,
      totalProgress: 5,
      progressUnit: 'Tỉnh thành',
    ),
    BadgeModel(
      id: 'badge_02',
      name: 'Chinh phục',
      description: 'Đã leo thành công đỉnh Fansipan cao 3,143m.',
      isUnlocked: true,
      achievedDate: '20/11/2025',
      currentProgress: 1,
      totalProgress: 1,
      progressUnit: 'Đỉnh núi',
    ),
    BadgeModel(
      id: 'badge_03',
      name: 'Định hướng',
      description: 'Hoàn thành 3 cung đường định vị bằng la bàn.',
      isUnlocked: true,
      achievedDate: '05/10/2025',
      currentProgress: 3,
      totalProgress: 3,
      progressUnit: 'Cung đường',
    ),
    BadgeModel(
      id: 'badge_04',
      name: 'Dấu chân',
      description: 'Đã chinh phục hết các tỉnh thành Nam Bộ.',
      isUnlocked: false,
      achievedDate: null,
      currentProgress: 2,
      totalProgress: 6,
      progressUnit: 'Tỉnh thành',
    ),
  ];
}
