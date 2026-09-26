import 'package:flutter/material.dart';

class AchievementModel {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final bool isUnlocked;

  const AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.isUnlocked = true,
  });
}

class UserProfileModel {
  final String id;
  final String name;
  final bool isPro;
  final String memberSince;
  final String bio;
  final String? email;
  final String? avatarUrl;
  final int visitedProvinces;
  final int totalProvinces;
  final int totalDistanceKm;
  final int completedTrips;
  final int totalDays;
  final List<AchievementModel> achievements;

  const UserProfileModel({
    required this.id,
    required this.name,
    this.isPro = true,
    required this.memberSince,
    required this.bio,
    this.email,
    this.avatarUrl,
    required this.visitedProvinces,
    this.totalProvinces = 34,
    required this.totalDistanceKm,
    required this.completedTrips,
    required this.totalDays,
    required this.achievements,
  });

  double get provinceProgress =>
      totalProvinces > 0 ? visitedProvinces / totalProvinces : 0.0;
}
