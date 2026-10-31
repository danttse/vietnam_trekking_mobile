import 'package:flutter/material.dart';

import '../../../core/widgets/buttons/btn_login_style.dart';
import '../data/models/post_model.dart';
import '../data/datasources/community_attachment_datasource.dart';
import '../viewmodels/create_new_post_viewmodel.dart';
import 'community_attachment_picker.dart';

class CreateNewPostCreen extends StatefulWidget {
  final PostModel? post;
  final CreateNewPostViewModel? viewModel;
  final String initialContent;
  final String initialType;
  final CommunityAttachment? initialJourney;
  const CreateNewPostCreen({
    super.key,
    this.post,
    this.viewModel,
    this.initialContent = '',
    this.initialType = 'NORMAL',
    this.initialJourney,
  });
  @override
  State<CreateNewPostCreen> createState() => _CreateNewPostState();
}

class _CreateNewPostState extends State<CreateNewPostCreen> {
  late final _vm =
      widget.viewModel ??
      CreateNewPostViewModel(
        editingPost: widget.post,
        initialContent: widget.initialContent,
        initialType: widget.initialType,
        initialJourney: widget.initialJourney,
      );
  @override
  void dispose() {
    if (widget.viewModel == null) _vm.dispose();
    super.dispose();
  }

  Future<void> _selectAttachment(bool journeys) async {
    final item = await Navigator.push<CommunityAttachment>(
      context,
      MaterialPageRoute(
        builder: (_) => CommunityAttachmentPicker(journeys: journeys),
      ),
    );
    if (!mounted || item == null) return;
    if (journeys) {
      _vm.selectJourney(item);
    } else {
      _vm.selectPlace(item);
    }
  }

  Widget _thumbnail(Widget image, VoidCallback remove) => SizedBox(
    width: 88,
    height: 88,
    child: Stack(
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: image,
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: IconButton.filledTonal(
            tooltip: 'Gỡ ảnh',
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.close, size: 18),
            onPressed: _vm.isLoading ? null : remove,
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _vm,
    builder: (context, _) {
      final theme = Theme.of(context);
      return PopScope(
        canPop: !_vm.isLoading,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              _vm.isEditing ? 'Chỉnh sửa bài viết' : 'Tạo bài viết mới',
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Chia sẻ chuyến đi của bạn',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _vm.visibility,
                    decoration: const InputDecoration(
                      labelText: 'Ai có thể xem bài viết?',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'PUBLIC',
                        child: Text('Công khai'),
                      ),
                      DropdownMenuItem(
                        value: 'PRIVATE',
                        child: Text('Chỉ mình tôi'),
                      ),
                    ],
                    onChanged: _vm.isLoading
                        ? null
                        : (value) {
                            if (value != null) _vm.setVisibility(value);
                          },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _vm.contentController,
                    enabled: !_vm.isLoading,
                    minLines: 5,
                    maxLines: 12,
                    maxLength: 10000,
                    decoration: const InputDecoration(
                      hintText: 'Bạn muốn chia sẻ điều gì?',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.photo_library_outlined),
                    title: const Text('Thêm ảnh'),
                    subtitle: Text(
                      '${_vm.imageCount}/${CreateNewPostViewModel.maxImages} ảnh',
                    ),
                    onTap:
                        _vm.isLoading ||
                            _vm.imageCount >= CreateNewPostViewModel.maxImages
                        ? null
                        : _vm.pickMultiImages,
                  ),
                  if (_vm.imageCount > 0)
                    SizedBox(
                      height: 96,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _vm.imageCount,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          if (index < _vm.existingImages.length) {
                            return _thumbnail(
                              Image.network(
                                _vm.existingImages[index],
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) =>
                                    const Icon(Icons.broken_image_outlined),
                              ),
                              () => _vm.removeExistingImage(index),
                            );
                          }
                          final local = index - _vm.existingImages.length;
                          return _thumbnail(
                            Image.file(
                              _vm.selectedImages[local],
                              fit: BoxFit.cover,
                            ),
                            () => _vm.removeImage(local),
                          );
                        },
                      ),
                    ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.place_outlined),
                    title: const Text('Gắn thẻ địa điểm'),
                    subtitle: Text(_vm.place?.name ?? 'Chọn địa điểm trekking'),
                    onTap: _vm.isLoading
                        ? null
                        : () => _selectAttachment(false),
                    trailing: _vm.place == null || _vm.journey != null
                        ? null
                        : IconButton(
                            tooltip: 'Gỡ địa điểm',
                            onPressed: _vm.isLoading
                                ? null
                                : () => _vm.selectPlace(null),
                            icon: const Icon(Icons.close),
                          ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.hiking),
                    title: const Text('Chia sẻ hành trình'),
                    subtitle: Text(
                      _vm.journey?.name ?? 'Chọn hành trình của bạn',
                    ),
                    onTap: _vm.isLoading ? null : () => _selectAttachment(true),
                    trailing: _vm.journey == null
                        ? null
                        : IconButton(
                            tooltip: 'Gỡ hành trình',
                            onPressed: _vm.isLoading
                                ? null
                                : () => _vm.selectJourney(null),
                            icon: const Icon(Icons.close),
                          ),
                  ),
                  if (_vm.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        _vm.errorMessage!,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  const SizedBox(height: 16),
                  BtnLoginPrimary(
                    text: _vm.isEditing ? 'Lưu thay đổi' : 'Đăng bài viết',
                    isLoading: _vm.isLoading,
                    onPressed: () async {
                      final result = await _vm.submitPost();
                      if (!context.mounted || result == null) return;
                      Navigator.pop(context, result);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
