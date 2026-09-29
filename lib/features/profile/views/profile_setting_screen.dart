import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../app/theme/app_theme_viewmodel.dart';
import '../view_models/profile_viewmodel.dart';
import '../view_models/profile_setting_viewmodel.dart';
import '../widgets/profile_widgets.dart';
import '../../../core/widgets/buttons/btn_outline_style.dart';

class ProfileSettingScreen extends StatefulWidget {
  const ProfileSettingScreen({super.key});

  @override
  State<ProfileSettingScreen> createState() => _ProfileSettingScreenState();
}

class _ProfileSettingScreenState extends State<ProfileSettingScreen> {
  final ProfileViewModel _profileViewModel = ProfileViewModel();
  final AppThemeViewModel _themeViewModel = AppThemeViewModel();
  final ProfileSettingViewModel _settingViewModel = ProfileSettingViewModel();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final profile = _profileViewModel.profile;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.settingsTitle,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
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
              const SizedBox(height: 20),
              //Nhom 1 tai khoan
              ProfileSettingGroupItem(
                title: l10n.settingsGroupAccount,
                items: [
                  ProfileSettingItem(
                    mainTitle: l10n.settingsChangePassword,
                    icon: Icons.lock_outline,
                    onTapAction: () => _settingViewModel.changePassword(context),
                  ),
                  ProfileSettingItem(
                    mainTitle: l10n.settingsChangeLanguage,
                    icon: Icons.language,
                    onTapAction: () => _settingViewModel.changeLanguage(context),
                  ),
                  ProfileSettingItem(
                    mainTitle: l10n.settingsChangeAvatar,
                    icon: Icons.photo_camera_outlined,
                    onTapAction: () => _settingViewModel.changeAvatar(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              //Nhom 2 Giao dien
              ListenableBuilder(
                listenable: _themeViewModel,
                builder: (context, _) => ProfileSettingGroupItem(
                  title: l10n.settingsGroupAppearance,
                  items: [
                    ProfileSettingItem(
                      mainTitle: l10n.settingsDarkMode,
                      icon: Icons.dark_mode_outlined,
                      trailing: Switch.adaptive(
                        value: _themeViewModel.isDarkMode,
                        activeTrackColor: colorScheme.primary,
                        onChanged: (value) => _themeViewModel.setDarkMode(value),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Nhom 3 Dong gop
              ProfileSettingGroupItem(
                title: l10n.settingsGroupContribute,
                items: [
                  ProfileSettingItem(
                    mainTitle: l10n.settingsSuggestPlace,
                    icon: Icons.place_outlined,
                    onTapAction: () => _settingViewModel.suggestPlace(context),
                  ),
                  ProfileSettingItem(
                    mainTitle: l10n.settingsSupportFeedback,
                    icon: Icons.help_outline,
                    onTapAction: () {},
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Group 4: KHÁC
              ProfileSettingGroupItem(
                title: l10n.settingsGroupOther,
                items: [
                  ProfileSettingItem(
                    mainTitle: l10n.settingsTermsOfUse,
                    icon: Icons.description_outlined,
                    onTapAction: () {},
                  ),
                  ProfileSettingItem(
                    mainTitle: l10n.settingsPrivacyPolicy,
                    icon: Icons.privacy_tip_outlined,
                    onTapAction: () {},
                  ),
                ],
              ),
              const SizedBox(height: 12),
              BtnOutlineStyle(
                text: l10n.logoutButton,
                icon: const Icon(Icons.exit_to_app),
                onPressed: () => _settingViewModel.logout(),
              ),
              const SizedBox(height: 8)
            ],
          ),
        ),
      ),
    );
  }
}
