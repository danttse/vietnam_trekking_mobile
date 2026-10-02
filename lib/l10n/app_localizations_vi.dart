// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appName => 'TrekViệt';

  @override
  String get appTagline => 'Hành trình mây ngàn Việt Nam';

  @override
  String get loginTitle => 'ĐĂNG NHẬP';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'Nhập email';

  @override
  String get passwordLabel => 'Mật khẩu';

  @override
  String get passwordHint => 'Nhập mật khẩu';

  @override
  String get forgotPassword => 'Quên mật khẩu?';

  @override
  String get loginButton => 'Đăng nhập';

  @override
  String get loginWithGoogle => 'Đăng nhập với Google';

  @override
  String get orDivider => 'Hoặc';

  @override
  String get noAccount => 'Bạn chưa có tài khoản?';

  @override
  String get registerNow => 'Đăng ký ngay';

  @override
  String get registerTitle => 'ĐĂNG KÝ';

  @override
  String get fullNameLabel => 'Họ và tên';

  @override
  String get fullNameHint => 'Nhập họ và tên';

  @override
  String get confirmPasswordLabel => 'Xác nhận mật khẩu';

  @override
  String get confirmPasswordHint => 'Nhập lại mật khẩu';

  @override
  String get agreeToTermsPrefix => 'Tôi đồng ý với ';

  @override
  String get termsOfService => 'Điều khoản dịch vụ';

  @override
  String get and => ' & ';

  @override
  String get privacyPolicy => 'Chính sách bảo mật';

  @override
  String get registerButton => 'Đăng ký';

  @override
  String get registerWithGoogle => 'Đăng ký với Google';

  @override
  String get alreadyHaveAccount => 'Bạn đã có tài khoản?';

  @override
  String get forgotPasswordTitle => 'Khôi phục mật khẩu';

  @override
  String get resetPasswordTitle => 'Đặt lại mật khẩu';

  @override
  String get forgotPasswordDescription =>
      'Nhập email đã đăng ký của bạn bên dưới. Chúng tôi\nsẽ gửi một liên kết an toàn để bạn đặt lại\nmật khẩu mới.';

  @override
  String get sendResetLink => 'Gửi liên kết đặt lại';

  @override
  String get resetPasswordDescription =>
      'Vui lòng nhập mật khẩu mới cho tài khoản của bạn.';

  @override
  String get newPasswordLabel => 'Mật khẩu mới';

  @override
  String get newPasswordHint => 'Nhập mật khẩu mới';

  @override
  String get updatePasswordButton => 'Cập nhật mật khẩu';

  @override
  String get backToLogin => 'Quay lại ';

  @override
  String get otpVerifiedSuccess =>
      'Xác thực OTP thành công! Vui lòng nhập mật khẩu mới.';

  @override
  String get updatePasswordSuccess =>
      'Cập nhật mật khẩu thành công! Vui lòng đăng nhập lại.';

  @override
  String get otpDialogTitle => 'Nhập mã xác thực';

  @override
  String get otpSentTo => 'Mã OTP đã được gửi đến:';

  @override
  String get resendOtp => 'Gửi lại mã';

  @override
  String get cancelButton => 'Hủy';

  @override
  String get confirmButton => 'Xác nhận';

  @override
  String get navHome => 'Trang chủ';

  @override
  String get navExplore => 'Khám phá';

  @override
  String get navCommunity => 'Cộng đồng';

  @override
  String get navJourney => 'Hành trình';

  @override
  String get navProfile => 'Hồ sơ';

  @override
  String get featureInDevelopment => 'Tính năng đang được phát triển';

  @override
  String get homeRankLabel => 'PHÂN HẠNG';

  @override
  String get homeStatProvinces => 'Tỉnh thành';

  @override
  String get homeStatDistance => 'Quãng đường';

  @override
  String get homeStatTrips => 'Chuyến đi';

  @override
  String get homeRecentCheckin => 'Check-In gần đây';

  @override
  String get provinceSheetTitle => 'Tỉnh thành đã đi';

  @override
  String get regionNorth => 'Miền Bắc';

  @override
  String get regionCentral => 'Miền Trung';

  @override
  String get regionSouth => 'Miền Nam';

  @override
  String get saveButton => 'Lưu';

  @override
  String get profileTitle => 'Hồ Sơ';

  @override
  String memberSince(String date) {
    return 'Thành viên từ $date';
  }

  @override
  String get profileProvinceMapTitle => 'Bản đồ tỉnh thành';

  @override
  String get profileProvinceUnit => 'tỉnh';

  @override
  String get profileStatTotalDistance => 'Tổng quãng đường';

  @override
  String get profileStatVisitedProvinces => 'Tỉnh thành đi qua';

  @override
  String get profileStatCompletedTrips => 'Chuyến đi hoàn thành';

  @override
  String get profileStatTotalDays => 'Tổng số ngày đi';

  @override
  String get profileAchievementsTitle => 'DANH HIỆU CỦA BẠN';

  @override
  String get settingsTitle => 'Cài Đặt';

  @override
  String get settingsGroupAccount => 'TÀI KHOẢN';

  @override
  String get settingsChangePassword => 'Đổi mật khẩu';

  @override
  String get settingsChangeLanguage => 'Đổi ngôn ngữ';

  @override
  String get settingsChangeAvatar => 'Đổi ảnh đại diện';

  @override
  String get settingsGroupAppearance => 'GIAO DIỆN';

  @override
  String get settingsDarkMode => 'Chế độ tối';

  @override
  String get settingsGroupContribute => 'ĐÓNG GÓP';

  @override
  String get settingsSuggestPlace => 'Đề xuất địa điểm mới';

  @override
  String get settingsSupportFeedback => 'Hỗ trợ & Phản hồi';

  @override
  String get settingsGroupOther => 'KHÁC';

  @override
  String get settingsTermsOfUse => 'Điều khoản sử dụng';

  @override
  String get settingsPrivacyPolicy => 'Chính sách quyền riêng tư';

  @override
  String get logoutButton => 'Đăng xuất';

  @override
  String get proposePlace => 'Đề xuất địa điểm mới';

  @override
  String get submitPropose => 'Gửi đề xuất';

  @override
  String get placeName => 'Tên địa điểm';

  @override
  String get enterPlaceName => 'Nhập tên địa điểm';

  @override
  String get provinceCity => 'Tỉnh/Thành phố';

  @override
  String get gpsCoordinates => 'Tọa độ GPS';

  @override
  String get getCurrentLocation => 'Lấy vị trí hiện tại';

  @override
  String get elevation => 'Độ cao (m)';

  @override
  String get difficulty => 'Độ khó';

  @override
  String get placeDescription => 'Mô tả địa điểm';

  @override
  String get enterPlaceDescription =>
      'Nhập thông tin mô tả chi tiết cung đường hoặc lưu ý khi trekking tại địa điểm này...';

  @override
  String get addImages => 'Thêm hình ảnh';

  @override
  String get addPhoto => '+ Thêm ảnh';

  @override
  String get suggestionNotice =>
      'Đề xuất của bạn sẽ được gửi về email quản trị viên để xem xét phê duyệt và cập nhật chính thức trên bản đồ TrekViệt.';

  @override
  String get featuredDestinations => 'Điểm đến nổi bật';

  @override
  String get popularTrails => 'Cung đường phổ biến';

  @override
  String get recommendedForYou => 'Gợi ý dành cho bạn';

  @override
  String get searchTrailsPlaces => 'Tìm cung đường, địa danh trekking...';

  @override
  String get seeAll => 'Xem tất cả';

  @override
  String get north => 'Miền Bắc';

  @override
  String get central => 'Miền Trung';

  @override
  String get south => 'Miền Nam';

  @override
  String get popular => 'Phổ biến';

  @override
  String get editBio => 'Chỉnh sửa Bio';

  @override
  String get titleBioBox => 'Giới thiệu bản thân (BIO)';

  @override
  String get editAvatar => 'Đổi Ảnh Đại Diện';

  @override
  String get avatarPickerTitle => 'TÙY CHỌN TẢI ẢNH';

  @override
  String get takeNewPhoto => 'Chụp ảnh mới';

  @override
  String get chooseFromLibrary => 'Chọn từ thư viện';

  @override
  String featureComingSoon(String feature) {
    return 'Tính năng $feature đang phát triển';
  }

  @override
  String get changePasswordTitle => 'Đổi Mật Khẩu';

  @override
  String get currentPasswordLabel => 'MẬT KHẨU HIỆN TẠI';

  @override
  String get currentPasswordHint => 'Nhập mật khẩu hiện tại';

  @override
  String get newPasswordLabelUpper => 'MẬT KHẨU MỚI';

  @override
  String get confirmNewPasswordLabelUpper => 'XÁC NHẬN MẬT KHẨU MỚI';

  @override
  String get confirmNewPasswordHint => 'Xác nhận lại mật khẩu mới';

  @override
  String get pleaseFillAllFields => 'Vui lòng nhập đầy đủ thông tin';

  @override
  String get passwordsDoNotMatch => 'Mật khẩu xác nhận không khớp';

  @override
  String get passwordTooShort => 'Mật khẩu phải có ít nhất 6 ký tự';

  @override
  String get changePasswordSuccess => 'Đổi mật khẩu thành công!';

  @override
  String get createNewPostHintText => 'Chia sẻ trải nghiệm trekking của bạn';
}
