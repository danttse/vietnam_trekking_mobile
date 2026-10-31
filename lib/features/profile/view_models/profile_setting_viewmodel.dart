import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets/sheet/select_language_sheet.dart';
import '../../../app/language/app_language_viewmodel.dart';
import '../../../app/theme/app_theme_viewmodel.dart';
import '../../../core/services/user_api_service.dart';
import '../../../core/services/auth_event_bus.dart';
import '../../../core/services/token_storage.dart';
import '../../../features/auth/repository/auth_repository.dart';
import '../../../features/auth/services/google_signin_service.dart';
import '../views/change_password_screen.dart';
import '../views/edit_avatar_screen.dart';
import '../views/suggest_place_screen.dart';
import '../views/support_feedback_screen.dart';
import '../../offline_map/presentation/views/offline_map_management_screen.dart';

class ProfileSettingViewModel extends ChangeNotifier {
  final UserApiService _api = UserApiService();
  String? error;
  bool _disposed = false;
  bool savingSettings = false;

  Future<void> loadSettings() async {
    try {
      final data =
          (await _api.auth.get('/users/me/settings')).data['data'] as Map;
      if (_disposed) return;
      _appLanguageViewModel.changeLanguage(data['language'] as String? ?? 'vi');
      AppThemeViewModel().setDarkMode(data['theme'] == 'dark');
    } catch (_) {
      if (!_disposed) {
        error = 'Không thể tải cài đặt.';
        notifyListeners();
      }
    }
  }

  Future<void> setTheme(bool dark) async {
    await _saveSettings({
      'theme': dark ? 'dark' : 'light',
    }, () => AppThemeViewModel().setDarkMode(dark));
  }

  Future<void> _saveSettings(
    Map<String, dynamic> values,
    VoidCallback apply,
  ) async {
    if (savingSettings) return;
    savingSettings = true;
    error = null;
    notifyListeners();
    try {
      await _api.auth.patch('/users/me/settings', data: values);
      if (!_disposed) apply();
    } catch (_) {
      if (!_disposed) error = 'Không thể lưu cài đặt. Vui lòng thử lại.';
    } finally {
      if (!_disposed) {
        savingSettings = false;
        notifyListeners();
      }
    }
  }

  final AppLanguageViewModel _appLanguageViewModel = AppLanguageViewModel();
  final AuthRepository _authRepository;
  final TokenStorage _tokenStorage;
  final AuthEventBus _eventBus;
  final GoogleSignInService _googleSignInService;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  ProfileSettingViewModel({
    required this._authRepository,
    required this._tokenStorage,
    required this._eventBus,
    GoogleSignInService? googleSignInService,
  }) : _googleSignInService = googleSignInService ?? GoogleSignInService();

  Future<void> changeLanguage(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SelectLanguageSheet(
        currentLocale: Localizations.localeOf(context).languageCode,
        onLanguageSelected: (code) {
          _saveSettings({
            'language': code,
          }, () => _appLanguageViewModel.changeLanguage(code));
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

  Future<void> supportAndFeedback(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SupportFeedbackScreen()),
    );
  }

  Future<void> openOfflineMapManagement(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OfflineMapManagementScreen()),
    );
  }

  Future<void> openTermsOfUse() async {
    // TODO: Implement open terms of use logic
  }

  Future<void> openPrivacyPolicy() async {
    // TODO: Implement open privacy policy logic
  }

  Future<void> logout() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      await _authRepository.logout(refreshToken: refreshToken);

      // QUAN TRỌNG: Sign out khỏi Google để clear cached credentials
      // Nếu không làm bước này, lần đăng nhập tiếp theo sẽ tự động dùng account cũ
      try {
        await _googleSignInService.signOut();
        if (kDebugMode) {
          debugPrint('[ProfileSettingViewModel] Google sign-out successful');
        }
      } catch (e) {
        // Google sign-out có thể fail nếu user chưa từng dùng Google login
        // Hoặc đã disconnect trước đó → ignore error
        if (kDebugMode) {
          debugPrint(
            '[ProfileSettingViewModel] Google sign-out error (ignored): $e',
          );
        }
      }
    } catch (e) {
      // Fail-safe: dù lỗi gì cũng vẫn đăng xuất phía local
      if (kDebugMode) {
        debugPrint('[ProfileSettingViewModel] logout error (ignored): $e');
      }
    } finally {
      _isLoading = false;
      if (!_disposed) notifyListeners();
    }

    // Fire event → LoginScreen lắng nghe và điều hướng
    _eventBus.fire(AuthEvent.loggedOut);
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
