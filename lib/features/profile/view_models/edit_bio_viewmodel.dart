import 'package:flutter/material.dart';
import '../data/models/profile_model.dart';

class EditBioViewModel extends ChangeNotifier {
  static const int maxBioLength = 160;

  final TextEditingController bioController = TextEditingController();

  bool _isLoading = false;
  bool _isSaved = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get isSaved => _isSaved;
  String? get errorMessage => _errorMessage;
  int get charCount => bioController.text.length;
  bool get isOverLimit => charCount > maxBioLength;

  /// Khởi tạo controller với bio hiện tại, được gọi 1 lần từ initState
  void initBio(String currentBio) {
    bioController.text = currentBio;
    bioController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Xóa toàn bộ nội dung bio
  void clearBio() {
    bioController.clear();
    notifyListeners();
  }

  /// Validate bio trước khi lưu
  bool _validate() {
    if (bioController.text.trim().isEmpty) {
      _errorMessage = 'Bio không được để trống.';
      notifyListeners();
      return false;
    }
    if (isOverLimit) {
      _errorMessage = 'Bio không được vượt quá $maxBioLength ký tự.';
      notifyListeners();
      return false;
    }
    return true;
  }

  /// Lưu bio mới.
  /// [onSaved] là callback để cập nhật ProfileViewModel qua Provider —
  /// screen truyền vào `context.read<ProfileViewModel>().updateProfile`
  Future<void> saveBio({
    required UserProfileModel currentProfile,
    required void Function(UserProfileModel updatedProfile) onSaved,
    required BuildContext context,
  }) async {
    if (!_validate()) return;

    _isLoading = true;
    _isSaved = false;
    notifyListeners();

    try {
      // TODO: Thay bằng API call thực tế
      await Future.delayed(const Duration(milliseconds: 600));

      final updatedProfile = _copyProfileWithBio(
        currentProfile,
        bioController.text.trim(),
      );

      // Gọi callback → cập nhật ProfileViewModel từ Provider
      onSaved(updatedProfile);

      _isSaved = true;
      notifyListeners();

      if (context.mounted) Navigator.of(context).pop();
    } catch (e) {
      _errorMessage = 'Lưu bio thất bại. Vui lòng thử lại.';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Copy immutable UserProfileModel với bio mới
  UserProfileModel _copyProfileWithBio(
    UserProfileModel profile,
    String newBio,
  ) {
    return UserProfileModel(
      id: profile.id,
      name: profile.name,
      isPro: profile.isPro,
      memberSince: profile.memberSince,
      bio: newBio,
      email: profile.email,
      avatarUrl: profile.avatarUrl,
      visitedProvinces: profile.visitedProvinces,
      totalProvinces: profile.totalProvinces,
      totalDistanceKm: profile.totalDistanceKm,
      completedTrips: profile.completedTrips,
      totalDays: profile.totalDays,
      achievements: profile.achievements,
    );
  }

  @override
  void dispose() {
    bioController.removeListener(_onTextChanged);
    bioController.dispose();
    super.dispose();
  }
}
