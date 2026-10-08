import 'package:flutter/material.dart';

class BadgeIconHelper {
  static IconData resolve(String name, [double altitude = 0]) {
    final text = name.toLowerCase();

    if (text.contains('thám hiểm')) return Icons.military_tech_outlined;
    if (text.contains('định hướng')) return Icons.explore_outlined;
    if (text.contains('dấu chân')) return Icons.directions_walk;
    if (text.contains('đỉnh') || text.contains('peak') || altitude >= 2000) {
      return Icons.terrain;
    }
    if (text.contains('thác') ||
        text.contains('waterfall') ||
        text.contains('suối')) {
      return Icons.water_drop_outlined;
    }
    if (text.contains('đèo') ||
        text.contains('đồi') ||
        text.contains('pass') ||
        text.contains('hill')) {
      return Icons.landscape_outlined;
    }
    if (text.contains('trạm') ||
        text.contains('trại') ||
        text.contains('camp') ||
        text.contains('station')) {
      return Icons.cabin_outlined;
    }
    if (text.contains('mốc') ||
        text.contains('cột') ||
        text.contains('border')) {
      return Icons.flag_outlined;
    }

    return Icons.military_tech_outlined;
  }
}
