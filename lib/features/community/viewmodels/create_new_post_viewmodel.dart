import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/models/post_model.dart';
import '../data/datasources/community_attachment_datasource.dart';
import '../data/datasources/community_remote_datasource.dart';
import '../../../core/services/trekking_upload_service.dart';
import '../../../core/services/auth_event_bus.dart';
import '../../../core/services/user_api_service.dart';
import '../../../core/network/api_error_handler.dart';

class CreateNewPostViewModel extends ChangeNotifier {
  static const int maxImages = 5;
  final PostModel? editingPost;
  final String initialType;
  final CommunityRemoteDataSource _dataSource;
  final Future<String> Function(String path) _uploadImage;
  final ImagePicker _picker;
  final List<File> _selectedImages = [];
  final List<String> _existingImages = [];
  // Reuse completed uploads when retrying a failed save.
  final Map<String, String> _uploadedImages = {};
  late final TextEditingController contentController;
  late final StreamSubscription<AuthEvent> _authSubscription;
  bool _disposed = false, _sessionEnded = false, _isLoading = false;
  bool _linksChanged = false;
  String? _errorMessage;
  String _visibility = 'PUBLIC';
  CommunityAttachment? _place, _journey;
  String _userName = '';
  String _userMemberSince = '';
  String? _userAvatarUrl;

  CreateNewPostViewModel({
    this.editingPost,
    String initialContent = '',
    this.initialType = 'NORMAL',
    CommunityAttachment? initialJourney,
    CommunityRemoteDataSource? dataSource,
    Future<String> Function(String path)? uploadImage,
    ImagePicker? picker,
  }) : _dataSource = dataSource ?? CommunityRemoteDataSource(),
       _uploadImage =
           uploadImage ??
           ((path) =>
               TrekkingUploadService().uploadImage(path, 'COMMUNITY_POST')),
       _picker = picker ?? ImagePicker() {
    final post = editingPost;
    contentController = TextEditingController(
      text: post?.content ?? initialContent,
    )..addListener(_emit);
    if (post == null && initialJourney != null) selectJourney(initialJourney);
    if (post != null) {
      _existingImages.addAll(post.images);
      _visibility = post.visibility;
      if (post.trekkingPlaceId != null) {
        _place = CommunityAttachment(
          id: post.trekkingPlaceId!,
          name: post.trekPlaceName ?? 'Địa điểm đã gắn',
        );
      }
      if (post.journeyId != null) {
        _journey = CommunityAttachment(
          id: post.journeyId!,
          name: 'Hành trình đã chia sẻ',
          placeId: post.trekkingPlaceId,
        );
      }
    }
    _authSubscription = AuthEventBus().stream.listen((_) {
      _sessionEnded = true;
      _errorMessage =
          'Phiên đăng nhập đã kết thúc. Vui lòng mở lại trình soạn bài.';
      _emit();
    });
    _loadCurrentUser();
  }

  List<File> get selectedImages => List.unmodifiable(_selectedImages);
  List<String> get existingImages => List.unmodifiable(_existingImages);
  int get imageCount => _selectedImages.length + _existingImages.length;
  CommunityAttachment? get place => _place;
  CommunityAttachment? get journey => _journey;
  String? get taggedLocation => _place?.id;
  String get userName => _userName;
  String get userMemberSince => _userMemberSince;
  String? get userAvatarUrl => _userAvatarUrl;
  String get visibility => _visibility;
  bool get isLoading => _isLoading;
  bool get isEditing => editingPost != null;
  String? get errorMessage => _errorMessage;
  void _emit() {
    if (!_disposed) notifyListeners();
  }

  Future<void> pickImage() async => _pick(single: true);
  Future<void> pickMultiImages() async => _pick();
  Future<void> _pick({bool single = false}) async {
    if (_isLoading || _disposed || _sessionEnded) return;
    if (imageCount >= maxImages) {
      _errorMessage = 'Chỉ được chọn tối đa 5 hình ảnh';
      _emit();
      return;
    }
    try {
      final files = single
          ? [
              await _picker.pickImage(
                source: ImageSource.gallery,
                imageQuality: 80,
              ),
            ].whereType<XFile>().toList()
          : await _picker.pickMultiImage(imageQuality: 80);
      if (_disposed || _sessionEnded || _isLoading) return;
      final paths = _selectedImages.map((f) => f.path).toSet();
      _selectedImages.addAll(
        files
            .where((f) => paths.add(f.path))
            .take(maxImages - imageCount)
            .map((f) => File(f.path)),
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = ApiErrorHandler.handle(e);
    }
    _emit();
  }

  void removeImage(int index) {
    if (_isLoading || index < 0 || index >= _selectedImages.length) return;
    _selectedImages.removeAt(index);
    _emit();
  }

  void removeExistingImage(int index) {
    if (_isLoading || index < 0 || index >= _existingImages.length) return;
    _existingImages.removeAt(index);
    _emit();
  }

  void clearContent() {
    if (!_isLoading) contentController.clear();
  }

  void setVisibility(String value) {
    if (_isLoading || !['PUBLIC', 'PRIVATE'].contains(value)) return;
    _visibility = value;
    _emit();
  }

  void selectPlace(CommunityAttachment? place) {
    if (_isLoading) return;
    _place = place;
    _journey = null;
    _linksChanged = true;
    _emit();
  }

  void selectJourney(CommunityAttachment? journey) {
    if (_isLoading) return;
    _journey = journey;
    _place = journey?.placeId == null
        ? null
        : CommunityAttachment(
            id: journey!.placeId!,
            name: journey.placeName ?? 'Địa điểm của hành trình',
          );
    _linksChanged = true;
    _emit();
  }

  Future<PostModel?> submitPost() async {
    if (_isLoading || _disposed || _sessionEnded) return null;
    final text = contentController.text.trim();
    if ((text.isEmpty && imageCount == 0) || text.length > 10000) {
      _errorMessage = text.length > 10000
          ? 'Nội dung tối đa 10.000 ký tự'
          : 'Vui lòng nhập nội dung hoặc thêm ảnh cho bài viết';
      _emit();
      return null;
    }
    _isLoading = true;
    _errorMessage = null;
    _emit();
    try {
      final images = [..._existingImages];
      for (final file in _selectedImages) {
        final url = _uploadedImages[file.path] ??= await _uploadImage(
          file.path,
        );
        if (_disposed || _sessionEnded) return null;
        images.add(url);
      }
      if (_disposed || _sessionEnded) return null;
      final type = !_linksChanged && editingPost != null
          ? editingPost!.type
          : (_journey != null
                ? 'JOURNEY_SHARE'
                : (initialType == 'BADGE_SHARE' ? 'BADGE_SHARE' : 'NORMAL'));
      final post = editingPost;
      final result = post == null
          ? await _dataSource.createPost(
              content: text,
              images: images,
              visibility: _visibility,
              type: type,
              journeyId: _journey?.id,
              trekkingPlaceId: _place?.id,
            )
          : await _dataSource.updatePost(
              post.postId,
              text,
              images: images,
              visibility: _visibility,
              type: _linksChanged ? type : null,
              replaceLinks: _linksChanged,
              journeyId: _journey?.id,
              trekkingPlaceId: _place?.id,
            );
      return _disposed || _sessionEnded ? null : result?.copyWith(trekPlaceName: result.trekPlaceName ?? _place?.name);
    } catch (e) {
      _errorMessage = ApiErrorHandler.handle(e);
      return null;
    } finally {
      _isLoading = false;
      _emit();
    }
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = await UserApiService().getProfile();
      if (_disposed) return;
      _userName = user['displayName'] as String? ?? '';
      _userAvatarUrl = user['avatarUrl'] as String?;
      final rawJoined = user['createdAt'] as String?;
      if (rawJoined != null) {
        final joined = DateTime.tryParse(rawJoined);
        _userMemberSince = joined != null ? '${joined.month}/${joined.year}' : '';
      }
      _emit();
    } catch (_) {
      // silently ignore — placeholder stays
    }
  }
  @override
  void dispose() {
    _disposed = true;
    _authSubscription.cancel();
    contentController.dispose();
    super.dispose();
  }
}
