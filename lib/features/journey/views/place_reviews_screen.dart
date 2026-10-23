import 'package:flutter/material.dart';

import '../../../core/network/api_error_handler.dart';
import '../data/models/review_model.dart';
import '../data/repositories/journey_repository.dart';
import 'widgets/rating_stars.dart';

class PlaceReviewsScreen extends StatefulWidget {
  final String placeId;
  final String placeName;
  final JourneyRepository? repository;
  const PlaceReviewsScreen({
    super.key,
    required this.placeId,
    required this.placeName,
    this.repository,
  });
  @override
  State<PlaceReviewsScreen> createState() => _PlaceReviewsScreenState();
}

class _PlaceReviewsScreenState extends State<PlaceReviewsScreen> {
  late final _repo = widget.repository ?? JourneyRepository();
  final _reviews = <ReviewModel>[];
  bool _loading = false;
  bool _hasMore = true;
  int _page = 1;
  String? _error;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool refresh = false}) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final page = refresh ? 1 : _page;
    try {
      final items = await _repo.getReviews(widget.placeId, page: page);
      if (!mounted) return;
      setState(() {
        if (refresh) _reviews.clear();
        _reviews.addAll(items);
        _hasMore = items.length == 20;
        _page = page + 1;
      });
    } catch (e) {
      if (mounted) setState(() => _error = ApiErrorHandler.handle(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Đánh giá địa điểm')),
      body: RefreshIndicator(
        onRefresh: () => _load(refresh: true),
        child: ListView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Text(
              widget.placeName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            for (final review in _reviews)
              Card(
                color: cs.surfaceContainerHighest,
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              review.isAnonymous
                                  ? 'Trekker ẩn danh'
                                  : review.displayName ?? 'Trekker',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          RatingStars(rating: review.rating, starSize: 16),
                        ],
                      ),
                      if (review.createdAt != null)
                        Text(
                          '${review.createdAt!.day}/${review.createdAt!.month}/${review.createdAt!.year}',
                          style: TextStyle(
                            fontSize: 11,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      if (review.content?.isNotEmpty == true) ...[
                        const SizedBox(height: 10),
                        Text(review.content!),
                      ],
                      if (review.imageUrls.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 80,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: review.imageUrls.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 8),
                            itemBuilder: (_, i) => ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                review.imageUrls[i],
                                width: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => const SizedBox(
                                  width: 100,
                                  child: Icon(Icons.broken_image_outlined),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            if (_loading) const Center(child: CircularProgressIndicator()),
            if (_error != null) ...[
              Text(_error!, textAlign: TextAlign.center),
              TextButton(onPressed: _load, child: const Text('Thử lại')),
            ],
            if (!_loading && _error == null && _reviews.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Chưa có đánh giá. Hãy chia sẻ trải nghiệm của bạn!',
                  textAlign: TextAlign.center,
                ),
              ),
            if (!_loading && _error == null && _hasMore && _reviews.isNotEmpty)
              TextButton(
                onPressed: _load,
                child: const Text('Xem thêm đánh giá'),
              ),
          ],
        ),
      ),
    );
  }
}
