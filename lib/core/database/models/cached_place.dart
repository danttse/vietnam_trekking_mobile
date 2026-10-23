class CachedPlace {
  final String trekkingPlaceId;
  final String? provinceId;
  final String name;
  final String? slug;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? description;
  final String? difficulty;
  final int? averageDurationMinutes;
  final String? imageUrl;
  final double? ratingAverage;
  final int? ratingCount;
  final String? status;
  final DateTime? cachedAt;
  final DateTime? updatedAt;

  const CachedPlace({
    required this.trekkingPlaceId,
    this.provinceId,
    required this.name,
    this.slug,
    this.address,
    this.latitude,
    this.longitude,
    this.description,
    this.difficulty,
    this.averageDurationMinutes,
    this.imageUrl,
    this.ratingAverage,
    this.ratingCount,
    this.status,
    this.cachedAt,
    this.updatedAt,
  });

  factory CachedPlace.fromMap(Map<String, dynamic> map) {
    return CachedPlace(
      trekkingPlaceId: map['trekkingPlaceId'] as String,
      provinceId: map['provinceId'] as String?,
      name: map['name'] as String,
      slug: map['slug'] as String?,
      address: map['address'] as String?,
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
      description: map['description'] as String?,
      difficulty: map['difficulty'] as String?,
      averageDurationMinutes: map['averageDurationMinutes'] as int?,
      imageUrl: map['imageUrl'] as String?,
      ratingAverage: map['ratingAverage'] as double?,
      ratingCount: map['ratingCount'] as int?,
      status: map['status'] as String?,
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
      'trekkingPlaceId': trekkingPlaceId,
      'provinceId': provinceId,
      'name': name,
      'slug': slug,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'difficulty': difficulty,
      'averageDurationMinutes': averageDurationMinutes,
      'imageUrl': imageUrl,
      'ratingAverage': ratingAverage,
      'ratingCount': ratingCount,
      'status': status,
      'cachedAt': cachedAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  CachedPlace copyWith({
    String? trekkingPlaceId,
    String? provinceId,
    String? name,
    String? slug,
    String? address,
    double? latitude,
    double? longitude,
    String? description,
    String? difficulty,
    int? averageDurationMinutes,
    String? imageUrl,
    double? ratingAverage,
    int? ratingCount,
    String? status,
    DateTime? cachedAt,
    DateTime? updatedAt,
  }) {
    return CachedPlace(
      trekkingPlaceId: trekkingPlaceId ?? this.trekkingPlaceId,
      provinceId: provinceId ?? this.provinceId,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      averageDurationMinutes:
          averageDurationMinutes ?? this.averageDurationMinutes,
      imageUrl: imageUrl ?? this.imageUrl,
      ratingAverage: ratingAverage ?? this.ratingAverage,
      ratingCount: ratingCount ?? this.ratingCount,
      status: status ?? this.status,
      cachedAt: cachedAt ?? this.cachedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
