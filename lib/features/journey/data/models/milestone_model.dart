class MilestoneModel {
  final String id;
  final String name;
  final int sequence;
  final double altitude;
  final bool isCheckedIn;
  final DateTime? checkedInAt;

  const MilestoneModel({
    this.id = '',
    this.name = '',
    this.sequence = 0,
    this.altitude = 0,
    this.isCheckedIn = false,
    this.checkedInAt,
  });

  MilestoneModel copyWith({
    String? id,
    String? name,
    int? sequence,
    double? altitude,
    bool? isCheckedIn,
    DateTime? checkedInAt,
  }) {
    return MilestoneModel(
      id: id ?? this.id,
      name: name ?? this.name,
      sequence: sequence ?? this.sequence,
      altitude: altitude ?? this.altitude,
      isCheckedIn: isCheckedIn ?? this.isCheckedIn,
      checkedInAt: checkedInAt ?? this.checkedInAt,
    );
  }
}
