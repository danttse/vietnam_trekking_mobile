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
  String get featuredDestinations => 'Featured Destinations';

  @override
  String get popularTrails => 'Popular Trails';

  @override
  String get recommendedForYou => 'Recommended for You';

  @override
  String get searchTrailsPlaces => 'Search trails, trekking destinations...';

  @override
  String get seeAll => 'See All';

  @override
  String get north => 'Northern';

  @override
  String get central => 'Central';

  @override
  String get south => 'Southern';

  @override
  String get popular => 'Popular';

  @override
  String get editBio => 'Edit Bio';

  @override
  String get titleBioBox => 'Biography (BIO)';

  @override
  String get editAvatar => 'Edit Avatar';

  @override
  String get avatarPickerTitle => 'UPLOAD OPTIONS';

  @override
  String get takeNewPhoto => 'Take a new photo';

  @override
  String get chooseFromLibrary => 'Choose from library';

  @override
  String featureComingSoon(String feature) {
    return 'Feature coming soon';
  }

  @override
  String get changePasswordTitle => 'Change Password';

  @override
  String get currentPasswordLabel => 'CURRENT PASSWORD';

  @override
  String get currentPasswordHint => 'Enter current password';

  @override
  String get newPasswordLabelUpper => 'NEW PASSWORD';

  @override
  String get confirmNewPasswordLabelUpper => 'CONFIRM NEW PASSWORD';

  @override
  String get confirmNewPasswordHint => 'Re-enter new password';

  @override
  String get pleaseFillAllFields => 'Please fill in all fields';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get changePasswordSuccess => 'Password changed successfully!';

  @override
  String get createNewPostHintText => 'Share your trekking experience';

  @override
  String get communityTabPosts => 'Posts';

  @override
  String get communityTabGroups => 'Groups';

  @override
  String get communityTabPersonal => 'Personal';

  @override
  String get postHideThis => 'Hide this post';

  @override
  String get postHideSubtitle => 'See fewer posts like this on your feed';

  @override
  String get postHiddenMessage => 'Post hidden';

  @override
  String get undo => 'Undo';

  @override
  String postHideAllFrom(String authorName) {
    return 'Hide all from $authorName';
  }

  @override
  String get thisPerson => 'this person';

  @override
  String get postReport => 'Report post';

  @override
  String get postReportSuccess =>
      'Thank you for your report. We will review this content.';

  @override
  String get communityNoPosts => 'No posts yet';

  @override
  String get commentsTitle => 'Comments';

  @override
  String get noCommentsYet => 'No comments yet';

  @override
  String get beFirstToComment => 'Be the first to comment!';

  @override
  String replyingTo(String userName) {
    return 'Replying to $userName';
  }

  @override
  String replyToHint(String userName) {
    return 'Reply to @$userName...';
  }

  @override
  String get writeCommentHint => 'Write a comment...';

  @override
  String get journeyCompleted => 'Completed';

  @override
  String get journeyUpcoming => 'Upcoming';

  @override
  String get journeyStatTrips => 'Trips';

  @override
  String get journeyStatDistance => 'Distance';

  @override
  String get journeyStatCompanions => 'Companions';

  @override
  String get journeyEmptyList => 'No journeys yet';

  @override
  String get createNewJourneyTitle => 'Create New Journey';

  @override
  String get journeyNameLabel => 'Journey Name';

  @override
  String get journeyNameHint => 'Enter journey name';

  @override
  String get journeyStartDateLabel => 'Start Date';

  @override
  String get journeyEndDateLabel => 'End Date';

  @override
  String get participantCountLabel => 'Number of Participants';

  @override
  String get participantCountHint => 'Enter number of participants';

  @override
  String get journeyNoteLabel => 'Notes/Description';

  @override
  String get journeyNoteHint => 'Enter notes or description for the journey';

  @override
  String get selectRouteLabel => 'Route';

  @override
  String get selectRouteHint => 'Select trekking route';

  @override
  String get selectRouteSheetTitle => 'Select Route';

  @override
  String get createJourneyButton => 'Create Journey';

  @override
  String get createJourneySuccess => 'Journey created successfully!';

  @override
  String get milestonesSectionTitle => 'MILESTONES';

  @override
  String get milestoneCheckedIn => 'Checked in';

  @override
  String get milestoneNotCheckedIn => 'Not yet';

  @override
  String get milestoneCheckInButton => 'Check In';

  @override
  String milestoneAltitude(String altitude) {
    return '$altitude m asl';
  }

  @override
  String milestoneProgress(int checked, int total) {
    return '$checked/$total milestones';
  }

  @override
  String get journeyDetailMapTitle => 'ROUTE MAP';

  @override
  String get journeyDetailDownloadMap => 'Download Offline Map';

  @override
  String get journeyDetailViewMap => 'View Offline Map';

  @override
  String get journeyActionStart => 'Start Journey';

  @override
  String get journeyActionPause => 'Pause Journey';

  @override
  String get journeyActionResume => 'Resume Journey';

  @override
  String get journeyActionViewMap => 'View Map';

  @override
  String get journeyRemainingTime => 'Remaining time';

  @override
  String get journeyCurrentElevation => 'Current elevation';

  @override
  String get journeyProgressTitle => 'Journey Progress';

  @override
  String get journeyCheckinPoints => 'Check-in points';

  @override
  String get journeyStatusPlanned => 'PLANNED';

  @override
  String get journeyStatusActive => 'IN PROGRESS';

  @override
  String get journeyStatusPaused => 'PAUSED';

  @override
  String get journeyStatusCompleted => 'COMPLETED';

  @override
  String get journeyStatusCancelled => 'CANCELLED';

  @override
  String get downloadOfflineMapTitle => 'Download Offline Map';

  @override
  String get downloadOfflineMapSubtitle =>
      'Store offline terrain data to prevent signal loss.';

  @override
  String get downloading => 'DOWNLOADING...';

  @override
  String get cancelDownload => 'Cancel download';

  @override
  String mapDataHeader(String name) {
    return '$name Map Data';
  }

  @override
  String get mapLabel => 'Map';

  @override
  String get zoomLevelLabel => 'Zoom level';

  @override
  String get zoomLevelDetail => '12 – 17 (Detailed)';

  @override
  String get fileSizeLabel => 'Size';

  @override
  String get waypointsLabel => 'Control points';

  @override
  String waypointsCount(int count) {
    return '$count Waypoints';
  }

  @override
  String get trailSupportLabel => 'Trails';

  @override
  String get supported => 'Supported';

  @override
  String get mapReadyTitle => 'Map is ready!';

  @override
  String get mapReadySubtitle => 'All data has been safely stored offline.';

  @override
  String get mapPackageInfoTitle => 'MAP PACKAGE INFORMATION';

  @override
  String get offlineMapFeature => 'Offline Map';

  @override
  String get hikingTrailFeature => 'Hiking Trail (Detailed)';

  @override
  String get waypointsFeature => 'Waypoints (Rest points)';

  @override
  String get backtrackFeature => 'Backtrack (Auto return mode)';

  @override
  String get checkinControlPointTitle => 'Check-in Checkpoint';

  @override
  String get checkinTargetPointLabel => 'TARGET DESTINATION';

  @override
  String checkinTargetAltitude(String altitude) {
    return 'Target altitude: $altitude m';
  }

  @override
  String checkinWithinRange(int distance) {
    return 'You are within check-in range! (${distance}m away)';
  }

  @override
  String get checkinNowButton => 'Check-in now';

  @override
  String get checkinAlreadySuccess => 'Already checked in';

  @override
  String get checkinRadiusNotice =>
      'You must be within a 500m radius to check-in successfully.';

  @override
  String checkinSuccessToast(String name) {
    return 'Successfully checked in at $name!';
  }

  @override
  String get checkinCongratulation => 'CONGRATULATIONS!';

  @override
  String get checkinSuccessTitle => 'Check-in successful!';

  @override
  String checkinSuccessMessage(String name) {
    return 'You have completed the checkpoint $name.';
  }

  @override
  String get achievementsEarnedTitle => 'ACHIEVEMENTS EARNED';

  @override
  String get statNewBadge => 'New badges';

  @override
  String get statMaxElevation => 'Max altitude';

  @override
  String get statConqueredProvinces => 'Provinces conquered';

  @override
  String get continueJourneyButton => 'Continue journey';

  @override
  String get ratePlaceButton => 'Rate destination';

  @override
  String get shareAchievementButton => 'Share achievement';

  @override
  String milestoneConquerBadgeTitle(String name) {
    return 'Conquer $name';
  }

  @override
  String milestoneConquerBadgeDesc(String name, String altitude) {
    return 'Successfully reached $name at ${altitude}m altitude';
  }

  @override
  String milestoneConquerBadgeDescSimple(String name) {
    return 'Successfully reached checkpoint $name';
  }

  @override
  String get ratePlaceTitle => 'Rate destination';

  @override
  String get rateSatisfactionLevel => 'YOUR SATISFACTION LEVEL?';

  @override
  String get rateShareExperience => 'SHARE YOUR EXPERIENCE';

  @override
  String get rateExperienceHint =>
      'Share your thoughts, tips, and experience about this checkpoint...';

  @override
  String get rateAnonymousLabel => 'Anonymous review';

  @override
  String get rateAnonymousDesc => 'Your name will not be shown publicly';

  @override
  String get rateSubmitButton => 'Submit review';

  @override
  String get rateThankYouTitle => 'Thank you!';

  @override
  String get rateThankYouMessage =>
      'Your review has been successfully submitted and will help the Trekker community tremendously.';

  @override
  String get rateYourReviewTitle => 'YOUR REVIEW';

  @override
  String rateStarsSummary(int rating, String name) {
    return '$rating/5 stars - $name';
  }

  @override
  String get rateViewOtherReviews => 'View other reviews';

  @override
  String get rateBackToHome => 'Back to home';

  @override
  String get badgeDetailTitle => 'Badge Details';

  @override
  String get missionProgressTitle => 'MISSION PROGRESS';

  @override
  String get otherBadgesTitle => 'YOUR OTHER BADGES';

  @override
  String achievedDatePrefix(String date) {
    return 'Achieved on: $date';
  }

  @override
  String get allBadgesTitle => 'All Badges';
}
