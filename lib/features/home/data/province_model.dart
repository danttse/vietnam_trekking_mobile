import 'datasources/province_path_mapper.dart';

class Province {
  final String id;
  final String name;
  final String region;
  final bool isVisited;
  final bool isCheckedIn;
  final double? area; // Diện tích (km²)
  final int? population; // Dân số (người)

  static const String mienBac = 'Miền Bắc';
  static const String mienTrung = 'Miền Trung';
  static const String mienNam = 'Miền Nam';

  const Province({
    required this.id,
    required this.name,
    required this.region,
    this.isVisited = false,
    this.isCheckedIn = false,
    this.area,
    this.population,
  });

  /// Alias tương thích ngược với code cũ
  bool get visited => isVisited;
  double? get acreage => area;

  /// Alias tiếng Việt
  double? get dienTich => area;
  int? get danSo => population;

  /// Lấy chỉ số SVG path để vẽ bản đồ
  int? get pathIndex => ProvincePathMapper.getPathIndex(id);

  Province copyWith({
    String? id,
    String? name,
    String? region,
    bool? isVisited,
    bool? isCheckedIn,
    bool? visited,
    double? area,
    int? population,
  }) {
    return Province(
      id: id ?? this.id,
      name: name ?? this.name,
      region: region ?? this.region,
      isVisited: isVisited ?? visited ?? this.isVisited,
      isCheckedIn: isCheckedIn ?? this.isCheckedIn,
      area: area ?? this.area,
      population: population ?? this.population,
    );
  }

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
      id: json['id'] as String,
      name: json['name'] as String,
      region: json['region'] as String,
      isVisited: (json['is_visited'] ?? json['isVisited'] ?? json['visited'] ?? false) as bool,
      isCheckedIn: (json['is_checked_in'] ?? json['isCheckedIn'] ?? false) as bool,
      area: (json['area'] ?? json['dien_tich'] ?? json['dienTich'])?.toDouble(),
      population: (json['population'] ?? json['dan_so'] ?? json['danSo']) as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'region': region,
      'is_visited': isVisited,
      'is_checked_in': isCheckedIn,
      if (area != null) 'area': area,
      if (population != null) 'population': population,
    };
  }
}