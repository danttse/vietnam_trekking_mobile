class ExplorePlaceModel {
  final String id;
  final String name;
  final String province;
  final String elevation;
  final String difficulty;
  final double rating;
  final int reviewCount;
  final String distance;//trong diagram chua thay
  final String duration;
  final String imageUrl;
  final String? tag;

  const ExplorePlaceModel({
    required this.id,
    required this.name,
    required this.province,
    required this.elevation,
    required this.difficulty,
    required this.rating,
    required this.reviewCount,
    required this.distance,
    required this.duration,
    required this.imageUrl,
    this.tag,
  });
}
