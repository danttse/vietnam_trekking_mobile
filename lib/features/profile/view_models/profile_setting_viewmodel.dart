import 'package:flutter/material.dart';
import '../../../core/widgets/sheet/select_language_sheet.dart';
import '../../../app/language/app_language_viewmodel.dart';
import '../views/suggest_place_screen.dart';

class ProfileSettingViewModel extends ChangeNotifier {
  final AppLanguageViewModel _appLanguageViewModel=AppLanguageViewModel();
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

  Future<void> changeAvatar() async {
    // TODO: Implement change avatar logic
  }

  Future<void> suggestPlace(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SuggestPlaceScreen()),
    );
  }

  Future<void> supportAndFeedback() async {
    // TODO: Implement support & feedback logic
  }

  Future<void> openTermsOfUse() async {
    // TODO: Implement open terms of use logic
  }

  Future<void> openPrivacyPolicy() async {
    // TODO: Implement open privacy policy logic
  }

  Future<void> logout() async {
    // TODO: Implement logout logic (clear token, navigate to login, etc.)
  }
}
