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
        icon: Icons.military_tech_outlined,
        isUnlocked: true,
        achievedDate: '15/12/2025',
        currentProgress: 5,
        totalProgress: 5,
        progressUnit: 'Tỉnh thành',
        badgeColor: Color(0xFFE57A58),
      ),
      AchievementModel(
        id: 'ach_2',
        title: 'Chinh phục',
        description: 'Đã leo thành công đỉnh Fansipan cao 3,143m.',
        icon: Icons.terrain,
        isUnlocked: true,
        achievedDate: '20/11/2025',
        currentProgress: 1,
        totalProgress: 1,
        progressUnit: 'Đỉnh núi',
        badgeColor: Color(0xFF2ED573),
      ),
      AchievementModel(
        id: 'ach_3',
        title: 'Định hướng',
        description: 'Hoàn thành 3 cung đường định vị bằng la bàn.',
        icon: Icons.explore_outlined,
        isUnlocked: true,
        achievedDate: '05/10/2025',
        currentProgress: 3,
        totalProgress: 3,
        progressUnit: 'Cung đường',
        badgeColor: Color(0xFFE57A58),
      ),
      AchievementModel(
        id: 'ach_4',
        title: 'Dấu chân',
        description: 'Đã chinh phục hết các tỉnh thành Nam Bộ.',
        icon: Icons.directions_walk,
        isUnlocked: false,
        achievedDate: null,
        currentProgress: 2,
        totalProgress: 6,
        progressUnit: 'Tỉnh thành',
        badgeColor: Color(0xFF8E9BAE),
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
