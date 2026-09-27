// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'TrekViet';

  @override
  String get appTagline => 'Journey through Vietnam\'s thousand clouds';

  @override
  String get loginTitle => 'LOGIN';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'Enter your email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get loginButton => 'Login';

  @override
  String get loginWithGoogle => 'Login with Google';

  @override
  String get orDivider => 'Or';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get registerNow => 'Register now';

  @override
  String get registerTitle => 'REGISTER';

  @override
  String get fullNameLabel => 'Full name';

  @override
  String get fullNameHint => 'Enter your full name';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get confirmPasswordHint => 'Re-enter your password';

  @override
  String get agreeToTermsPrefix => 'I agree to the ';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get and => ' & ';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get registerButton => 'Register';

  @override
  String get registerWithGoogle => 'Register with Google';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get forgotPasswordTitle => 'Recover Password';

  @override
  String get resetPasswordTitle => 'Reset Password';

  @override
  String get forgotPasswordDescription =>
      'Enter your registered email below. We will\nsend you a secure link to reset\nyour new password.';

  @override
  String get sendResetLink => 'Send reset link';

  @override
  String get resetPasswordDescription =>
      'Please enter a new password for your account.';

  @override
  String get newPasswordLabel => 'New password';

  @override
  String get newPasswordHint => 'Enter new password';

  @override
  String get updatePasswordButton => 'Update password';

  @override
  String get backToLogin => 'Back to ';

  @override
  String get otpVerifiedSuccess =>
      'OTP verified! Please enter your new password.';

  @override
  String get updatePasswordSuccess =>
      'Password updated successfully! Please login again.';

  @override
  String get otpDialogTitle => 'Enter verification code';

  @override
  String get otpSentTo => 'OTP code has been sent to:';

  @override
  String get resendOtp => 'Resend code';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get confirmButton => 'Confirm';

  @override
  String get navHome => 'Home';

  @override
  String get navExplore => 'Explore';

  @override
  String get navCommunity => 'Community';

  @override
  String get navJourney => 'Journey';

  @override
  String get navProfile => 'Profile';

  @override
  String get featureInDevelopment => 'Feature is under development';

  @override
  String get homeRankLabel => 'RANK';

  @override
  String get homeStatProvinces => 'Provinces';

  @override
  String get homeStatDistance => 'Distance';

  @override
  String get homeStatTrips => 'Trips';

  @override
  String get homeRecentCheckin => 'Recent Check-Ins';

  @override
  String get provinceSheetTitle => 'Visited Provinces';

  @override
  String get regionNorth => 'North';

  @override
  String get regionCentral => 'Central';

  @override
  String get regionSouth => 'South';

  @override
  String get saveButton => 'Save';

  @override
  String get profileTitle => 'Profile';

  @override
  String memberSince(String date) {
    return 'Member since $date';
  }

  @override
  String get profileProvinceMapTitle => 'Province Map';

  @override
  String get profileProvinceUnit => 'provinces';

  @override
  String get profileStatTotalDistance => 'Total distance';

  @override
  String get profileStatVisitedProvinces => 'Provinces visited';

  @override
  String get profileStatCompletedTrips => 'Completed trips';

  @override
  String get profileStatTotalDays => 'Total days traveled';

  @override
  String get profileAchievementsTitle => 'YOUR ACHIEVEMENTS';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsGroupAccount => 'ACCOUNT';

  @override
  String get settingsChangePassword => 'Change password';

  @override
  String get settingsChangeLanguage => 'Change language';

  @override
  String get settingsChangeAvatar => 'Change avatar';

  @override
  String get settingsGroupAppearance => 'APPEARANCE';

  @override
  String get settingsDarkMode => 'Dark mode';

  @override
  String get settingsGroupContribute => 'CONTRIBUTE';

  @override
  String get settingsSuggestPlace => 'Suggest a new place';

  @override
  String get settingsSupportFeedback => 'Support & Feedback';

  @override
  String get settingsGroupOther => 'OTHER';

  @override
  String get settingsTermsOfUse => 'Terms of Use';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get logoutButton => 'Logout';

  @override
  String get proposePlace => 'Suggest a new location';

  @override
  String get submitPropose => 'Submit suggestion';

  @override
  String get placeName => 'Place name';

  @override
  String get enterPlaceName => 'Enter place name';

  @override
  String get provinceCity => 'Province/City';

  @override
  String get gpsCoordinates => 'GPS Coordinates';

  @override
  String get getCurrentLocation => 'Get current location';

  @override
  String get elevation => 'Elevation (m)';

  @override
  String get difficulty => 'Difficulty';

  @override
  String get placeDescription => 'Place description';

  @override
  String get enterPlaceDescription =>
      'Enter detailed information about the trail or notes for trekking at this location...';

  @override
  String get addImages => 'Add images';

  @override
  String get addPhoto => '+ Add photo';

  @override
  String get suggestionNotice =>
      'Your suggestion will be sent to the administrator\'s email for review and approval before being officially added to the TrekViệt map.';

  @override
  String featureComingSoon(String feature) {
    return 'Feature $feature is under development';
  }
}
