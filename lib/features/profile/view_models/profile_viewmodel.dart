import 'package:flutter/material.dart';
import '../data/models/profile_model.dart';

class ProfileViewModel extends ChangeNotifier {
  UserProfileModel _profile = const UserProfileModel(
    id: 'user_1',
    name: 'Minh Trần',
    isPro: true,
    memberSince: 'Tháng 3, 2024',
    bio: 'Yêu thích cung đường núi cao & mây ngàn Việt Nam',
    email: 'minhtran@email.com',
    visitedProvinces: 12,
    totalDistanceKm: 384,
    completedTrips: 18,
    totalDays: 42,
    achievements: [
      AchievementModel(
        id: 'ach_1',
        title: 'Nhà thám hiểm',
        description: 'Đã trekking qua trên 5 tỉnh thành khác nhau.',
        icon: Icons.explore_outlined,
        isUnlocked: true,
      ),
      AchievementModel(
        id: 'ach_2',
        title: 'Chinh phục đỉnh cao',
        description: 'Đã leo thành công đỉnh Fansipan cao 3,143m.',
        icon: Icons.landscape_outlined,
        isUnlocked: true,
      ),
      AchievementModel(
        id: 'ach_3',
        title: 'Dấu chân miền Nam',
        description: 'Đã chinh phục hết các tỉnh thành Nam Bộ.',
        icon: Icons.directions_walk,
        isUnlocked: false,
      ),
    ],
  );

  bool _isLoading = false;

  UserProfileModel get profile => _profile;
  bool get isLoading => _isLoading;

  void updateProfile(UserProfileModel newProfile) {
    _profile = newProfile;
    notifyListeners();
  }

  void refreshData() {
    _isLoading = true;
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 300), () {
      _isLoading = false;
      notifyListeners();
    });
  }
}
