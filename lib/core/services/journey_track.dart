import 'dart:math' as math;

import '../database/models/track_point.dart';

/// GPS track uses the standard polyline precision (1e5), shared with the API.
class JourneyTrack {
  static double distance(TrackPoint a, TrackPoint b) {
    const radians = math.pi / 180;
    final lat = (b.latitude - a.latitude) * radians;
    final lng = (b.longitude - a.longitude) * radians;
    final h =
        math.pow(math.sin(lat / 2), 2) +
        math.cos(a.latitude * radians) *
            math.cos(b.latitude * radians) *
            math.pow(math.sin(lng / 2), 2);
    return 6371000 * 2 * math.asin(math.sqrt(h.clamp(0, 1)));
  }

  static bool accepts(TrackPoint point, TrackPoint? previous, DateTime now) {
    if (!point.latitude.isFinite ||
        !point.longitude.isFinite ||
        point.latitude.abs() > 90 ||
        point.longitude.abs() > 180 ||
        point.accuracy == null ||
        !point.accuracy!.isFinite ||
        point.accuracy! < 0 ||
        point.accuracy! > 50 ||
        now.difference(point.recordedAt).abs() > const Duration(seconds: 30)) {
      return false;
    }
    if (previous == null) return true;
    final seconds =
        point.recordedAt.difference(previous.recordedAt).inMilliseconds / 1000;
    if (seconds <= 0) return false;
    final meters = distance(previous, point);
    return meters >= 5 && meters / seconds <= 10;
  }

  static String encode(List<TrackPoint> points) {
    final result = StringBuffer();
    var latitude = 0, longitude = 0;
    void write(int delta) {
      var value = delta < 0 ? ~(delta << 1) : delta << 1;
      while (value >= 32) {
        result.writeCharCode((value & 31 | 32) + 63);
        value >>= 5;
      }
      result.writeCharCode(value + 63);
    }

    for (final p in points) {
      final lat = (p.latitude * 1e5).round();
      final lng = (p.longitude * 1e5).round();
      write(lat - latitude);
      write(lng - longitude);
      latitude = lat;
      longitude = lng;
    }
    return result.toString();
  }

  static List<TrackPoint> decode(String encoded, String journeyId) {
    var index = 0, latitude = 0, longitude = 0;
    final points = <TrackPoint>[];
    int read() {
      var value = 0, shift = 0;
      while (true) {
        if (index >= encoded.length || shift > 30) {
          throw const FormatException('Invalid track');
        }
        final byte = encoded.codeUnitAt(index++) - 63;
        if (byte < 0 || byte > 63) throw const FormatException('Invalid track');
        value |= (byte & 31) << shift;
        if (byte < 32) break;
        shift += 5;
      }
      return value & 1 != 0 ? ~(value >> 1) : value >> 1;
    }

    try {
      while (index < encoded.length) {
        latitude += read();
        longitude += read();
        if (latitude.abs() > 9000000 || longitude.abs() > 18000000) return [];
        points.add(
          TrackPoint(
            localJourneyId: journeyId,
            latitude: latitude / 1e5,
            longitude: longitude / 1e5,
            recordedAt: DateTime.fromMillisecondsSinceEpoch(0),
          ),
        );
      }
      return points;
    } on FormatException {
      return [];
    }
  }

  static Map<String, dynamic> completionBody(List<TrackPoint> points) {
    if (points.length < 2) return {};
    var meters = 0.0, elevation = 0.0, seconds = 0;
    for (var i = 1; i < points.length; i++) {
      final previous = points[i - 1], current = points[i];
      final gap = current.recordedAt.difference(previous.recordedAt).inSeconds;
      // Long GPS interruptions must not add invented distance or moving time.
      if (gap <= 0 || gap > 120) continue;
      meters += distance(previous, current);
      seconds += gap;
      if (current.altitude != null && previous.altitude != null) {
        final gain = current.altitude! - previous.altitude!;
        if (gain > 3) elevation += gain;
      }
    }
    final altitudes = points
        .map((p) => p.altitude)
        .whereType<double>()
        .where((v) => v.isFinite);
    return {
      'track': {'encodedPolyline': encode(points)},
      'statistics': {
        'distanceMeters': meters,
        'durationSeconds': seconds,
        'elevationGain': elevation,
        if (altitudes.isNotEmpty) 'maxAltitude': altitudes.reduce(math.max),
        'averageSpeed': seconds == 0 ? 0.0 : meters / seconds,
      },
    };
  }
}
