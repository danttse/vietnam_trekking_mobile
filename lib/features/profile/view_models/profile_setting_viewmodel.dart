import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../core/widgets/sheet/select_language_sheet.dart';
import '../../../app/language/app_language_viewmodel.dart';
import '../../../core/services/auth_event_bus.dart';
import '../../../core/services/token_storage.dart';
import '../../../features/auth/repository/auth_repository.dart';
import '../views/change_password_screen.dart';
import '../views/edit_avatar_screen.dart';
import '../views/suggest_place_screen.dart';

// [BACKEND TEST TEMP IMPORTS - for screens dev frontend hasn't implemented yet]
import '../views/temp_test/support_feedback_screen.dart';
import '../views/temp_test/terms_of_use_screen.dart';
import '../views/temp_test/privacy_policy_screen.dart';

class ProfileSettingViewModel extends ChangeNotifier {
  final AppLanguageViewModel _appLanguageViewModel = AppLanguageViewModel();
  final AuthRepository _authRepository;
  final TokenStorage _tokenStorage;
  final AuthEventBus _eventBus;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  ProfileSettingViewModel({
    required this._authRepository,
    required this._tokenStorage,
    required this._eventBus,
  });

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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditAvatarScreen()),
    );
  }

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
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      await _authRepository.logout(refreshToken: refreshToken);
    } catch (e) {
      // Fail-safe: dù lỗi gì cũng vẫn đăng xuất phía local
      if (kDebugMode) {
        debugPrint('[ProfileSettingViewModel] logout error (ignored): $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    // Fire event → LoginScreen lắng nghe và điều hướng
    _eventBus.fire(AuthEvent.authExpired);
  }
}
