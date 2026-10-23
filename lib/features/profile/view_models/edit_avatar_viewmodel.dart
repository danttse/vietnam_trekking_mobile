import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:io';

import '../../../core/services/user_api_service.dart';

class EditAvatarViewModel extends ChangeNotifier {
  final UserApiService _api;
  bool _disposed = false;
  EditAvatarViewModel({UserApiService? api}) : _api = api ?? UserApiService();
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  bool _isLoading = false;
  String? _errorMessage;

  File? get selectedImage => _selectedImage;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasNewImage => _selectedImage != null;

  Future<void> pickFromCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (photo != null) {
        _selectedImage = File(photo.path);
        _errorMessage = null;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Không thể mở camera. Vui lòng thử lại.';
      notifyListeners();
    }
  }

  Future<void> pickFromGallery() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (photo != null) {
        _selectedImage = File(photo.path);
        _errorMessage = null;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Không thể mở thư viện ảnh. Vui lòng thử lại.';
      notifyListeners();
    }
  }

  Future<String?> saveAvatar() async {
    if (_selectedImage == null) return null;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      return await _api.uploadAvatar(_selectedImage!.path);
    } catch (e) {
      _errorMessage = 'Lưu ảnh thất bại. Vui lòng thử lại.';
      return null;
    } finally {
      _isLoading = false;
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
