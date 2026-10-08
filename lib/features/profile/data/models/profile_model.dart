import 'package:flutter/material.dart';

class AchievementModel {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final bool isUnlocked;
  final String? achievedDate;
  final int currentProgress;
  final int totalProgress;
  final String progressUnit;
  final Color? badgeColor;

  const AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.isUnlocked = true,
    this.achievedDate,
    this.currentProgress = 0,
    this.totalProgress = 0,
    this.progressUnit = '',
    this.badgeColor,
  });

  AchievementModel copyWith({
    String? id,
    String? title,
    String? description,
    IconData? icon,
    bool? isUnlocked,
    String? achievedDate,
    int? currentProgress,
    int? totalProgress,
    String? progressUnit,
    Color? badgeColor,
  }) {
    return AchievementModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      achievedDate: achievedDate ?? this.achievedDate,
      currentProgress: currentProgress ?? this.currentProgress,
      totalProgress: totalProgress ?? this.totalProgress,
      progressUnit: progressUnit ?? this.progressUnit,
      badgeColor: badgeColor ?? this.badgeColor,
    );
  }
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

  UserProfileModel copyWith({
    String? id,
    String? name,
    bool? isPro,
    String? memberSince,
    String? bio,
    String? email,
    String? avatarUrl,
    int? visitedProvinces,
    int? totalProvinces,
    int? totalDistanceKm,
    int? completedTrips,
    int? totalDays,
    List<AchievementModel>? achievements,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      isPro: isPro ?? this.isPro,
      memberSince: memberSince ?? this.memberSince,
      bio: bio ?? this.bio,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      visitedProvinces: visitedProvinces ?? this.visitedProvinces,
      totalProvinces: totalProvinces ?? this.totalProvinces,
      totalDistanceKm: totalDistanceKm ?? this.totalDistanceKm,
      completedTrips: completedTrips ?? this.completedTrips,
      totalDays: totalDays ?? this.totalDays,
      achievements: achievements ?? this.achievements,
    );
  }
}
