class CatalogPage {
  final List<Map<String, dynamic>> items;
  final int page;
  final int limit;
  final int total;
  final bool hasMore;
  const CatalogPage({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.hasMore,
  });
  factory CatalogPage.fromJson(Map<String, dynamic> json) => CatalogPage(
    items: (json['items'] as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList(),
    page: (json['page'] as num).toInt(),
    limit: (json['limit'] as num).toInt(),
    total: (json['total'] as num).toInt(),
    hasMore:
        json['hasMore'] as bool? ??
        (json['page'] as num) * (json['limit'] as num) < (json['total'] as num),
  );
  Map<String, dynamic> toJson() => {
    'items': items,
    'page': page,
    'limit': limit,
    'total': total,
    'hasMore': hasMore,
  };
}
