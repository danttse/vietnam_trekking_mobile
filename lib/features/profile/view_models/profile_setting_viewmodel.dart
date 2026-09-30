import 'package:flutter/material.dart';
import '../../../core/widgets/sheet/select_language_sheet.dart';
import '../../../app/language/app_language_viewmodel.dart';
import '../views/suggest_place_screen.dart';
import '../view_models/profile_viewmodel.dart';

// [BACKEND TEST TEMP IMPORTS]
import '../views/temp_test/change_avatar_screen.dart';
import '../views/temp_test/change_password_screen.dart';
import '../views/temp_test/edit_bio_screen.dart';
import '../views/temp_test/support_feedback_screen.dart';
import '../views/temp_test/terms_of_use_screen.dart';
import '../views/temp_test/privacy_policy_screen.dart';

class ProfileSettingViewModel extends ChangeNotifier {
  final AppLanguageViewModel _appLanguageViewModel = AppLanguageViewModel();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> changeLanguage(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SelectLanguageSheet(
        currentLocale: Localizations.localeOf(context).languageCode,
        onLanguageSelected: (code) {
          _appLanguageViewModel.changeLanguage(code);
        },
      ),
    );
  }

  Future<void> changeAvatar(BuildContext context) async {
    // Lấy avatar hiện tại từ ProfileViewModel nếu có
    final profileVm = ProfileViewModel();
    final currentAvatarUrl = profileVm.user?.avatarUrl;
    profileVm.dispose();

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeAvatarScreen(initialAvatarUrl: currentAvatarUrl),
      ),
    );

    // Nếu upload thành công, refresh ProfileViewModel ở màn hình trên
    if (result != null && context.mounted) {
      // Signal to rebuild — navigator pop sẽ trigger parent rebuild tự động
    }
  }

  Future<void> changeBio(BuildContext context) async {
    final profileVm = ProfileViewModel();
    final user = profileVm.user;
    profileVm.dispose();

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditBioScreen(
          initialName: user?.displayName ?? '',
          initialEmail: user?.email ?? '',
          initialBio: user?.bio ?? '',
          avatarUrl: user?.avatarUrl,
        ),
      ),
    );
  }

  // [BACKEND TEST TEMP NAVIGATION]
  Future<void> changePassword(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
    );
  }

  Future<void> suggestPlace(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SuggestPlaceScreen()),
    );
  }

  // [BACKEND TEST TEMP NAVIGATION]
  Future<void> supportAndFeedback(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SupportFeedbackScreen()),
    );
  }

  // [BACKEND TEST TEMP NAVIGATION]
  Future<void> openTermsOfUse(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TermsOfUseScreen()),
    );
  }

  // [BACKEND TEST TEMP NAVIGATION]
  Future<void> openPrivacyPolicy(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
    );
  }

  Future<void> logout() async {
    // TODO: Implement logout logic
  }
}
