import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @appName.
  ///
  /// In vi, this message translates to:
  /// **'TrekViệt'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In vi, this message translates to:
  /// **'Hành trình mây ngàn Việt Nam'**
  String get appTagline;

  /// No description provided for @loginTitle.
  ///
  /// In vi, this message translates to:
  /// **'ĐĂNG NHẬP'**
  String get loginTitle;

  /// No description provided for @emailLabel.
  ///
  /// In vi, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập email'**
  String get emailHint;

  /// No description provided for @passwordLabel.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập mật khẩu'**
  String get passwordHint;

  /// No description provided for @forgotPassword.
  ///
  /// In vi, this message translates to:
  /// **'Quên mật khẩu?'**
  String get forgotPassword;

  /// No description provided for @loginButton.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập'**
  String get loginButton;

  /// No description provided for @loginWithGoogle.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập với Google'**
  String get loginWithGoogle;

  /// No description provided for @orDivider.
  ///
  /// In vi, this message translates to:
  /// **'Hoặc'**
  String get orDivider;

  /// No description provided for @noAccount.
  ///
  /// In vi, this message translates to:
  /// **'Bạn chưa có tài khoản?'**
  String get noAccount;

  /// No description provided for @registerNow.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký ngay'**
  String get registerNow;

  /// No description provided for @registerTitle.
  ///
  /// In vi, this message translates to:
  /// **'ĐĂNG KÝ'**
  String get registerTitle;

  /// No description provided for @fullNameLabel.
  ///
  /// In vi, this message translates to:
  /// **'Họ và tên'**
  String get fullNameLabel;

  /// No description provided for @fullNameHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập họ và tên'**
  String get fullNameHint;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận mật khẩu'**
  String get confirmPasswordLabel;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập lại mật khẩu'**
  String get confirmPasswordHint;

  /// No description provided for @agreeToTermsPrefix.
  ///
  /// In vi, this message translates to:
  /// **'Tôi đồng ý với '**
  String get agreeToTermsPrefix;

  /// No description provided for @termsOfService.
  ///
  /// In vi, this message translates to:
  /// **'Điều khoản dịch vụ'**
  String get termsOfService;

  /// No description provided for @and.
  ///
  /// In vi, this message translates to:
  /// **' & '**
  String get and;

  /// No description provided for @privacyPolicy.
  ///
  /// In vi, this message translates to:
  /// **'Chính sách bảo mật'**
  String get privacyPolicy;

  /// No description provided for @registerButton.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký'**
  String get registerButton;

  /// No description provided for @registerWithGoogle.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký với Google'**
  String get registerWithGoogle;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đã có tài khoản?'**
  String get alreadyHaveAccount;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In vi, this message translates to:
  /// **'Khôi phục mật khẩu'**
  String get forgotPasswordTitle;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đặt lại mật khẩu'**
  String get resetPasswordTitle;

  /// No description provided for @forgotPasswordDescription.
  ///
  /// In vi, this message translates to:
  /// **'Nhập email đã đăng ký của bạn bên dưới. Chúng tôi\nsẽ gửi một liên kết an toàn để bạn đặt lại\nmật khẩu mới.'**
  String get forgotPasswordDescription;

  /// No description provided for @sendResetLink.
  ///
  /// In vi, this message translates to:
  /// **'Gửi liên kết đặt lại'**
  String get sendResetLink;

  /// No description provided for @resetPasswordDescription.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập mật khẩu mới cho tài khoản của bạn.'**
  String get resetPasswordDescription;

  /// No description provided for @newPasswordLabel.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu mới'**
  String get newPasswordLabel;

  /// No description provided for @newPasswordHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập mật khẩu mới'**
  String get newPasswordHint;

  /// No description provided for @updatePasswordButton.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật mật khẩu'**
  String get updatePasswordButton;

  /// No description provided for @backToLogin.
  ///
  /// In vi, this message translates to:
  /// **'Quay lại '**
  String get backToLogin;

  /// No description provided for @otpVerifiedSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Xác thực OTP thành công! Vui lòng nhập mật khẩu mới.'**
  String get otpVerifiedSuccess;

  /// No description provided for @updatePasswordSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật mật khẩu thành công! Vui lòng đăng nhập lại.'**
  String get updatePasswordSuccess;

  /// No description provided for @otpDialogTitle.
  ///
  /// In vi, this message translates to:
  /// **'Nhập mã xác thực'**
  String get otpDialogTitle;

  /// No description provided for @otpSentTo.
  ///
  /// In vi, this message translates to:
  /// **'Mã OTP đã được gửi đến:'**
  String get otpSentTo;

  /// No description provided for @resendOtp.
  ///
  /// In vi, this message translates to:
  /// **'Gửi lại mã'**
  String get resendOtp;

  /// No description provided for @cancelButton.
  ///
  /// In vi, this message translates to:
  /// **'Hủy'**
  String get cancelButton;

  /// No description provided for @confirmButton.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận'**
  String get confirmButton;

  /// No description provided for @navHome.
  ///
  /// In vi, this message translates to:
  /// **'Trang chủ'**
  String get navHome;

  /// No description provided for @navExplore.
  ///
  /// In vi, this message translates to:
  /// **'Khám phá'**
  String get navExplore;

  /// No description provided for @navCommunity.
  ///
  /// In vi, this message translates to:
  /// **'Cộng đồng'**
  String get navCommunity;

  /// No description provided for @navJourney.
  ///
  /// In vi, this message translates to:
  /// **'Hành trình'**
  String get navJourney;

  /// No description provided for @navProfile.
  ///
  /// In vi, this message translates to:
  /// **'Hồ sơ'**
  String get navProfile;

  /// No description provided for @featureInDevelopment.
  ///
  /// In vi, this message translates to:
  /// **'Tính năng đang được phát triển'**
  String get featureInDevelopment;

  /// No description provided for @homeRankLabel.
  ///
  /// In vi, this message translates to:
  /// **'PHÂN HẠNG'**
  String get homeRankLabel;

  /// No description provided for @homeStatProvinces.
  ///
  /// In vi, this message translates to:
  /// **'Tỉnh thành'**
  String get homeStatProvinces;

  /// No description provided for @homeStatDistance.
  ///
  /// In vi, this message translates to:
  /// **'Quãng đường'**
  String get homeStatDistance;

  /// No description provided for @homeStatTrips.
  ///
  /// In vi, this message translates to:
  /// **'Chuyến đi'**
  String get homeStatTrips;

  /// No description provided for @homeRecentCheckin.
  ///
  /// In vi, this message translates to:
  /// **'Check-In gần đây'**
  String get homeRecentCheckin;

  /// No description provided for @provinceSheetTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tỉnh thành đã đi'**
  String get provinceSheetTitle;

  /// No description provided for @regionNorth.
  ///
  /// In vi, this message translates to:
  /// **'Miền Bắc'**
  String get regionNorth;

  /// No description provided for @regionCentral.
  ///
  /// In vi, this message translates to:
  /// **'Miền Trung'**
  String get regionCentral;

  /// No description provided for @regionSouth.
  ///
  /// In vi, this message translates to:
  /// **'Miền Nam'**
  String get regionSouth;

  /// No description provided for @saveButton.
  ///
  /// In vi, this message translates to:
  /// **'Lưu'**
  String get saveButton;

  /// No description provided for @profileTitle.
  ///
  /// In vi, this message translates to:
  /// **'Hồ Sơ'**
  String get profileTitle;

  /// No description provided for @memberSince.
  ///
  /// In vi, this message translates to:
  /// **'Thành viên từ {date}'**
  String memberSince(String date);

  /// No description provided for @profileProvinceMapTitle.
  ///
  /// In vi, this message translates to:
  /// **'Bản đồ tỉnh thành'**
  String get profileProvinceMapTitle;

  /// No description provided for @profileProvinceUnit.
  ///
  /// In vi, this message translates to:
  /// **'tỉnh'**
  String get profileProvinceUnit;

  /// No description provided for @profileStatTotalDistance.
  ///
  /// In vi, this message translates to:
  /// **'Tổng quãng đường'**
  String get profileStatTotalDistance;

  /// No description provided for @profileStatVisitedProvinces.
  ///
  /// In vi, this message translates to:
  /// **'Tỉnh thành đi qua'**
  String get profileStatVisitedProvinces;

  /// No description provided for @profileStatCompletedTrips.
  ///
  /// In vi, this message translates to:
  /// **'Chuyến đi hoàn thành'**
  String get profileStatCompletedTrips;

  /// No description provided for @profileStatTotalDays.
  ///
  /// In vi, this message translates to:
  /// **'Tổng số ngày đi'**
  String get profileStatTotalDays;

  /// No description provided for @profileAchievementsTitle.
  ///
  /// In vi, this message translates to:
  /// **'DANH HIỆU CỦA BẠN'**
  String get profileAchievementsTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Cài Đặt'**
  String get settingsTitle;

  /// No description provided for @settingsGroupAccount.
  ///
  /// In vi, this message translates to:
  /// **'TÀI KHOẢN'**
  String get settingsGroupAccount;

  /// No description provided for @settingsChangePassword.
  ///
  /// In vi, this message translates to:
  /// **'Đổi mật khẩu'**
  String get settingsChangePassword;

  /// No description provided for @settingsChangeLanguage.
  ///
  /// In vi, this message translates to:
  /// **'Đổi ngôn ngữ'**
  String get settingsChangeLanguage;

  /// No description provided for @settingsChangeAvatar.
  ///
  /// In vi, this message translates to:
  /// **'Đổi ảnh đại diện'**
  String get settingsChangeAvatar;

  /// No description provided for @settingsGroupAppearance.
  ///
  /// In vi, this message translates to:
  /// **'GIAO DIỆN'**
  String get settingsGroupAppearance;

  /// No description provided for @settingsDarkMode.
  ///
  /// In vi, this message translates to:
  /// **'Chế độ tối'**
  String get settingsDarkMode;

  /// No description provided for @settingsGroupContribute.
  ///
  /// In vi, this message translates to:
  /// **'ĐÓNG GÓP'**
  String get settingsGroupContribute;

  /// No description provided for @settingsSuggestPlace.
  ///
  /// In vi, this message translates to:
  /// **'Đề xuất địa điểm mới'**
  String get settingsSuggestPlace;

  /// No description provided for @settingsSupportFeedback.
  ///
  /// In vi, this message translates to:
  /// **'Hỗ trợ & Phản hồi'**
  String get settingsSupportFeedback;

  /// No description provided for @settingsGroupOther.
  ///
  /// In vi, this message translates to:
  /// **'KHÁC'**
  String get settingsGroupOther;

  /// No description provided for @settingsTermsOfUse.
  ///
  /// In vi, this message translates to:
  /// **'Điều khoản sử dụng'**
  String get settingsTermsOfUse;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In vi, this message translates to:
  /// **'Chính sách quyền riêng tư'**
  String get settingsPrivacyPolicy;

  /// No description provided for @logoutButton.
  ///
  /// In vi, this message translates to:
  /// **'Đăng xuất'**
  String get logoutButton;

  /// No description provided for @proposePlace.
  ///
  /// In vi, this message translates to:
  /// **'Đề xuất địa điểm mới'**
  String get proposePlace;

  /// No description provided for @submitPropose.
  ///
  /// In vi, this message translates to:
  /// **'Gửi đề xuất'**
  String get submitPropose;

  /// No description provided for @placeName.
  ///
  /// In vi, this message translates to:
  /// **'Tên địa điểm'**
  String get placeName;

  /// No description provided for @enterPlaceName.
  ///
  /// In vi, this message translates to:
  /// **'Nhập tên địa điểm'**
  String get enterPlaceName;

  /// No description provided for @provinceCity.
  ///
  /// In vi, this message translates to:
  /// **'Tỉnh/Thành phố'**
  String get provinceCity;

  /// No description provided for @gpsCoordinates.
  ///
  /// In vi, this message translates to:
  /// **'Tọa độ GPS'**
  String get gpsCoordinates;

  /// No description provided for @getCurrentLocation.
  ///
  /// In vi, this message translates to:
  /// **'Lấy vị trí hiện tại'**
  String get getCurrentLocation;

  /// No description provided for @elevation.
  ///
  /// In vi, this message translates to:
  /// **'Độ cao (m)'**
  String get elevation;

  /// No description provided for @difficulty.
  ///
  /// In vi, this message translates to:
  /// **'Độ khó'**
  String get difficulty;

  /// No description provided for @placeDescription.
  ///
  /// In vi, this message translates to:
  /// **'Mô tả địa điểm'**
  String get placeDescription;

  /// No description provided for @enterPlaceDescription.
  ///
  /// In vi, this message translates to:
  /// **'Nhập thông tin mô tả chi tiết cung đường hoặc lưu ý khi trekking tại địa điểm này...'**
  String get enterPlaceDescription;

  /// No description provided for @addImages.
  ///
  /// In vi, this message translates to:
  /// **'Thêm hình ảnh'**
  String get addImages;

  /// No description provided for @addPhoto.
  ///
  /// In vi, this message translates to:
  /// **'+ Thêm ảnh'**
  String get addPhoto;

  /// No description provided for @suggestionNotice.
  ///
  /// In vi, this message translates to:
  /// **'Đề xuất của bạn sẽ được gửi về email quản trị viên để xem xét phê duyệt và cập nhật chính thức trên bản đồ TrekViệt.'**
  String get suggestionNotice;

  /// No description provided for @featuredDestinations.
  ///
  /// In vi, this message translates to:
  /// **'Điểm đến nổi bật'**
  String get featuredDestinations;

  /// No description provided for @popularTrails.
  ///
  /// In vi, this message translates to:
  /// **'Cung đường phổ biến'**
  String get popularTrails;

  /// No description provided for @recommendedForYou.
  ///
  /// In vi, this message translates to:
  /// **'Gợi ý dành cho bạn'**
  String get recommendedForYou;

  /// No description provided for @searchTrailsPlaces.
  ///
  /// In vi, this message translates to:
  /// **'Tìm cung đường, địa danh trekking...'**
  String get searchTrailsPlaces;

  /// No description provided for @seeAll.
  ///
  /// In vi, this message translates to:
  /// **'Xem tất cả'**
  String get seeAll;

  /// No description provided for @north.
  ///
  /// In vi, this message translates to:
  /// **'Miền Bắc'**
  String get north;

  /// No description provided for @central.
  ///
  /// In vi, this message translates to:
  /// **'Miền Trung'**
  String get central;

  /// No description provided for @south.
  ///
  /// In vi, this message translates to:
  /// **'Miền Nam'**
  String get south;

  /// No description provided for @popular.
  ///
  /// In vi, this message translates to:
  /// **'Phổ biến'**
  String get popular;

  /// No description provided for @editBio.
  ///
  /// In vi, this message translates to:
  /// **'Chỉnh sửa Bio'**
  String get editBio;

  /// No description provided for @titleBioBox.
  ///
  /// In vi, this message translates to:
  /// **'Giới thiệu bản thân (BIO)'**
  String get titleBioBox;

  /// No description provided for @editAvatar.
  ///
  /// In vi, this message translates to:
  /// **'Đổi Ảnh Đại Diện'**
  String get editAvatar;

  /// No description provided for @avatarPickerTitle.
  ///
  /// In vi, this message translates to:
  /// **'TÙY CHỌN TẢI ẢNH'**
  String get avatarPickerTitle;

  /// No description provided for @takeNewPhoto.
  ///
  /// In vi, this message translates to:
  /// **'Chụp ảnh mới'**
  String get takeNewPhoto;

  /// No description provided for @chooseFromLibrary.
  ///
  /// In vi, this message translates to:
  /// **'Chọn từ thư viện'**
  String get chooseFromLibrary;

  /// No description provided for @featureComingSoon.
  ///
  /// In vi, this message translates to:
  /// **'Tính năng {feature} đang phát triển'**
  String featureComingSoon(String feature);

  /// No description provided for @changePasswordTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đổi Mật Khẩu'**
  String get changePasswordTitle;

  /// No description provided for @currentPasswordLabel.
  ///
  /// In vi, this message translates to:
  /// **'MẬT KHẨU HIỆN TẠI'**
  String get currentPasswordLabel;

  /// No description provided for @currentPasswordHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập mật khẩu hiện tại'**
  String get currentPasswordHint;

  /// No description provided for @newPasswordLabelUpper.
  ///
  /// In vi, this message translates to:
  /// **'MẬT KHẨU MỚI'**
  String get newPasswordLabelUpper;

  /// No description provided for @confirmNewPasswordLabelUpper.
  ///
  /// In vi, this message translates to:
  /// **'XÁC NHẬN MẬT KHẨU MỚI'**
  String get confirmNewPasswordLabelUpper;

  /// No description provided for @confirmNewPasswordHint.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận lại mật khẩu mới'**
  String get confirmNewPasswordHint;

  /// No description provided for @pleaseFillAllFields.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập đầy đủ thông tin'**
  String get pleaseFillAllFields;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu xác nhận không khớp'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordTooShort.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu phải có ít nhất 6 ký tự'**
  String get passwordTooShort;

  /// No description provided for @changePasswordSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đổi mật khẩu thành công!'**
  String get changePasswordSuccess;

  /// No description provided for @createNewPostHintText.
  ///
  /// In vi, this message translates to:
  /// **'Chia sẻ trải nghiệm trekking của bạn'**
  String get createNewPostHintText;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
