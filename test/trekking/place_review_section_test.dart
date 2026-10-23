import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vietnam_trekking_mobile/features/journey/data/models/review_model.dart';
import 'package:vietnam_trekking_mobile/features/journey/data/repositories/journey_repository.dart';
import 'package:vietnam_trekking_mobile/features/journey/views/widgets/place_review_section.dart';
import 'package:vietnam_trekking_mobile/features/journey/viewmodels/review_viewmodel.dart';

class _Repository extends JourneyRepository {
  final Map<String, dynamic> access;
  int creates = 0, updates = 0;
  CreateReviewRequest? sent;
  _Repository(this.access);
  @override
  Future<List<ReviewModel>> getReviews(
    String placeId, {
    int page = 1,
    int limit = 20,
  }) async => [
    const ReviewModel(
      reviewId: 'r1',
      placeId: 'p1',
      rating: 4,
      content: 'Đường đẹp, dễ đi',
      isAnonymous: true,
    ),
  ];
  @override
  Future<Map<String, dynamic>> getReviewEligibility(String placeId) async =>
      access;
  @override
  Future<ReviewModel> createReview(
    String placeId,
    CreateReviewRequest request,
  ) async {
    creates++;
    sent = request;
    return ReviewModel(
      reviewId: 'r1',
      placeId: placeId,
      rating: request.rating,
    );
  }

  @override
  Future<ReviewModel> updateReview(
    String placeId,
    String reviewId,
    CreateReviewRequest request,
  ) async {
    updates++;
    sent = request;
    return ReviewModel(
      reviewId: reviewId,
      placeId: placeId,
      rating: request.rating,
      editCount: 1,
    );
  }
}

void main() {
  testWidgets('completed user sees review action and public comments', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PlaceReviewSection(
            placeId: 'p1',
            repository: _Repository({'canCreate': true, 'canEdit': false}),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Đường đẹp, dễ đi'), findsOneWidget);
    expect(find.text('Trekker ẩn danh'), findsOneWidget);
    expect(find.byType(OutlinedButton), findsOneWidget);
    final section = tester.getRect(find.byType(PlaceReviewSection));
    final card = tester.getRect(find.byType(Card));
    expect(card.left, section.left);
    expect(card.right, section.right);
    expect(tester.takeException(), isNull);
  });

  testWidgets('used edit is locked and removed reviews cannot be recreated', (
    tester,
  ) async {
    for (final deleted in [false, true]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlaceReviewSection(
              key: ValueKey(deleted),
              placeId: 'p1',
              repository: _Repository({
                'canCreate': false,
                'canEdit': false,
                'review': {
                  'detailEvaluateId': 'r1',
                  'point': 4,
                  'editCount': 1,
                  'deleted': deleted,
                },
              }),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(OutlinedButton), findsNothing);
      expect(
        find.text(
          deleted
              ? 'Đánh giá của bạn đã được gỡ.'
              : 'Bạn đã dùng lượt chỉnh sửa đánh giá.',
        ),
        findsOneWidget,
      );
    }
  });

  test('editing uses PUT and preserves attached images while allowing empty content', () async {
    final repo = _Repository({});
    final vm = ReviewViewModel(
      placeId: 'p1',
      repo: repo,
      existingReview: const ReviewModel(
        reviewId: 'r1',
        placeId: 'p1',
        rating: 4,
        content: 'Cũ',
        imageUrls: ['https://example.com/photo.jpg'],
      ),
    );
    vm.setContent('');
    await vm.submit();
    await vm.submit();
    expect(repo.creates, 0);
    expect(repo.updates, 1);
    expect(repo.sent!.toJson()['content'], '');
    expect(repo.sent!.imageUrls, ['https://example.com/photo.jpg']);
    vm.dispose();
  });
}
