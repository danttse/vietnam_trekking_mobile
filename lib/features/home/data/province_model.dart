import 'datasources/province_path_mapper.dart';

class Province {
  final String id;
  final String name;
  final String region;
  final bool isVisited;
  final bool isCheckedIn;

  static const String mienBac = 'Miền Bắc';
  static const String mienTrung = 'Miền Trung';
  static const String mienNam = 'Miền Nam';

  const Province({
    required this.id,
    required this.name,
    required this.region,
    this.isVisited = false,
    this.isCheckedIn = false,
  });

  /// Alias tương thích ngược với code cũ
  bool get visited => isVisited;

  /// Lấy chỉ số SVG path để vẽ bản đồ
  int? get pathIndex => ProvincePathMapper.getPathIndex(id);

  Province copyWith({
    String? id,
    String? name,
    String? region,
    bool? isVisited,
    bool? isCheckedIn,
    bool? visited,
  }) {
    return Province(
      id: id ?? this.id,
      name: name ?? this.name,
      region: region ?? this.region,
      isVisited: isVisited ?? visited ?? this.isVisited,
      isCheckedIn: isCheckedIn ?? this.isCheckedIn,
    );
  }

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
      id: json['id'] as String,
      name: json['name'] as String,
      region: json['region'] as String,
      isVisited: (json['is_visited'] ?? json['isVisited'] ?? json['visited'] ?? false) as bool,
      isCheckedIn: (json['is_checked_in'] ?? json['isCheckedIn'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'region': region,
      'is_visited': isVisited,
      'is_checked_in': isCheckedIn,
    };
  }
}