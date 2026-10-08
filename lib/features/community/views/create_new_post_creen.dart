import 'dart:io';

import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'package:vietnam_trekking_mobile/features/profile/widgets/profile_widgets.dart';
import '../../../core/widgets/app_bar/app_top_bar_with_back.dart';
import '../../../core/widgets/cards/post_card.dart';
import '../data/models/post_model.dart';
import '../viewmodels/create_new_post_viewmodel.dart';
import '../../../core/widgets/buttons/btn_login_style.dart';
import '../../../core/widgets/cards/image_load_card.dart';

class CreateNewPostCreen extends StatefulWidget {
  const CreateNewPostCreen({super.key});

  @override
  State<CreateNewPostCreen> createState() => _CreateNewPostState();
}

class _CreateNewPostState extends State<CreateNewPostCreen> {
  late final CreateNewPostViewModel _createNewPostViewModel;
  @override
  void initState() {
    super.initState();
    _createNewPostViewModel = CreateNewPostViewModel();
  }
  @override
  void dispose() {
    super.dispose();
  }
  Widget _buildItemSelection(BuildContext context,String title,IconData icon, VoidCallback onTapAction, String resultSelection)
  {
    final colorScheme=Theme.of(context).colorScheme;
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
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Text(
            resultSelection,
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final colorScheme=Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            AppTopBarWithBack(title: "Tạo bài viết mới"),
            Expanded(
              child: ListenableBuilder(
                listenable: _createNewPostViewModel,
                builder: (context, _) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ProfileHeaderCard(name: "Tên người dùng", memberSince: "19/2", bio: "",subTitle: "Đang chia sẻ với TrekViệt"),
                  const SizedBox(height: 12),
                  Container(
                      child: TextField(
                        style: const TextStyle(fontSize: 12),
                        controller: _createNewPostViewModel.contentController,
                        textInputAction: TextInputAction.done,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: l10n?.createNewPostHintText ?? "Bạn đang nghĩ gì?",
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        errorText: _createNewPostViewModel.errorMessage,
                        suffixIcon: _createNewPostViewModel.contentController.text.isNotEmpty
                          ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _createNewPostViewModel.clearContent,
                          )
                        : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ProfileSettingGroupItem(
                    title: "Thêm vào bài viết",
                    items: [
                      _buildItemSelection(
                        context,
                        "Thêm ảnh",
                        Icons.camera_alt,
                        () {
                          if (_createNewPostViewModel.imageCount >=
                              CreateNewPostViewModel.maxImages) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Chỉ được chọn tối đa 5 hình ảnh'),
                              ),
                            );
                          } else {
                            _createNewPostViewModel.pickMultiImages();
                          }
                        },
                        _createNewPostViewModel.selectedImages.isNotEmpty
                            ? "${_createNewPostViewModel.selectedImages.length} ảnh đã chọn"
                            : "",
                      ),
                      _buildItemSelection(context, "Gắn thẻ địa điểm", Icons.location_pin, () {}, ""),
                    ],
                  ),
                  if (_createNewPostViewModel.selectedImages.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 72,
                      child: Row(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _createNewPostViewModel.selectedImages.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: ImageLoadCard(
                                    imageUrl: _createNewPostViewModel.selectedImages[index],
                                    onTapRemove: () => _createNewPostViewModel.removeImage(index),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${_createNewPostViewModel.imageCount}/${CreateNewPostViewModel.maxImages}',
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  BtnLoginPrimary(
                    text: "Đăng bài viết",
                    isLoading: _createNewPostViewModel.isLoading,
                    onPressed: () async {
                      final post = await _createNewPostViewModel.submitPost();
                      if (post != null) {
                        Navigator.pop(context, post);
                      }
                    },
                  ),
                ],
              ),
            );
                }
              )
            )
          ],
        ),
      )
    );
  }
}