import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../data/models/journey_model.dart';
import '../data/models/milestone_model.dart';

class RateMilestoneViewModel extends ChangeNotifier {
  final MilestoneModel? milestone;
  final JourneyModel? journey;

  int _rating = 0;
  bool _isAnonymous = false;
  bool _isLoading = false;
  bool _isSubmitted = false;

  final TextEditingController descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<File> _selectedImages = [];

  RateMilestoneViewModel({
    this.milestone,
    this.journey,
  });

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
    if (_rating != value) {
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

    final List<XFile> pickedFiles =
        await _picker.pickMultiImage(imageQuality: 80);
    if (pickedFiles.isNotEmpty) {
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
    if (_isLoading) return false;

    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    _isLoading = false;
    _isSubmitted = true;
    notifyListeners();
    return true;
  }

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }
}
