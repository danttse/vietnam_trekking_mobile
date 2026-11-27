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

  /// No description provided for @journeyCancelled.
  ///
  /// In vi, this message translates to:
  /// **'Đã hủy'**
  String get journeyCancelled;

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
  /// **'Điểm cao nhất'**
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

  /// No description provided for @promoteSkip.
  ///
  /// In vi, this message translates to:
  /// **'Bỏ qua'**
  String get promoteSkip;

  /// No description provided for @promoteNext.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp theo'**
  String get promoteNext;

  /// No description provided for @promoteStart.
  ///
  /// In vi, this message translates to:
  /// **'Bắt đầu sử dụng'**
  String get promoteStart;

  /// No description provided for @promoteExploreTitle.
  ///
  /// In vi, this message translates to:
  /// **'Khám phá địa điểm trekking khắp Việt Nam'**
  String get promoteExploreTitle;

  /// No description provided for @promoteExploreDesc.
  ///
  /// In vi, this message translates to:
  /// **'Tìm hiểu các cung đường, địa điểm đẹp, thông tin chi tiết, đánh giá từ cộng đồng.'**
  String get promoteExploreDesc;

  /// No description provided for @promoteGpsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tạo hành trình và ghi lại GPS'**
  String get promoteGpsTitle;

  /// No description provided for @promoteGpsDesc.
  ///
  /// In vi, this message translates to:
  /// **'Lên kế hoạch, ghi lại hành trình thực tế, check-in cột mốc và xem lại đường đi (track logs).'**
  String get promoteGpsDesc;

  /// No description provided for @promoteGpsRecording.
  ///
  /// In vi, this message translates to:
  /// **'ĐANG GHI'**
  String get promoteGpsRecording;

  /// No description provided for @promoteGpsDistance.
  ///
  /// In vi, this message translates to:
  /// **'Quãng đường'**
  String get promoteGpsDistance;

  /// No description provided for @promoteGpsElevation.
  ///
  /// In vi, this message translates to:
  /// **'Độ cao'**
  String get promoteGpsElevation;

  /// No description provided for @promoteGpsSpeed.
  ///
  /// In vi, this message translates to:
  /// **'Vận tốc'**
  String get promoteGpsSpeed;

  /// No description provided for @promoteOfflineTitle.
  ///
  /// In vi, this message translates to:
  /// **'Hoạt động offline\nmọi lúc mọi nơi'**
  String get promoteOfflineTitle;

  /// No description provided for @promoteOfflineDesc.
  ///
  /// In vi, this message translates to:
  /// **'Tải bản đồ, dữ liệu địa điểm để sử dụng ngay cả khi không có Internet.'**
  String get promoteOfflineDesc;

  /// No description provided for @promoteOfflineMapTitle.
  ///
  /// In vi, this message translates to:
  /// **'Bản đồ offline (MBTiles)'**
  String get promoteOfflineMapTitle;

  /// No description provided for @promoteOfflineMapSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Dung lượng tối ưu, tải nhanh chóng'**
  String get promoteOfflineMapSubtitle;

  /// No description provided for @promoteOfflineFavoriteTitle.
  ///
  /// In vi, this message translates to:
  /// **'Lưu địa điểm yêu thích'**
  String get promoteOfflineFavoriteTitle;

  /// No description provided for @promoteOfflineFavoriteSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Không lo mất dấu tọa độ quan trọng'**
  String get promoteOfflineFavoriteSubtitle;

  /// No description provided for @promoteOfflineGpsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Ghi GPS và check-in'**
  String get promoteOfflineGpsTitle;

  /// No description provided for @promoteOfflineGpsSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Vẫn lưu đầy đủ lịch sử chuyến đi'**
  String get promoteOfflineGpsSubtitle;

  /// No description provided for @promoteStatsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Theo dõi hành trình và\nthành tựu'**
  String get promoteStatsTitle;

  /// No description provided for @promoteStatsDesc.
  ///
  /// In vi, this message translates to:
  /// **'Lưu dấu 34 tỉnh đã đi, thu thập huy hiệu và xem thống kê hành trình của bạn.'**
  String get promoteStatsDesc;

  /// No description provided for @promoteStatsProvinces.
  ///
  /// In vi, this message translates to:
  /// **'Tỉnh thành đã đi'**
  String get promoteStatsProvinces;

  /// No description provided for @promoteStatsDistance.
  ///
  /// In vi, this message translates to:
  /// **'Quãng đường đã đi'**
  String get promoteStatsDistance;

  /// No description provided for @promoteStatsBadgeMountain.
  ///
  /// In vi, this message translates to:
  /// **'Núi rừng'**
  String get promoteStatsBadgeMountain;

  /// No description provided for @promoteStatsBadgeMountainSub.
  ///
  /// In vi, this message translates to:
  /// **'5 đỉnh chinh phục'**
  String get promoteStatsBadgeMountainSub;

  /// No description provided for @promoteStatsBadgeIsland.
  ///
  /// In vi, this message translates to:
  /// **'Biển đảo'**
  String get promoteStatsBadgeIsland;

  /// No description provided for @promoteStatsBadgeIslandSub.
  ///
  /// In vi, this message translates to:
  /// **'3 vùng vịnh'**
  String get promoteStatsBadgeIslandSub;

  /// No description provided for @promoteStatsBadgeExplore.
  ///
  /// In vi, this message translates to:
  /// **'Khám phá'**
  String get promoteStatsBadgeExplore;

  /// No description provided for @promoteStatsBadgeExploreSub.
  ///
  /// In vi, this message translates to:
  /// **'10 tỉnh thành'**
  String get promoteStatsBadgeExploreSub;

  /// No description provided for @promoteCommunityTitle.
  ///
  /// In vi, this message translates to:
  /// **'Kết nối cộng đồng yêu trekking'**
  String get promoteCommunityTitle;

  /// No description provided for @promoteCommunityDesc.
  ///
  /// In vi, this message translates to:
  /// **'Chia sẻ hành trình, ảnh, kinh nghiệm và tương tác với những người có cùng đam mê.'**
  String get promoteCommunityDesc;

  /// No description provided for @supportFaqHeader.
  ///
  /// In vi, this message translates to:
  /// **'CÂU HỎI THƯỜNG GẶP'**
  String get supportFaqHeader;

  /// No description provided for @supportFeedbackHeader.
  ///
  /// In vi, this message translates to:
  /// **'GỬI PHẢN HỒI CHO CHÚNG TÔI'**
  String get supportFeedbackHeader;

  /// No description provided for @supportIssueTypeLabel.
  ///
  /// In vi, this message translates to:
  /// **'LOẠI VẤN ĐỀ'**
  String get supportIssueTypeLabel;

  /// No description provided for @supportDescriptionLabel.
  ///
  /// In vi, this message translates to:
  /// **'MÔ TẢ CHI TIẾT'**
  String get supportDescriptionLabel;

  /// No description provided for @supportDescriptionHint.
  ///
  /// In vi, this message translates to:
  /// **'Mô tả lỗi hoặc đề xuất của bạn tại đây...'**
  String get supportDescriptionHint;

  /// No description provided for @supportSubmitButton.
  ///
  /// In vi, this message translates to:
  /// **'Gửi phản hồi'**
  String get supportSubmitButton;

  /// No description provided for @supportDirectEmail.
  ///
  /// In vi, this message translates to:
  /// **'Hoặc gửi thư trực tiếp đến chúng tôi qua'**
  String get supportDirectEmail;

  /// No description provided for @supportEmptyError.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập mô tả chi tiết của bạn'**
  String get supportEmptyError;

  /// No description provided for @supportSuccessMessage.
  ///
  /// In vi, this message translates to:
  /// **'Cảm ơn bạn đã gửi phản hồi! Chúng tôi sẽ phản hồi sớm nhất.'**
  String get supportSuccessMessage;

  /// No description provided for @supportIssueGpsMap.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi định vị GPS / Bản đồ'**
  String get supportIssueGpsMap;

  /// No description provided for @supportIssueAccount.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi tài khoản / Đăng nhập'**
  String get supportIssueAccount;

  /// No description provided for @supportIssueContent.
  ///
  /// In vi, this message translates to:
  /// **'Đóng góp nội dung / Địa điểm'**
  String get supportIssueContent;

  /// No description provided for @supportIssueAppExperience.
  ///
  /// In vi, this message translates to:
  /// **'Góp ý trải nghiệm ứng dụng'**
  String get supportIssueAppExperience;

  /// No description provided for @supportIssueOther.
  ///
  /// In vi, this message translates to:
  /// **'Vấn đề khác'**
  String get supportIssueOther;

  /// No description provided for @supportFaq1Q.
  ///
  /// In vi, this message translates to:
  /// **'Làm sao để check-in tại cột mốc?'**
  String get supportFaq1Q;

  /// No description provided for @supportFaq1A.
  ///
  /// In vi, this message translates to:
  /// **'Bật định vị GPS trên điện thoại của bạn, di chuyển đến phạm vi 50m quanh cột mốc và nhấn nút ‘Check-in ngay’ trên màn hình Bản đồ hành trình.'**
  String get supportFaq1A;

  /// No description provided for @supportFaq2Q.
  ///
  /// In vi, this message translates to:
  /// **'Huy hiệu hoạt động như thế nào?'**
  String get supportFaq2Q;

  /// No description provided for @supportFaq2A.
  ///
  /// In vi, this message translates to:
  /// **'Huy hiệu sẽ tự động được mở khóa khi bạn hoàn thành các thử thách trekking, chinh phục các đỉnh núi hoặc hoàn thành các mốc khám phá tỉnh thành.'**
  String get supportFaq2A;

  /// No description provided for @supportFaq3Q.
  ///
  /// In vi, this message translates to:
  /// **'Cách tạo hành trình mới?'**
  String get supportFaq3Q;

  /// No description provided for @supportFaq3A.
  ///
  /// In vi, this message translates to:
  /// **'Vào mục Hành trình, nhấn biểu tượng dấu (+) hoặc nút ‘Bắt đầu hành trình’ để bật chế độ ghi GPS thời gian thực và lưu lại cung đường của bạn.'**
  String get supportFaq3A;

  /// No description provided for @rankSectionTitle.
  ///
  /// In vi, this message translates to:
  /// **'HẠNG TREKKING CỦA BẠN'**
  String get rankSectionTitle;

  /// No description provided for @rankXpEarned.
  ///
  /// In vi, this message translates to:
  /// **'Bạn nhận được +{xp} XP'**
  String rankXpEarned(String xp);

  /// No description provided for @rankPromoted.
  ///
  /// In vi, this message translates to:
  /// **'Lên hạng {name} · Level {level}!'**
  String rankPromoted(String name, int level);

  /// No description provided for @rankDetailTitle.
  ///
  /// In vi, this message translates to:
  /// **'Hạng và XP'**
  String get rankDetailTitle;

  /// No description provided for @rankLevel.
  ///
  /// In vi, this message translates to:
  /// **'Level {level}'**
  String rankLevel(int level);

  /// No description provided for @rankViewDetails.
  ///
  /// In vi, this message translates to:
  /// **'Xem chi tiết các hạng'**
  String get rankViewDetails;

  /// No description provided for @rankCurrentXp.
  ///
  /// In vi, this message translates to:
  /// **'XP hiện tại'**
  String get rankCurrentXp;

  /// No description provided for @rankNextTarget.
  ///
  /// In vi, this message translates to:
  /// **'Hạng tiếp theo: {name}'**
  String rankNextTarget(String name);

  /// No description provided for @rankXpRemaining.
  ///
  /// In vi, this message translates to:
  /// **'Cần thêm {xp} XP để đạt mốc XP tiếp theo'**
  String rankXpRemaining(String xp);

  /// No description provided for @rankXpReached.
  ///
  /// In vi, this message translates to:
  /// **'Đã đủ XP. Hoàn thành các điều kiện còn lại để lên hạng.'**
  String get rankXpReached;

  /// No description provided for @rankHighest.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đã đạt hạng cao nhất!'**
  String get rankHighest;

  /// No description provided for @rankRequirementsTitle.
  ///
  /// In vi, this message translates to:
  /// **'ĐIỀU KIỆN LÊN HẠNG'**
  String get rankRequirementsTitle;

  /// No description provided for @rankRequirementsHint.
  ///
  /// In vi, this message translates to:
  /// **'Cần đạt đủ các điều kiện. Hạng được cập nhật theo hoạt động đã xác nhận của bạn.'**
  String get rankRequirementsHint;

  /// No description provided for @rankAllTitle.
  ///
  /// In vi, this message translates to:
  /// **'TẤT CẢ CÁC HẠNG'**
  String get rankAllTitle;

  /// No description provided for @rankCurrent.
  ///
  /// In vi, this message translates to:
  /// **'Hiện tại'**
  String get rankCurrent;

  /// No description provided for @rankUnavailable.
  ///
  /// In vi, this message translates to:
  /// **'Chưa tải được hạng của bạn'**
  String get rankUnavailable;

  /// No description provided for @rankLoading.
  ///
  /// In vi, this message translates to:
  /// **'Đang tải hạng…'**
  String get rankLoading;

  /// No description provided for @rankCatalogEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có danh sách hạng'**
  String get rankCatalogEmpty;

  /// No description provided for @rankRetry.
  ///
  /// In vi, this message translates to:
  /// **'Thử lại'**
  String get rankRetry;

  /// No description provided for @rankXpLabel.
  ///
  /// In vi, this message translates to:
  /// **'Điểm XP'**
  String get rankXpLabel;

  /// No description provided for @rankJourneysLabel.
  ///
  /// In vi, this message translates to:
  /// **'Hành trình hoàn thành'**
  String get rankJourneysLabel;

  /// No description provided for @rankProvincesLabel.
  ///
  /// In vi, this message translates to:
  /// **'Tỉnh thành đã đi'**
  String get rankProvincesLabel;

  /// No description provided for @rankBadgesLabel.
  ///
  /// In vi, this message translates to:
  /// **'Huy hiệu'**
  String get rankBadgesLabel;

  /// No description provided for @rankDistanceLabel.
  ///
  /// In vi, this message translates to:
  /// **'Quãng đường (km)'**
  String get rankDistanceLabel;

  /// No description provided for @rankContributionsLabel.
  ///
  /// In vi, this message translates to:
  /// **'Đóng góp được duyệt'**
  String get rankContributionsLabel;

  /// No description provided for @rankOverallProgress.
  ///
  /// In vi, this message translates to:
  /// **'Tiến độ các điều kiện: {percent}%'**
  String rankOverallProgress(String percent);

  /// No description provided for @rankPromotionTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chúc mừng bạn thăng hạng!'**
  String get rankPromotionTitle;

  /// No description provided for @xpHistoryHint.
  ///
  /// In vi, this message translates to:
  /// **'XP được tự động cập nhật sau hoạt động đã xác nhận. Xem lại các lần nhận và điều chỉnh XP tại đây.'**
  String get xpHistoryHint;

  /// No description provided for @xpRouteApproved.
  ///
  /// In vi, this message translates to:
  /// **'Đóng góp cung đường được duyệt'**
  String get xpRouteApproved;

  /// No description provided for @xpJourneyCompleted.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn thành hành trình'**
  String get xpJourneyCompleted;

  /// No description provided for @xpHistoryTitle.
  ///
  /// In vi, this message translates to:
  /// **'Lịch sử XP'**
  String get xpHistoryTitle;

  /// No description provided for @xpReversal.
  ///
  /// In vi, this message translates to:
  /// **'Thu hồi XP'**
  String get xpReversal;

  /// No description provided for @xpMilestoneCheckin.
  ///
  /// In vi, this message translates to:
  /// **'Check-in cột mốc'**
  String get xpMilestoneCheckin;

  /// No description provided for @xpHistoryLoadMore.
  ///
  /// In vi, this message translates to:
  /// **'Xem thêm'**
  String get xpHistoryLoadMore;

  /// No description provided for @xpJourneyElevation.
  ///
  /// In vi, this message translates to:
  /// **'Độ cao đã chinh phục'**
  String get xpJourneyElevation;

  /// No description provided for @xpOtherActivity.
  ///
  /// In vi, this message translates to:
  /// **'Phần thưởng hoạt động'**
  String get xpOtherActivity;

  /// No description provided for @xpAdminAdjustment.
  ///
  /// In vi, this message translates to:
  /// **'Điều chỉnh XP'**
  String get xpAdminAdjustment;

  /// No description provided for @xpJourneyDistance.
  ///
  /// In vi, this message translates to:
  /// **'Quãng đường đã đi'**
  String get xpJourneyDistance;

  /// No description provided for @xpProvinceVisited.
  ///
  /// In vi, this message translates to:
  /// **'Khám phá tỉnh mới'**
  String get xpProvinceVisited;

  /// No description provided for @rankPromotionMessage.
  ///
  /// In vi, this message translates to:
  /// **'Những hành trình của bạn đã tạo nên một cột mốc mới. Tiếp tục khám phá nhé!'**
  String get rankPromotionMessage;

  /// No description provided for @xpPlaceApproved.
  ///
  /// In vi, this message translates to:
  /// **'Đóng góp địa điểm được duyệt'**
  String get xpPlaceApproved;

  /// No description provided for @xpPlaceVisited.
  ///
  /// In vi, this message translates to:
  /// **'Ghé thăm địa điểm'**
  String get xpPlaceVisited;

  /// No description provided for @rankPromotionContinue.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp tục khám phá'**
  String get rankPromotionContinue;

  /// No description provided for @xpBadgeEarned.
  ///
  /// In vi, this message translates to:
  /// **'Nhận huy hiệu'**
  String get xpBadgeEarned;

  /// No description provided for @xpHistoryEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Bạn chưa có lịch sử XP. Bắt đầu hành trình khám phá nhé!'**
  String get xpHistoryEmpty;

  /// No description provided for @otpVerificationTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xác thực Email'**
  String get otpVerificationTitle;

  /// No description provided for @otpExpiredLabel.
  ///
  /// In vi, this message translates to:
  /// **'OTP hết hạn. Vui lòng gửi lại.'**
  String get otpExpiredLabel;

  /// No description provided for @otpExpiresIn.
  ///
  /// In vi, this message translates to:
  /// **'OTP hết hạn sau'**
  String get otpExpiresIn;

  /// No description provided for @otpIncompleteError.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập đủ 6 chữ số OTP'**
  String get otpIncompleteError;

  /// No description provided for @otpResendSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đã gửi lại mã OTP. Vui lòng kiểm tra email.'**
  String get otpResendSuccess;

  /// No description provided for @journeyMilestonesLoading.
  ///
  /// In vi, this message translates to:
  /// **'Đang tải điểm check-in…'**
  String get journeyMilestonesLoading;

  /// No description provided for @journeyMilestonesLoadFailed.
  ///
  /// In vi, this message translates to:
  /// **'Chưa tải được điểm check-in'**
  String get journeyMilestonesLoadFailed;

  /// No description provided for @journeyMilestonesEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có điểm check-in'**
  String get journeyMilestonesEmpty;

  /// No description provided for @journeyMilestonesEmptyMessage.
  ///
  /// In vi, this message translates to:
  /// **'Cung đường này chưa có cột mốc check-in chính thức. Quản trị viên cần thêm cột mốc cho cung đường trước khi bạn có thể check-in. Bạn vẫn có thể mở bản đồ để đánh dấu mốc cá nhân.'**
  String get journeyMilestonesEmptyMessage;

  /// No description provided for @journeyReloadMilestones.
  ///
  /// In vi, this message translates to:
  /// **'Tải lại cột mốc'**
  String get journeyReloadMilestones;

  /// No description provided for @journeyCheckinClose.
  ///
  /// In vi, this message translates to:
  /// **'Đóng'**
  String get journeyCheckinClose;

  /// No description provided for @commonRetry.
  ///
  /// In vi, this message translates to:
  /// **'Thử lại'**
  String get commonRetry;

  /// No description provided for @commonReload.
  ///
  /// In vi, this message translates to:
  /// **'Tải lại'**
  String get commonReload;

  /// No description provided for @commonLoading.
  ///
  /// In vi, this message translates to:
  /// **'Đang tải…'**
  String get commonLoading;

  /// No description provided for @commonSaving.
  ///
  /// In vi, this message translates to:
  /// **'Đang lưu…'**
  String get commonSaving;

  /// No description provided for @commonDelete.
  ///
  /// In vi, this message translates to:
  /// **'Xóa'**
  String get commonDelete;

  /// No description provided for @commonClose.
  ///
  /// In vi, this message translates to:
  /// **'Đóng'**
  String get commonClose;

  /// No description provided for @commonSaveChanges.
  ///
  /// In vi, this message translates to:
  /// **'Lưu thay đổi'**
  String get commonSaveChanges;

  /// No description provided for @commonViewMore.
  ///
  /// In vi, this message translates to:
  /// **'Xem thêm'**
  String get commonViewMore;

  /// No description provided for @commonNoData.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có dữ liệu'**
  String get commonNoData;

  /// No description provided for @postCreateTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tạo bài viết'**
  String get postCreateTitle;

  /// No description provided for @postEditTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chỉnh sửa bài viết'**
  String get postEditTitle;

  /// No description provided for @postSharingWithTrekViet.
  ///
  /// In vi, this message translates to:
  /// **'Đang chia sẻ cùng cộng đồng TrekViệt'**
  String get postSharingWithTrekViet;

  /// No description provided for @visibilityPublic.
  ///
  /// In vi, this message translates to:
  /// **'Công khai'**
  String get visibilityPublic;

  /// No description provided for @visibilityPrivate.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ mình tôi'**
  String get visibilityPrivate;

  /// No description provided for @whatsOnYourMind.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đang nghĩ gì?'**
  String get whatsOnYourMind;

  /// No description provided for @postAddToPost.
  ///
  /// In vi, this message translates to:
  /// **'Thêm vào bài viết'**
  String get postAddToPost;

  /// No description provided for @postAddPhoto.
  ///
  /// In vi, this message translates to:
  /// **'Ảnh'**
  String get postAddPhoto;

  /// No description provided for @postMaxImagesHint.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ có thể chọn tối đa 10 ảnh'**
  String get postMaxImagesHint;

  /// No description provided for @postSelectedImagesCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} ảnh đã chọn'**
  String postSelectedImagesCount(int count);

  /// No description provided for @postRemoveImage.
  ///
  /// In vi, this message translates to:
  /// **'Xóa ảnh'**
  String get postRemoveImage;

  /// No description provided for @postTagLocation.
  ///
  /// In vi, this message translates to:
  /// **'Gắn vị trí'**
  String get postTagLocation;

  /// No description provided for @postShareJourney.
  ///
  /// In vi, this message translates to:
  /// **'Chia sẻ hành trình'**
  String get postShareJourney;

  /// No description provided for @postPublishButton.
  ///
  /// In vi, this message translates to:
  /// **'Đăng bài'**
  String get postPublishButton;

  /// No description provided for @postDeleteTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xóa bài viết'**
  String get postDeleteTitle;

  /// No description provided for @postDeleteMessage.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc chắn muốn xóa bài viết này không? Hành động này không thể hoàn tác.'**
  String get postDeleteMessage;

  /// No description provided for @postDeleteError.
  ///
  /// In vi, this message translates to:
  /// **'Không thể xóa bài viết: {error}'**
  String postDeleteError(String error);

  /// No description provided for @postCopiedToClipboard.
  ///
  /// In vi, this message translates to:
  /// **'Đã sao chép vào bộ nhớ tạm'**
  String get postCopiedToClipboard;

  /// No description provided for @postEditAction.
  ///
  /// In vi, this message translates to:
  /// **'Chỉnh sửa bài viết'**
  String get postEditAction;

  /// No description provided for @postDeleteAction.
  ///
  /// In vi, this message translates to:
  /// **'Xóa bài viết'**
  String get postDeleteAction;

  /// No description provided for @postPublishedSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đã đăng bài viết thành công'**
  String get postPublishedSuccess;

  /// No description provided for @syncBeforeCommunityShare.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng đồng bộ hành trình trước khi chia sẻ lên cộng đồng'**
  String get syncBeforeCommunityShare;

  /// No description provided for @shareJourneyDefaultContent.
  ///
  /// In vi, this message translates to:
  /// **'Hành trình trekking {name} của mình!'**
  String shareJourneyDefaultContent(String name);

  /// No description provided for @reportFeatureUnavailable.
  ///
  /// In vi, this message translates to:
  /// **'Tính năng báo cáo chưa khả dụng'**
  String get reportFeatureUnavailable;

  /// No description provided for @messagesTabTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tin nhắn'**
  String get messagesTabTitle;

  /// No description provided for @newMessageTooltip.
  ///
  /// In vi, this message translates to:
  /// **'Nhắn tin mới'**
  String get newMessageTooltip;

  /// No description provided for @groupCreateTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tạo nhóm trekking'**
  String get groupCreateTitle;

  /// No description provided for @groupNameLabel.
  ///
  /// In vi, this message translates to:
  /// **'Tên nhóm'**
  String get groupNameLabel;

  /// No description provided for @groupMaxMembersHint.
  ///
  /// In vi, this message translates to:
  /// **'Tối đa 10 thành viên cho nhóm thường'**
  String get groupMaxMembersHint;

  /// No description provided for @groupAddByEmailOrQr.
  ///
  /// In vi, this message translates to:
  /// **'Thêm bằng Email/QR'**
  String get groupAddByEmailOrQr;

  /// No description provided for @unselect.
  ///
  /// In vi, this message translates to:
  /// **'Bỏ chọn'**
  String get unselect;

  /// No description provided for @groupCreating.
  ///
  /// In vi, this message translates to:
  /// **'Đang tạo nhóm...'**
  String get groupCreating;

  /// No description provided for @groupCreateButton.
  ///
  /// In vi, this message translates to:
  /// **'Tạo nhóm'**
  String get groupCreateButton;

  /// No description provided for @groupNameAndMemberRequired.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập tên nhóm và chọn ít nhất 1 thành viên'**
  String get groupNameAndMemberRequired;

  /// No description provided for @groupDetailsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiết nhóm'**
  String get groupDetailsTitle;

  /// No description provided for @groupMemberCount.
  ///
  /// In vi, this message translates to:
  /// **'Thành viên ({count})'**
  String groupMemberCount(int count);

  /// No description provided for @groupRenameDialogTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đổi tên nhóm'**
  String get groupRenameDialogTitle;

  /// No description provided for @groupRenameButton.
  ///
  /// In vi, this message translates to:
  /// **'Đổi tên'**
  String get groupRenameButton;

  /// No description provided for @groupAddMemberButton.
  ///
  /// In vi, this message translates to:
  /// **'Thêm thành viên'**
  String get groupAddMemberButton;

  /// No description provided for @groupOwnerRole.
  ///
  /// In vi, this message translates to:
  /// **'Trưởng nhóm'**
  String get groupOwnerRole;

  /// No description provided for @groupTransferOwnerTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chuyển quyền trưởng nhóm'**
  String get groupTransferOwnerTitle;

  /// No description provided for @groupTransferOwnerMessage.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc muốn chuyển quyền trưởng nhóm cho {name}? Bạn sẽ trở thành thành viên thường.'**
  String groupTransferOwnerMessage(String name);

  /// No description provided for @groupTransferOwnerConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Chuyển quyền'**
  String get groupTransferOwnerConfirm;

  /// No description provided for @groupTransferOwnerAction.
  ///
  /// In vi, this message translates to:
  /// **'Chuyển quyền trưởng nhóm'**
  String get groupTransferOwnerAction;

  /// No description provided for @groupRemoveMemberAction.
  ///
  /// In vi, this message translates to:
  /// **'Xóa khỏi nhóm'**
  String get groupRemoveMemberAction;

  /// No description provided for @groupLeaveAction.
  ///
  /// In vi, this message translates to:
  /// **'Rời nhóm'**
  String get groupLeaveAction;

  /// No description provided for @groupLeaveOwnerHint.
  ///
  /// In vi, this message translates to:
  /// **'Bạn là trưởng nhóm. Hãy chuyển quyền trưởng nhóm cho người khác trước khi rời nhóm.'**
  String get groupLeaveOwnerHint;

  /// No description provided for @messagesHeaderSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Nhắn tin trực tiếp và nhóm trekking'**
  String get messagesHeaderSubtitle;

  /// No description provided for @noConversationsYet.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có cuộc trò chuyện nào'**
  String get noConversationsYet;

  /// No description provided for @groupPaused.
  ///
  /// In vi, this message translates to:
  /// **'Nhóm tạm dừng'**
  String get groupPaused;

  /// No description provided for @directMessage.
  ///
  /// In vi, this message translates to:
  /// **'Trò chuyện trực tiếp'**
  String get directMessage;

  /// No description provided for @viewMoreConversations.
  ///
  /// In vi, this message translates to:
  /// **'Xem thêm cuộc trò chuyện'**
  String get viewMoreConversations;

  /// No description provided for @selectMember.
  ///
  /// In vi, this message translates to:
  /// **'Chọn thành viên'**
  String get selectMember;

  /// No description provided for @searchUser.
  ///
  /// In vi, this message translates to:
  /// **'Tìm kiếm người dùng'**
  String get searchUser;

  /// No description provided for @searchUserHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập email hoặc tên người dùng...'**
  String get searchUserHint;

  /// No description provided for @emailOrQrContent.
  ///
  /// In vi, this message translates to:
  /// **'Nội dung Email hoặc mã QR'**
  String get emailOrQrContent;

  /// No description provided for @searchButton.
  ///
  /// In vi, this message translates to:
  /// **'Tìm kiếm'**
  String get searchButton;

  /// No description provided for @scanQrButton.
  ///
  /// In vi, this message translates to:
  /// **'Quét mã QR'**
  String get scanQrButton;

  /// No description provided for @personalPage.
  ///
  /// In vi, this message translates to:
  /// **'Trang cá nhân'**
  String get personalPage;

  /// No description provided for @groupSuspendedByAdmin.
  ///
  /// In vi, this message translates to:
  /// **'Nhóm đã bị quản trị viên đình chỉ hoạt động'**
  String get groupSuspendedByAdmin;

  /// No description provided for @olderMessages.
  ///
  /// In vi, this message translates to:
  /// **'Tin nhắn cũ hơn'**
  String get olderMessages;

  /// No description provided for @recallMessage.
  ///
  /// In vi, this message translates to:
  /// **'Thu hồi'**
  String get recallMessage;

  /// No description provided for @reportMessage.
  ///
  /// In vi, this message translates to:
  /// **'Báo cáo'**
  String get reportMessage;

  /// No description provided for @reportReason.
  ///
  /// In vi, this message translates to:
  /// **'Lý do báo cáo'**
  String get reportReason;

  /// No description provided for @reportMessageDesc.
  ///
  /// In vi, this message translates to:
  /// **'Mô tả lý do bạn báo cáo tin nhắn này'**
  String get reportMessageDesc;

  /// No description provided for @reportSentToAdmin.
  ///
  /// In vi, this message translates to:
  /// **'Đã gửi báo cáo cho quản trị viên'**
  String get reportSentToAdmin;

  /// No description provided for @formerMember.
  ///
  /// In vi, this message translates to:
  /// **'Thành viên cũ'**
  String get formerMember;

  /// No description provided for @messageRecalled.
  ///
  /// In vi, this message translates to:
  /// **'Tin nhắn đã được thu hồi'**
  String get messageRecalled;

  /// No description provided for @typeMessageHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập tin nhắn...'**
  String get typeMessageHint;

  /// No description provided for @sendMessageTooltip.
  ///
  /// In vi, this message translates to:
  /// **'Gửi'**
  String get sendMessageTooltip;

  /// No description provided for @sendErrorRetryHint.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi gửi: {error}. Bấm để thử lại.'**
  String sendErrorRetryHint(String error);

  /// No description provided for @commentSaveError.
  ///
  /// In vi, this message translates to:
  /// **'Không thể lưu bình luận: {error}'**
  String commentSaveError(String error);

  /// No description provided for @commentDeleteTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xóa bình luận'**
  String get commentDeleteTitle;

  /// No description provided for @commentDeleteMessage.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc muốn xóa bình luận này không?'**
  String get commentDeleteMessage;

  /// No description provided for @commentDeleteError.
  ///
  /// In vi, this message translates to:
  /// **'Không thể xóa bình luận: {error}'**
  String commentDeleteError(String error);

  /// No description provided for @commentEditTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chỉnh sửa bình luận'**
  String get commentEditTitle;

  /// No description provided for @contentRequired.
  ///
  /// In vi, this message translates to:
  /// **'Nội dung không được để trống'**
  String get contentRequired;

  /// No description provided for @selectYourJourney.
  ///
  /// In vi, this message translates to:
  /// **'Chọn hành trình của bạn'**
  String get selectYourJourney;

  /// No description provided for @searchPlaceHint.
  ///
  /// In vi, this message translates to:
  /// **'Tìm địa điểm'**
  String get searchPlaceHint;

  /// No description provided for @onlySyncedJourneysHint.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ có thể chia sẻ các hành trình đã đồng bộ lên hệ thống'**
  String get onlySyncedJourneysHint;

  /// No description provided for @noDataToSelect.
  ///
  /// In vi, this message translates to:
  /// **'Không có dữ liệu để chọn'**
  String get noDataToSelect;

  /// No description provided for @finishJourneyTitle.
  ///
  /// In vi, this message translates to:
  /// **'Kết thúc hành trình?'**
  String get finishJourneyTitle;

  /// No description provided for @finishJourneyDesc.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc chắn muốn kết thúc hành trình này? Sau khi kết thúc, dữ liệu track log sẽ được lưu lại.'**
  String get finishJourneyDesc;

  /// No description provided for @finishJourneySaveGpsNotice.
  ///
  /// In vi, this message translates to:
  /// **'Sau khi kết thúc, bạn có thể lưu track log GPS thành tuyến đường mới để đóng góp cho cộng đồng.'**
  String get finishJourneySaveGpsNotice;

  /// No description provided for @keepGoingButton.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp tục đi'**
  String get keepGoingButton;

  /// No description provided for @finishButton.
  ///
  /// In vi, this message translates to:
  /// **'Kết thúc'**
  String get finishButton;

  /// No description provided for @finishAndSendToAdmin.
  ///
  /// In vi, this message translates to:
  /// **'Kết thúc & Gửi duyệt'**
  String get finishAndSendToAdmin;

  /// No description provided for @locationFetchFailed.
  ///
  /// In vi, this message translates to:
  /// **'Không thể lấy vị trí hiện tại: {error}'**
  String locationFetchFailed(String error);

  /// No description provided for @locationFetchForMarkerFailed.
  ///
  /// In vi, this message translates to:
  /// **'Không thể lấy vị trí GPS để tạo điểm mốc'**
  String get locationFetchForMarkerFailed;

  /// No description provided for @sendToAdminButton.
  ///
  /// In vi, this message translates to:
  /// **'Gửi cho Admin'**
  String get sendToAdminButton;

  /// No description provided for @markersSyncedSendToAdmin.
  ///
  /// In vi, this message translates to:
  /// **'Các điểm mốc đã được đồng bộ lên máy chủ. Bạn có thể gửi đóng góp để quản trị viên duyệt đưa vào bản đồ chính thức.'**
  String get markersSyncedSendToAdmin;

  /// No description provided for @markersSavedOfflineNeedSync.
  ///
  /// In vi, this message translates to:
  /// **'Các điểm mốc đã được lưu offline. Khi có mạng và sau khi đồng bộ lên máy chủ, bạn có thể gửi đóng góp cho quản trị viên.'**
  String get markersSavedOfflineNeedSync;

  /// No description provided for @markersSavedOfflineAutoSync.
  ///
  /// In vi, this message translates to:
  /// **'Các điểm mốc được lưu offline trên máy và sẽ tự động đồng bộ khi có kết nối mạng.'**
  String get markersSavedOfflineAutoSync;

  /// No description provided for @completeJourneyBeforeSendAdmin.
  ///
  /// In vi, this message translates to:
  /// **'Hãy hoàn thành hành trình trước khi gửi đề xuất tuyến đường/cột mốc cho Admin.'**
  String get completeJourneyBeforeSendAdmin;

  /// No description provided for @milestonesLoadFailedRetry.
  ///
  /// In vi, this message translates to:
  /// **'Không thể tải cột mốc. Bấm để thử lại.'**
  String get milestonesLoadFailedRetry;

  /// No description provided for @downloadOrUpdateOfflineMap.
  ///
  /// In vi, this message translates to:
  /// **'Tải / Cập nhật bản đồ Offline'**
  String get downloadOrUpdateOfflineMap;

  /// No description provided for @journeyMapTitle.
  ///
  /// In vi, this message translates to:
  /// **'Bản đồ hành trình'**
  String get journeyMapTitle;

  /// No description provided for @detailLabel.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiết'**
  String get detailLabel;

  /// No description provided for @journeyDetailTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiết hành trình'**
  String get journeyDetailTitle;

  /// No description provided for @milestonesArrivedCount.
  ///
  /// In vi, this message translates to:
  /// **'Đã đến {checked}/{total} cột mốc'**
  String milestonesArrivedCount(int checked, int total);

  /// No description provided for @backtrackReturnToStart.
  ///
  /// In vi, this message translates to:
  /// **'Backtrack: Quay về điểm xuất phát'**
  String get backtrackReturnToStart;

  /// No description provided for @backtrackRecordRoute.
  ///
  /// In vi, this message translates to:
  /// **'Backtrack: Ghi tracklog đường đi'**
  String get backtrackRecordRoute;

  /// No description provided for @savedRoute.
  ///
  /// In vi, this message translates to:
  /// **'Tuyến đường đã lưu'**
  String get savedRoute;

  /// No description provided for @recordingGpsForeground.
  ///
  /// In vi, this message translates to:
  /// **'Đang ghi GPS chạy ngầm'**
  String get recordingGpsForeground;

  /// No description provided for @pausedRecordingGps.
  ///
  /// In vi, this message translates to:
  /// **'Tạm dừng ghi GPS'**
  String get pausedRecordingGps;

  /// No description provided for @savedOfflineUsable.
  ///
  /// In vi, this message translates to:
  /// **'Đã lưu offline, có thể dùng khi mất sóng'**
  String get savedOfflineUsable;

  /// No description provided for @stopGpsRecording.
  ///
  /// In vi, this message translates to:
  /// **'Dừng ghi GPS'**
  String get stopGpsRecording;

  /// No description provided for @recordRouteButton.
  ///
  /// In vi, this message translates to:
  /// **'Ghi đường đi'**
  String get recordRouteButton;

  /// No description provided for @startGpsRecording.
  ///
  /// In vi, this message translates to:
  /// **'Bắt đầu ghi GPS'**
  String get startGpsRecording;

  /// No description provided for @exitBacktrack.
  ///
  /// In vi, this message translates to:
  /// **'Thoát Backtrack'**
  String get exitBacktrack;

  /// No description provided for @returnAlongRoute.
  ///
  /// In vi, this message translates to:
  /// **'Quay lại theo đường đã đi'**
  String get returnAlongRoute;

  /// No description provided for @backtrackOrangeTrailNotice.
  ///
  /// In vi, this message translates to:
  /// **'Theo dõi vệt màu cam trên bản đồ để quay trở lại điểm xuất phát an toàn.'**
  String get backtrackOrangeTrailNotice;

  /// No description provided for @checkinPointLegend.
  ///
  /// In vi, this message translates to:
  /// **'Điểm check-in'**
  String get checkinPointLegend;

  /// No description provided for @yourMarkerLegend.
  ///
  /// In vi, this message translates to:
  /// **'Điểm mốc của bạn'**
  String get yourMarkerLegend;

  /// No description provided for @yourLocationAccuracy.
  ///
  /// In vi, this message translates to:
  /// **'Vị trí của bạn (±{accuracy}m)'**
  String yourLocationAccuracy(String accuracy);

  /// No description provided for @sendMarkersToAdminCount.
  ///
  /// In vi, this message translates to:
  /// **'Gửi {count} điểm mốc cho Admin'**
  String sendMarkersToAdminCount(int count);

  /// No description provided for @markMilestoneButton.
  ///
  /// In vi, this message translates to:
  /// **'Đánh dấu mốc'**
  String get markMilestoneButton;

  /// No description provided for @savingJourneyProgress.
  ///
  /// In vi, this message translates to:
  /// **'Đang lưu dữ liệu hành trình...'**
  String get savingJourneyProgress;

  /// No description provided for @finishJourneyButton.
  ///
  /// In vi, this message translates to:
  /// **'Kết thúc hành trình'**
  String get finishJourneyButton;

  /// No description provided for @shareToCommunityButton.
  ///
  /// In vi, this message translates to:
  /// **'Chia sẻ lên cộng đồng'**
  String get shareToCommunityButton;

  /// No description provided for @shareRouteToAdminButton.
  ///
  /// In vi, this message translates to:
  /// **'Đóng góp tuyến đường cho Admin'**
  String get shareRouteToAdminButton;

  /// No description provided for @cannotOpenRouteShare.
  ///
  /// In vi, this message translates to:
  /// **'Không thể mở chia sẻ tuyến đường: {error}'**
  String cannotOpenRouteShare(String error);

  /// No description provided for @offlineMapAvailable.
  ///
  /// In vi, this message translates to:
  /// **'Bản đồ offline khả dụng'**
  String get offlineMapAvailable;

  /// No description provided for @offlineMapNotDownloaded.
  ///
  /// In vi, this message translates to:
  /// **'Chưa tải bản đồ offline'**
  String get offlineMapNotDownloaded;

  /// No description provided for @tapViewMapNotice.
  ///
  /// In vi, this message translates to:
  /// **'Chạm để xem bản đồ lộ trình chi tiết'**
  String get tapViewMapNotice;

  /// No description provided for @checkinPhotosCount.
  ///
  /// In vi, this message translates to:
  /// **'Ảnh check-in ({count})'**
  String checkinPhotosCount(int count);

  /// No description provided for @cannotOpenJourneyData.
  ///
  /// In vi, this message translates to:
  /// **'Không thể mở dữ liệu hành trình'**
  String get cannotOpenJourneyData;

  /// No description provided for @journeyPlansLabel.
  ///
  /// In vi, this message translates to:
  /// **'Kế hoạch hành trình'**
  String get journeyPlansLabel;

  /// No description provided for @journeyEstimatedTotal.
  ///
  /// In vi, this message translates to:
  /// **'Ước tính tổng cộng: {count} ngày'**
  String journeyEstimatedTotal(int count);

  /// No description provided for @personCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} người'**
  String personCount(int count);

  /// No description provided for @provincesLabel.
  ///
  /// In vi, this message translates to:
  /// **'Tỉnh thành'**
  String get provincesLabel;

  /// No description provided for @noPlansYet.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có kế hoạch hành trình nào'**
  String get noPlansYet;

  /// No description provided for @startFirstJourneyHint.
  ///
  /// In vi, this message translates to:
  /// **'Hãy bắt đầu chuyến đi đầu tiên của bạn!'**
  String get startFirstJourneyHint;

  /// No description provided for @createPlanForNextTripHint.
  ///
  /// In vi, this message translates to:
  /// **'Tạo kế hoạch cho chuyến đi sắp tới của bạn'**
  String get createPlanForNextTripHint;

  /// No description provided for @otherLabel.
  ///
  /// In vi, this message translates to:
  /// **'Khác'**
  String get otherLabel;

  /// No description provided for @contributionTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đóng góp tuyến đường & cột mốc'**
  String get contributionTitle;

  /// No description provided for @contributionMarkerOnlyTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đóng góp cột mốc'**
  String get contributionMarkerOnlyTitle;

  /// No description provided for @contributionSuccessTitle.
  ///
  /// In vi, this message translates to:
  /// **'Gửi đóng góp thành công!'**
  String get contributionSuccessTitle;

  /// No description provided for @contributionSavedOfflineTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đã lưu đóng góp offline!'**
  String get contributionSavedOfflineTitle;

  /// No description provided for @contributionOfflineNotice.
  ///
  /// In vi, this message translates to:
  /// **'Dữ liệu đóng góp đã được lưu trên máy của bạn. Khi có kết nối mạng, ứng dụng sẽ tự động đồng bộ và gửi đến quản trị viên để xem xét phê duyệt.'**
  String get contributionOfflineNotice;

  /// No description provided for @contributionMarkersReceived.
  ///
  /// In vi, this message translates to:
  /// **'Cảm ơn bạn đã đóng góp {count} điểm mốc mới. Quản trị viên sẽ xem xét và phê duyệt để đưa lên bản đồ chính thức của TrekViệt.'**
  String contributionMarkersReceived(int count);

  /// No description provided for @contributionRouteAndMarkersReceived.
  ///
  /// In vi, this message translates to:
  /// **'Cảm ơn bạn đã đóng góp tuyến đường cùng {count} điểm mốc mới. Quản trị viên sẽ xem xét và phê duyệt để đưa lên bản đồ chính thức của TrekViệt.'**
  String contributionRouteAndMarkersReceived(int count);

  /// No description provided for @contributionStatusPendingSync.
  ///
  /// In vi, this message translates to:
  /// **'Trạng thái: Chờ đồng bộ khi có mạng'**
  String get contributionStatusPendingSync;

  /// No description provided for @contributionViewHistoryNotice.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có thể xem lại trong Lịch sử đóng góp ở trang Hồ sơ.'**
  String get contributionViewHistoryNotice;

  /// No description provided for @contributionSourceJourney.
  ///
  /// In vi, this message translates to:
  /// **'Từ hành trình: {name}'**
  String contributionSourceJourney(String name);

  /// No description provided for @contributionNameLabel.
  ///
  /// In vi, this message translates to:
  /// **'Tên tuyến đường đề xuất *'**
  String get contributionNameLabel;

  /// No description provided for @contributionMarkerNameLabel.
  ///
  /// In vi, this message translates to:
  /// **'Tên đóng góp *'**
  String get contributionMarkerNameLabel;

  /// No description provided for @contributionNameHint.
  ///
  /// In vi, this message translates to:
  /// **'VD: Cung đường leo Fansipan qua Trạm Tôn...'**
  String get contributionNameHint;

  /// No description provided for @contributionNameRequired.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập tên tuyến đường đề xuất'**
  String get contributionNameRequired;

  /// No description provided for @contributionDescLabel.
  ///
  /// In vi, this message translates to:
  /// **'Mô tả chi tiết'**
  String get contributionDescLabel;

  /// No description provided for @contributionDescHint.
  ///
  /// In vi, this message translates to:
  /// **'Mô tả về địa hình, cảnh quan, trải nghiệm thực tế...'**
  String get contributionDescHint;

  /// No description provided for @contributionSafetyLabel.
  ///
  /// In vi, this message translates to:
  /// **'Lưu ý an toàn / Mẹo đi đường'**
  String get contributionSafetyLabel;

  /// No description provided for @contributionSafetyHint.
  ///
  /// In vi, this message translates to:
  /// **'Nguồn nước, điểm cắm trại an toàn, đoạn trơn trượt...'**
  String get contributionSafetyHint;

  /// No description provided for @contributionSelectMarkersLabel.
  ///
  /// In vi, this message translates to:
  /// **'Chọn các điểm mốc kèm theo ({count})'**
  String contributionSelectMarkersLabel(int count);

  /// No description provided for @contributionSelectMarkersHint.
  ///
  /// In vi, this message translates to:
  /// **'Đánh dấu chọn các điểm mốc cá nhân bạn đã tạo để gửi duyệt kèm tuyến đường'**
  String get contributionSelectMarkersHint;

  /// No description provided for @contributionSubmitButton.
  ///
  /// In vi, this message translates to:
  /// **'Gửi cho Admin duyệt'**
  String get contributionSubmitButton;

  /// No description provided for @contributionSkipButton.
  ///
  /// In vi, this message translates to:
  /// **'Bỏ qua đóng góp'**
  String get contributionSkipButton;

  /// No description provided for @markerFormCreateTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đánh dấu điểm mốc'**
  String get markerFormCreateTitle;

  /// No description provided for @markerFormEditTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chỉnh sửa điểm mốc'**
  String get markerFormEditTitle;

  /// No description provided for @markerNameLabel.
  ///
  /// In vi, this message translates to:
  /// **'Tên điểm mốc *'**
  String get markerNameLabel;

  /// No description provided for @markerNameHint.
  ///
  /// In vi, this message translates to:
  /// **'VD: Đỉnh núi, Suối nước, Điểm cắm trại...'**
  String get markerNameHint;

  /// No description provided for @markerTypeLabel.
  ///
  /// In vi, this message translates to:
  /// **'Loại điểm mốc'**
  String get markerTypeLabel;

  /// No description provided for @markerGpsCoordinates.
  ///
  /// In vi, this message translates to:
  /// **'Tọa độ GPS'**
  String get markerGpsCoordinates;

  /// No description provided for @markerPhotosLabel.
  ///
  /// In vi, this message translates to:
  /// **'Hình ảnh điểm mốc'**
  String get markerPhotosLabel;

  /// No description provided for @markerAddPhoto.
  ///
  /// In vi, this message translates to:
  /// **'+ Thêm ảnh'**
  String get markerAddPhoto;

  /// No description provided for @markerNoteLabel.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú thêm'**
  String get markerNoteLabel;

  /// No description provided for @markerNoteHint.
  ///
  /// In vi, this message translates to:
  /// **'Lưu ý về nguồn nước, độ dốc, sóng điện thoại...'**
  String get markerNoteHint;

  /// No description provided for @markerSaveOffline.
  ///
  /// In vi, this message translates to:
  /// **'Lưu trên máy'**
  String get markerSaveOffline;

  /// No description provided for @markerSaveAndSync.
  ///
  /// In vi, this message translates to:
  /// **'Lưu & Đồng bộ điểm mốc'**
  String get markerSaveAndSync;

  /// No description provided for @markerSyncDesc.
  ///
  /// In vi, this message translates to:
  /// **'Điểm mốc sẽ được lưu trên máy và tự động đồng bộ lên máy chủ khi có mạng.'**
  String get markerSyncDesc;

  /// No description provided for @markerSaveError.
  ///
  /// In vi, this message translates to:
  /// **'Không thể lưu điểm mốc: {error}'**
  String markerSaveError(String error);

  /// No description provided for @placeReviewTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đánh giá địa điểm'**
  String get placeReviewTitle;

  /// No description provided for @anonymousTrekker.
  ///
  /// In vi, this message translates to:
  /// **'Trekker ẩn danh'**
  String get anonymousTrekker;

  /// No description provided for @noReviewsYet.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có đánh giá'**
  String get noReviewsYet;

  /// No description provided for @viewMoreReviews.
  ///
  /// In vi, this message translates to:
  /// **'Xem thêm đánh giá'**
  String get viewMoreReviews;

  /// No description provided for @satisfactionLevelPrompt.
  ///
  /// In vi, this message translates to:
  /// **'Mức độ hài lòng của bạn?'**
  String get satisfactionLevelPrompt;

  /// No description provided for @shareExperiencePrompt.
  ///
  /// In vi, this message translates to:
  /// **'Chia sẻ trải nghiệm'**
  String get shareExperiencePrompt;

  /// No description provided for @shareExperienceHint.
  ///
  /// In vi, this message translates to:
  /// **'Chia sẻ cảm nhận, lời khuyên và trải nghiệm về địa điểm này...'**
  String get shareExperienceHint;

  /// No description provided for @addPhotosPrompt.
  ///
  /// In vi, this message translates to:
  /// **'Thêm hình ảnh'**
  String get addPhotosPrompt;

  /// No description provided for @addPhotosMax10.
  ///
  /// In vi, this message translates to:
  /// **'Tối đa 10 ảnh'**
  String get addPhotosMax10;

  /// No description provided for @anonymousReviewLabel.
  ///
  /// In vi, this message translates to:
  /// **'Đánh giá ẩn danh'**
  String get anonymousReviewLabel;

  /// No description provided for @anonymousReviewDesc.
  ///
  /// In vi, this message translates to:
  /// **'Tên của bạn sẽ không hiển thị công khai'**
  String get anonymousReviewDesc;

  /// No description provided for @submitReviewButton.
  ///
  /// In vi, this message translates to:
  /// **'Gửi đánh giá'**
  String get submitReviewButton;

  /// No description provided for @saveReviewEditButton.
  ///
  /// In vi, this message translates to:
  /// **'Lưu đánh giá'**
  String get saveReviewEditButton;

  /// No description provided for @reviewThankYouTitle.
  ///
  /// In vi, this message translates to:
  /// **'Cảm ơn bạn!'**
  String get reviewThankYouTitle;

  /// No description provided for @reviewThankYouMessage.
  ///
  /// In vi, this message translates to:
  /// **'Đánh giá của bạn đã được ghi nhận và sẽ giúp ích rất nhiều cho cộng đồng Trekker Việt Nam.'**
  String get reviewThankYouMessage;

  /// No description provided for @yourReviewSection.
  ///
  /// In vi, this message translates to:
  /// **'Đánh giá của bạn'**
  String get yourReviewSection;

  /// No description provided for @viewOtherReviewsButton.
  ///
  /// In vi, this message translates to:
  /// **'Xem các đánh giá khác'**
  String get viewOtherReviewsButton;

  /// No description provided for @backToHomeButton.
  ///
  /// In vi, this message translates to:
  /// **'Quay về trang chủ'**
  String get backToHomeButton;

  /// No description provided for @noFeaturedPlaces.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có địa điểm nổi bật nào'**
  String get noFeaturedPlaces;

  /// No description provided for @noMatchingRoutes.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy cung đường phù hợp'**
  String get noMatchingRoutes;

  /// No description provided for @noMatchingSuggestions.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy gợi ý phù hợp'**
  String get noMatchingSuggestions;

  /// No description provided for @addRouteButton.
  ///
  /// In vi, this message translates to:
  /// **'Thêm cung đường'**
  String get addRouteButton;

  /// No description provided for @addPlaceButton.
  ///
  /// In vi, this message translates to:
  /// **'Thêm địa điểm'**
  String get addPlaceButton;

  /// No description provided for @routeEstimatedDuration.
  ///
  /// In vi, this message translates to:
  /// **'Thời gian ước tính: {duration}'**
  String routeEstimatedDuration(String duration);

  /// No description provided for @routeMaxElevation.
  ///
  /// In vi, this message translates to:
  /// **'Độ cao tối đa: {elevation} m'**
  String routeMaxElevation(String elevation);

  /// No description provided for @routeElevationGain.
  ///
  /// In vi, this message translates to:
  /// **'Độ cao tích lũy: {gain} m'**
  String routeElevationGain(String gain);

  /// No description provided for @routeTotalDistance.
  ///
  /// In vi, this message translates to:
  /// **'Tổng chiều dài: {distance} km'**
  String routeTotalDistance(String distance);

  /// No description provided for @routeDescriptionTitle.
  ///
  /// In vi, this message translates to:
  /// **'Mô tả cung đường'**
  String get routeDescriptionTitle;

  /// No description provided for @routeNoDescription.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có mô tả cho cung đường này.'**
  String get routeNoDescription;

  /// No description provided for @routeDifficultyPrefix.
  ///
  /// In vi, this message translates to:
  /// **'Độ khó: {difficulty}'**
  String routeDifficultyPrefix(String difficulty);

  /// No description provided for @routePlacePrefix.
  ///
  /// In vi, this message translates to:
  /// **'Địa điểm: {place}'**
  String routePlacePrefix(String place);

  /// No description provided for @routeStartPrefix.
  ///
  /// In vi, this message translates to:
  /// **'Điểm bắt đầu: {coords}'**
  String routeStartPrefix(String coords);

  /// No description provided for @routeEndPrefix.
  ///
  /// In vi, this message translates to:
  /// **'Điểm kết thúc: {coords}'**
  String routeEndPrefix(String coords);

  /// No description provided for @downloadMapBeforeStart.
  ///
  /// In vi, this message translates to:
  /// **'Tải bản đồ trước khi bắt đầu'**
  String get downloadMapBeforeStart;

  /// No description provided for @cannotStartJourney.
  ///
  /// In vi, this message translates to:
  /// **'Không thể bắt đầu hành trình: {error}'**
  String cannotStartJourney(String error);

  /// No description provided for @backToJourneyScreen.
  ///
  /// In vi, this message translates to:
  /// **'Quay lại danh sách hành trình'**
  String get backToJourneyScreen;

  /// No description provided for @difficultyEasy.
  ///
  /// In vi, this message translates to:
  /// **'Dễ'**
  String get difficultyEasy;

  /// No description provided for @difficultyModerate.
  ///
  /// In vi, this message translates to:
  /// **'Trung bình'**
  String get difficultyModerate;

  /// No description provided for @difficultyHard.
  ///
  /// In vi, this message translates to:
  /// **'Khó'**
  String get difficultyHard;

  /// No description provided for @difficultyExpert.
  ///
  /// In vi, this message translates to:
  /// **'Chuyên nghiệp'**
  String get difficultyExpert;

  /// No description provided for @placeAboutSection.
  ///
  /// In vi, this message translates to:
  /// **'Giới thiệu'**
  String get placeAboutSection;

  /// No description provided for @placeNoDescription.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có thông tin giới thiệu cho địa điểm này.'**
  String get placeNoDescription;

  /// No description provided for @placeRoutesSection.
  ///
  /// In vi, this message translates to:
  /// **'Cung đường trekking ({count})'**
  String placeRoutesSection(int count);

  /// No description provided for @placeNoRoutes.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có cung đường nào tại địa điểm này.'**
  String get placeNoRoutes;

  /// No description provided for @offlineMapTitle.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý bản đồ Offline'**
  String get offlineMapTitle;

  /// No description provided for @offlineMapStorageUsed.
  ///
  /// In vi, this message translates to:
  /// **'Dung lượng đã dùng: {size}'**
  String offlineMapStorageUsed(String size);

  /// No description provided for @offlineMapCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} bản đồ đã tải'**
  String offlineMapCount(int count);

  /// No description provided for @noOfflineMapsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có bản đồ ngoại tuyến nào'**
  String get noOfflineMapsTitle;

  /// No description provided for @noOfflineMapsDesc.
  ///
  /// In vi, this message translates to:
  /// **'Hãy tải bản đồ của các cung đường bạn sắp đi để sử dụng khi mất kết nối mạng.'**
  String get noOfflineMapsDesc;

  /// No description provided for @deleteOfflineMapTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xóa bản đồ ngoại tuyến'**
  String get deleteOfflineMapTitle;

  /// No description provided for @deleteOfflineMapConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc chắn muốn xóa bản đồ của \"{name}\"? Bạn sẽ cần tải lại nếu muốn dùng offline.'**
  String deleteOfflineMapConfirm(String name);

  /// No description provided for @deleteOfflineMapButton.
  ///
  /// In vi, this message translates to:
  /// **'Xóa bản đồ'**
  String get deleteOfflineMapButton;

  /// No description provided for @deleteOfflineMapSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đã xóa bản đồ {name}'**
  String deleteOfflineMapSuccess(String name);

  /// No description provided for @deleteOfflineMapError.
  ///
  /// In vi, this message translates to:
  /// **'Không thể xóa bản đồ: {error}'**
  String deleteOfflineMapError(String error);

  /// No description provided for @offlineMapInUseNotice.
  ///
  /// In vi, this message translates to:
  /// **'Bản đồ \"{name}\" đang được sử dụng bởi hành trình hiện tại.'**
  String offlineMapInUseNotice(String name);

  /// No description provided for @badgeUnlocked.
  ///
  /// In vi, this message translates to:
  /// **'Đã đạt được'**
  String get badgeUnlocked;

  /// No description provided for @badgeLocked.
  ///
  /// In vi, this message translates to:
  /// **'Chưa đạt được'**
  String get badgeLocked;

  /// No description provided for @badgeAchievedDate.
  ///
  /// In vi, this message translates to:
  /// **'Đạt được ngày: {date}'**
  String badgeAchievedDate(String date);

  /// No description provided for @badgeMissionProgress.
  ///
  /// In vi, this message translates to:
  /// **'Tiến trình thử thách'**
  String get badgeMissionProgress;

  /// No description provided for @viewAll.
  ///
  /// In vi, this message translates to:
  /// **'Xem tất cả'**
  String get viewAll;

  /// No description provided for @shareAchievement.
  ///
  /// In vi, this message translates to:
  /// **'Chia sẻ thành tích'**
  String get shareAchievement;

  /// No description provided for @shareAchievementText.
  ///
  /// In vi, this message translates to:
  /// **'Mình vừa đạt được danh hiệu \"{title}\" trên TrekViệt! Cùng khám phá các cung đường trekking Việt Nam nhé!'**
  String shareAchievementText(String title);

  /// No description provided for @suggestPlaceSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đề xuất địa điểm đã được gửi thành công! Quản trị viên sẽ kiểm tra và phản hồi sớm.'**
  String get suggestPlaceSuccess;

  /// No description provided for @filterAll.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả'**
  String get filterAll;

  /// No description provided for @cannotLoadRoutesError.
  ///
  /// In vi, this message translates to:
  /// **'Không tải được một số cung đường: {error}'**
  String cannotLoadRoutesError(String error);

  /// No description provided for @noDistanceAvailable.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có cự ly'**
  String get noDistanceAvailable;

  /// No description provided for @reviewsCount.
  ///
  /// In vi, this message translates to:
  /// **'{rating} ({count} đánh giá)'**
  String reviewsCount(String rating, int count);

  /// No description provided for @durationMinutes.
  ///
  /// In vi, this message translates to:
  /// **'{minutes} phút'**
  String durationMinutes(int minutes);

  /// No description provided for @durationHours.
  ///
  /// In vi, this message translates to:
  /// **'{hours} giờ'**
  String durationHours(int hours);

  /// No description provided for @durationHoursMinutes.
  ///
  /// In vi, this message translates to:
  /// **'{hours} giờ {minutes} phút'**
  String durationHoursMinutes(int hours, int minutes);

  /// No description provided for @durationDays.
  ///
  /// In vi, this message translates to:
  /// **'{days} ngày'**
  String durationDays(String days);

  /// No description provided for @routeScope.
  ///
  /// In vi, this message translates to:
  /// **'Tuyến đường'**
  String get routeScope;

  /// No description provided for @placeScope.
  ///
  /// In vi, this message translates to:
  /// **'Địa điểm'**
  String get placeScope;

  /// No description provided for @mapInUseBadge.
  ///
  /// In vi, this message translates to:
  /// **'Đang đi'**
  String get mapInUseBadge;

  /// No description provided for @downloadedOnDate.
  ///
  /// In vi, this message translates to:
  /// **'Đã tải: {date}'**
  String downloadedOnDate(String date);

  /// No description provided for @readyForOfflineUse.
  ///
  /// In vi, this message translates to:
  /// **'Sẵn sàng sử dụng offline'**
  String get readyForOfflineUse;

  /// No description provided for @manageOfflineMaps.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý bản đồ offline'**
  String get manageOfflineMaps;

  /// No description provided for @yourContributions.
  ///
  /// In vi, this message translates to:
  /// **'Đóng góp của bạn'**
  String get yourContributions;

  /// No description provided for @tabContributionSubmitted.
  ///
  /// In vi, this message translates to:
  /// **'Đã gửi'**
  String get tabContributionSubmitted;

  /// No description provided for @tabContributionApproved.
  ///
  /// In vi, this message translates to:
  /// **'Đã duyệt'**
  String get tabContributionApproved;

  /// No description provided for @tabContributionRejected.
  ///
  /// In vi, this message translates to:
  /// **'Từ chối'**
  String get tabContributionRejected;

  /// No description provided for @rejectionReason.
  ///
  /// In vi, this message translates to:
  /// **'Lý do từ chối:'**
  String get rejectionReason;

  /// No description provided for @noRejectionReason.
  ///
  /// In vi, this message translates to:
  /// **'Không có lý do chi tiết từ quản trị viên.'**
  String get noRejectionReason;

  /// No description provided for @noContributionsSubmitted.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có đóng góp nào đang chờ duyệt.'**
  String get noContributionsSubmitted;

  /// No description provided for @noContributionsApproved.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có đóng góp nào được duyệt.'**
  String get noContributionsApproved;

  /// No description provided for @noContributionsRejected.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có đóng góp nào bị từ chối.'**
  String get noContributionsRejected;

  /// No description provided for @contributionTypeRoute.
  ///
  /// In vi, this message translates to:
  /// **'Cung đường'**
  String get contributionTypeRoute;

  /// No description provided for @contributionTypePlace.
  ///
  /// In vi, this message translates to:
  /// **'Địa điểm'**
  String get contributionTypePlace;

  /// No description provided for @contributionDate.
  ///
  /// In vi, this message translates to:
  /// **'Ngày gửi: {date}'**
  String contributionDate(String date);

  /// No description provided for @homeNoPlacesToExplore.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có địa điểm để khám phá'**
  String get homeNoPlacesToExplore;

  /// No description provided for @yourMapPosterTitle.
  ///
  /// In vi, this message translates to:
  /// **'Ảnh bản đồ của bạn'**
  String get yourMapPosterTitle;

  /// No description provided for @downloadPosterNow.
  ///
  /// In vi, this message translates to:
  /// **'Tải ảnh ngay'**
  String get downloadPosterNow;

  /// No description provided for @loadProvinces.
  ///
  /// In vi, this message translates to:
  /// **'Tải danh sách tỉnh'**
  String get loadProvinces;

  /// No description provided for @statElevation.
  ///
  /// In vi, this message translates to:
  /// **'Độ cao'**
  String get statElevation;

  /// No description provided for @statDuration.
  ///
  /// In vi, this message translates to:
  /// **'Thời gian'**
  String get statDuration;

  /// No description provided for @statRoutes.
  ///
  /// In vi, this message translates to:
  /// **'Cung đường'**
  String get statRoutes;

  /// No description provided for @difficultyExtreme.
  ///
  /// In vi, this message translates to:
  /// **'Cực khó'**
  String get difficultyExtreme;

  /// No description provided for @commonError.
  ///
  /// In vi, this message translates to:
  /// **'Đã có lỗi xảy ra. Vui lòng thử lại'**
  String get commonError;

  /// No description provided for @statTotalDistance.
  ///
  /// In vi, this message translates to:
  /// **'Tổng quãng đường'**
  String get statTotalDistance;

  /// No description provided for @statElevationGain.
  ///
  /// In vi, this message translates to:
  /// **'Độ cao tổng'**
  String get statElevationGain;

  /// No description provided for @statEstimatedDuration.
  ///
  /// In vi, this message translates to:
  /// **'Thời gian dự kiến'**
  String get statEstimatedDuration;

  /// No description provided for @storageUsedLabel.
  ///
  /// In vi, this message translates to:
  /// **'Dung lượng đã sử dụng'**
  String get storageUsedLabel;

  /// No description provided for @journeyCompletedTitle.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn thành hành trình!'**
  String get journeyCompletedTitle;

  /// No description provided for @termsOfUseTitle.
  ///
  /// In vi, this message translates to:
  /// **'Điều khoản sử dụng'**
  String get termsOfUseTitle;

  /// No description provided for @termsLastUpdated.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật lần cuối: 20/12/2025'**
  String get termsLastUpdated;

  /// No description provided for @termsSection1Title.
  ///
  /// In vi, this message translates to:
  /// **'Giới thiệu'**
  String get termsSection1Title;

  /// No description provided for @termsSection1Content.
  ///
  /// In vi, this message translates to:
  /// **'Chào mừng bạn đến với Trek Việt Nam, ứng dụng hỗ trợ điều hướng, ghi lại nhật ký hành trình trekking và kết nối cộng đồng đam mê dã ngoại tại Việt Nam. Bằng việc đăng ký tài khoản, bạn đồng ý tuân thủ các điều khoản này.'**
  String get termsSection1Content;

  /// No description provided for @termsSection2Title.
  ///
  /// In vi, this message translates to:
  /// **'Điều kiện sử dụng'**
  String get termsSection2Title;

  /// No description provided for @termsSection2Content.
  ///
  /// In vi, this message translates to:
  /// **'Bạn phải từ 16 tuổi trở lên hoặc có sự giám sát của người bảo hộ để sử dụng ứng dụng. Bạn chịu trách nhiệm hoàn toàn về tính bảo mật của mật khẩu và mọi hoạt động dưới tài khoản của mình.'**
  String get termsSection2Content;

  /// No description provided for @termsSection3Title.
  ///
  /// In vi, this message translates to:
  /// **'Quyền và nghĩa vụ của người dùng'**
  String get termsSection3Title;

  /// No description provided for @termsSection3Content.
  ///
  /// In vi, this message translates to:
  /// **'Người dùng được phép sử dụng bản đồ ngoại tuyến, lưu trữ lịch sử di chuyển và chia sẻ ảnh trekking lành mạnh lên cộng đồng. Nghiêm cấm hành vi phá hoại dữ liệu, đăng tải thông tin sai lệch về bản đồ biên giới hoặc địa danh nhạy cảm.'**
  String get termsSection3Content;

  /// No description provided for @termsSection4Title.
  ///
  /// In vi, this message translates to:
  /// **'Quyền sở hữu trí tuệ'**
  String get termsSection4Title;

  /// No description provided for @termsSection4Content.
  ///
  /// In vi, this message translates to:
  /// **'Toàn bộ mã nguồn, thiết kế đồ họa, hệ thống huy hiệu và cơ sở dữ liệu cung đường trekking độc quyền đều thuộc quyền sở hữu của Trek Việt Nam. Mọi hành vi sao chép không xin phép đều bị nghiêm cấm.'**
  String get termsSection4Content;

  /// No description provided for @termsSection5Title.
  ///
  /// In vi, this message translates to:
  /// **'Giới hạn trách nhiệm'**
  String get termsSection5Title;

  /// No description provided for @termsSection5Content.
  ///
  /// In vi, this message translates to:
  /// **'Trekking là hoạt động thể thao mạo hiểm ngoài trời. Chúng tôi cung cấp bản đồ GPS mang tính tham khảo và không chịu trách nhiệm pháp lý trước bất kỳ tai nạn, rủi ro tự nhiên hay lạc đường nào của bạn trên cung đường thực tế.'**
  String get termsSection5Content;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chính sách bảo mật'**
  String get privacyPolicyTitle;

  /// No description provided for @privacySection1Title.
  ///
  /// In vi, this message translates to:
  /// **'Thu thập dữ liệu'**
  String get privacySection1Title;

  /// No description provided for @privacySection1Content.
  ///
  /// In vi, this message translates to:
  /// **'Chúng tôi thu thập thông tin đăng ký (Tên, Email, Ảnh đại diện) và đặc biệt là dữ liệu vị trí GPS của bạn (ngay cả khi ứng dụng chạy ngầm) để vẽ bản đồ hành trình trekking và kích hoạt tính năng check-in.'**
  String get privacySection1Content;

  /// No description provided for @privacySection2Title.
  ///
  /// In vi, this message translates to:
  /// **'Sử dụng dữ liệu'**
  String get privacySection2Title;

  /// No description provided for @privacySection2Content.
  ///
  /// In vi, this message translates to:
  /// **'Dữ liệu vị trí được sử dụng để hiển thị vị trí của bạn trên bản đồ dã ngoại, thống kê tổng quãng đường di chuyển và mở khóa các huy hiệu thám hiểm cá nhân.'**
  String get privacySection2Content;

  /// No description provided for @privacySection3Title.
  ///
  /// In vi, this message translates to:
  /// **'Chia sẻ dữ liệu'**
  String get privacySection3Title;

  /// No description provided for @privacySection3Content.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin và lịch sử đi trekking của bạn chỉ được chia sẻ công khai khi bạn chủ động ấn nút \'Đăng bài viết\' trên diễn đàn Cộng đồng hoặc chia sẻ huy hiệu lên mạng xã hội.'**
  String get privacySection3Content;

  /// No description provided for @privacySection4Title.
  ///
  /// In vi, this message translates to:
  /// **'Bảo mật thông tin'**
  String get privacySection4Title;

  /// No description provided for @privacySection4Content.
  ///
  /// In vi, this message translates to:
  /// **'Trek Việt Nam áp dụng các biện pháp mã hóa đầu cuối tiên tiến nhất để bảo vệ thông tin cá nhân và dữ liệu tọa độ của bạn trước các truy cập trái phép.'**
  String get privacySection4Content;

  /// No description provided for @privacySection5Title.
  ///
  /// In vi, this message translates to:
  /// **'Quyền của bạn'**
  String get privacySection5Title;

  /// No description provided for @privacySection5Content.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có quyền truy cập, chỉnh sửa thông tin hồ sơ cá nhân hoặc yêu cầu xóa vĩnh viễn tài khoản cùng toàn bộ lịch sử định vị GPS đã lưu trên máy chủ của chúng tôi bất kỳ lúc nào.'**
  String get privacySection5Content;

  /// No description provided for @journeyOptionsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tùy chọn'**
  String get journeyOptionsTitle;

  /// No description provided for @routeDetailOption.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiết Tuyến đường'**
  String get routeDetailOption;

  /// No description provided for @journeyDetailOption.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiết Hành trình'**
  String get journeyDetailOption;

  /// No description provided for @selectPlaceTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chọn địa điểm'**
  String get selectPlaceTitle;

  /// No description provided for @cannotLoadPlaces.
  ///
  /// In vi, this message translates to:
  /// **'Không thể tải địa điểm.'**
  String get cannotLoadPlaces;

  /// No description provided for @noPlacesAvailable.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có địa điểm.'**
  String get noPlacesAvailable;

  /// No description provided for @changePlaceButton.
  ///
  /// In vi, this message translates to:
  /// **'Đổi địa điểm'**
  String get changePlaceButton;

  /// No description provided for @searchRouteHint.
  ///
  /// In vi, this message translates to:
  /// **'Tìm cung đường'**
  String get searchRouteHint;

  /// No description provided for @cannotLoadRoutesAtPlace.
  ///
  /// In vi, this message translates to:
  /// **'Không thể tải cung đường tại địa điểm này.'**
  String get cannotLoadRoutesAtPlace;

  /// No description provided for @placeHasNoRoutes.
  ///
  /// In vi, this message translates to:
  /// **'Địa điểm này chưa có cung đường.'**
  String get placeHasNoRoutes;

  /// No description provided for @routesAtPlacePrefix.
  ///
  /// In vi, this message translates to:
  /// **'Cung đường tại {place}'**
  String routesAtPlacePrefix(String place);

  /// No description provided for @downloadButton.
  ///
  /// In vi, this message translates to:
  /// **'Tải xuống'**
  String get downloadButton;

  /// No description provided for @retryDownloadButton.
  ///
  /// In vi, this message translates to:
  /// **'Thử tải lại'**
  String get retryDownloadButton;

  /// No description provided for @cannotLoadRoutesGeneral.
  ///
  /// In vi, this message translates to:
  /// **'Không thể tải cung đường. Vui lòng thử lại.'**
  String get cannotLoadRoutesGeneral;

  /// No description provided for @personalQrTitle.
  ///
  /// In vi, this message translates to:
  /// **'QR cá nhân'**
  String get personalQrTitle;

  /// No description provided for @personalQrDesc.
  ///
  /// In vi, this message translates to:
  /// **'Người khác quét mã này để xem trang cá nhân và nhắn tin cho bạn.'**
  String get personalQrDesc;

  /// No description provided for @copyCodeButton.
  ///
  /// In vi, this message translates to:
  /// **'Sao chép mã'**
  String get copyCodeButton;

  /// No description provided for @closeButton.
  ///
  /// In vi, this message translates to:
  /// **'Đóng'**
  String get closeButton;

  /// No description provided for @noBioYet.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có giới thiệu.'**
  String get noBioYet;

  /// No description provided for @userPostsCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} bài viết'**
  String userPostsCount(int count);

  /// No description provided for @aboutSection.
  ///
  /// In vi, this message translates to:
  /// **'Giới thiệu'**
  String get aboutSection;

  /// No description provided for @personalBio.
  ///
  /// In vi, this message translates to:
  /// **'Giới thiệu cá nhân'**
  String get personalBio;

  /// No description provided for @myQrCode.
  ///
  /// In vi, this message translates to:
  /// **'QR của tôi'**
  String get myQrCode;

  /// No description provided for @reissueQrDialogTitle.
  ///
  /// In vi, this message translates to:
  /// **'Cấp lại QR?'**
  String get reissueQrDialogTitle;

  /// No description provided for @reissueQrDialogMessage.
  ///
  /// In vi, this message translates to:
  /// **'Mã cũ sẽ ngừng hoạt động.'**
  String get reissueQrDialogMessage;

  /// No description provided for @reissueButton.
  ///
  /// In vi, this message translates to:
  /// **'Cấp lại'**
  String get reissueButton;

  /// No description provided for @sendMessageButton.
  ///
  /// In vi, this message translates to:
  /// **'Nhắn tin'**
  String get sendMessageButton;

  /// No description provided for @cannotStartJourneyGeneral.
  ///
  /// In vi, this message translates to:
  /// **'Không thể bắt đầu hành trình. Vui lòng thử lại.'**
  String get cannotStartJourneyGeneral;

  /// No description provided for @viewMorePosts.
  ///
  /// In vi, this message translates to:
  /// **'Xem thêm bài viết'**
  String get viewMorePosts;

  /// No description provided for @communityProfileTitle.
  ///
  /// In vi, this message translates to:
  /// **'Trang cá nhân cộng đồng'**
  String get communityProfileTitle;

  /// No description provided for @backToJourneyButton.
  ///
  /// In vi, this message translates to:
  /// **'Quay lại hành trình'**
  String get backToJourneyButton;

  /// No description provided for @markerNameRequired.
  ///
  /// In vi, this message translates to:
  /// **'Nhập tên cột mốc'**
  String get markerNameRequired;

  /// No description provided for @syncFailedCheck.
  ///
  /// In vi, this message translates to:
  /// **'Đồng bộ thất bại — cần kiểm tra'**
  String get syncFailedCheck;

  /// No description provided for @savedOfflinePendingSync.
  ///
  /// In vi, this message translates to:
  /// **'Đã lưu trên máy · chờ đồng bộ'**
  String get savedOfflinePendingSync;

  /// No description provided for @memberCountText.
  ///
  /// In vi, this message translates to:
  /// **'{count} thành viên'**
  String memberCountText(int count);

  /// No description provided for @cancelJourneyButton.
  ///
  /// In vi, this message translates to:
  /// **'Hủy hành trình'**
  String get cancelJourneyButton;

  /// No description provided for @cancelJourneyConfirmTitle.
  ///
  /// In vi, this message translates to:
  /// **'Hủy hành trình?'**
  String get cancelJourneyConfirmTitle;

  /// No description provided for @cancelJourneyConfirmMessage.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc chắn muốn hủy hành trình này không? Trạng thái sẽ chuyển sang đã hủy.'**
  String get cancelJourneyConfirmMessage;

  /// No description provided for @editReviewOnceButton.
  ///
  /// In vi, this message translates to:
  /// **'Chỉnh sửa đánh giá (1 lần)'**
  String get editReviewOnceButton;

  /// No description provided for @completeJourneyToReview.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn thành hành trình tại đây để đánh giá.'**
  String get completeJourneyToReview;

  /// No description provided for @reviewRemoved.
  ///
  /// In vi, this message translates to:
  /// **'Đánh giá của bạn đã được gỡ.'**
  String get reviewRemoved;

  /// No description provided for @reviewEditLimitReached.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đã dùng lượt chỉnh sửa đánh giá.'**
  String get reviewEditLimitReached;

  /// No description provided for @viewAllReviewsButton.
  ///
  /// In vi, this message translates to:
  /// **'Xem tất cả đánh giá'**
  String get viewAllReviewsButton;
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
