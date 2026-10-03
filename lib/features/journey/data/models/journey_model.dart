import 'package:flutter/material.dart';
import '../../../route/data/models/route_model.dart';

enum JourneyStatus {
  planned,
  active,
  paused,
  completed,
  cancelled,
}

extension JourneyStatusExt on JourneyStatus {
  String get label {
    switch (this) {
      case JourneyStatus.planned:
        return 'DỰ KIẾN';
      case JourneyStatus.active:
        return 'ĐANG ĐI';
      case JourneyStatus.paused:
        return 'TẠM DỪNG';
      case JourneyStatus.completed:
        return 'HOÀN THÀNH';
      case JourneyStatus.cancelled:
        return 'ĐÃ HỦY';
    }
  }

  Color get color {
    switch (this) {
      case JourneyStatus.planned:
        return const Color(0xFFFF6E40);
      case JourneyStatus.active:
        return const Color(0xFFb9dbc0);
      case JourneyStatus.paused:
        return const Color(0xFFFFA502);
      case JourneyStatus.completed:
        return const Color(0xFF207335);
      case JourneyStatus.cancelled:
        return const Color.fromARGB(255, 178, 2, 2);
    }
  }

  Color get backgroundColor => color.withValues(alpha: 0.15);
}

class JourneyStatistics {
  final double distanceMeters;
  final Duration duration;
  final double elevationGain;
  final double maxAltitude;
  final int checkinCount;
  final int markerCount;

  const JourneyStatistics({
    required this.distanceMeters,
    required this.duration,
    required this.elevationGain,
    required this.maxAltitude,
    required this.checkinCount,
    required this.markerCount,
  });

  double get distanceKm => distanceMeters / 1000.0;
}

class JourneyModel {
  final String journeyId;
  final String name;
  final RouteModel route;
  final DateTime? plannedStartAt;
  final DateTime? plannedEndAt;
  final int participantCount;
  final String? note;
  final JourneyStatus status;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final JourneyStatistics? statistics;

  const JourneyModel({
    required this.journeyId,
    required this.name,
    required this.route,
    this.plannedStartAt,
    this.plannedEndAt,
    this.participantCount = 1,
    this.note,
    required this.status,
    this.startedAt,
    this.completedAt,
    this.statistics,
  });

  DateTime get primaryDate => startedAt ?? plannedStartAt ?? DateTime.now();

  String get dateRangeText {
    final start = startedAt ?? plannedStartAt;
    final end = completedAt ?? plannedEndAt;

    if (start == null && end == null) return '';
    if (start != null && end == null) {
      return '${_formatDayMonth(start)}/${start.year}';
    }
    if (start != null && end != null) {
      if (start.year == end.year) {
        return '${_formatDayMonth(start)} - ${_formatDayMonth(end)}/${end.year}';
      }
      return '${_formatDayMonth(start)}/${start.year} - ${_formatDayMonth(end)}/${end.year}';
    }
    return '';
  }

  String get summarySubtitle {
    final parts = <String>[];
    if (route.province != null && route.province!.isNotEmpty) {
      parts.add(route.province!);
    }
    if (participantCount > 0) {
      parts.add('$participantCount thành viên');
    }

    final double km = statistics != null
        ? statistics!.distanceKm
        : route.distanceKm;

    final String kmFormatted = km.truncateToDouble() == km
        ? km.toStringAsFixed(0)
        : km.toStringAsFixed(1);
    parts.add('$kmFormatted km');

    return parts.join(' • ');
  }

  static String _formatDayMonth(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
}
