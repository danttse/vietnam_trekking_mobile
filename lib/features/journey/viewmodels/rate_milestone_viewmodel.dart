import '../../../core/services/user_api_service.dart';
import '../../../core/services/trekking_upload_service.dart';
import '../../../core/network/api_error_handler.dart';

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/models/journey_model.dart';
import '../data/models/milestone_model.dart';

class RateMilestoneViewModel extends ChangeNotifier {
  final MilestoneModel? milestone;
  final JourneyModel? journey;
  final UserApiService _api;

  String? error;
  bool _disposed = false;
  final Map<String, String> _uploaded = {};
  int _rating = 0;
  bool _isAnonymous = false;
  bool _isLoading = false;
  bool _isSubmitted = false;

  final TextEditingController descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<File> _selectedImages = [];

  RateMilestoneViewModel({this.milestone, this.journey, UserApiService? api})
    : _api = api ?? UserApiService();

  int get rating => _rating;
  bool get isAnonymous => _isAnonymous;
  bool get isLoading => _isLoading;
  bool get isSubmitted => _isSubmitted;
  List<File> get selectedImages => _selectedImages;

  String get milestoneName {
    if (milestone != null && milestone!.name.isNotEmpty) {
      return milestone!.name;
    }
    return journey?.name ?? 'Điểm kiểm soát';
  }

  String? get milestoneImageUrl => journey?.route.imageUrl;

  String get locationText {
    final province = journey?.route.province;
    if (province != null && province.isNotEmpty) {
      return '$province, Việt Nam';
    }
    return 'Việt Nam';
  }

  void setRating(int value) {
    if (value >= 1 && value <= 5 && _rating != value && !_isLoading) {
      _rating = value;
      notifyListeners();
    }
  }

  void setAnonymous(bool value) {
    if (_isAnonymous != value) {
      _isAnonymous = value;
      notifyListeners();
    }
  }

  static const int maxImages = 5;

  Future<void> pickMultiImages() async {
    if (_selectedImages.length >= maxImages) {
      return;
    }

    final List<XFile> pickedFiles = await _picker.pickMultiImage(
      imageQuality: 80,
    );
    if (!_disposed && pickedFiles.isNotEmpty) {
      final remainingSlots = maxImages - _selectedImages.length;
      final filesToAdd = pickedFiles
          .take(remainingSlots)
          .map((x) => File(x.path))
          .toList();
      _selectedImages.addAll(filesToAdd);
      notifyListeners();
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < _selectedImages.length) {
      _selectedImages.removeAt(index);
      notifyListeners();
    }
  }

  Future<bool> submit() async {
    if (_isLoading || _isSubmitted) return false;
    if (_rating < 1 || journey == null) {
      error = 'Vui lòng chọn số sao và địa điểm của hành trình.';
      notifyListeners();
      return false;
    }
    _isLoading = true;
    error = null;
    notifyListeners();
    try {
      final uploads = TrekkingUploadService();
      final urls = <String>[];
      for (final image in _selectedImages) {
        final url =
            _uploaded[image.path] ??
            await uploads.uploadImage(image.path, 'PLACE_REVIEW');
        _uploaded[image.path] = url;
        urls.add(url);
      }
      await _api.trekking.post(
        '/places/${journey!.trekkingPlaceId}/reviews',
        data: {
          'point': _rating,
          'isAnonymous': _isAnonymous,
          'content': descriptionController.text.trim(),
          'imagesUrl': urls,
        },
      );
      if (!_disposed) _isSubmitted = true;
      return true;
    } catch (e) {
      if (!_disposed) error = ApiErrorHandler.handle(e);
      return false;
    } finally {
      if (!_disposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    descriptionController.dispose();
    super.dispose();
  }
}
