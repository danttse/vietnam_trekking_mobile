import 'package:flutter/material.dart';

import '../../../route/data/models/route_model.dart';

enum JourneyStatus { planned, active, paused, completed, cancelled }

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
  final String offlineSyncStatus;
  bool get pendingSync => offlineSyncStatus == 'PENDING';
  final String userId;
  final String? clientJourneyId;
  final String? provinceId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
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
  final String? encodedPolyline;

  const JourneyModel({
    this.offlineSyncStatus = 'SYNCED',
    this.userId = '',
    this.clientJourneyId,
    this.provinceId,
    this.createdAt,
    this.updatedAt,
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
    this.encodedPolyline,
  });

  String get trekkingPlaceId => route.trekkingPlaceId;
  String get trekkingRouteId => route.routeId;
  double get distanceMeters => statistics?.distanceMeters ?? 0;
  int get durationSeconds => statistics?.duration.inSeconds ?? 0;
  double get elevationGain => statistics?.elevationGain ?? 0;
  double get maxAltitude => statistics?.maxAltitude ?? 0;
  int get checkinCount => statistics?.checkinCount ?? 0;
  int get markerCount => statistics?.markerCount ?? 0;
  int get memberCount => participantCount;
  double get routeDistanceMeters => route.distanceMeters;
  double get displayDistanceKm => status == JourneyStatus.completed
      ? statistics?.distanceKm ?? 0
      : (statistics?.distanceMeters ?? 0) > 0
      ? statistics!.distanceKm
      : route.distanceKm;
  String? get placeImageUrl => route.imageUrl;
  String? get placeAddress => route.province;

  factory JourneyModel.fromJson(
    Map<String, dynamic> json, {
    RouteModel? route,
  }) {
    final stats = json['statistics'] as Map? ?? {};
    DateTime? date(String key) =>
        DateTime.tryParse(json[key]?.toString() ?? '');
    return JourneyModel(
      offlineSyncStatus: json['offlineSyncStatus']?.toString() ?? 'SYNCED',
      journeyId: (json['journeyId'] ?? json['_id'] ?? json['id']).toString(),
      userId: json['userId'] as String? ?? '',
      clientJourneyId: json['clientJourneyId'] as String?,
      provinceId: json['provinceId'] as String?,
      createdAt: date('createdAt'),
      updatedAt: date('updatedAt'),
      name: json['name'] as String? ?? '',
      encodedPolyline: (json['track'] as Map?)?['encodedPolyline'] as String?,
      route:
          route ??
          RouteModel.fromJson({
            'trekkingRouteId': json['trekkingRouteId'],
            'trekkingPlaceId': json['trekkingPlaceId'],
            'name': json['routeName'] ?? '',
          }),
      status: JourneyStatus.values.firstWhere(
        (s) => s.name.toUpperCase() == json['status'],
        orElse: () => JourneyStatus.planned,
      ),
      plannedStartAt: date('plannedStartAt'),
      plannedEndAt: date('plannedEndAt'),
      startedAt: date('startedAt'),
      completedAt: date('completedAt'),
      participantCount: (json['participantCount'] as num? ?? 1).toInt(),
      note: json['note'] as String?,
      statistics: JourneyStatistics(
        distanceMeters: (stats['distanceMeters'] as num? ?? 0).toDouble(),
        duration: Duration(
          seconds: (stats['durationSeconds'] as num? ?? 0).toInt(),
        ),
        elevationGain: (stats['elevationGain'] as num? ?? 0).toDouble(),
        maxAltitude: (stats['maxAltitude'] as num? ?? 0).toDouble(),
        checkinCount: (json['checkinCount'] as num? ?? 0).toInt(),
        markerCount: (json['markerCount'] as num? ?? 0).toInt(),
      ),
    );
  }

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

    final double km = displayDistanceKm;

    final String kmFormatted = km.truncateToDouble() == km
        ? km.toStringAsFixed(0)
        : km.toStringAsFixed(1);
    parts.add('$kmFormatted km');

    return parts.join(' • ');
  }

  static String _formatDayMonth(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
}
