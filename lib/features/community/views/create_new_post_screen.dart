import 'package:flutter/material.dart';
import '../../../core/widgets/app_bar/app_top_bar_with_back.dart';
import '../../../core/widgets/buttons/btn_login_style.dart';
import '../../../core/widgets/cards/image_load_card.dart';
import '../../../core/widgets/chips/horizontal_chip_bar.dart';
import '../../../l10n/app_localizations.dart';
import 'package:vietnam_trekking_mobile/features/profile/widgets/profile_widgets.dart';
import '../data/datasources/community_attachment_datasource.dart';
import '../data/models/post_model.dart';
import '../viewmodels/create_new_post_viewmodel.dart';
import 'community_attachment_picker.dart';

class CreateNewPostScreen extends StatefulWidget {
  final PostModel? post;
  final CreateNewPostViewModel? viewModel;
  final String initialContent;
  final String initialType;
  final CommunityAttachment? initialJourney;

  const CreateNewPostScreen({
    super.key,
    this.post,
    this.viewModel,
    this.initialContent = '',
    this.initialType = 'NORMAL',
    this.initialJourney,
  });

  @override
  State<CreateNewPostScreen> createState() => _CreateNewPostState();
}

class _CreateNewPostState extends State<CreateNewPostScreen> {
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

  Widget _thumbnail(Widget image, VoidCallback remove, [String? removeTooltip]) => SizedBox(
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
            tooltip: removeTooltip ?? 'Gỡ ảnh',
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.close, size: 18),
            onPressed: _vm.isLoading ? null : remove,
          ),
        ),
      ],
    ),
  );

  Widget _buildItemSelection(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTapAction,
    String resultSelection,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTapAction,
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: colorScheme.onSurfaceVariant,
              size: 15,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resultSelection,
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return PopScope(
      canPop: !_vm.isLoading,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: SafeArea(
          child: Column(
            children: [
              AppTopBarWithBack(
                title: _vm.isEditing
                    ? (l10n?.postEditTitle ?? 'Chỉnh sửa bài viết')
                    : (l10n?.postCreateTitle ?? 'Tạo bài viết mới'),
              ),
              Expanded(
                child: ListenableBuilder(
                  listenable: _vm,
                  builder: (context, _) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          ProfileHeaderCard(
                            name: _vm.userName.isNotEmpty
                                ? _vm.userName
                                : (l10n?.commonLoading ?? 'Đang tải...'),
                            memberSince: _vm.userMemberSince,
                            bio: '',
                            avatarUrl: _vm.userAvatarUrl,
                            subTitle: l10n?.postSharingWithTrekViet ??
                                'Đang chia sẻ với TrekViệt',
                          ),
                          const SizedBox(height: 12),
                          HorizontalChipBar(
                            items: [
                              l10n?.visibilityPublic ?? 'Công khai',
                              l10n?.visibilityPrivate ?? 'Chỉ mình tôi',
                            ],
                            selectedIndex: _vm.visibility == 'PRIVATE' ? 1 : 0,
                            onSelect: (index) {
                              if (!_vm.isLoading) {
                                _vm.setVisibility(
                                  index == 1 ? 'PRIVATE' : 'PUBLIC',
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            style: const TextStyle(fontSize: 12),
                            controller: _vm.contentController,
                            enabled: !_vm.isLoading,
                            textInputAction: TextInputAction.done,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText:
                                  l10n?.createNewPostHintText ??
                                  l10n?.whatsOnYourMind ??
                                  'Bạn đang nghĩ gì?',
                              filled: true,
                              fillColor: colorScheme.surfaceContainerHighest,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: _vm.contentController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: _vm.clearContent,
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ProfileSettingGroupItem(
                            title: l10n?.postAddToPost ?? 'Thêm vào bài viết',
                            items: [
                              _buildItemSelection(
                                context,
                                l10n?.postAddPhoto ?? 'Thêm ảnh',
                                Icons.camera_alt,
                                () {
                                  if (_vm.imageCount >=
                                      CreateNewPostViewModel.maxImages) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          l10n?.postMaxImagesHint ??
                                              'Chỉ được chọn tối đa 5 hình ảnh',
                                        ),
                                      ),
                                    );
                                  } else {
                                    _vm.pickMultiImages();
                                  }
                                },
                                _vm.selectedImages.isNotEmpty
                                    ? (l10n?.postSelectedImagesCount(
                                            _vm.selectedImages.length) ??
                                        '${_vm.selectedImages.length} ảnh đã chọn')
                                    : '',
                              ),
                              _buildItemSelection(
                                context,
                                l10n?.postTagLocation ?? 'Gắn thẻ địa điểm',
                                Icons.location_pin,
                                _vm.isLoading
                                    ? () {}
                                    : () => _selectAttachment(false),
                                _vm.place?.name ?? '',
                              ),
                              _buildItemSelection(
                                context,
                                l10n?.postShareJourney ?? 'Chia sẻ hành trình',
                                Icons.hiking,
                                _vm.isLoading
                                    ? () {}
                                    : () => _selectAttachment(true),
                                _vm.journey?.name ?? '',
                              ),
                            ],
                          ),
                          if (_vm.imageCount > 0) ...[
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 72,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _vm.imageCount,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 0),
                                itemBuilder: (context, index) {
                                  if (index < _vm.existingImages.length) {
                                    return _thumbnail(
                                      Image.network(
                                        _vm.existingImages[index],
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(
                                              Icons.broken_image_outlined,
                                            ),
                                      ),
                                      () => _vm.removeExistingImage(index),
                                      l10n?.postRemoveImage,
                                    );
                                  }
                                  final local =
                                      index - _vm.existingImages.length;
                                  return ImageLoadCard(
                                    imageUrl: _vm.selectedImages[local],
                                    onTapRemove: () => _vm.removeImage(local),
                                  );
                                },
                              ),
                            ),
                          ],
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                '${_vm.imageCount}/${CreateNewPostViewModel.maxImages}',
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                          if (_vm.errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                _vm.errorMessage!,
                                style: TextStyle(
                                  color: colorScheme.error,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          const SizedBox(height: 12),
                          BtnLoginPrimary(
                            text: _vm.isEditing
                                ? (l10n?.commonSaveChanges ?? 'Lưu thay đổi')
                                : (l10n?.postPublishButton ?? 'Đăng bài viết'),
                            isLoading: _vm.isLoading,
                            onPressed: () async {
                              final result = await _vm.submitPost();
                              if (!context.mounted || result == null) return;
                              Navigator.pop(context, result);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
