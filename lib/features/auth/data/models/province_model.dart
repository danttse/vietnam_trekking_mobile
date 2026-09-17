class Province {
  final int id;
  final String name;
  final int pathIndex;
  final bool visited;
  final String? lastVisit;

  const Province({
    required this.id,
    required this.name,
    required this.pathIndex,
    required this.visited,
    this.lastVisit,
  });
}