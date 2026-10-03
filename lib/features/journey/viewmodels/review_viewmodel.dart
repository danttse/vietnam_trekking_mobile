import 'package:flutter/foundation.dart';
import '../data/models/review_model.dart';
import '../data/repositories/journey_repository.dart';

enum ReviewSubmitState { idle, submitting, success, error }

class ReviewViewModel extends ChangeNotifier {
  final JourneyRepository _repo;
  final String placeId;
  final String? placeName;
  final String? journeyId;

  ReviewViewModel({
    required this.placeId,
    this.placeName,
    this.journeyId,
    JourneyRepository? repo,
  }) : _repo = repo ?? JourneyRepository();

  // ── Form state ────────────────────────────────────────────────────────────
  int rating = 0; // 0 = unset
  String content = '';
  List<String> imageLocalPaths = [];
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
    imageLocalPaths = [...imageLocalPaths, localPath];
    notifyListeners();
  }

  void removeImage(String localPath) {
    imageLocalPaths = imageLocalPaths.where((p) => p != localPath).toList();
    notifyListeners();
  }

  bool get canSubmit =>
      rating > 0 && _state != ReviewSubmitState.submitting;

  Future<void> submit() async {
    if (!canSubmit) return;

    _state = ReviewSubmitState.submitting;
    _error = null;
    notifyListeners();

    try {
      final request = CreateReviewRequest(
        rating: rating,
        content: content.trim().isEmpty ? null : content.trim(),
        isAnonymous: isAnonymous,
        journeyId: journeyId,
        // imageUrls: uploaded remote URLs — simplified: pass local for now
      );
      submittedReview = await _repo.createReview(placeId, request);
      _state = ReviewSubmitState.success;
    } catch (e) {
      _error = e.toString();
      _state = ReviewSubmitState.error;
    }
    notifyListeners();
  }

  void reset() {
    rating = 0;
    content = '';
    imageLocalPaths = [];
    isAnonymous = false;
    _state = ReviewSubmitState.idle;
    _error = null;
    submittedReview = null;
    notifyListeners();
  }
}
