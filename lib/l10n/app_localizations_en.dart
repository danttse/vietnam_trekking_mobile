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
  String get journeyCancelled => 'Cancelled';

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
  String get statMaxElevation => 'Max elevation';

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

  @override
  String get promoteSkip => 'Skip';

  @override
  String get promoteNext => 'Next';

  @override
  String get promoteStart => 'Get Started';

  @override
  String get promoteExploreTitle =>
      'Explore trekking destinations across Vietnam';

  @override
  String get promoteExploreDesc =>
      'Discover trails, scenic spots, detailed info, and community reviews.';

  @override
  String get promoteGpsTitle => 'Create journeys and record GPS';

  @override
  String get promoteGpsDesc =>
      'Plan trips, record real-time tracks, check-in milestones, and review track logs.';

  @override
  String get promoteGpsRecording => 'RECORDING';

  @override
  String get promoteGpsDistance => 'Distance';

  @override
  String get promoteGpsElevation => 'Elevation';

  @override
  String get promoteGpsSpeed => 'Speed';

  @override
  String get promoteOfflineTitle => 'Work offline\nanytime, anywhere';

  @override
  String get promoteOfflineDesc =>
      'Download maps and location data to use even without Internet.';

  @override
  String get promoteOfflineMapTitle => 'Offline maps (MBTiles)';

  @override
  String get promoteOfflineMapSubtitle => 'Optimized storage, fast download';

  @override
  String get promoteOfflineFavoriteTitle => 'Save favorite places';

  @override
  String get promoteOfflineFavoriteSubtitle =>
      'Never lose track of important coordinates';

  @override
  String get promoteOfflineGpsTitle => 'Record GPS & check-in';

  @override
  String get promoteOfflineGpsSubtitle => 'Full trip history is safely kept';

  @override
  String get promoteStatsTitle => 'Track journeys and\nachievements';

  @override
  String get promoteStatsDesc =>
      'Mark 34 explored provinces, collect badges, and view your travel stats.';

  @override
  String get promoteStatsProvinces => 'Provinces visited';

  @override
  String get promoteStatsDistance => 'Distance traveled';

  @override
  String get promoteStatsBadgeMountain => 'Mountains & Forests';

  @override
  String get promoteStatsBadgeMountainSub => '5 peaks conquered';

  @override
  String get promoteStatsBadgeIsland => 'Islands & Bays';

  @override
  String get promoteStatsBadgeIslandSub => '3 bays visited';

  @override
  String get promoteStatsBadgeExplore => 'Explorer';

  @override
  String get promoteStatsBadgeExploreSub => '10 provinces';

  @override
  String get promoteCommunityTitle => 'Connect with trekking lovers';

  @override
  String get promoteCommunityDesc =>
      'Share journeys, photos, experience, and interact with people of the same passion.';

  @override
  String get supportFaqHeader => 'FREQUENTLY ASKED QUESTIONS';

  @override
  String get supportFeedbackHeader => 'SEND US FEEDBACK';

  @override
  String get supportIssueTypeLabel => 'ISSUE TYPE';

  @override
  String get supportDescriptionLabel => 'DETAILED DESCRIPTION';

  @override
  String get supportDescriptionHint =>
      'Describe your issue or suggestion here...';

  @override
  String get supportSubmitButton => 'Submit Feedback';

  @override
  String get supportDirectEmail => 'Or email us directly at';

  @override
  String get supportEmptyError => 'Please enter your detailed description';

  @override
  String get supportSuccessMessage =>
      'Thank you for your feedback! We will get back to you soon.';

  @override
  String get supportIssueGpsMap => 'GPS / Map issue';

  @override
  String get supportIssueAccount => 'Account / Login issue';

  @override
  String get supportIssueContent => 'Content / Destination contribution';

  @override
  String get supportIssueAppExperience => 'App experience feedback';

  @override
  String get supportIssueOther => 'Other issue';

  @override
  String get supportFaq1Q => 'How do I check-in at a milestone?';

  @override
  String get supportFaq1A =>
      'Enable GPS on your phone, move within 50m of the milestone, and tap \'Check-in now\' on the Journey Map screen.';

  @override
  String get supportFaq2Q => 'How do badges work?';

  @override
  String get supportFaq2A =>
      'Badges are automatically unlocked when you complete trekking challenges, conquer peaks, or achieve province exploration milestones.';

  @override
  String get supportFaq3Q => 'How to create a new journey?';

  @override
  String get supportFaq3A =>
      'Go to the Journey tab, tap the (+) icon or \'Start journey\' button to enable real-time GPS tracking and save your trail.';

  @override
  String get rankSectionTitle => 'YOUR TREKKING RANK';

  @override
  String rankXpEarned(String xp) {
    return 'You earned +$xp XP';
  }

  @override
  String rankPromoted(String name, int level) {
    return 'Promoted to $name · Level $level!';
  }

  @override
  String get rankDetailTitle => 'Rank and XP';

  @override
  String rankLevel(int level) {
    return 'Level $level';
  }

  @override
  String get rankViewDetails => 'View all rank details';

  @override
  String get rankCurrentXp => 'Current XP';

  @override
  String rankNextTarget(String name) {
    return 'Next rank: $name';
  }

  @override
  String rankXpRemaining(String xp) {
    return '$xp more XP to reach the next XP milestone';
  }

  @override
  String get rankXpReached =>
      'XP requirement met. Complete the remaining requirements to rank up.';

  @override
  String get rankHighest => 'You have reached the highest rank!';

  @override
  String get rankRequirementsTitle => 'RANK UP REQUIREMENTS';

  @override
  String get rankRequirementsHint =>
      'Meet all requirements to rank up. Your rank updates from your verified activities.';

  @override
  String get rankAllTitle => 'ALL RANKS';

  @override
  String get rankCurrent => 'Current';

  @override
  String get rankUnavailable => 'Your rank could not be loaded';

  @override
  String get rankLoading => 'Loading rank…';

  @override
  String get rankCatalogEmpty => 'No ranks available yet';

  @override
  String get rankRetry => 'Retry';

  @override
  String get rankXpLabel => 'XP points';

  @override
  String get rankJourneysLabel => 'Completed journeys';

  @override
  String get rankProvincesLabel => 'Visited provinces';

  @override
  String get rankBadgesLabel => 'Badges';

  @override
  String get rankDistanceLabel => 'Distance (km)';

  @override
  String get rankContributionsLabel => 'Approved contributions';

  @override
  String rankOverallProgress(String percent) {
    return 'Requirements progress: $percent%';
  }

  @override
  String get rankPromotionTitle => 'You ranked up!';

  @override
  String get xpHistoryHint =>
      'XP updates automatically after verified activities. Review your rewards and adjustments here.';

  @override
  String get xpRouteApproved => 'Route contribution approved';

  @override
  String get xpJourneyCompleted => 'Journey completed';

  @override
  String get xpHistoryTitle => 'XP history';

  @override
  String get xpReversal => 'XP reversal';

  @override
  String get xpMilestoneCheckin => 'Milestone check-in';

  @override
  String get xpHistoryLoadMore => 'Load more';

  @override
  String get xpJourneyElevation => 'Elevation gained';

  @override
  String get xpOtherActivity => 'Activity reward';

  @override
  String get xpAdminAdjustment => 'XP adjustment';

  @override
  String get xpJourneyDistance => 'Distance travelled';

  @override
  String get xpProvinceVisited => 'New province visited';

  @override
  String get rankPromotionMessage =>
      'Your adventures have brought you to a new milestone. Keep exploring!';

  @override
  String get xpPlaceApproved => 'Place contribution approved';

  @override
  String get xpPlaceVisited => 'Place visited';

  @override
  String get rankPromotionContinue => 'Keep exploring';

  @override
  String get xpBadgeEarned => 'Badge earned';

  @override
  String get xpHistoryEmpty => 'No XP activity yet. Start your next adventure!';

  @override
  String get otpVerificationTitle => 'Email Verification';

  @override
  String get otpExpiredLabel => 'OTP expired. Please resend.';

  @override
  String get otpExpiresIn => 'OTP expires in';

  @override
  String get otpIncompleteError => 'Please enter all 6 OTP digits';

  @override
  String get otpResendSuccess => 'OTP resent. Please check your email.';

  @override
  String get journeyMilestonesLoading => 'Loading check-in points…';

  @override
  String get journeyMilestonesLoadFailed => 'Could not load check-in points';

  @override
  String get journeyMilestonesEmpty => 'No check-in points yet';

  @override
  String get journeyMilestonesEmptyMessage =>
      'This route has no official check-in milestones yet. An administrator needs to add milestones to the route before you can check in. You can still open the map to add personal markers.';

  @override
  String get journeyReloadMilestones => 'Reload milestones';

  @override
  String get journeyCheckinClose => 'Close';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonReload => 'Reload';

  @override
  String get commonLoading => 'Loading…';

  @override
  String get commonSaving => 'Saving…';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonClose => 'Close';

  @override
  String get commonSaveChanges => 'Save changes';

  @override
  String get commonViewMore => 'View more';

  @override
  String get commonNoData => 'No data yet';

  @override
  String get postCreateTitle => 'Create post';

  @override
  String get postEditTitle => 'Edit post';

  @override
  String get postSharingWithTrekViet => 'Sharing with TrekViệt community';

  @override
  String get visibilityPublic => 'Public';

  @override
  String get visibilityPrivate => 'Only me';

  @override
  String get whatsOnYourMind => 'What\'s on your mind?';

  @override
  String get postAddToPost => 'Add to your post';

  @override
  String get postAddPhoto => 'Photo';

  @override
  String get postMaxImagesHint => 'You can select up to 10 images';

  @override
  String postSelectedImagesCount(int count) {
    return '$count images selected';
  }

  @override
  String get postRemoveImage => 'Remove image';

  @override
  String get postTagLocation => 'Tag location';

  @override
  String get postShareJourney => 'Share journey';

  @override
  String get postPublishButton => 'Post';

  @override
  String get postDeleteTitle => 'Delete post';

  @override
  String get postDeleteMessage =>
      'Are you sure you want to delete this post? This action cannot be undone.';

  @override
  String postDeleteError(String error) {
    return 'Cannot delete post: $error';
  }

  @override
  String get postCopiedToClipboard => 'Copied to clipboard';

  @override
  String get postEditAction => 'Edit post';

  @override
  String get postDeleteAction => 'Delete post';

  @override
  String get postPublishedSuccess => 'Post published successfully';

  @override
  String get syncBeforeCommunityShare =>
      'Please sync journey before sharing to community';

  @override
  String shareJourneyDefaultContent(String name) {
    return 'My trekking journey at $name!';
  }

  @override
  String get reportFeatureUnavailable => 'Reporting is not available yet';

  @override
  String get messagesTabTitle => 'Messages';

  @override
  String get newMessageTooltip => 'New message';

  @override
  String get groupCreateTitle => 'Create trekking group';

  @override
  String get groupNameLabel => 'Group name';

  @override
  String get groupMaxMembersHint => 'Maximum 10 members for regular groups';

  @override
  String get groupAddByEmailOrQr => 'Add by Email/QR';

  @override
  String get unselect => 'Deselect';

  @override
  String get groupCreating => 'Creating group...';

  @override
  String get groupCreateButton => 'Create group';

  @override
  String get groupNameAndMemberRequired =>
      'Please enter group name and select at least 1 member';

  @override
  String get groupDetailsTitle => 'Group details';

  @override
  String groupMemberCount(int count) {
    return 'Members ($count)';
  }

  @override
  String get groupRenameDialogTitle => 'Rename group';

  @override
  String get groupRenameButton => 'Rename';

  @override
  String get groupAddMemberButton => 'Add member';

  @override
  String get groupOwnerRole => 'Group leader';

  @override
  String get groupTransferOwnerTitle => 'Transfer leadership';

  @override
  String groupTransferOwnerMessage(String name) {
    return 'Are you sure you want to transfer leadership to $name? You will become a regular member.';
  }

  @override
  String get groupTransferOwnerConfirm => 'Transfer';

  @override
  String get groupTransferOwnerAction => 'Transfer leader';

  @override
  String get groupRemoveMemberAction => 'Remove from group';

  @override
  String get groupLeaveAction => 'Leave group';

  @override
  String get groupLeaveOwnerHint =>
      'You are the leader. Please transfer leadership before leaving.';

  @override
  String get messagesHeaderSubtitle => 'Direct messages and trekking groups';

  @override
  String get noConversationsYet => 'No conversations yet';

  @override
  String get groupPaused => 'Group paused';

  @override
  String get directMessage => 'Direct message';

  @override
  String get viewMoreConversations => 'View more conversations';

  @override
  String get selectMember => 'Select member';

  @override
  String get searchUser => 'Search user';

  @override
  String get searchUserHint => 'Enter email or username...';

  @override
  String get emailOrQrContent => 'Email or QR content';

  @override
  String get searchButton => 'Search';

  @override
  String get scanQrButton => 'Scan QR code';

  @override
  String get personalPage => 'Profile';

  @override
  String get groupSuspendedByAdmin =>
      'Group has been suspended by administrator';

  @override
  String get olderMessages => 'Older messages';

  @override
  String get recallMessage => 'Recall';

  @override
  String get reportMessage => 'Report';

  @override
  String get reportReason => 'Reason for report';

  @override
  String get reportMessageDesc => 'Describe why you are reporting this message';

  @override
  String get reportSentToAdmin => 'Report sent to administrator';

  @override
  String get formerMember => 'Former member';

  @override
  String get messageRecalled => 'Message has been recalled';

  @override
  String get typeMessageHint => 'Type a message...';

  @override
  String get sendMessageTooltip => 'Send';

  @override
  String sendErrorRetryHint(String error) {
    return 'Failed to send: $error. Tap to retry.';
  }

  @override
  String commentSaveError(String error) {
    return 'Cannot save comment: $error';
  }

  @override
  String get commentDeleteTitle => 'Delete comment';

  @override
  String get commentDeleteMessage =>
      'Are you sure you want to delete this comment?';

  @override
  String commentDeleteError(String error) {
    return 'Cannot delete comment: $error';
  }

  @override
  String get commentEditTitle => 'Edit comment';

  @override
  String get contentRequired => 'Content cannot be empty';

  @override
  String get selectYourJourney => 'Select your journey';

  @override
  String get searchPlaceHint => 'Search place';

  @override
  String get onlySyncedJourneysHint => 'Only synced journeys can be shared';

  @override
  String get noDataToSelect => 'No data available to select';

  @override
  String get finishJourneyTitle => 'Finish journey?';

  @override
  String get finishJourneyDesc =>
      'Are you sure you want to finish this journey? Track log data will be saved.';

  @override
  String get finishJourneySaveGpsNotice =>
      'After finishing, you can save your GPS track log as a new route to contribute.';

  @override
  String get keepGoingButton => 'Keep going';

  @override
  String get finishButton => 'Finish';

  @override
  String get finishAndSendToAdmin => 'Finish & Submit';

  @override
  String locationFetchFailed(String error) {
    return 'Could not get current location: $error';
  }

  @override
  String get locationFetchForMarkerFailed =>
      'Could not get GPS location for marker';

  @override
  String get sendToAdminButton => 'Send to Admin';

  @override
  String get markersSyncedSendToAdmin =>
      'Markers synced to server. You can submit them for admin review to add to official maps.';

  @override
  String get markersSavedOfflineNeedSync =>
      'Markers saved offline. Once online and synced to server, you can submit to admin.';

  @override
  String get markersSavedOfflineAutoSync =>
      'Markers saved offline on device and will sync automatically when online.';

  @override
  String get completeJourneyBeforeSendAdmin =>
      'Please complete the journey before submitting route/marker proposals to Admin.';

  @override
  String get milestonesLoadFailedRetry =>
      'Could not load milestones. Tap to retry.';

  @override
  String get downloadOrUpdateOfflineMap => 'Download / Update offline map';

  @override
  String get journeyMapTitle => 'Journey map';

  @override
  String get detailLabel => 'Details';

  @override
  String get journeyDetailTitle => 'Journey details';

  @override
  String milestonesArrivedCount(int checked, int total) {
    return 'Reached $checked/$total milestones';
  }

  @override
  String get backtrackReturnToStart => 'Backtrack: Return to start';

  @override
  String get backtrackRecordRoute => 'Backtrack: Record route';

  @override
  String get savedRoute => 'Saved route';

  @override
  String get recordingGpsForeground => 'Recording GPS in background';

  @override
  String get pausedRecordingGps => 'Paused GPS recording';

  @override
  String get savedOfflineUsable => 'Saved offline, usable without connection';

  @override
  String get stopGpsRecording => 'Stop GPS recording';

  @override
  String get recordRouteButton => 'Record route';

  @override
  String get startGpsRecording => 'Start GPS recording';

  @override
  String get exitBacktrack => 'Exit Backtrack';

  @override
  String get returnAlongRoute => 'Return along recorded route';

  @override
  String get backtrackOrangeTrailNotice =>
      'Follow the orange trail on map to return to starting point safely.';

  @override
  String get checkinPointLegend => 'Check-in point';

  @override
  String get yourMarkerLegend => 'Your marker';

  @override
  String yourLocationAccuracy(String accuracy) {
    return 'Your location (±${accuracy}m)';
  }

  @override
  String sendMarkersToAdminCount(int count) {
    return 'Send $count markers to Admin';
  }

  @override
  String get markMilestoneButton => 'Add marker';

  @override
  String get savingJourneyProgress => 'Saving journey progress...';

  @override
  String get finishJourneyButton => 'Finish journey';

  @override
  String get shareToCommunityButton => 'Share to community';

  @override
  String get shareRouteToAdminButton => 'Contribute route to Admin';

  @override
  String cannotOpenRouteShare(String error) {
    return 'Cannot open route share: $error';
  }

  @override
  String get offlineMapAvailable => 'Offline map available';

  @override
  String get offlineMapNotDownloaded => 'Offline map not downloaded';

  @override
  String get tapViewMapNotice => 'Tap to view detailed route map';

  @override
  String checkinPhotosCount(int count) {
    return 'Check-in photos ($count)';
  }

  @override
  String get cannotOpenJourneyData => 'Cannot open journey data';

  @override
  String get journeyPlansLabel => 'Journey plans';

  @override
  String journeyEstimatedTotal(int count) {
    return 'Estimated total: $count days';
  }

  @override
  String personCount(int count) {
    return '$count people';
  }

  @override
  String get provincesLabel => 'Provinces';

  @override
  String get noPlansYet => 'No journey plans yet';

  @override
  String get startFirstJourneyHint => 'Start your first journey!';

  @override
  String get createPlanForNextTripHint => 'Plan your next adventure';

  @override
  String get otherLabel => 'Other';

  @override
  String get contributionTitle => 'Contribute route & markers';

  @override
  String get contributionMarkerOnlyTitle => 'Contribute markers';

  @override
  String get contributionSuccessTitle => 'Contribution submitted successfully!';

  @override
  String get contributionSavedOfflineTitle => 'Contribution saved offline!';

  @override
  String get contributionOfflineNotice =>
      'Contribution saved locally. Once connected to internet, the app will automatically sync and submit it to admins for review.';

  @override
  String contributionMarkersReceived(int count) {
    return 'Thank you for contributing $count new markers. Admin will review and approve them to add to the official TrekViệt map.';
  }

  @override
  String contributionRouteAndMarkersReceived(int count) {
    return 'Thank you for contributing the route and $count new markers. Admin will review and approve them to add to the official TrekViệt map.';
  }

  @override
  String get contributionStatusPendingSync =>
      'Status: Pending sync when online';

  @override
  String get contributionViewHistoryNotice =>
      'You can review this in Contribution History on your Profile page.';

  @override
  String contributionSourceJourney(String name) {
    return 'From journey: $name';
  }

  @override
  String get contributionNameLabel => 'Proposed route name *';

  @override
  String get contributionMarkerNameLabel => 'Contribution name *';

  @override
  String get contributionNameHint => 'e.g.: Fansipan climb via Tram Ton...';

  @override
  String get contributionNameRequired => 'Please enter proposed route name';

  @override
  String get contributionDescLabel => 'Detailed description';

  @override
  String get contributionDescHint =>
      'Describe terrain, landscape, practical experience...';

  @override
  String get contributionSafetyLabel => 'Safety notes / Trail tips';

  @override
  String get contributionSafetyHint =>
      'Water sources, safe camp spots, slippery spots...';

  @override
  String contributionSelectMarkersLabel(int count) {
    return 'Select accompanying markers ($count)';
  }

  @override
  String get contributionSelectMarkersHint =>
      'Select personal markers you created to submit with the route';

  @override
  String get contributionSubmitButton => 'Submit to Admin for review';

  @override
  String get contributionSkipButton => 'Skip contribution';

  @override
  String get markerFormCreateTitle => 'Add marker';

  @override
  String get markerFormEditTitle => 'Edit marker';

  @override
  String get markerNameLabel => 'Marker name *';

  @override
  String get markerNameHint => 'e.g.: Mountain peak, Stream, Camp site...';

  @override
  String get markerTypeLabel => 'Marker type';

  @override
  String get markerGpsCoordinates => 'GPS coordinates';

  @override
  String get markerPhotosLabel => 'Marker photos';

  @override
  String get markerAddPhoto => '+ Add photo';

  @override
  String get markerNoteLabel => 'Additional note';

  @override
  String get markerNoteHint => 'Notes on water, steep slope, phone signal...';

  @override
  String get markerSaveOffline => 'Save marker (Offline)';

  @override
  String get markerSaveAndSync => 'Save & Sync marker';

  @override
  String get markerSyncDesc =>
      'Marker will be saved on device and synced to server when online.';

  @override
  String markerSaveError(String error) {
    return 'Cannot save marker: $error';
  }

  @override
  String get placeReviewTitle => 'Place reviews';

  @override
  String get anonymousTrekker => 'Anonymous Trekker';

  @override
  String get noReviewsYet => 'No reviews yet';

  @override
  String get viewMoreReviews => 'View more reviews';

  @override
  String get satisfactionLevelPrompt => 'How was your experience?';

  @override
  String get shareExperiencePrompt => 'Share your experience';

  @override
  String get shareExperienceHint =>
      'Share tips, advice and your experience at this place...';

  @override
  String get addPhotosPrompt => 'Add photos';

  @override
  String get addPhotosMax10 => 'Up to 10 photos';

  @override
  String get anonymousReviewLabel => 'Anonymous review';

  @override
  String get anonymousReviewDesc => 'Your name will not be shown publicly';

  @override
  String get submitReviewButton => 'Submit review';

  @override
  String get saveReviewEditButton => 'Save review';

  @override
  String get reviewThankYouTitle => 'Thank you!';

  @override
  String get reviewThankYouMessage =>
      'Your review has been recorded and will help the Trekker community in Vietnam.';

  @override
  String get yourReviewSection => 'Your review';

  @override
  String get viewOtherReviewsButton => 'View other reviews';

  @override
  String get backToHomeButton => 'Back to home';

  @override
  String get noFeaturedPlaces => 'No featured places yet';

  @override
  String get noMatchingRoutes => 'No matching routes found';

  @override
  String get noMatchingSuggestions => 'No matching suggestions found';

  @override
  String get addRouteButton => 'Add route';

  @override
  String get addPlaceButton => 'Add place';

  @override
  String routeEstimatedDuration(String duration) {
    return 'Estimated duration: $duration';
  }

  @override
  String routeMaxElevation(String elevation) {
    return 'Max elevation: $elevation m';
  }

  @override
  String routeElevationGain(String gain) {
    return 'Elevation gain: $gain m';
  }

  @override
  String routeTotalDistance(String distance) {
    return 'Total distance: $distance km';
  }

  @override
  String get routeDescriptionTitle => 'Route description';

  @override
  String get routeNoDescription => 'No description available for this route.';

  @override
  String routeDifficultyPrefix(String difficulty) {
    return 'Difficulty: $difficulty';
  }

  @override
  String routePlacePrefix(String place) {
    return 'Location: $place';
  }

  @override
  String routeStartPrefix(String coords) {
    return 'Start point: $coords';
  }

  @override
  String routeEndPrefix(String coords) {
    return 'End point: $coords';
  }

  @override
  String get downloadMapBeforeStart => 'Download map before start';

  @override
  String cannotStartJourney(String error) {
    return 'Cannot start journey: $error';
  }

  @override
  String get backToJourneyScreen => 'Back to journeys';

  @override
  String get difficultyEasy => 'Easy';

  @override
  String get difficultyModerate => 'Moderate';

  @override
  String get difficultyHard => 'Hard';

  @override
  String get difficultyExpert => 'Expert';

  @override
  String get placeAboutSection => 'About';

  @override
  String get placeNoDescription => 'No description available for this place.';

  @override
  String placeRoutesSection(int count) {
    return 'Trekking routes ($count)';
  }

  @override
  String get placeNoRoutes => 'No routes at this location yet.';

  @override
  String get offlineMapTitle => 'Offline map management';

  @override
  String offlineMapStorageUsed(String size) {
    return 'Storage used: $size';
  }

  @override
  String offlineMapCount(int count) {
    return '$count maps downloaded';
  }

  @override
  String get noOfflineMapsTitle => 'No offline maps yet';

  @override
  String get noOfflineMapsDesc =>
      'Download maps for your upcoming trails to use when offline.';

  @override
  String get deleteOfflineMapTitle => 'Delete offline map';

  @override
  String deleteOfflineMapConfirm(String name) {
    return 'Are you sure you want to delete the offline map for \"$name\"? You will need to re-download it to use offline.';
  }

  @override
  String get deleteOfflineMapButton => 'Delete map';

  @override
  String deleteOfflineMapSuccess(String name) {
    return 'Deleted map for $name';
  }

  @override
  String deleteOfflineMapError(String error) {
    return 'Cannot delete map: $error';
  }

  @override
  String offlineMapInUseNotice(String name) {
    return 'Map \"$name\" is currently in use by active journey.';
  }

  @override
  String get badgeUnlocked => 'Unlocked';

  @override
  String get badgeLocked => 'Locked';

  @override
  String badgeAchievedDate(String date) {
    return 'Achieved on: $date';
  }

  @override
  String get badgeMissionProgress => 'Challenge progress';

  @override
  String get viewAll => 'View all';

  @override
  String get shareAchievement => 'Share achievement';

  @override
  String shareAchievementText(String title) {
    return 'I just earned the \"$title\" badge on TrekViệt! Let\'s explore Vietnam\'s trekking trails together!';
  }

  @override
  String get suggestPlaceSuccess =>
      'Place suggestion submitted successfully! Admins will review and respond soon.';

  @override
  String get filterAll => 'All';

  @override
  String cannotLoadRoutesError(String error) {
    return 'Could not load some routes: $error';
  }

  @override
  String get noDistanceAvailable => 'No distance info';

  @override
  String reviewsCount(String rating, int count) {
    return '$rating ($count reviews)';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String durationHours(int hours) {
    return '$hours hr';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours hr $minutes min';
  }

  @override
  String durationDays(String days) {
    return '$days days';
  }

  @override
  String get routeScope => 'Route';

  @override
  String get placeScope => 'Place';

  @override
  String get mapInUseBadge => 'Active';

  @override
  String downloadedOnDate(String date) {
    return 'Downloaded: $date';
  }

  @override
  String get readyForOfflineUse => 'Ready for offline use';

  @override
  String get manageOfflineMaps => 'Manage offline maps';

  @override
  String get homeNoPlacesToExplore => 'No places to explore yet';

  @override
  String get yourMapPosterTitle => 'Your map poster';

  @override
  String get downloadPosterNow => 'Download image now';

  @override
  String get loadProvinces => 'Load provinces';

  @override
  String get statElevation => 'Elevation';

  @override
  String get statDuration => 'Duration';

  @override
  String get statRoutes => 'Routes';

  @override
  String get difficultyExtreme => 'Extreme';

  @override
  String get commonError => 'An error occurred. Please try again.';

  @override
  String get statTotalDistance => 'Total distance';

  @override
  String get statElevationGain => 'Total elevation gain';

  @override
  String get statEstimatedDuration => 'Estimated duration';

  @override
  String get storageUsedLabel => 'Storage used';

  @override
  String get journeyCompletedTitle => 'Journey completed!';

  @override
  String get termsOfUseTitle => 'Terms of Use';

  @override
  String get termsLastUpdated => 'Last updated: 12/20/2025';

  @override
  String get termsSection1Title => 'Introduction';

  @override
  String get termsSection1Content =>
      'Welcome to Trek Vietnam, an application that supports navigation, logging trekking journeys, and connecting outdoor enthusiast communities in Vietnam. By registering an account, you agree to comply with these terms.';

  @override
  String get termsSection2Title => 'Terms of Service';

  @override
  String get termsSection2Content =>
      'You must be 16 years of age or older or have guardian supervision to use the application. You are solely responsible for password security and all activities under your account.';

  @override
  String get termsSection3Title => 'User Rights and Obligations';

  @override
  String get termsSection3Content =>
      'Users are allowed to use offline maps, store travel history, and share healthy trekking photos with the community. Acts of vandalizing data or posting misleading information about border maps or sensitive landmarks are strictly prohibited.';

  @override
  String get termsSection4Title => 'Intellectual Property Rights';

  @override
  String get termsSection4Content =>
      'All source code, graphic designs, badge systems, and proprietary trekking route databases are the property of Trek Vietnam. Any unauthorized copying is strictly prohibited.';

  @override
  String get termsSection5Title => 'Limitation of Liability';

  @override
  String get termsSection5Content =>
      'Trekking is an outdoor extreme sport. We provide GPS maps for reference and are not liable for any accidents, natural risks, or getting lost on actual trails.';

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String get privacySection1Title => 'Data Collection';

  @override
  String get privacySection1Content =>
      'We collect registration information (Name, Email, Avatar) and specifically your GPS location data (even when the app runs in the background) to map trekking routes and enable check-in features.';

  @override
  String get privacySection2Title => 'Data Usage';

  @override
  String get privacySection2Content =>
      'Location data is used to display your position on outdoor maps, tally total distance traveled, and unlock personal exploration badges.';

  @override
  String get privacySection3Title => 'Data Sharing';

  @override
  String get privacySection3Content =>
      'Your information and trekking history are only shared publicly when you actively click \'Publish Post\' in Community forums or share badges to social networks.';

  @override
  String get privacySection4Title => 'Information Security';

  @override
  String get privacySection4Content =>
      'Trek Vietnam applies advanced end-to-end encryption measures to protect your personal information and coordinate data from unauthorized access.';

  @override
  String get privacySection5Title => 'Your Rights';

  @override
  String get privacySection5Content =>
      'You have the right to access, edit your personal profile information, or request permanent deletion of your account and all GPS location history stored on our servers at any time.';

  @override
  String get journeyOptionsTitle => 'Options';

  @override
  String get routeDetailOption => 'Route Details';

  @override
  String get journeyDetailOption => 'Journey Details';

  @override
  String get selectPlaceTitle => 'Select Place';

  @override
  String get cannotLoadPlaces => 'Cannot load places.';

  @override
  String get noPlacesAvailable => 'No places available.';

  @override
  String get changePlaceButton => 'Change place';

  @override
  String get searchRouteHint => 'Search route';

  @override
  String get cannotLoadRoutesAtPlace => 'Cannot load routes for this place.';

  @override
  String get placeHasNoRoutes => 'This place has no routes.';

  @override
  String routesAtPlacePrefix(String place) {
    return 'Routes at $place';
  }

  @override
  String get downloadButton => 'Download';

  @override
  String get retryDownloadButton => 'Retry download';

  @override
  String get cannotLoadRoutesGeneral => 'Cannot load routes. Please try again.';

  @override
  String get personalQrTitle => 'Personal QR';

  @override
  String get personalQrDesc =>
      'Others scan this code to view your profile and message you.';

  @override
  String get copyCodeButton => 'Copy code';

  @override
  String get closeButton => 'Close';

  @override
  String get noBioYet => 'No bio yet.';

  @override
  String userPostsCount(int count) {
    return '$count posts';
  }

  @override
  String get aboutSection => 'About';

  @override
  String get personalBio => 'Personal Bio';

  @override
  String get myQrCode => 'My QR';

  @override
  String get reissueQrDialogTitle => 'Reissue QR?';

  @override
  String get reissueQrDialogMessage => 'The old code will stop working.';

  @override
  String get reissueButton => 'Reissue';

  @override
  String get sendMessageButton => 'Message';

  @override
  String get cannotStartJourneyGeneral =>
      'Cannot start journey. Please try again.';

  @override
  String get viewMorePosts => 'View more posts';

  @override
  String get communityProfileTitle => 'Community Profile';

  @override
  String get backToJourneyButton => 'Back to journey';

  @override
  String get markerNameRequired => 'Enter milestone name';

  @override
  String get syncFailedCheck => 'Sync failed — review needed';

  @override
  String get savedOfflinePendingSync => 'Saved on device · pending sync';

  @override
  String memberCountText(int count) {
    return '$count members';
  }

  @override
  String get cancelJourneyButton => 'Cancel journey';

  @override
  String get cancelJourneyConfirmTitle => 'Cancel journey?';

  @override
  String get cancelJourneyConfirmMessage =>
      'Are you sure you want to cancel this journey? Its status will be changed to cancelled.';

  @override
  String get editReviewOnceButton => 'Edit review (1 time)';

  @override
  String get completeJourneyToReview => 'Complete a journey here to review.';

  @override
  String get reviewRemoved => 'Your review has been removed.';

  @override
  String get reviewEditLimitReached => 'You have used your review edit limit.';

  @override
  String get viewAllReviewsButton => 'View all reviews';
}
