import 'package:flutter/material.dart';
import '../../../../core/utils/badge_icon_helper.dart';

class BadgeModel {
  final String id;
  final String name;
  final String description;
  final String? iconUrl;
  final IconData icon;
  final bool isUnlocked;
  final String? achievedDate;
  final int currentProgress;
  final int totalProgress;
  final String progressUnit;

  BadgeModel({
    required this.id,
    required this.name,
    this.description = '',
    this.iconUrl,
    IconData? icon,
    this.isUnlocked = true,
    this.achievedDate,
    this.currentProgress = 0,
    this.totalProgress = 0,
    this.progressUnit = '',
  }) : icon = icon ?? BadgeIconHelper.resolve(name);

  String get title => name;
}
