import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../data/models/post_model.dart';

class CreateNewPostViewModel extends ChangeNotifier {
  final TextEditingController contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<File> _selectedImages = [];
  
  String? _taggedLocation = 'Fansipan'; // Địa điểm mẫu
  bool _isLoading = false;
  String? _errorMessage;

  List<File> get selectedImages => _selectedImages;
  int get imageCount => _selectedImages.length;
  String? get taggedLocation => _taggedLocation;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ///Chon anh
  Future<void> pickImage() async {
    if (_selectedImages.length >= 5) {
      _errorMessage = 'Chỉ được chọn tối đa 5 hình ảnh';
      notifyListeners();
      return;
    }

    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      _selectedImages.add(File(pickedFile.path));
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<void> pickMultiImages() async {
    if (_selectedImages.length >= 5) {
      _errorMessage = 'Chỉ được chọn tối đa 5 hình ảnh';
      notifyListeners();
      return;
    }

    final List<XFile> pickedFiles = await _picker.pickMultiImage(
      imageQuality: 80,
    );

    if (pickedFiles.isNotEmpty) {
      final remainingSlots = 5 - _selectedImages.length;
      final filesToAdd = pickedFiles
          .take(remainingSlots)
          .map((x) => File(x.path))
          .toList();

      _selectedImages.addAll(filesToAdd);
      _errorMessage = null;
      notifyListeners();
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < _selectedImages.length) {
      _selectedImages.removeAt(index);
      _errorMessage = null;
      notifyListeners();
    }
  }

  void clearContent() {
    contentController.clear();
    notifyListeners();
  }

  void setTaggedLocation(String? location) {
    _taggedLocation = location;
    notifyListeners();
  }

  Future<PostModel?> submitPost() async {
    final text = contentController.text.trim();
    if (text.isEmpty && _selectedImages.isEmpty) {
      _errorMessage = 'Vui lòng nhập nội dung hoặc thêm ảnh cho bài viết';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    final newPost = PostModel(
      postId: 'post_${DateTime.now().millisecondsSinceEpoch}',
      authorId: 'user_001',
      authorName: 'Minh Trần',
      authorAvatar:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80',
      content: text,
      images: _selectedImages.map((f) => f.path).toList(),
      type: 'NORMAL',
      trekkingPlaceId: _taggedLocation,
      reactionCount: 0,
      commentCount: 0,
      isLiked: false,
      visibility: 'PUBLIC',
      createdAt: DateTime.now(),
    );

    _isLoading = false;
    notifyListeners();
    return newPost;
  }

  @override
  void dispose() {
    contentController.dispose();
    super.dispose();
  }
}
