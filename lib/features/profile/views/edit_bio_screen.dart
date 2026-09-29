import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vietnam_trekking_mobile/core/widgets/app_bar/app_top_bar_with_back.dart';
import 'package:vietnam_trekking_mobile/core/widgets/buttons/btn_login_style.dart';
import 'package:vietnam_trekking_mobile/features/profile/view_models/edit_bio_viewmodel.dart';
import '../../../l10n/app_localizations.dart';
import '../view_models/profile_viewmodel.dart';
import '../widgets/profile_widgets.dart';

class EditBioScreen extends StatefulWidget {
  const EditBioScreen({super.key});

  @override
  State<EditBioScreen> createState() => _EditBioScreenState();
}

class _EditBioScreenState extends State<EditBioScreen> {
  late final EditBioViewModel _editBioViewModel;

  @override
  void initState() {
    super.initState();
    // Lấy profile hiện tại từ Provider (read = không subscribe, chỉ lấy 1 lần)
    final currentBio = context.read<ProfileViewModel>().profile.bio;
    _editBioViewModel = EditBioViewModel()..initBio(currentBio);
  }

  @override
  void dispose() {
    _editBioViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    // watch → lấy profile mới nhất để hiển thị header card
    final profile = context.watch<ProfileViewModel>().profile;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTopBarWithBack(title: l10n.editBio),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.15),
                          width: 1,
                        ),
                      ),
                      child: ProfileHeaderCard(
                        name: profile.name,
                        isPro: profile.isPro,
                        memberSince: l10n.memberSince(profile.memberSince),
                        bio: profile.bio,
                        subTitle: profile.email,
                        avatarUrl: profile.avatarUrl,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.titleBioBox,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListenableBuilder(
                      listenable: _editBioViewModel,
                      builder: (context, _) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: TextField(
                                style: const TextStyle(fontSize: 12),
                                controller: _editBioViewModel.bioController,
                                textInputAction: TextInputAction.done,
                                maxLines: 4,
                                decoration: InputDecoration(
                                  hintText: l10n.searchTrailsPlaces,
                                  filled: true,
                                  fillColor: colorScheme.surfaceContainerHighest,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  errorText: _editBioViewModel.errorMessage,
                                  suffixIcon: _editBioViewModel.bioController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear),
                                          onPressed: _editBioViewModel.clearBio,
                                        )
                                      : null,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: Text(
                                '${_editBioViewModel.charCount}/${EditBioViewModel.maxBioLength}',
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _editBioViewModel.isOverLimit
                                      ? colorScheme.error
                                      : colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            ListenableBuilder(
              listenable: _editBioViewModel,
              builder: (context, _) => Padding(
                padding: const EdgeInsets.all(16.0),
                child: BtnLoginPrimary(
                  text: l10n.saveButton,
                  isLoading: _editBioViewModel.isLoading,
                  onPressed: _editBioViewModel.isLoading
                      ? null
                      : () => _editBioViewModel.saveBio(
                            currentProfile: profile,
                            onSaved: context.read<ProfileViewModel>().updateProfile,
                            context: context,
                          ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}