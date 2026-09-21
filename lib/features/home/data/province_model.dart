class Province {
  final int id;
  final String name;
  final int pathIndex;
  final bool visited;
  final String region;

  static const String mienBac = 'Miền Bắc';
  static const String mienTrung = 'Miền Trung';
  static const String mienNam = 'Miền Nam';

  const Province({
    required this.id,
    required this.name,
    required this.pathIndex,
    required this.visited,
    required this.region,
  });

  Province copyWith({
    int? id,
    String? name,
    int? pathIndex,
    bool? visited,
    String? region,
  }) {
    return Province(
      id: id ?? this.id,
      name: name ?? this.name,
      pathIndex: pathIndex ?? this.pathIndex,
      visited: visited ?? this.visited,
      region: region ?? this.region,
    );
  }
}