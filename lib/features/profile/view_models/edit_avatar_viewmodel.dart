import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditAvatarViewModel extends ChangeNotifier {
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
      await Future.delayed(const Duration(milliseconds: 800));
      final savedPath = _selectedImage!.path;
      return savedPath;
    } catch (e) {
      _errorMessage = 'Lưu ảnh thất bại. Vui lòng thử lại.';
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
