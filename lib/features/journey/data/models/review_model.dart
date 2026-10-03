/// Model Review (đánh giá địa điểm) trả về từ API.
class ReviewModel {
  final String reviewId;
  final String placeId;
  final String? userId;
  final String? displayName;
  final String? avatarUrl;
  final int rating; // 1–5
  final String? content;
  final List<String> imageUrls;
  final bool isAnonymous;
  final DateTime? createdAt;

  const ReviewModel({
    required this.reviewId,
    required this.placeId,
    this.userId,
    this.displayName,
    this.avatarUrl,
    required this.rating,
    this.content,
    this.imageUrls = const [],
    this.isAnonymous = false,
    this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      // Backend trả "detailEvaluateId", fallback về "reviewId"/"id"
      reviewId: json['detailEvaluateId'] as String? ??
          json['reviewId'] as String? ??
          json['id'] as String? ??
          '',
      // Backend trả "trekkingPlaceId", frontend dùng "placeId"
      placeId: json['trekkingPlaceId'] as String? ??
          json['placeId'] as String? ??
          '',
      userId: json['userId'] as String?,
      displayName: json['displayName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      // Backend dùng "point" (1-5), frontend dùng "rating"
      rating: json['point'] as int? ??
          json['rating'] as int? ?? 0,
      content: json['content'] as String?,
      // Backend dùng "imagesUrl", frontend dùng "imageUrls"
      imageUrls: (json['imagesUrl'] as List<dynamic>?)
              ?.cast<String>() ??
          (json['imageUrls'] as List<dynamic>?)
              ?.cast<String>() ??
          [],
      isAnonymous: json['isAnonymous'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }
}

/// Request body để POST review
class CreateReviewRequest {
  final int rating;
  final String? content;
  final List<String> imageUrls;
  final bool isAnonymous;
  final String? journeyId;

  const CreateReviewRequest({
    required this.rating,
    this.content,
    this.imageUrls = const [],
    this.isAnonymous = false,
    this.journeyId,
  });

  Map<String, dynamic> toJson() => {
        // Backend nhận "point" (1-5), không phải "rating"
        'point': rating,
        if (content != null && content!.isNotEmpty) 'content': content,
        // Backend nhận "imagesUrl", không phải "imageUrls"
        if (imageUrls.isNotEmpty) 'imagesUrl': imageUrls,
        if (journeyId != null) 'journeyId': journeyId,
      };
}
