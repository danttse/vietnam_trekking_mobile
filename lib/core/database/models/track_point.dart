class TrackPoint {
  final int? trackPointId; // Auto-increment, null khi chưa insert
  final String localJourneyId;
  final double latitude;
  final double longitude;
  final double? altitude;
  final double? accuracy;
  final double? speed;
  final double? heading;
  final DateTime recordedAt;

  const TrackPoint({
    this.trackPointId,
    required this.localJourneyId,
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.accuracy,
    this.speed,
    this.heading,
    required this.recordedAt,
  });

  factory TrackPoint.fromMap(Map<String, dynamic> map) {
    return TrackPoint(
      trackPointId: map['trackPointId'] as int?,
      localJourneyId: map['localJourneyId'] as String,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      altitude: (map['altitude'] as num?)?.toDouble(),
      accuracy: (map['accuracy'] as num?)?.toDouble(),
      speed: (map['speed'] as num?)?.toDouble(),
      heading: (map['heading'] as num?)?.toDouble(),
      recordedAt: DateTime.parse(map['recordedAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (trackPointId != null) 'trackPointId': trackPointId,
      'localJourneyId': localJourneyId,
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'accuracy': accuracy,
      'speed': speed,
      'heading': heading,
      'recordedAt': recordedAt.toIso8601String(),
    };
  }
}
