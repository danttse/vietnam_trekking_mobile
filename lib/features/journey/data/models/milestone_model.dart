class MilestoneModel {
  final String trekkingRouteId;
  final String? description;
  final String type;
  final double latitude;
  final double longitude;
  final double checkinRadiusMeters;
  final bool required;
  final String? imageUrl;
  final bool isCurrentLocation;
  final String id;
  final String name;
  final int sequence;
  final double altitude;
  final bool isCheckedIn;
  final DateTime? checkedInAt;

  const MilestoneModel({
    String id = '',
    String? milestoneId,
    this.trekkingRouteId = '',
    this.description,
    this.type = 'CHECKPOINT',
    this.latitude = 0,
    this.longitude = 0,
    this.checkinRadiusMeters = 50,
    this.required = true,
    this.imageUrl,
    this.isCurrentLocation = false,
    this.name = '',
    int sequence = 0,
    int? sequenceNumber,
    this.altitude = 0,
    this.isCheckedIn = false,
    this.checkedInAt,
  }) : id = milestoneId ?? id,
       sequence = sequenceNumber ?? sequence;

  String get milestoneId => id;
  int get sequenceNumber => sequence;
  String get altitudeLabel => '${altitude.toStringAsFixed(0)} m';

  factory MilestoneModel.fromJson(Map<String, dynamic> json) {
    final coords = (json['location'] as Map?)?['coordinates'] as List?;
    return MilestoneModel(
      id: (json['milestoneId'] ?? json['_id'] ?? json['id'] ?? '').toString(),
      trekkingRouteId: json['trekkingRouteId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      type: json['type'] as String? ?? 'CHECKPOINT',
      sequence: (json['sequence'] as num? ?? 0).toInt(),
      latitude: coords != null && coords.length >= 2
          ? (coords[1] as num).toDouble()
          : 0,
      longitude: coords != null && coords.length >= 2
          ? (coords[0] as num).toDouble()
          : 0,
      altitude: (json['altitude'] as num? ?? 0).toDouble(),
      checkinRadiusMeters: (json['checkinRadiusMeters'] as num? ?? 50)
          .toDouble(),
      required: json['required'] as bool? ?? true,
      imageUrl: json['imageUrl'] as String?,
      isCheckedIn: json['isCheckedIn'] == true,
      checkedInAt: DateTime.tryParse(json['checkedInAt']?.toString() ?? ''),
    );
  }

  MilestoneModel copyWith({
    String? id,
    String? name,
    int? sequence,
    double? altitude,
    bool? isCheckedIn,
    DateTime? checkedInAt,
  }) {
    return MilestoneModel(
      trekkingRouteId: trekkingRouteId,
      description: description,
      type: type,
      latitude: latitude,
      longitude: longitude,
      checkinRadiusMeters: checkinRadiusMeters,
      required: required,
      imageUrl: imageUrl,
      isCurrentLocation: isCurrentLocation,
      id: id ?? this.id,
      name: name ?? this.name,
      sequence: sequence ?? this.sequence,
      altitude: altitude ?? this.altitude,
      isCheckedIn: isCheckedIn ?? this.isCheckedIn,
      checkedInAt: checkedInAt ?? this.checkedInAt,
    );
  }
}
