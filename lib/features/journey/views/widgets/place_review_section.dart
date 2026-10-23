import 'package:flutter/material.dart';

import '../../../../core/network/api_error_handler.dart';
import '../../data/models/review_model.dart';
import '../../data/repositories/journey_repository.dart';
import '../review_screen.dart';
import '../place_reviews_screen.dart';
import 'rating_stars.dart';

class PlaceReviewSection extends StatefulWidget {
  final String placeId;
  final String? placeName;
  final JourneyRepository? repository;
  const PlaceReviewSection({
    super.key,
    required this.placeId,
    this.placeName,
    this.repository,
  });
  @override
  State<PlaceReviewSection> createState() => _PlaceReviewSectionState();
}

class _PlaceReviewSectionState extends State<PlaceReviewSection> {
  late final JourneyRepository _repo;
  List<ReviewModel> _reviews = [];
  ReviewModel? _own;
  bool _canCreate = false, _canEdit = false, _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? JourneyRepository();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _canCreate = false;
      _canEdit = false;
    });
    try {
      final reviews = await _repo.getReviews(widget.placeId, limit: 3);
      if (!mounted) return;
      setState(() => _reviews = reviews);
      try {
        final access = await _repo.getReviewEligibility(widget.placeId);
        if (!mounted) return;
        setState(() {
          _canCreate = access['canCreate'] == true;
          _canEdit = access['canEdit'] == true;
          _own = access['review'] == null
              ? null
              : ReviewModel.fromJson(
                  Map<String, dynamic>.from(access['review']),
                );
        });
      } catch (e) {
        if (mounted) setState(() => _error = ApiErrorHandler.handle(e));
      }
    } catch (e) {
      if (mounted) setState(() => _error = ApiErrorHandler.handle(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'ĐÁNH GIÁ ĐỊA ĐIỂM',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        if (_loading) const LinearProgressIndicator(),
        if (_error != null)
          TextButton(onPressed: _load, child: Text('$_error · Thử lại')),
        if (!_loading && _error == null && !_canCreate && !_canEdit)
          Text(
            _own == null
                ? 'Hoàn thành hành trình tại đây để đánh giá.'
                : _own!.deleted
                ? 'Đánh giá của bạn đã được gỡ.'
                : 'Bạn đã dùng lượt chỉnh sửa đánh giá.',
            style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
          ),
        if (_canCreate || _canEdit)
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.primary,
              side: BorderSide(color: colors.primary.withValues(alpha: 0.5)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.rate_review_outlined, size: 18),
            label: Text(
              _canCreate ? 'Đánh giá địa điểm' : 'Chỉnh sửa đánh giá (1 lần)',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReviewScreen(
                    placeId: widget.placeId,
                    placeName: widget.placeName ?? 'Địa điểm',
                    existingReview: _own,
                  ),
                ),
              );
              if (mounted) await _load();
            },
          ),
        for (final review in _reviews)
          Card(
            color: colors.surfaceContainerHighest,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            margin: const EdgeInsets.only(top: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                color: colors.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          review.isAnonymous
                              ? 'Trekker ẩn danh'
                              : review.displayName ?? 'Trekker',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colors.onSurface,
                          ),
                        ),
                      ),
                      if (review.createdAt != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${review.createdAt!.day}/${review.createdAt!.month}/${review.createdAt!.year}',
                          style: TextStyle(
                            fontSize: 10,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  RatingStars(
                    rating: review.rating,
                    starSize: 16,
                    activeColor: Colors.amber,
                    inactiveColor: colors.outlineVariant,
                  ),
                  if (review.content?.isNotEmpty == true) ...[
                    const SizedBox(height: 10),
                    Text(
                      review.content!,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: colors.onSurface,
                      ),
                    ),
                  ],
                  if (review.imageUrls.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final url in review.imageUrls)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              url,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (_, error, stack) => SizedBox(
                                width: 80,
                                height: 80,
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        if (!_loading && _reviews.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Chưa có bình luận địa điểm.',
              style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
            ),
          ),
        const SizedBox(height: 8),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: colors.primary),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PlaceReviewsScreen(
                  placeId: widget.placeId,
                  placeName: widget.placeName ?? 'Địa điểm',
                ),
              ),
            );
            if (mounted) await _load();
          },
          child: const Text(
            'Xem tất cả đánh giá',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
