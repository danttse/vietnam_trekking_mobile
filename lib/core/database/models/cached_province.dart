class CachedProvince {
  final String provinceId;
  final String? code;
  final String name;
  final String? region;
  final String? mapFeatureId;
  final DateTime? cachedAt;
  final DateTime? updatedAt;

  const CachedProvince({
    required this.provinceId,
    this.code,
    required this.name,
    this.region,
    this.mapFeatureId,
    this.cachedAt,
    this.updatedAt,
  });

  factory CachedProvince.fromMap(Map<String, dynamic> map) {
    return CachedProvince(
      provinceId: map['provinceId'] as String,
      code: map['code'] as String?,
      name: map['name'] as String,
      region: map['region'] as String?,
      mapFeatureId: map['mapFeatureId'] as String?,
      cachedAt: map['cachedAt'] != null
          ? DateTime.parse(map['cachedAt'] as String)
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'provinceId': provinceId,
      'code': code,
      'name': name,
      'region': region,
      'mapFeatureId': mapFeatureId,
      'cachedAt': cachedAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
