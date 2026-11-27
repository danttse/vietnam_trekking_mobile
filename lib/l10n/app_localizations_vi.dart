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
    return 'Tính năng sắp ra mắt';
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

  @override
  String get communityTabPosts => 'Bài viết';

  @override
  String get communityTabGroups => 'Nhóm';

  @override
  String get communityTabPersonal => 'Cá nhân';

  @override
  String get postHideThis => 'Ẩn bài viết này';

  @override
  String get postHideSubtitle =>
      'Bớt nhìn thấy các bài viết tương tự trên bảng tin';

  @override
  String get postHiddenMessage => 'Đã ẩn bài viết';

  @override
  String get undo => 'Hoàn tác';

  @override
  String postHideAllFrom(String authorName) {
    return 'Ẩn tất cả từ $authorName';
  }

  @override
  String get thisPerson => 'người này';

  @override
  String get postReport => 'Báo cáo bài viết';

  @override
  String get postReportSuccess =>
      'Cảm ơn bạn đã gửi báo cáo. Chúng tôi sẽ xem xét nội dung này.';

  @override
  String get communityNoPosts => 'Chưa có bài viết nào';

  @override
  String get commentsTitle => 'Bình luận';

  @override
  String get noCommentsYet => 'Chưa có bình luận nào';

  @override
  String get beFirstToComment => 'Hãy là người đầu tiên bình luận!';

  @override
  String replyingTo(String userName) {
    return 'Đang trả lời $userName';
  }

  @override
  String replyToHint(String userName) {
    return 'Trả lời @$userName...';
  }

  @override
  String get writeCommentHint => 'Viết bình luận...';

  @override
  String get journeyCompleted => 'Đã hoàn thành';

  @override
  String get journeyUpcoming => 'Sắp tới';

  @override
  String get journeyCancelled => 'Đã hủy';

  @override
  String get journeyStatTrips => 'Chuyến đi';

  @override
  String get journeyStatDistance => 'Quãng đường';

  @override
  String get journeyStatCompanions => 'Người đồng hành';

  @override
  String get journeyEmptyList => 'Chưa có hành trình nào';

  @override
  String get createNewJourneyTitle => 'Tạo hành trình mới';

  @override
  String get journeyNameLabel => 'Tên chuyến đi';

  @override
  String get journeyNameHint => 'Nhập tên chuyến đi';

  @override
  String get journeyStartDateLabel => 'Ngày bắt đầu';

  @override
  String get journeyEndDateLabel => 'Ngày kết thúc';

  @override
  String get participantCountLabel => 'Số người tham gia';

  @override
  String get participantCountHint => 'Nhập số người tham gia';

  @override
  String get journeyNoteLabel => 'Ghi chú/Mô tả';

  @override
  String get journeyNoteHint => 'Nhập ghi chú hoặc mô tả cho chuyến đi';

  @override
  String get selectRouteLabel => 'Tuyến đường';

  @override
  String get selectRouteHint => 'Chọn tuyến đường trekking';

  @override
  String get selectRouteSheetTitle => 'Chọn tuyến đường';

  @override
  String get createJourneyButton => 'Tạo hành trình';

  @override
  String get createJourneySuccess => 'Đã tạo hành trình thành công!';

  @override
  String get milestonesSectionTitle => 'CÁC MỐC HÀNH TRÌNH';

  @override
  String get milestoneCheckedIn => 'Đã check-in';

  @override
  String get milestoneNotCheckedIn => 'Chưa đến';

  @override
  String get milestoneCheckInButton => 'Check In';

  @override
  String milestoneAltitude(String altitude) {
    return '$altitude m so mực nước biển';
  }

  @override
  String milestoneProgress(int checked, int total) {
    return '$checked/$total mốc';
  }

  @override
  String get journeyDetailMapTitle => 'BẢN ĐỒ LỘ TRÌNH';

  @override
  String get journeyDetailDownloadMap => 'Tải bản đồ Offline';

  @override
  String get journeyDetailViewMap => 'Xem bản đồ Offline';

  @override
  String get journeyActionStart => 'Bắt đầu hành trình';

  @override
  String get journeyActionPause => 'Tạm dừng hành trình';

  @override
  String get journeyActionResume => 'Tiếp tục hành trình';

  @override
  String get journeyActionViewMap => 'Xem bản đồ';

  @override
  String get journeyRemainingTime => 'Thời gian còn lại';

  @override
  String get journeyCurrentElevation => 'Độ cao hiện tại';

  @override
  String get journeyProgressTitle => 'Tiến trình hành trình';

  @override
  String get journeyCheckinPoints => 'Điểm check-in';

  @override
  String get journeyStatusPlanned => 'DỰ KIẾN';

  @override
  String get journeyStatusActive => 'ĐANG ĐI';

  @override
  String get journeyStatusPaused => 'TẠM DỪNG';

  @override
  String get journeyStatusCompleted => 'HOÀN THÀNH';

  @override
  String get journeyStatusCancelled => 'ĐÃ HỦY';

  @override
  String get downloadOfflineMapTitle => 'Tải bản đồ Offline';

  @override
  String get downloadOfflineMapSubtitle =>
      'Lưu trữ dữ liệu địa hình ngoại tuyến để đề phòng mất sóng.';

  @override
  String get downloading => 'ĐANG TẢI...';

  @override
  String get cancelDownload => 'Hủy tải xuống';

  @override
  String mapDataHeader(String name) {
    return 'Dữ liệu $name Map';
  }

  @override
  String get mapLabel => 'Bản đồ';

  @override
  String get zoomLevelLabel => 'Mức Zoom';

  @override
  String get zoomLevelDetail => '12 – 17 (Chi tiết)';

  @override
  String get fileSizeLabel => 'Dung lượng';

  @override
  String get waypointsLabel => 'Điểm kiểm soát';

  @override
  String waypointsCount(int count) {
    return '$count Waypoints';
  }

  @override
  String get trailSupportLabel => 'Đường mòn';

  @override
  String get supported => 'Có hỗ trợ';

  @override
  String get mapReadyTitle => 'Bản đồ đã sẵn sàng!';

  @override
  String get mapReadySubtitle =>
      'Mọi dữ liệu đã được lưu trữ an toàn ngoại tuyến.';

  @override
  String get mapPackageInfoTitle => 'THÔNG TIN GÓI BẢN ĐỒ';

  @override
  String get offlineMapFeature => 'Offline Map (Bản đồ ngoại tuyến)';

  @override
  String get hikingTrailFeature => 'Hiking Trail (Đường mòn chi tiết)';

  @override
  String get waypointsFeature => 'Waypoints (Các điểm dừng chân)';

  @override
  String get backtrackFeature => 'Backtrack (Chế độ quay lại tự động)';

  @override
  String get checkinControlPointTitle => 'Điểm kiểm soát Check-in';

  @override
  String get checkinTargetPointLabel => 'ĐIỂM CẦN ĐẾN';

  @override
  String checkinTargetAltitude(String altitude) {
    return 'Độ cao mục tiêu: $altitude m';
  }

  @override
  String checkinWithinRange(int distance) {
    return 'Bạn đang ở trong phạm vi check-in! (Cách ${distance}m)';
  }

  @override
  String get checkinNowButton => 'Check-in ngay';

  @override
  String get checkinAlreadySuccess => 'Đã check-in thành công';

  @override
  String get checkinRadiusNotice =>
      'Bạn cần ở trong phạm vi bán kính 500m để có thể check-in thành công.';

  @override
  String checkinSuccessToast(String name) {
    return 'Đã check-in thành công tại $name!';
  }

  @override
  String get checkinCongratulation => 'CHÚC MỪNG!';

  @override
  String get checkinSuccessTitle => 'Check-in thành công!';

  @override
  String checkinSuccessMessage(String name) {
    return 'Bạn đã hoàn thành điểm mốc $name.';
  }

  @override
  String get achievementsEarnedTitle => 'HUY HIỆU ĐÃ ĐẠT ĐƯỢC';

  @override
  String get statNewBadge => 'Huy hiệu mới';

  @override
  String get statMaxElevation => 'Điểm cao nhất';

  @override
  String get statConqueredProvinces => 'Tỉnh đã chinh phục';

  @override
  String get continueJourneyButton => 'Tiếp tục hành trình';

  @override
  String get ratePlaceButton => 'Đánh giá địa điểm';

  @override
  String get shareAchievementButton => 'Chia sẻ thành tích';

  @override
  String milestoneConquerBadgeTitle(String name) {
    return 'Chinh phục $name';
  }

  @override
  String milestoneConquerBadgeDesc(String name, String altitude) {
    return 'Ghi dấu chân thành công tại $name ở độ cao ${altitude}m';
  }

  @override
  String milestoneConquerBadgeDescSimple(String name) {
    return 'Ghi dấu chân thành công tại điểm mốc $name';
  }

  @override
  String get ratePlaceTitle => 'Đánh giá địa điểm';

  @override
  String get rateSatisfactionLevel => 'MỨC ĐỘ HÀI LÒNG CỦA BẠN?';

  @override
  String get rateShareExperience => 'CHIA SẺ TRẢI NGHIỆM';

  @override
  String get rateExperienceHint =>
      'Chia sẻ cảm nhận, lời khuyên và trải nghiệm về điểm mốc này...';

  @override
  String get rateAnonymousLabel => 'Đánh giá ẩn danh';

  @override
  String get rateAnonymousDesc => 'Tên của bạn sẽ không hiển thị công khai';

  @override
  String get rateSubmitButton => 'Gửi đánh giá';

  @override
  String get rateThankYouTitle => 'Cảm ơn bạn!';

  @override
  String get rateThankYouMessage =>
      'Đánh giá của bạn đã được gửi thành công và sẽ giúp ích rất nhiều cho cộng đồng Trekker Việt Nam.';

  @override
  String get rateYourReviewTitle => 'ĐÁNH GIÁ CỦA BẠN';

  @override
  String rateStarsSummary(int rating, String name) {
    return '$rating/5 sao - $name';
  }

  @override
  String get rateViewOtherReviews => 'Xem đánh giá khác';

  @override
  String get rateBackToHome => 'Quay về trang chủ';

  @override
  String get badgeDetailTitle => 'Chi tiết huy hiệu';

  @override
  String get missionProgressTitle => 'TIẾN TRÌNH NHIỆM VỤ';

  @override
  String get otherBadgesTitle => 'HUY HIỆU KHÁC CỦA BẠN';

  @override
  String achievedDatePrefix(String date) {
    return 'Ngày đạt được: $date';
  }

  @override
  String get allBadgesTitle => 'Tất cả huy hiệu';

  @override
  String get promoteSkip => 'Bỏ qua';

  @override
  String get promoteNext => 'Tiếp theo';

  @override
  String get promoteStart => 'Bắt đầu sử dụng';

  @override
  String get promoteExploreTitle => 'Khám phá địa điểm trekking khắp Việt Nam';

  @override
  String get promoteExploreDesc =>
      'Tìm hiểu các cung đường, địa điểm đẹp, thông tin chi tiết, đánh giá từ cộng đồng.';

  @override
  String get promoteGpsTitle => 'Tạo hành trình và ghi lại GPS';

  @override
  String get promoteGpsDesc =>
      'Lên kế hoạch, ghi lại hành trình thực tế, check-in cột mốc và xem lại đường đi (track logs).';

  @override
  String get promoteGpsRecording => 'ĐANG GHI';

  @override
  String get promoteGpsDistance => 'Quãng đường';

  @override
  String get promoteGpsElevation => 'Độ cao';

  @override
  String get promoteGpsSpeed => 'Vận tốc';

  @override
  String get promoteOfflineTitle => 'Hoạt động offline\nmọi lúc mọi nơi';

  @override
  String get promoteOfflineDesc =>
      'Tải bản đồ, dữ liệu địa điểm để sử dụng ngay cả khi không có Internet.';

  @override
  String get promoteOfflineMapTitle => 'Bản đồ offline (MBTiles)';

  @override
  String get promoteOfflineMapSubtitle => 'Dung lượng tối ưu, tải nhanh chóng';

  @override
  String get promoteOfflineFavoriteTitle => 'Lưu địa điểm yêu thích';

  @override
  String get promoteOfflineFavoriteSubtitle =>
      'Không lo mất dấu tọa độ quan trọng';

  @override
  String get promoteOfflineGpsTitle => 'Ghi GPS và check-in';

  @override
  String get promoteOfflineGpsSubtitle => 'Vẫn lưu đầy đủ lịch sử chuyến đi';

  @override
  String get promoteStatsTitle => 'Theo dõi hành trình và\nthành tựu';

  @override
  String get promoteStatsDesc =>
      'Lưu dấu 34 tỉnh đã đi, thu thập huy hiệu và xem thống kê hành trình của bạn.';

  @override
  String get promoteStatsProvinces => 'Tỉnh thành đã đi';

  @override
  String get promoteStatsDistance => 'Quãng đường đã đi';

  @override
  String get promoteStatsBadgeMountain => 'Núi rừng';

  @override
  String get promoteStatsBadgeMountainSub => '5 đỉnh chinh phục';

  @override
  String get promoteStatsBadgeIsland => 'Biển đảo';

  @override
  String get promoteStatsBadgeIslandSub => '3 vùng vịnh';

  @override
  String get promoteStatsBadgeExplore => 'Khám phá';

  @override
  String get promoteStatsBadgeExploreSub => '10 tỉnh thành';

  @override
  String get promoteCommunityTitle => 'Kết nối cộng đồng yêu trekking';

  @override
  String get promoteCommunityDesc =>
      'Chia sẻ hành trình, ảnh, kinh nghiệm và tương tác với những người có cùng đam mê.';

  @override
  String get supportFaqHeader => 'CÂU HỎI THƯỜNG GẶP';

  @override
  String get supportFeedbackHeader => 'GỬI PHẢN HỒI CHO CHÚNG TÔI';

  @override
  String get supportIssueTypeLabel => 'LOẠI VẤN ĐỀ';

  @override
  String get supportDescriptionLabel => 'MÔ TẢ CHI TIẾT';

  @override
  String get supportDescriptionHint =>
      'Mô tả lỗi hoặc đề xuất của bạn tại đây...';

  @override
  String get supportSubmitButton => 'Gửi phản hồi';

  @override
  String get supportDirectEmail => 'Hoặc gửi thư trực tiếp đến chúng tôi qua';

  @override
  String get supportEmptyError => 'Vui lòng nhập mô tả chi tiết của bạn';

  @override
  String get supportSuccessMessage =>
      'Cảm ơn bạn đã gửi phản hồi! Chúng tôi sẽ phản hồi sớm nhất.';

  @override
  String get supportIssueGpsMap => 'Lỗi định vị GPS / Bản đồ';

  @override
  String get supportIssueAccount => 'Lỗi tài khoản / Đăng nhập';

  @override
  String get supportIssueContent => 'Đóng góp nội dung / Địa điểm';

  @override
  String get supportIssueAppExperience => 'Góp ý trải nghiệm ứng dụng';

  @override
  String get supportIssueOther => 'Vấn đề khác';

  @override
  String get supportFaq1Q => 'Làm sao để check-in tại cột mốc?';

  @override
  String get supportFaq1A =>
      'Bật định vị GPS trên điện thoại của bạn, di chuyển đến phạm vi 50m quanh cột mốc và nhấn nút ‘Check-in ngay’ trên màn hình Bản đồ hành trình.';

  @override
  String get supportFaq2Q => 'Huy hiệu hoạt động như thế nào?';

  @override
  String get supportFaq2A =>
      'Huy hiệu sẽ tự động được mở khóa khi bạn hoàn thành các thử thách trekking, chinh phục các đỉnh núi hoặc hoàn thành các mốc khám phá tỉnh thành.';

  @override
  String get supportFaq3Q => 'Cách tạo hành trình mới?';

  @override
  String get supportFaq3A =>
      'Vào mục Hành trình, nhấn biểu tượng dấu (+) hoặc nút ‘Bắt đầu hành trình’ để bật chế độ ghi GPS thời gian thực và lưu lại cung đường của bạn.';

  @override
  String get rankSectionTitle => 'HẠNG TREKKING CỦA BẠN';

  @override
  String rankXpEarned(String xp) {
    return 'Bạn nhận được +$xp XP';
  }

  @override
  String rankPromoted(String name, int level) {
    return 'Lên hạng $name · Level $level!';
  }

  @override
  String get rankDetailTitle => 'Hạng và XP';

  @override
  String rankLevel(int level) {
    return 'Level $level';
  }

  @override
  String get rankViewDetails => 'Xem chi tiết các hạng';

  @override
  String get rankCurrentXp => 'XP hiện tại';

  @override
  String rankNextTarget(String name) {
    return 'Hạng tiếp theo: $name';
  }

  @override
  String rankXpRemaining(String xp) {
    return 'Cần thêm $xp XP để đạt mốc XP tiếp theo';
  }

  @override
  String get rankXpReached =>
      'Đã đủ XP. Hoàn thành các điều kiện còn lại để lên hạng.';

  @override
  String get rankHighest => 'Bạn đã đạt hạng cao nhất!';

  @override
  String get rankRequirementsTitle => 'ĐIỀU KIỆN LÊN HẠNG';

  @override
  String get rankRequirementsHint =>
      'Cần đạt đủ các điều kiện. Hạng được cập nhật theo hoạt động đã xác nhận của bạn.';

  @override
  String get rankAllTitle => 'TẤT CẢ CÁC HẠNG';

  @override
  String get rankCurrent => 'Hiện tại';

  @override
  String get rankUnavailable => 'Chưa tải được hạng của bạn';

  @override
  String get rankLoading => 'Đang tải hạng…';

  @override
  String get rankCatalogEmpty => 'Chưa có danh sách hạng';

  @override
  String get rankRetry => 'Thử lại';

  @override
  String get rankXpLabel => 'Điểm XP';

  @override
  String get rankJourneysLabel => 'Hành trình hoàn thành';

  @override
  String get rankProvincesLabel => 'Tỉnh thành đã đi';

  @override
  String get rankBadgesLabel => 'Huy hiệu';

  @override
  String get rankDistanceLabel => 'Quãng đường (km)';

  @override
  String get rankContributionsLabel => 'Đóng góp được duyệt';

  @override
  String rankOverallProgress(String percent) {
    return 'Tiến độ các điều kiện: $percent%';
  }

  @override
  String get rankPromotionTitle => 'Chúc mừng bạn thăng hạng!';

  @override
  String get xpHistoryHint =>
      'XP được tự động cập nhật sau hoạt động đã xác nhận. Xem lại các lần nhận và điều chỉnh XP tại đây.';

  @override
  String get xpRouteApproved => 'Đóng góp cung đường được duyệt';

  @override
  String get xpJourneyCompleted => 'Hoàn thành hành trình';

  @override
  String get xpHistoryTitle => 'Lịch sử XP';

  @override
  String get xpReversal => 'Thu hồi XP';

  @override
  String get xpMilestoneCheckin => 'Check-in cột mốc';

  @override
  String get xpHistoryLoadMore => 'Xem thêm';

  @override
  String get xpJourneyElevation => 'Độ cao đã chinh phục';

  @override
  String get xpOtherActivity => 'Phần thưởng hoạt động';

  @override
  String get xpAdminAdjustment => 'Điều chỉnh XP';

  @override
  String get xpJourneyDistance => 'Quãng đường đã đi';

  @override
  String get xpProvinceVisited => 'Khám phá tỉnh mới';

  @override
  String get rankPromotionMessage =>
      'Những hành trình của bạn đã tạo nên một cột mốc mới. Tiếp tục khám phá nhé!';

  @override
  String get xpPlaceApproved => 'Đóng góp địa điểm được duyệt';

  @override
  String get xpPlaceVisited => 'Ghé thăm địa điểm';

  @override
  String get rankPromotionContinue => 'Tiếp tục khám phá';

  @override
  String get xpBadgeEarned => 'Nhận huy hiệu';

  @override
  String get xpHistoryEmpty =>
      'Bạn chưa có lịch sử XP. Bắt đầu hành trình khám phá nhé!';

  @override
  String get otpVerificationTitle => 'Xác thực Email';

  @override
  String get otpExpiredLabel => 'OTP hết hạn. Vui lòng gửi lại.';

  @override
  String get otpExpiresIn => 'OTP hết hạn sau';

  @override
  String get otpIncompleteError => 'Vui lòng nhập đủ 6 chữ số OTP';

  @override
  String get otpResendSuccess => 'Đã gửi lại mã OTP. Vui lòng kiểm tra email.';

  @override
  String get journeyMilestonesLoading => 'Đang tải điểm check-in…';

  @override
  String get journeyMilestonesLoadFailed => 'Chưa tải được điểm check-in';

  @override
  String get journeyMilestonesEmpty => 'Chưa có điểm check-in';

  @override
  String get journeyMilestonesEmptyMessage =>
      'Cung đường này chưa có cột mốc check-in chính thức. Quản trị viên cần thêm cột mốc cho cung đường trước khi bạn có thể check-in. Bạn vẫn có thể mở bản đồ để đánh dấu mốc cá nhân.';

  @override
  String get journeyReloadMilestones => 'Tải lại cột mốc';

  @override
  String get journeyCheckinClose => 'Đóng';

  @override
  String get commonRetry => 'Thử lại';

  @override
  String get commonReload => 'Tải lại';

  @override
  String get commonLoading => 'Đang tải…';

  @override
  String get commonSaving => 'Đang lưu…';

  @override
  String get commonDelete => 'Xóa';

  @override
  String get commonClose => 'Đóng';

  @override
  String get commonSaveChanges => 'Lưu thay đổi';

  @override
  String get commonViewMore => 'Xem thêm';

  @override
  String get commonNoData => 'Chưa có dữ liệu';

  @override
  String get postCreateTitle => 'Tạo bài viết';

  @override
  String get postEditTitle => 'Chỉnh sửa bài viết';

  @override
  String get postSharingWithTrekViet => 'Đang chia sẻ cùng cộng đồng TrekViệt';

  @override
  String get visibilityPublic => 'Công khai';

  @override
  String get visibilityPrivate => 'Chỉ mình tôi';

  @override
  String get whatsOnYourMind => 'Bạn đang nghĩ gì?';

  @override
  String get postAddToPost => 'Thêm vào bài viết';

  @override
  String get postAddPhoto => 'Ảnh';

  @override
  String get postMaxImagesHint => 'Chỉ có thể chọn tối đa 10 ảnh';

  @override
  String postSelectedImagesCount(int count) {
    return '$count ảnh đã chọn';
  }

  @override
  String get postRemoveImage => 'Xóa ảnh';

  @override
  String get postTagLocation => 'Gắn vị trí';

  @override
  String get postShareJourney => 'Chia sẻ hành trình';

  @override
  String get postPublishButton => 'Đăng bài';

  @override
  String get postDeleteTitle => 'Xóa bài viết';

  @override
  String get postDeleteMessage =>
      'Bạn có chắc chắn muốn xóa bài viết này không? Hành động này không thể hoàn tác.';

  @override
  String postDeleteError(String error) {
    return 'Không thể xóa bài viết: $error';
  }

  @override
  String get postCopiedToClipboard => 'Đã sao chép vào bộ nhớ tạm';

  @override
  String get postEditAction => 'Chỉnh sửa bài viết';

  @override
  String get postDeleteAction => 'Xóa bài viết';

  @override
  String get postPublishedSuccess => 'Đã đăng bài viết thành công';

  @override
  String get syncBeforeCommunityShare =>
      'Vui lòng đồng bộ hành trình trước khi chia sẻ lên cộng đồng';

  @override
  String shareJourneyDefaultContent(String name) {
    return 'Hành trình trekking $name của mình!';
  }

  @override
  String get reportFeatureUnavailable => 'Tính năng báo cáo chưa khả dụng';

  @override
  String get messagesTabTitle => 'Tin nhắn';

  @override
  String get newMessageTooltip => 'Nhắn tin mới';

  @override
  String get groupCreateTitle => 'Tạo nhóm trekking';

  @override
  String get groupNameLabel => 'Tên nhóm';

  @override
  String get groupMaxMembersHint => 'Tối đa 10 thành viên cho nhóm thường';

  @override
  String get groupAddByEmailOrQr => 'Thêm bằng Email/QR';

  @override
  String get unselect => 'Bỏ chọn';

  @override
  String get groupCreating => 'Đang tạo nhóm...';

  @override
  String get groupCreateButton => 'Tạo nhóm';

  @override
  String get groupNameAndMemberRequired =>
      'Vui lòng nhập tên nhóm và chọn ít nhất 1 thành viên';

  @override
  String get groupDetailsTitle => 'Chi tiết nhóm';

  @override
  String groupMemberCount(int count) {
    return 'Thành viên ($count)';
  }

  @override
  String get groupRenameDialogTitle => 'Đổi tên nhóm';

  @override
  String get groupRenameButton => 'Đổi tên';

  @override
  String get groupAddMemberButton => 'Thêm thành viên';

  @override
  String get groupOwnerRole => 'Trưởng nhóm';

  @override
  String get groupTransferOwnerTitle => 'Chuyển quyền trưởng nhóm';

  @override
  String groupTransferOwnerMessage(String name) {
    return 'Bạn có chắc muốn chuyển quyền trưởng nhóm cho $name? Bạn sẽ trở thành thành viên thường.';
  }

  @override
  String get groupTransferOwnerConfirm => 'Chuyển quyền';

  @override
  String get groupTransferOwnerAction => 'Chuyển quyền trưởng nhóm';

  @override
  String get groupRemoveMemberAction => 'Xóa khỏi nhóm';

  @override
  String get groupLeaveAction => 'Rời nhóm';

  @override
  String get groupLeaveOwnerHint =>
      'Bạn là trưởng nhóm. Hãy chuyển quyền trưởng nhóm cho người khác trước khi rời nhóm.';

  @override
  String get messagesHeaderSubtitle => 'Nhắn tin trực tiếp và nhóm trekking';

  @override
  String get noConversationsYet => 'Chưa có cuộc trò chuyện nào';

  @override
  String get groupPaused => 'Nhóm tạm dừng';

  @override
  String get directMessage => 'Trò chuyện trực tiếp';

  @override
  String get viewMoreConversations => 'Xem thêm cuộc trò chuyện';

  @override
  String get selectMember => 'Chọn thành viên';

  @override
  String get searchUser => 'Tìm kiếm người dùng';

  @override
  String get searchUserHint => 'Nhập email hoặc tên người dùng...';

  @override
  String get emailOrQrContent => 'Nội dung Email hoặc mã QR';

  @override
  String get searchButton => 'Tìm kiếm';

  @override
  String get scanQrButton => 'Quét mã QR';

  @override
  String get personalPage => 'Trang cá nhân';

  @override
  String get groupSuspendedByAdmin =>
      'Nhóm đã bị quản trị viên đình chỉ hoạt động';

  @override
  String get olderMessages => 'Tin nhắn cũ hơn';

  @override
  String get recallMessage => 'Thu hồi';

  @override
  String get reportMessage => 'Báo cáo';

  @override
  String get reportReason => 'Lý do báo cáo';

  @override
  String get reportMessageDesc => 'Mô tả lý do bạn báo cáo tin nhắn này';

  @override
  String get reportSentToAdmin => 'Đã gửi báo cáo cho quản trị viên';

  @override
  String get formerMember => 'Thành viên cũ';

  @override
  String get messageRecalled => 'Tin nhắn đã được thu hồi';

  @override
  String get typeMessageHint => 'Nhập tin nhắn...';

  @override
  String get sendMessageTooltip => 'Gửi';

  @override
  String sendErrorRetryHint(String error) {
    return 'Lỗi gửi: $error. Bấm để thử lại.';
  }

  @override
  String commentSaveError(String error) {
    return 'Không thể lưu bình luận: $error';
  }

  @override
  String get commentDeleteTitle => 'Xóa bình luận';

  @override
  String get commentDeleteMessage =>
      'Bạn có chắc muốn xóa bình luận này không?';

  @override
  String commentDeleteError(String error) {
    return 'Không thể xóa bình luận: $error';
  }

  @override
  String get commentEditTitle => 'Chỉnh sửa bình luận';

  @override
  String get contentRequired => 'Nội dung không được để trống';

  @override
  String get selectYourJourney => 'Chọn hành trình của bạn';

  @override
  String get searchPlaceHint => 'Tìm địa điểm';

  @override
  String get onlySyncedJourneysHint =>
      'Chỉ có thể chia sẻ các hành trình đã đồng bộ lên hệ thống';

  @override
  String get noDataToSelect => 'Không có dữ liệu để chọn';

  @override
  String get finishJourneyTitle => 'Kết thúc hành trình?';

  @override
  String get finishJourneyDesc =>
      'Bạn có chắc chắn muốn kết thúc hành trình này? Sau khi kết thúc, dữ liệu track log sẽ được lưu lại.';

  @override
  String get finishJourneySaveGpsNotice =>
      'Sau khi kết thúc, bạn có thể lưu track log GPS thành tuyến đường mới để đóng góp cho cộng đồng.';

  @override
  String get keepGoingButton => 'Tiếp tục đi';

  @override
  String get finishButton => 'Kết thúc';

  @override
  String get finishAndSendToAdmin => 'Kết thúc & Gửi duyệt';

  @override
  String locationFetchFailed(String error) {
    return 'Không thể lấy vị trí hiện tại: $error';
  }

  @override
  String get locationFetchForMarkerFailed =>
      'Không thể lấy vị trí GPS để tạo điểm mốc';

  @override
  String get sendToAdminButton => 'Gửi cho Admin';

  @override
  String get markersSyncedSendToAdmin =>
      'Các điểm mốc đã được đồng bộ lên máy chủ. Bạn có thể gửi đóng góp để quản trị viên duyệt đưa vào bản đồ chính thức.';

  @override
  String get markersSavedOfflineNeedSync =>
      'Các điểm mốc đã được lưu offline. Khi có mạng và sau khi đồng bộ lên máy chủ, bạn có thể gửi đóng góp cho quản trị viên.';

  @override
  String get markersSavedOfflineAutoSync =>
      'Các điểm mốc được lưu offline trên máy và sẽ tự động đồng bộ khi có kết nối mạng.';

  @override
  String get completeJourneyBeforeSendAdmin =>
      'Hãy hoàn thành hành trình trước khi gửi đề xuất tuyến đường/cột mốc cho Admin.';

  @override
  String get milestonesLoadFailedRetry =>
      'Không thể tải cột mốc. Bấm để thử lại.';

  @override
  String get downloadOrUpdateOfflineMap => 'Tải / Cập nhật bản đồ Offline';

  @override
  String get journeyMapTitle => 'Bản đồ hành trình';

  @override
  String get detailLabel => 'Chi tiết';

  @override
  String get journeyDetailTitle => 'Chi tiết hành trình';

  @override
  String milestonesArrivedCount(int checked, int total) {
    return 'Đã đến $checked/$total cột mốc';
  }

  @override
  String get backtrackReturnToStart => 'Backtrack: Quay về điểm xuất phát';

  @override
  String get backtrackRecordRoute => 'Backtrack: Ghi tracklog đường đi';

  @override
  String get savedRoute => 'Tuyến đường đã lưu';

  @override
  String get recordingGpsForeground => 'Đang ghi GPS chạy ngầm';

  @override
  String get pausedRecordingGps => 'Tạm dừng ghi GPS';

  @override
  String get savedOfflineUsable => 'Đã lưu offline, có thể dùng khi mất sóng';

  @override
  String get stopGpsRecording => 'Dừng ghi GPS';

  @override
  String get recordRouteButton => 'Ghi đường đi';

  @override
  String get startGpsRecording => 'Bắt đầu ghi GPS';

  @override
  String get exitBacktrack => 'Thoát Backtrack';

  @override
  String get returnAlongRoute => 'Quay lại theo đường đã đi';

  @override
  String get backtrackOrangeTrailNotice =>
      'Theo dõi vệt màu cam trên bản đồ để quay trở lại điểm xuất phát an toàn.';

  @override
  String get checkinPointLegend => 'Điểm check-in';

  @override
  String get yourMarkerLegend => 'Điểm mốc của bạn';

  @override
  String yourLocationAccuracy(String accuracy) {
    return 'Vị trí của bạn (±${accuracy}m)';
  }

  @override
  String sendMarkersToAdminCount(int count) {
    return 'Gửi $count điểm mốc cho Admin';
  }

  @override
  String get markMilestoneButton => 'Đánh dấu mốc';

  @override
  String get savingJourneyProgress => 'Đang lưu dữ liệu hành trình...';

  @override
  String get finishJourneyButton => 'Kết thúc hành trình';

  @override
  String get shareToCommunityButton => 'Chia sẻ lên cộng đồng';

  @override
  String get shareRouteToAdminButton => 'Đóng góp tuyến đường cho Admin';

  @override
  String cannotOpenRouteShare(String error) {
    return 'Không thể mở chia sẻ tuyến đường: $error';
  }

  @override
  String get offlineMapAvailable => 'Bản đồ offline khả dụng';

  @override
  String get offlineMapNotDownloaded => 'Chưa tải bản đồ offline';

  @override
  String get tapViewMapNotice => 'Chạm để xem bản đồ lộ trình chi tiết';

  @override
  String checkinPhotosCount(int count) {
    return 'Ảnh check-in ($count)';
  }

  @override
  String get cannotOpenJourneyData => 'Không thể mở dữ liệu hành trình';

  @override
  String get journeyPlansLabel => 'Kế hoạch hành trình';

  @override
  String journeyEstimatedTotal(int count) {
    return 'Ước tính tổng cộng: $count ngày';
  }

  @override
  String personCount(int count) {
    return '$count người';
  }

  @override
  String get provincesLabel => 'Tỉnh thành';

  @override
  String get noPlansYet => 'Chưa có kế hoạch hành trình nào';

  @override
  String get startFirstJourneyHint => 'Hãy bắt đầu chuyến đi đầu tiên của bạn!';

  @override
  String get createPlanForNextTripHint =>
      'Tạo kế hoạch cho chuyến đi sắp tới của bạn';

  @override
  String get otherLabel => 'Khác';

  @override
  String get contributionTitle => 'Đóng góp tuyến đường & cột mốc';

  @override
  String get contributionMarkerOnlyTitle => 'Đóng góp cột mốc';

  @override
  String get contributionSuccessTitle => 'Gửi đóng góp thành công!';

  @override
  String get contributionSavedOfflineTitle => 'Đã lưu đóng góp offline!';

  @override
  String get contributionOfflineNotice =>
      'Dữ liệu đóng góp đã được lưu trên máy của bạn. Khi có kết nối mạng, ứng dụng sẽ tự động đồng bộ và gửi đến quản trị viên để xem xét phê duyệt.';

  @override
  String contributionMarkersReceived(int count) {
    return 'Cảm ơn bạn đã đóng góp $count điểm mốc mới. Quản trị viên sẽ xem xét và phê duyệt để đưa lên bản đồ chính thức của TrekViệt.';
  }

  @override
  String contributionRouteAndMarkersReceived(int count) {
    return 'Cảm ơn bạn đã đóng góp tuyến đường cùng $count điểm mốc mới. Quản trị viên sẽ xem xét và phê duyệt để đưa lên bản đồ chính thức của TrekViệt.';
  }

  @override
  String get contributionStatusPendingSync =>
      'Trạng thái: Chờ đồng bộ khi có mạng';

  @override
  String get contributionViewHistoryNotice =>
      'Bạn có thể xem lại trong Lịch sử đóng góp ở trang Hồ sơ.';

  @override
  String contributionSourceJourney(String name) {
    return 'Từ hành trình: $name';
  }

  @override
  String get contributionNameLabel => 'Tên tuyến đường đề xuất *';

  @override
  String get contributionMarkerNameLabel => 'Tên đóng góp *';

  @override
  String get contributionNameHint =>
      'VD: Cung đường leo Fansipan qua Trạm Tôn...';

  @override
  String get contributionNameRequired =>
      'Vui lòng nhập tên tuyến đường đề xuất';

  @override
  String get contributionDescLabel => 'Mô tả chi tiết';

  @override
  String get contributionDescHint =>
      'Mô tả về địa hình, cảnh quan, trải nghiệm thực tế...';

  @override
  String get contributionSafetyLabel => 'Lưu ý an toàn / Mẹo đi đường';

  @override
  String get contributionSafetyHint =>
      'Nguồn nước, điểm cắm trại an toàn, đoạn trơn trượt...';

  @override
  String contributionSelectMarkersLabel(int count) {
    return 'Chọn các điểm mốc kèm theo ($count)';
  }

  @override
  String get contributionSelectMarkersHint =>
      'Đánh dấu chọn các điểm mốc cá nhân bạn đã tạo để gửi duyệt kèm tuyến đường';

  @override
  String get contributionSubmitButton => 'Gửi cho Admin duyệt';

  @override
  String get contributionSkipButton => 'Bỏ qua đóng góp';

  @override
  String get markerFormCreateTitle => 'Đánh dấu điểm mốc';

  @override
  String get markerFormEditTitle => 'Chỉnh sửa điểm mốc';

  @override
  String get markerNameLabel => 'Tên điểm mốc *';

  @override
  String get markerNameHint => 'VD: Đỉnh núi, Suối nước, Điểm cắm trại...';

  @override
  String get markerTypeLabel => 'Loại điểm mốc';

  @override
  String get markerGpsCoordinates => 'Tọa độ GPS';

  @override
  String get markerPhotosLabel => 'Hình ảnh điểm mốc';

  @override
  String get markerAddPhoto => '+ Thêm ảnh';

  @override
  String get markerNoteLabel => 'Ghi chú thêm';

  @override
  String get markerNoteHint =>
      'Lưu ý về nguồn nước, độ dốc, sóng điện thoại...';

  @override
  String get markerSaveOffline => 'Lưu trên máy';

  @override
  String get markerSaveAndSync => 'Lưu & Đồng bộ điểm mốc';

  @override
  String get markerSyncDesc =>
      'Điểm mốc sẽ được lưu trên máy và tự động đồng bộ lên máy chủ khi có mạng.';

  @override
  String markerSaveError(String error) {
    return 'Không thể lưu điểm mốc: $error';
  }

  @override
  String get placeReviewTitle => 'Đánh giá địa điểm';

  @override
  String get anonymousTrekker => 'Trekker ẩn danh';

  @override
  String get noReviewsYet => 'Chưa có đánh giá';

  @override
  String get viewMoreReviews => 'Xem thêm đánh giá';

  @override
  String get satisfactionLevelPrompt => 'Mức độ hài lòng của bạn?';

  @override
  String get shareExperiencePrompt => 'Chia sẻ trải nghiệm';

  @override
  String get shareExperienceHint =>
      'Chia sẻ cảm nhận, lời khuyên và trải nghiệm về địa điểm này...';

  @override
  String get addPhotosPrompt => 'Thêm hình ảnh';

  @override
  String get addPhotosMax10 => 'Tối đa 10 ảnh';

  @override
  String get anonymousReviewLabel => 'Đánh giá ẩn danh';

  @override
  String get anonymousReviewDesc => 'Tên của bạn sẽ không hiển thị công khai';

  @override
  String get submitReviewButton => 'Gửi đánh giá';

  @override
  String get saveReviewEditButton => 'Lưu đánh giá';

  @override
  String get reviewThankYouTitle => 'Cảm ơn bạn!';

  @override
  String get reviewThankYouMessage =>
      'Đánh giá của bạn đã được ghi nhận và sẽ giúp ích rất nhiều cho cộng đồng Trekker Việt Nam.';

  @override
  String get yourReviewSection => 'Đánh giá của bạn';

  @override
  String get viewOtherReviewsButton => 'Xem các đánh giá khác';

  @override
  String get backToHomeButton => 'Quay về trang chủ';

  @override
  String get noFeaturedPlaces => 'Chưa có địa điểm nổi bật nào';

  @override
  String get noMatchingRoutes => 'Không tìm thấy cung đường phù hợp';

  @override
  String get noMatchingSuggestions => 'Không tìm thấy gợi ý phù hợp';

  @override
  String get addRouteButton => 'Thêm cung đường';

  @override
  String get addPlaceButton => 'Thêm địa điểm';

  @override
  String routeEstimatedDuration(String duration) {
    return 'Thời gian ước tính: $duration';
  }

  @override
  String routeMaxElevation(String elevation) {
    return 'Độ cao tối đa: $elevation m';
  }

  @override
  String routeElevationGain(String gain) {
    return 'Độ cao tích lũy: $gain m';
  }

  @override
  String routeTotalDistance(String distance) {
    return 'Tổng chiều dài: $distance km';
  }

  @override
  String get routeDescriptionTitle => 'Mô tả cung đường';

  @override
  String get routeNoDescription => 'Chưa có mô tả cho cung đường này.';

  @override
  String routeDifficultyPrefix(String difficulty) {
    return 'Độ khó: $difficulty';
  }

  @override
  String routePlacePrefix(String place) {
    return 'Địa điểm: $place';
  }

  @override
  String routeStartPrefix(String coords) {
    return 'Điểm bắt đầu: $coords';
  }

  @override
  String routeEndPrefix(String coords) {
    return 'Điểm kết thúc: $coords';
  }

  @override
  String get downloadMapBeforeStart => 'Tải bản đồ trước khi bắt đầu';

  @override
  String cannotStartJourney(String error) {
    return 'Không thể bắt đầu hành trình: $error';
  }

  @override
  String get backToJourneyScreen => 'Quay lại danh sách hành trình';

  @override
  String get difficultyEasy => 'Dễ';

  @override
  String get difficultyModerate => 'Trung bình';

  @override
  String get difficultyHard => 'Khó';

  @override
  String get difficultyExpert => 'Chuyên nghiệp';

  @override
  String get placeAboutSection => 'Giới thiệu';

  @override
  String get placeNoDescription =>
      'Chưa có thông tin giới thiệu cho địa điểm này.';

  @override
  String placeRoutesSection(int count) {
    return 'Cung đường trekking ($count)';
  }

  @override
  String get placeNoRoutes => 'Chưa có cung đường nào tại địa điểm này.';

  @override
  String get offlineMapTitle => 'Quản lý bản đồ Offline';

  @override
  String offlineMapStorageUsed(String size) {
    return 'Dung lượng đã dùng: $size';
  }

  @override
  String offlineMapCount(int count) {
    return '$count bản đồ đã tải';
  }

  @override
  String get noOfflineMapsTitle => 'Chưa có bản đồ ngoại tuyến nào';

  @override
  String get noOfflineMapsDesc =>
      'Hãy tải bản đồ của các cung đường bạn sắp đi để sử dụng khi mất kết nối mạng.';

  @override
  String get deleteOfflineMapTitle => 'Xóa bản đồ ngoại tuyến';

  @override
  String deleteOfflineMapConfirm(String name) {
    return 'Bạn có chắc chắn muốn xóa bản đồ của \"$name\"? Bạn sẽ cần tải lại nếu muốn dùng offline.';
  }

  @override
  String get deleteOfflineMapButton => 'Xóa bản đồ';

  @override
  String deleteOfflineMapSuccess(String name) {
    return 'Đã xóa bản đồ $name';
  }

  @override
  String deleteOfflineMapError(String error) {
    return 'Không thể xóa bản đồ: $error';
  }

  @override
  String offlineMapInUseNotice(String name) {
    return 'Bản đồ \"$name\" đang được sử dụng bởi hành trình hiện tại.';
  }

  @override
  String get badgeUnlocked => 'Đã đạt được';

  @override
  String get badgeLocked => 'Chưa đạt được';

  @override
  String badgeAchievedDate(String date) {
    return 'Đạt được ngày: $date';
  }

  @override
  String get badgeMissionProgress => 'Tiến trình thử thách';

  @override
  String get viewAll => 'Xem tất cả';

  @override
  String get shareAchievement => 'Chia sẻ thành tích';

  @override
  String shareAchievementText(String title) {
    return 'Mình vừa đạt được danh hiệu \"$title\" trên TrekViệt! Cùng khám phá các cung đường trekking Việt Nam nhé!';
  }

  @override
  String get suggestPlaceSuccess =>
      'Đề xuất địa điểm đã được gửi thành công! Quản trị viên sẽ kiểm tra và phản hồi sớm.';

  @override
  String get filterAll => 'Tất cả';

  @override
  String cannotLoadRoutesError(String error) {
    return 'Không tải được một số cung đường: $error';
  }

  @override
  String get noDistanceAvailable => 'Chưa có cự ly';

  @override
  String reviewsCount(String rating, int count) {
    return '$rating ($count đánh giá)';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes phút';
  }

  @override
  String durationHours(int hours) {
    return '$hours giờ';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours giờ $minutes phút';
  }

  @override
  String durationDays(String days) {
    return '$days ngày';
  }

  @override
  String get routeScope => 'Tuyến đường';

  @override
  String get placeScope => 'Địa điểm';

  @override
  String get mapInUseBadge => 'Đang đi';

  @override
  String downloadedOnDate(String date) {
    return 'Đã tải: $date';
  }

  @override
  String get readyForOfflineUse => 'Sẵn sàng sử dụng offline';

  @override
  String get manageOfflineMaps => 'Quản lý bản đồ offline';

  @override
  String get yourContributions => 'Đóng góp của bạn';

  @override
  String get tabContributionSubmitted => 'Đã gửi';

  @override
  String get tabContributionApproved => 'Đã duyệt';

  @override
  String get tabContributionRejected => 'Từ chối';

  @override
  String get rejectionReason => 'Lý do từ chối:';

  @override
  String get noRejectionReason => 'Không có lý do chi tiết từ quản trị viên.';

  @override
  String get noContributionsSubmitted => 'Chưa có đóng góp nào đang chờ duyệt.';

  @override
  String get noContributionsApproved => 'Chưa có đóng góp nào được duyệt.';

  @override
  String get noContributionsRejected => 'Chưa có đóng góp nào bị từ chối.';

  @override
  String get contributionTypeRoute => 'Cung đường';

  @override
  String get contributionTypePlace => 'Địa điểm';

  @override
  String contributionDate(String date) {
    return 'Ngày gửi: $date';
  }

  @override
  String get homeNoPlacesToExplore => 'Chưa có địa điểm để khám phá';

  @override
  String get yourMapPosterTitle => 'Ảnh bản đồ của bạn';

  @override
  String get downloadPosterNow => 'Tải ảnh ngay';

  @override
  String get loadProvinces => 'Tải danh sách tỉnh';

  @override
  String get statElevation => 'Độ cao';

  @override
  String get statDuration => 'Thời gian';

  @override
  String get statRoutes => 'Cung đường';

  @override
  String get difficultyExtreme => 'Cực khó';

  @override
  String get commonError => 'Đã có lỗi xảy ra. Vui lòng thử lại';

  @override
  String get statTotalDistance => 'Tổng quãng đường';

  @override
  String get statElevationGain => 'Độ cao tổng';

  @override
  String get statEstimatedDuration => 'Thời gian dự kiến';

  @override
  String get storageUsedLabel => 'Dung lượng đã sử dụng';

  @override
  String get journeyCompletedTitle => 'Hoàn thành hành trình!';

  @override
  String get termsOfUseTitle => 'Điều khoản sử dụng';

  @override
  String get termsLastUpdated => 'Cập nhật lần cuối: 20/12/2025';

  @override
  String get termsSection1Title => 'Giới thiệu';

  @override
  String get termsSection1Content =>
      'Chào mừng bạn đến với Trek Việt Nam, ứng dụng hỗ trợ điều hướng, ghi lại nhật ký hành trình trekking và kết nối cộng đồng đam mê dã ngoại tại Việt Nam. Bằng việc đăng ký tài khoản, bạn đồng ý tuân thủ các điều khoản này.';

  @override
  String get termsSection2Title => 'Điều kiện sử dụng';

  @override
  String get termsSection2Content =>
      'Bạn phải từ 16 tuổi trở lên hoặc có sự giám sát của người bảo hộ để sử dụng ứng dụng. Bạn chịu trách nhiệm hoàn toàn về tính bảo mật của mật khẩu và mọi hoạt động dưới tài khoản của mình.';

  @override
  String get termsSection3Title => 'Quyền và nghĩa vụ của người dùng';

  @override
  String get termsSection3Content =>
      'Người dùng được phép sử dụng bản đồ ngoại tuyến, lưu trữ lịch sử di chuyển và chia sẻ ảnh trekking lành mạnh lên cộng đồng. Nghiêm cấm hành vi phá hoại dữ liệu, đăng tải thông tin sai lệch về bản đồ biên giới hoặc địa danh nhạy cảm.';

  @override
  String get termsSection4Title => 'Quyền sở hữu trí tuệ';

  @override
  String get termsSection4Content =>
      'Toàn bộ mã nguồn, thiết kế đồ họa, hệ thống huy hiệu và cơ sở dữ liệu cung đường trekking độc quyền đều thuộc quyền sở hữu của Trek Việt Nam. Mọi hành vi sao chép không xin phép đều bị nghiêm cấm.';

  @override
  String get termsSection5Title => 'Giới hạn trách nhiệm';

  @override
  String get termsSection5Content =>
      'Trekking là hoạt động thể thao mạo hiểm ngoài trời. Chúng tôi cung cấp bản đồ GPS mang tính tham khảo và không chịu trách nhiệm pháp lý trước bất kỳ tai nạn, rủi ro tự nhiên hay lạc đường nào của bạn trên cung đường thực tế.';

  @override
  String get privacyPolicyTitle => 'Chính sách bảo mật';

  @override
  String get privacySection1Title => 'Thu thập dữ liệu';

  @override
  String get privacySection1Content =>
      'Chúng tôi thu thập thông tin đăng ký (Tên, Email, Ảnh đại diện) và đặc biệt là dữ liệu vị trí GPS của bạn (ngay cả khi ứng dụng chạy ngầm) để vẽ bản đồ hành trình trekking và kích hoạt tính năng check-in.';

  @override
  String get privacySection2Title => 'Sử dụng dữ liệu';

  @override
  String get privacySection2Content =>
      'Dữ liệu vị trí được sử dụng để hiển thị vị trí của bạn trên bản đồ dã ngoại, thống kê tổng quãng đường di chuyển và mở khóa các huy hiệu thám hiểm cá nhân.';

  @override
  String get privacySection3Title => 'Chia sẻ dữ liệu';

  @override
  String get privacySection3Content =>
      'Thông tin và lịch sử đi trekking của bạn chỉ được chia sẻ công khai khi bạn chủ động ấn nút \'Đăng bài viết\' trên diễn đàn Cộng đồng hoặc chia sẻ huy hiệu lên mạng xã hội.';

  @override
  String get privacySection4Title => 'Bảo mật thông tin';

  @override
  String get privacySection4Content =>
      'Trek Việt Nam áp dụng các biện pháp mã hóa đầu cuối tiên tiến nhất để bảo vệ thông tin cá nhân và dữ liệu tọa độ của bạn trước các truy cập trái phép.';

  @override
  String get privacySection5Title => 'Quyền của bạn';

  @override
  String get privacySection5Content =>
      'Bạn có quyền truy cập, chỉnh sửa thông tin hồ sơ cá nhân hoặc yêu cầu xóa vĩnh viễn tài khoản cùng toàn bộ lịch sử định vị GPS đã lưu trên máy chủ của chúng tôi bất kỳ lúc nào.';

  @override
  String get journeyOptionsTitle => 'Tùy chọn';

  @override
  String get routeDetailOption => 'Chi tiết Tuyến đường';

  @override
  String get journeyDetailOption => 'Chi tiết Hành trình';

  @override
  String get selectPlaceTitle => 'Chọn địa điểm';

  @override
  String get cannotLoadPlaces => 'Không thể tải địa điểm.';

  @override
  String get noPlacesAvailable => 'Chưa có địa điểm.';

  @override
  String get changePlaceButton => 'Đổi địa điểm';

  @override
  String get searchRouteHint => 'Tìm cung đường';

  @override
  String get cannotLoadRoutesAtPlace =>
      'Không thể tải cung đường tại địa điểm này.';

  @override
  String get placeHasNoRoutes => 'Địa điểm này chưa có cung đường.';

  @override
  String routesAtPlacePrefix(String place) {
    return 'Cung đường tại $place';
  }

  @override
  String get downloadButton => 'Tải xuống';

  @override
  String get retryDownloadButton => 'Thử tải lại';

  @override
  String get cannotLoadRoutesGeneral =>
      'Không thể tải cung đường. Vui lòng thử lại.';

  @override
  String get personalQrTitle => 'QR cá nhân';

  @override
  String get personalQrDesc =>
      'Người khác quét mã này để xem trang cá nhân và nhắn tin cho bạn.';

  @override
  String get copyCodeButton => 'Sao chép mã';

  @override
  String get closeButton => 'Đóng';

  @override
  String get noBioYet => 'Chưa có giới thiệu.';

  @override
  String userPostsCount(int count) {
    return '$count bài viết';
  }

  @override
  String get aboutSection => 'Giới thiệu';

  @override
  String get personalBio => 'Giới thiệu cá nhân';

  @override
  String get myQrCode => 'QR của tôi';

  @override
  String get reissueQrDialogTitle => 'Cấp lại QR?';

  @override
  String get reissueQrDialogMessage => 'Mã cũ sẽ ngừng hoạt động.';

  @override
  String get reissueButton => 'Cấp lại';

  @override
  String get sendMessageButton => 'Nhắn tin';

  @override
  String get cannotStartJourneyGeneral =>
      'Không thể bắt đầu hành trình. Vui lòng thử lại.';

  @override
  String get viewMorePosts => 'Xem thêm bài viết';

  @override
  String get communityProfileTitle => 'Trang cá nhân cộng đồng';

  @override
  String get backToJourneyButton => 'Quay lại hành trình';

  @override
  String get markerNameRequired => 'Nhập tên cột mốc';

  @override
  String get syncFailedCheck => 'Đồng bộ thất bại — cần kiểm tra';

  @override
  String get savedOfflinePendingSync => 'Đã lưu trên máy · chờ đồng bộ';

  @override
  String memberCountText(int count) {
    return '$count thành viên';
  }

  @override
  String get cancelJourneyButton => 'Hủy hành trình';

  @override
  String get cancelJourneyConfirmTitle => 'Hủy hành trình?';

  @override
  String get cancelJourneyConfirmMessage =>
      'Bạn có chắc chắn muốn hủy hành trình này không? Trạng thái sẽ chuyển sang đã hủy.';

  @override
  String get editReviewOnceButton => 'Chỉnh sửa đánh giá (1 lần)';

  @override
  String get completeJourneyToReview =>
      'Hoàn thành hành trình tại đây để đánh giá.';

  @override
  String get reviewRemoved => 'Đánh giá của bạn đã được gỡ.';

  @override
  String get reviewEditLimitReached => 'Bạn đã dùng lượt chỉnh sửa đánh giá.';

  @override
  String get viewAllReviewsButton => 'Xem tất cả đánh giá';
}
