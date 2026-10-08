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
  /// **'Tính năng sắp ra mắt'**
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

  /// No description provided for @communityTabPosts.
  ///
  /// In vi, this message translates to:
  /// **'Bài viết'**
  String get communityTabPosts;

  /// No description provided for @communityTabGroups.
  ///
  /// In vi, this message translates to:
  /// **'Nhóm'**
  String get communityTabGroups;

  /// No description provided for @communityTabPersonal.
  ///
  /// In vi, this message translates to:
  /// **'Cá nhân'**
  String get communityTabPersonal;

  /// No description provided for @postHideThis.
  ///
  /// In vi, this message translates to:
  /// **'Ẩn bài viết này'**
  String get postHideThis;

  /// No description provided for @postHideSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Bớt nhìn thấy các bài viết tương tự trên bảng tin'**
  String get postHideSubtitle;

  /// No description provided for @postHiddenMessage.
  ///
  /// In vi, this message translates to:
  /// **'Đã ẩn bài viết'**
  String get postHiddenMessage;

  /// No description provided for @undo.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn tác'**
  String get undo;

  /// No description provided for @postHideAllFrom.
  ///
  /// In vi, this message translates to:
  /// **'Ẩn tất cả từ {authorName}'**
  String postHideAllFrom(String authorName);

  /// No description provided for @thisPerson.
  ///
  /// In vi, this message translates to:
  /// **'người này'**
  String get thisPerson;

  /// No description provided for @postReport.
  ///
  /// In vi, this message translates to:
  /// **'Báo cáo bài viết'**
  String get postReport;

  /// No description provided for @postReportSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Cảm ơn bạn đã gửi báo cáo. Chúng tôi sẽ xem xét nội dung này.'**
  String get postReportSuccess;

  /// No description provided for @communityNoPosts.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có bài viết nào'**
  String get communityNoPosts;

  /// No description provided for @commentsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Bình luận'**
  String get commentsTitle;

  /// No description provided for @noCommentsYet.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có bình luận nào'**
  String get noCommentsYet;

  /// No description provided for @beFirstToComment.
  ///
  /// In vi, this message translates to:
  /// **'Hãy là người đầu tiên bình luận!'**
  String get beFirstToComment;

  /// No description provided for @replyingTo.
  ///
  /// In vi, this message translates to:
  /// **'Đang trả lời {userName}'**
  String replyingTo(String userName);

  /// No description provided for @replyToHint.
  ///
  /// In vi, this message translates to:
  /// **'Trả lời @{userName}...'**
  String replyToHint(String userName);

  /// No description provided for @writeCommentHint.
  ///
  /// In vi, this message translates to:
  /// **'Viết bình luận...'**
  String get writeCommentHint;

  /// No description provided for @journeyCompleted.
  ///
  /// In vi, this message translates to:
  /// **'Đã hoàn thành'**
  String get journeyCompleted;

  /// No description provided for @journeyUpcoming.
  ///
  /// In vi, this message translates to:
  /// **'Sắp tới'**
  String get journeyUpcoming;

  /// No description provided for @journeyStatTrips.
  ///
  /// In vi, this message translates to:
  /// **'Chuyến đi'**
  String get journeyStatTrips;

  /// No description provided for @journeyStatDistance.
  ///
  /// In vi, this message translates to:
  /// **'Quãng đường'**
  String get journeyStatDistance;

  /// No description provided for @journeyStatCompanions.
  ///
  /// In vi, this message translates to:
  /// **'Người đồng hành'**
  String get journeyStatCompanions;

  /// No description provided for @journeyEmptyList.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có hành trình nào'**
  String get journeyEmptyList;

  /// No description provided for @createNewJourneyTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tạo hành trình mới'**
  String get createNewJourneyTitle;

  /// No description provided for @journeyNameLabel.
  ///
  /// In vi, this message translates to:
  /// **'Tên chuyến đi'**
  String get journeyNameLabel;

  /// No description provided for @journeyNameHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập tên chuyến đi'**
  String get journeyNameHint;

  /// No description provided for @journeyStartDateLabel.
  ///
  /// In vi, this message translates to:
  /// **'Ngày bắt đầu'**
  String get journeyStartDateLabel;

  /// No description provided for @journeyEndDateLabel.
  ///
  /// In vi, this message translates to:
  /// **'Ngày kết thúc'**
  String get journeyEndDateLabel;

  /// No description provided for @participantCountLabel.
  ///
  /// In vi, this message translates to:
  /// **'Số người tham gia'**
  String get participantCountLabel;

  /// No description provided for @participantCountHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập số người tham gia'**
  String get participantCountHint;

  /// No description provided for @journeyNoteLabel.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú/Mô tả'**
  String get journeyNoteLabel;

  /// No description provided for @journeyNoteHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập ghi chú hoặc mô tả cho chuyến đi'**
  String get journeyNoteHint;

  /// No description provided for @selectRouteLabel.
  ///
  /// In vi, this message translates to:
  /// **'Tuyến đường'**
  String get selectRouteLabel;

  /// No description provided for @selectRouteHint.
  ///
  /// In vi, this message translates to:
  /// **'Chọn tuyến đường trekking'**
  String get selectRouteHint;

  /// No description provided for @selectRouteSheetTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chọn tuyến đường'**
  String get selectRouteSheetTitle;

  /// No description provided for @createJourneyButton.
  ///
  /// In vi, this message translates to:
  /// **'Tạo hành trình'**
  String get createJourneyButton;

  /// No description provided for @createJourneySuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đã tạo hành trình thành công!'**
  String get createJourneySuccess;

  /// No description provided for @milestonesSectionTitle.
  ///
  /// In vi, this message translates to:
  /// **'CÁC MỐC HÀNH TRÌNH'**
  String get milestonesSectionTitle;

  /// No description provided for @milestoneCheckedIn.
  ///
  /// In vi, this message translates to:
  /// **'Đã check-in'**
  String get milestoneCheckedIn;

  /// No description provided for @milestoneNotCheckedIn.
  ///
  /// In vi, this message translates to:
  /// **'Chưa đến'**
  String get milestoneNotCheckedIn;

  /// No description provided for @milestoneCheckInButton.
  ///
  /// In vi, this message translates to:
  /// **'Check In'**
  String get milestoneCheckInButton;

  /// No description provided for @milestoneAltitude.
  ///
  /// In vi, this message translates to:
  /// **'{altitude} m so mực nước biển'**
  String milestoneAltitude(String altitude);

  /// No description provided for @milestoneProgress.
  ///
  /// In vi, this message translates to:
  /// **'{checked}/{total} mốc'**
  String milestoneProgress(int checked, int total);

  /// No description provided for @journeyDetailMapTitle.
  ///
  /// In vi, this message translates to:
  /// **'BẢN ĐỒ LỘ TRÌNH'**
  String get journeyDetailMapTitle;

  /// No description provided for @journeyDetailDownloadMap.
  ///
  /// In vi, this message translates to:
  /// **'Tải bản đồ Offline'**
  String get journeyDetailDownloadMap;

  /// No description provided for @journeyDetailViewMap.
  ///
  /// In vi, this message translates to:
  /// **'Xem bản đồ Offline'**
  String get journeyDetailViewMap;

  /// No description provided for @journeyActionStart.
  ///
  /// In vi, this message translates to:
  /// **'Bắt đầu hành trình'**
  String get journeyActionStart;

  /// No description provided for @journeyActionPause.
  ///
  /// In vi, this message translates to:
  /// **'Tạm dừng hành trình'**
  String get journeyActionPause;

  /// No description provided for @journeyActionResume.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp tục hành trình'**
  String get journeyActionResume;

  /// No description provided for @journeyActionViewMap.
  ///
  /// In vi, this message translates to:
  /// **'Xem bản đồ'**
  String get journeyActionViewMap;

  /// No description provided for @journeyRemainingTime.
  ///
  /// In vi, this message translates to:
  /// **'Thời gian còn lại'**
  String get journeyRemainingTime;

  /// No description provided for @journeyCurrentElevation.
  ///
  /// In vi, this message translates to:
  /// **'Độ cao hiện tại'**
  String get journeyCurrentElevation;

  /// No description provided for @journeyProgressTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tiến trình hành trình'**
  String get journeyProgressTitle;

  /// No description provided for @journeyCheckinPoints.
  ///
  /// In vi, this message translates to:
  /// **'Điểm check-in'**
  String get journeyCheckinPoints;

  /// No description provided for @journeyStatusPlanned.
  ///
  /// In vi, this message translates to:
  /// **'DỰ KIẾN'**
  String get journeyStatusPlanned;

  /// No description provided for @journeyStatusActive.
  ///
  /// In vi, this message translates to:
  /// **'ĐANG ĐI'**
  String get journeyStatusActive;

  /// No description provided for @journeyStatusPaused.
  ///
  /// In vi, this message translates to:
  /// **'TẠM DỪNG'**
  String get journeyStatusPaused;

  /// No description provided for @journeyStatusCompleted.
  ///
  /// In vi, this message translates to:
  /// **'HOÀN THÀNH'**
  String get journeyStatusCompleted;

  /// No description provided for @journeyStatusCancelled.
  ///
  /// In vi, this message translates to:
  /// **'ĐÃ HỦY'**
  String get journeyStatusCancelled;

  /// No description provided for @downloadOfflineMapTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tải bản đồ Offline'**
  String get downloadOfflineMapTitle;

  /// No description provided for @downloadOfflineMapSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Lưu trữ dữ liệu địa hình ngoại tuyến để đề phòng mất sóng.'**
  String get downloadOfflineMapSubtitle;

  /// No description provided for @downloading.
  ///
  /// In vi, this message translates to:
  /// **'ĐANG TẢI...'**
  String get downloading;

  /// No description provided for @cancelDownload.
  ///
  /// In vi, this message translates to:
  /// **'Hủy tải xuống'**
  String get cancelDownload;

  /// No description provided for @mapDataHeader.
  ///
  /// In vi, this message translates to:
  /// **'Dữ liệu {name} Map'**
  String mapDataHeader(String name);

  /// No description provided for @mapLabel.
  ///
  /// In vi, this message translates to:
  /// **'Bản đồ'**
  String get mapLabel;

  /// No description provided for @zoomLevelLabel.
  ///
  /// In vi, this message translates to:
  /// **'Mức Zoom'**
  String get zoomLevelLabel;

  /// No description provided for @zoomLevelDetail.
  ///
  /// In vi, this message translates to:
  /// **'12 – 17 (Chi tiết)'**
  String get zoomLevelDetail;

  /// No description provided for @fileSizeLabel.
  ///
  /// In vi, this message translates to:
  /// **'Dung lượng'**
  String get fileSizeLabel;

  /// No description provided for @waypointsLabel.
  ///
  /// In vi, this message translates to:
  /// **'Điểm kiểm soát'**
  String get waypointsLabel;

  /// No description provided for @waypointsCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} Waypoints'**
  String waypointsCount(int count);

  /// No description provided for @trailSupportLabel.
  ///
  /// In vi, this message translates to:
  /// **'Đường mòn'**
  String get trailSupportLabel;

  /// No description provided for @supported.
  ///
  /// In vi, this message translates to:
  /// **'Có hỗ trợ'**
  String get supported;

  /// No description provided for @mapReadyTitle.
  ///
  /// In vi, this message translates to:
  /// **'Bản đồ đã sẵn sàng!'**
  String get mapReadyTitle;

  /// No description provided for @mapReadySubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Mọi dữ liệu đã được lưu trữ an toàn ngoại tuyến.'**
  String get mapReadySubtitle;

  /// No description provided for @mapPackageInfoTitle.
  ///
  /// In vi, this message translates to:
  /// **'THÔNG TIN GÓI BẢN ĐỒ'**
  String get mapPackageInfoTitle;

  /// No description provided for @offlineMapFeature.
  ///
  /// In vi, this message translates to:
  /// **'Offline Map (Bản đồ ngoại tuyến)'**
  String get offlineMapFeature;

  /// No description provided for @hikingTrailFeature.
  ///
  /// In vi, this message translates to:
  /// **'Hiking Trail (Đường mòn chi tiết)'**
  String get hikingTrailFeature;

  /// No description provided for @waypointsFeature.
  ///
  /// In vi, this message translates to:
  /// **'Waypoints (Các điểm dừng chân)'**
  String get waypointsFeature;

  /// No description provided for @backtrackFeature.
  ///
  /// In vi, this message translates to:
  /// **'Backtrack (Chế độ quay lại tự động)'**
  String get backtrackFeature;

  /// No description provided for @checkinControlPointTitle.
  ///
  /// In vi, this message translates to:
  /// **'Điểm kiểm soát Check-in'**
  String get checkinControlPointTitle;

  /// No description provided for @checkinTargetPointLabel.
  ///
  /// In vi, this message translates to:
  /// **'ĐIỂM CẦN ĐẾN'**
  String get checkinTargetPointLabel;

  /// No description provided for @checkinTargetAltitude.
  ///
  /// In vi, this message translates to:
  /// **'Độ cao mục tiêu: {altitude} m'**
  String checkinTargetAltitude(String altitude);

  /// No description provided for @checkinWithinRange.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đang ở trong phạm vi check-in! (Cách {distance}m)'**
  String checkinWithinRange(int distance);

  /// No description provided for @checkinNowButton.
  ///
  /// In vi, this message translates to:
  /// **'Check-in ngay'**
  String get checkinNowButton;

  /// No description provided for @checkinAlreadySuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đã check-in thành công'**
  String get checkinAlreadySuccess;

  /// No description provided for @checkinRadiusNotice.
  ///
  /// In vi, this message translates to:
  /// **'Bạn cần ở trong phạm vi bán kính 500m để có thể check-in thành công.'**
  String get checkinRadiusNotice;

  /// No description provided for @checkinSuccessToast.
  ///
  /// In vi, this message translates to:
  /// **'Đã check-in thành công tại {name}!'**
  String checkinSuccessToast(String name);

  /// No description provided for @checkinCongratulation.
  ///
  /// In vi, this message translates to:
  /// **'CHÚC MỪNG!'**
  String get checkinCongratulation;

  /// No description provided for @checkinSuccessTitle.
  ///
  /// In vi, this message translates to:
  /// **'Check-in thành công!'**
  String get checkinSuccessTitle;

  /// No description provided for @checkinSuccessMessage.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đã hoàn thành điểm mốc {name}.'**
  String checkinSuccessMessage(String name);

  /// No description provided for @achievementsEarnedTitle.
  ///
  /// In vi, this message translates to:
  /// **'HUY HIỆU ĐÃ ĐẠT ĐƯỢC'**
  String get achievementsEarnedTitle;

  /// No description provided for @statNewBadge.
  ///
  /// In vi, this message translates to:
  /// **'Huy hiệu mới'**
  String get statNewBadge;

  /// No description provided for @statMaxElevation.
  ///
  /// In vi, this message translates to:
  /// **'Độ cao tối đa'**
  String get statMaxElevation;

  /// No description provided for @statConqueredProvinces.
  ///
  /// In vi, this message translates to:
  /// **'Tỉnh đã chinh phục'**
  String get statConqueredProvinces;

  /// No description provided for @continueJourneyButton.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp tục hành trình'**
  String get continueJourneyButton;

  /// No description provided for @ratePlaceButton.
  ///
  /// In vi, this message translates to:
  /// **'Đánh giá địa điểm'**
  String get ratePlaceButton;

  /// No description provided for @shareAchievementButton.
  ///
  /// In vi, this message translates to:
  /// **'Chia sẻ thành tích'**
  String get shareAchievementButton;

  /// No description provided for @milestoneConquerBadgeTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chinh phục {name}'**
  String milestoneConquerBadgeTitle(String name);

  /// No description provided for @milestoneConquerBadgeDesc.
  ///
  /// In vi, this message translates to:
  /// **'Ghi dấu chân thành công tại {name} ở độ cao {altitude}m'**
  String milestoneConquerBadgeDesc(String name, String altitude);

  /// No description provided for @milestoneConquerBadgeDescSimple.
  ///
  /// In vi, this message translates to:
  /// **'Ghi dấu chân thành công tại điểm mốc {name}'**
  String milestoneConquerBadgeDescSimple(String name);

  /// No description provided for @ratePlaceTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đánh giá địa điểm'**
  String get ratePlaceTitle;

  /// No description provided for @rateSatisfactionLevel.
  ///
  /// In vi, this message translates to:
  /// **'MỨC ĐỘ HÀI LÒNG CỦA BẠN?'**
  String get rateSatisfactionLevel;

  /// No description provided for @rateShareExperience.
  ///
  /// In vi, this message translates to:
  /// **'CHIA SẺ TRẢI NGHIỆM'**
  String get rateShareExperience;

  /// No description provided for @rateExperienceHint.
  ///
  /// In vi, this message translates to:
  /// **'Chia sẻ cảm nhận, lời khuyên và trải nghiệm về điểm mốc này...'**
  String get rateExperienceHint;

  /// No description provided for @rateAnonymousLabel.
  ///
  /// In vi, this message translates to:
  /// **'Đánh giá ẩn danh'**
  String get rateAnonymousLabel;

  /// No description provided for @rateAnonymousDesc.
  ///
  /// In vi, this message translates to:
  /// **'Tên của bạn sẽ không hiển thị công khai'**
  String get rateAnonymousDesc;

  /// No description provided for @rateSubmitButton.
  ///
  /// In vi, this message translates to:
  /// **'Gửi đánh giá'**
  String get rateSubmitButton;

  /// No description provided for @rateThankYouTitle.
  ///
  /// In vi, this message translates to:
  /// **'Cảm ơn bạn!'**
  String get rateThankYouTitle;

  /// No description provided for @rateThankYouMessage.
  ///
  /// In vi, this message translates to:
  /// **'Đánh giá của bạn đã được gửi thành công và sẽ giúp ích rất nhiều cho cộng đồng Trekker Việt Nam.'**
  String get rateThankYouMessage;

  /// No description provided for @rateYourReviewTitle.
  ///
  /// In vi, this message translates to:
  /// **'ĐÁNH GIÁ CỦA BẠN'**
  String get rateYourReviewTitle;

  /// No description provided for @rateStarsSummary.
  ///
  /// In vi, this message translates to:
  /// **'{rating}/5 sao - {name}'**
  String rateStarsSummary(int rating, String name);

  /// No description provided for @rateViewOtherReviews.
  ///
  /// In vi, this message translates to:
  /// **'Xem đánh giá khác'**
  String get rateViewOtherReviews;

  /// No description provided for @rateBackToHome.
  ///
  /// In vi, this message translates to:
  /// **'Quay về trang chủ'**
  String get rateBackToHome;

  /// No description provided for @badgeDetailTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiết huy hiệu'**
  String get badgeDetailTitle;

  /// No description provided for @missionProgressTitle.
  ///
  /// In vi, this message translates to:
  /// **'TIẾN TRÌNH NHIỆM VỤ'**
  String get missionProgressTitle;

  /// No description provided for @otherBadgesTitle.
  ///
  /// In vi, this message translates to:
  /// **'HUY HIỆU KHÁC CỦA BẠN'**
  String get otherBadgesTitle;

  /// No description provided for @achievedDatePrefix.
  ///
  /// In vi, this message translates to:
  /// **'Ngày đạt được: {date}'**
  String achievedDatePrefix(String date);

  /// No description provided for @allBadgesTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả huy hiệu'**
  String get allBadgesTitle;
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
