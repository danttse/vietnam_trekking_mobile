import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/app_bar/app_top_bar_with_back.dart';
import '../../../core/widgets/buttons/btn_login_style.dart';
import '../../../core/widgets/cards/profile_setting_group_item.dart';
import '../../../core/widgets/cards/profile_setting_item.dart';
import '../../../l10n/app_localizations.dart';
import '../view_models/edit_avatar_viewmodel.dart';
import '../view_models/profile_viewmodel.dart';

class EditAvatarScreen extends StatefulWidget {
  const EditAvatarScreen({super.key});

  @override
  State<EditAvatarScreen> createState() => _EditAvatarScreenState();
}

class _EditAvatarScreenState extends State<EditAvatarScreen> {
  final EditAvatarViewModel _viewModel = EditAvatarViewModel();

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final profile = context.watch<ProfileViewModel>().profile;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTopBarWithBack(title: l10n.editAvatar),
                //phan chinh
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: colorScheme.surfaceContainerHighest,
                                    width: 3,
                                  ),
                                ),
                                child: ClipOval(
                                  child: _buildAvatarImage(
                                      profile.avatarUrl, colorScheme),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: InkWell(
                                  onTap: () =>
                                      _viewModel.pickFromGallery(),
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: colorScheme.surface,
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.camera_alt_outlined,
                                      size: 16,
                                      color: colorScheme.onPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        if (_viewModel.errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _viewModel.errorMessage!,
                              style: TextStyle(
                                fontSize: 13,
                                color: colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        ProfileSettingGroupItem(
                          title: l10n.avatarPickerTitle,
                          items: [
                            ProfileSettingItem(
                              icon: Icons.camera_alt_outlined,
                              mainTitle: l10n.takeNewPhoto,
                              onTapAction: () =>
                                  _viewModel.pickFromCamera(),
                            ),
                            ProfileSettingItem(
                              icon: Icons.photo_library_outlined,
                              mainTitle: l10n.chooseFromLibrary,
                              onTapAction: () =>
                                  _viewModel.pickFromGallery(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: BtnLoginPrimary(
                    text: l10n.saveButton,
                    isLoading: _viewModel.isLoading,
                    onPressed: (_viewModel.isLoading || !_viewModel.hasNewImage)
                        ? null
                        : () async {
                            final path = await _viewModel.saveAvatar();
                            if (path != null && context.mounted) {
                              final profileVM = context.read<ProfileViewModel>();
                              profileVM.updateProfile(
                                profileVM.profile.copyWith(avatarUrl: path),
                              );
                              Navigator.of(context).pop();
                            }
                          },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
  Widget _buildAvatarImage(String? avatarUrl, ColorScheme colorScheme) {
    if (_viewModel.selectedImage != null) {
      return Image.file(
        _viewModel.selectedImage!,
        fit: BoxFit.cover,
      );
    }
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return Image.network(
        avatarUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, e, s) => _fallbackAvatar(colorScheme),
      );
    }
    return Image.asset(
      'assets/images/img_app_logo_ver2.png',
      fit: BoxFit.cover,
      errorBuilder: (_, e, s) => _fallbackAvatar(colorScheme),
    );
  }

  Widget _fallbackAvatar(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Icon(Icons.person, size: 48, color: colorScheme.onSurfaceVariant),
    );
  }
}
