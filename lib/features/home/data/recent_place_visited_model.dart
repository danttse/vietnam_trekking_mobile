class RecentPlace {
  final String name;
  final String lastVisited;
  final String? placeId;
  final String imageUrl;

  const RecentPlace({
    required this.name,
    required this.lastVisited,
    this.placeId,
    this.imageUrl = '',
  });
}
