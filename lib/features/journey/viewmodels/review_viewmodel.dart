import '../../../core/services/trekking_upload_service.dart';
import '../../../core/network/api_error_handler.dart';

import 'package:flutter/foundation.dart';

import '../data/models/review_model.dart';
import '../data/repositories/journey_repository.dart';

enum ReviewSubmitState { idle, submitting, success, error }

class ReviewViewModel extends ChangeNotifier {
  final JourneyRepository _repo;
  final String placeId;
  final String? placeName;
  final String? journeyId;
  final ReviewModel? existingReview;

  ReviewViewModel({
    required this.placeId,
    this.placeName,
    this.journeyId,
    this.existingReview,
    JourneyRepository? repo,
  }) : _repo = repo ?? JourneyRepository() {
    if (existingReview != null) {
      rating = existingReview!.rating;
      content = existingReview!.content ?? '';
      imageRemoteUrls = [...existingReview!.imageUrls];
      isAnonymous = existingReview!.isAnonymous;
    }
  }

  // ── Form state ────────────────────────────────────────────────────────────
  int rating = 0; // 0 = unset
  String content = '';
  List<String> imageLocalPaths = [];
  List<String> imageRemoteUrls = [];
  bool isAnonymous = false;

  ReviewSubmitState _state = ReviewSubmitState.idle;
  ReviewSubmitState get state => _state;

  String? _error;
  String? get error => _error;

  ReviewModel? submittedReview;

  // ── Actions ───────────────────────────────────────────────────────────────

  void setRating(int value) {
    rating = value;
    notifyListeners();
  }

  void setContent(String value) {
    content = value;
    notifyListeners();
  }

  void toggleAnonymous() {
    isAnonymous = !isAnonymous;
    notifyListeners();
  }

  void addImage(String localPath) {
    if (imageLocalPaths.length + imageRemoteUrls.length >= 10) return;
    imageLocalPaths = [...imageLocalPaths, localPath];
    notifyListeners();
  }

  void removeImage(String localPath) {
    imageLocalPaths = imageLocalPaths.where((p) => p != localPath).toList();
    notifyListeners();
  }

  void removeRemoteImage(String url) {
    imageRemoteUrls = imageRemoteUrls.where((value) => value != url).toList();
    notifyListeners();
  }

  bool get canSubmit =>
      rating > 0 &&
      _state != ReviewSubmitState.submitting &&
      _state != ReviewSubmitState.success &&
      (existingReview == null ||
          (!existingReview!.deleted && existingReview!.editCount < 1));

  Future<void> submit() async {
    if (!canSubmit) return;

    _state = ReviewSubmitState.submitting;
    _error = null;
    notifyListeners();

    try {
      final uploaded = <String>[...imageRemoteUrls];
      for (final path in imageLocalPaths) {
        uploaded.add(
          await TrekkingUploadService().uploadImage(path, 'PLACE_REVIEW'),
        );
      }
      final request = CreateReviewRequest(
        rating: rating,
        imageUrls: uploaded,
        content: content.trim().isEmpty ? null : content.trim(),
        isAnonymous: isAnonymous,
        journeyId: journeyId,
      );
      submittedReview = existingReview == null
          ? await _repo.createReview(placeId, request)
          : await _repo.updateReview(
              placeId,
              existingReview!.reviewId,
              request,
            );
      _state = ReviewSubmitState.success;
    } catch (e) {
      _error = ApiErrorHandler.handle(e);
      _state = ReviewSubmitState.error;
    }
    notifyListeners();
  }

  void reset() {
    rating = 0;
    content = '';
    imageLocalPaths = [];
    imageRemoteUrls = [];
    isAnonymous = false;
    _state = ReviewSubmitState.idle;
    _error = null;
    submittedReview = null;
    notifyListeners();
  }
}
