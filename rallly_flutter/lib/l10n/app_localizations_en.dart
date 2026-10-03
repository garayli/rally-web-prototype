// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'RallyMatch';

  @override
  String get sportTennis => 'Tennis';

  @override
  String get sportTennisSub => 'Singles & doubles';

  @override
  String get sportPadel => 'Padel';

  @override
  String get sportPadelSub => 'Racquet sport';

  @override
  String get sportBadminton => 'Badminton';

  @override
  String get sportBadmintonSub => 'Indoor & outdoor';

  @override
  String get sportSquash => 'Squash';

  @override
  String get sportSquashSub => 'Court sport';

  @override
  String get skillBeginner => 'Beginner';

  @override
  String get skillBeginnerSub => 'Under 1 year — learning the basics';

  @override
  String get skillIntermediate => 'Intermediate';

  @override
  String get skillIntermediateSub => '1–4 years — rallies comfortably';

  @override
  String get skillAdvanced => 'Advanced';

  @override
  String get skillAdvancedSub => 'Competitive — strong all-round game';

  @override
  String get skillExpert => 'Expert';

  @override
  String get skillExpertSub => 'Tournament level — top-tier play';

  @override
  String get dayMon => 'Mon';

  @override
  String get dayTue => 'Tue';

  @override
  String get dayWed => 'Wed';

  @override
  String get dayThu => 'Thu';

  @override
  String get dayFri => 'Fri';

  @override
  String get daySat => 'Sat';

  @override
  String get daySun => 'Sun';

  @override
  String get timeMorning => 'Morning';

  @override
  String get timeAfternoon => 'Afternoon';

  @override
  String get timeEvening => 'Evening';

  @override
  String get courtThemeClay => 'Clay';

  @override
  String get courtThemeHard => 'Hard court';

  @override
  String get courtThemeGrass => 'Grass';

  @override
  String get navFindOpponent => 'Find Opponent';

  @override
  String get navMessages => 'Messages';

  @override
  String get navNotifications => 'Alerts';

  @override
  String get navProfile => 'Profile';

  @override
  String get createMatchFab => 'Create Match';

  @override
  String get matchBadgeLabel => 'MATCH';

  @override
  String get requestShort => 'Request';

  @override
  String get profileCompleteTitle => 'Complete your profile';

  @override
  String profilePercentDone(int percent) {
    return '$percent% complete';
  }

  @override
  String profileMissing(String items) {
    return 'Missing: $items';
  }

  @override
  String get missingBio => 'bio';

  @override
  String get missingAvailability => 'availability';

  @override
  String get missingSport => 'sport';

  @override
  String get missingLevel => 'level';

  @override
  String get profileSetSchedule => 'Set your weekly schedule';

  @override
  String get profileTitle => 'My Profile';

  @override
  String get courtThemeTitle => 'Court Theme';

  @override
  String get courtThemeSubtitle => 'Choose the app\'s color theme';

  @override
  String get courtThemeClaySub => 'Roland-Garros style';

  @override
  String get courtThemeHardSub => 'US Open style';

  @override
  String get courtThemeGrassSub => 'Wimbledon style';

  @override
  String get photoUploadSoon => 'Photo upload coming soon';

  @override
  String profileNtrpLine(String rating, String level) {
    return '🎾  NTRP $rating — $level';
  }

  @override
  String get profileNtrpUnknown => '🎾  NTRP —';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get statWins => 'WINS';

  @override
  String get statLosses => 'LOSSES';

  @override
  String get statPlayed => 'PLAYED';

  @override
  String get statRating => 'RATING';

  @override
  String get uploadScore => 'Upload Score';

  @override
  String get scoreRequests => 'Score Requests';

  @override
  String get myMatchesHeader => 'MY MATCHES';

  @override
  String tabUpcomingCount(int count) {
    return 'Upcoming ($count)';
  }

  @override
  String tabPastCount(int count) {
    return 'Past ($count)';
  }

  @override
  String tabPendingCount(int count) {
    return 'Pending ($count)';
  }

  @override
  String get emptyUpcoming => 'No upcoming matches';

  @override
  String get emptyPast => 'No past matches';

  @override
  String get emptyPending => 'No pending requests';

  @override
  String get sectionMyGame => 'MY GAME';

  @override
  String get reputation => 'Reputation';

  @override
  String get reputationSub => '4.9 rating · 4 reviews';

  @override
  String get achievements => 'Achievements';

  @override
  String get achievementsSub => '12 of 18 earned';

  @override
  String get myResults => 'My Results';

  @override
  String get myResultsSub => 'Match history and scores';

  @override
  String get logResult => 'Log Result';

  @override
  String get logResultSub => 'Log your latest match';

  @override
  String get sectionAccount => 'ACCOUNT';

  @override
  String get editProfileSub => 'Update name, location, bio, level';

  @override
  String get gamePreferences => 'Game Preferences';

  @override
  String get gamePreferencesSub => 'Level, court type, format';

  @override
  String get gamePreferencesSoon => 'Game preferences coming soon';

  @override
  String get availability => 'Availability';

  @override
  String get sectionApp => 'APP';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsSub => 'Match requests, reminders';

  @override
  String get courtThemeOptions => 'Clay / Hard court / Grass';

  @override
  String get privacySecurity => 'Privacy & Security';

  @override
  String get privacySecuritySub => 'Profile visibility';

  @override
  String get privacySettingsSoon => 'Privacy settings coming soon';

  @override
  String get sectionAbout => 'ABOUT';

  @override
  String get termsPrivacy => 'Terms & Privacy';

  @override
  String get termsPrivacySoon => 'Terms & Privacy coming soon';

  @override
  String get signOut => 'Sign Out';

  @override
  String get profileLoadingRetry => 'Loading profile, please try again';

  @override
  String get profileUpdated => 'Profile updated';

  @override
  String vsOpponent(String name) {
    return 'vs $name';
  }

  @override
  String get statusUpcomingUpper => 'UPCOMING';

  @override
  String get statusCompletedUpper => 'COMPLETED';

  @override
  String get statusPendingUpper => 'PENDING';

  @override
  String get statusCancelledUpper => 'CANCELLED';

  @override
  String get statusConfirmed => 'Confirmed';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get formatDoubles => 'Doubles';

  @override
  String get formatSingles => 'Singles';

  @override
  String get requestMatch => 'Request Match';

  @override
  String get sort => 'Sort';

  @override
  String get filter => 'Filter';

  @override
  String get upcomingMatchesHeader => 'UPCOMING MATCHES';

  @override
  String get seeAll => 'See all';

  @override
  String nearbyPlayersHeader(int count) {
    return '$count PLAYERS NEARBY';
  }

  @override
  String get map => 'Map';

  @override
  String get openLobbiesHeader => 'OPEN LOBBIES';

  @override
  String get createLobby => 'Create Lobby';

  @override
  String get nearbyPlayersEyebrow => 'NEARBY PLAYERS';

  @override
  String playersWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count players are waiting for you',
      one: '1 player is waiting for you',
    );
    return '$_temp0';
  }

  @override
  String get searchNameOrLocation => 'Search by name or location…';

  @override
  String winRatePercent(int percent) {
    return '$percent% win rate';
  }

  @override
  String matchesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count matches',
      one: '1 match',
    );
    return '$_temp0';
  }

  @override
  String get skillShortBeginner => 'Beg.';

  @override
  String get skillShortIntermediate => 'Int.';

  @override
  String get skillShortAdvanced => 'Adv.';

  @override
  String get skillShortExpert => 'Exp.';

  @override
  String get tennisBadge => '🎾 TENNIS';

  @override
  String get sortDistance => 'Distance';

  @override
  String get sortWins => 'Wins';

  @override
  String get sortSheetSubtitle => 'How to order players';

  @override
  String get apply => 'Apply';

  @override
  String get filterTitle => 'Filter';

  @override
  String get clear => 'Clear';

  @override
  String get level => 'Level';

  @override
  String get distance => 'Distance';

  @override
  String get all => 'All';

  @override
  String get join => 'Join';

  @override
  String lobbyJoinSent(String sport) {
    return 'Join request sent to the $sport lobby!';
  }

  @override
  String get authErrorRateLimit =>
      'Too many code requests. Please wait a few minutes and try again.';

  @override
  String get authErrorGeneric => 'Something went wrong. Please try again.';

  @override
  String get authErrorNoAccount =>
      'No account found for this email. Go back and choose \"Get started\" to sign up.';

  @override
  String get authErrorInvalidEmail => 'Please enter a valid email address.';

  @override
  String get authErrorCodeInvalidOrExpired =>
      'The code is invalid or has expired. Please request a new one.';

  @override
  String get authErrorInvalidCode => 'Invalid code. Please try again.';

  @override
  String get authErrorResendFailed =>
      'Couldn\'t send the code. Please try again.';

  @override
  String get authCreateAccount => 'Create account';

  @override
  String get authWelcomeBack => 'Welcome back';

  @override
  String get authEmailPromptSignUp =>
      'Enter your email address and we\'ll send you a one-time code';

  @override
  String get authEmailPromptSignIn =>
      'We\'ll send a sign-in code to your email address';

  @override
  String get authEmailLabel => 'EMAIL ADDRESS';

  @override
  String get authEmailHint => 'you@example.com';

  @override
  String get authSendCode => 'Send code';

  @override
  String get authHaveAccount => 'Already have an account? ';

  @override
  String get authNoAccount => 'Don\'t have an account? ';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authSignUp => 'Sign up';

  @override
  String get authCheckEmail => 'Check your email';

  @override
  String get authCodeSentTo =>
      'We sent an 8-digit code to your email address:\n';

  @override
  String get authVerify => 'Verify';

  @override
  String get authResendCode => 'Resend code';

  @override
  String authResendIn(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get landingSignInButton => 'Sign In';

  @override
  String get landingHeadline => 'Find your\nperfect opponent.';

  @override
  String get landingSubtitle =>
      'Find tennis players at your level, book courts and track your progress.';

  @override
  String get landingStatPlayers => 'Players';

  @override
  String get landingStatMatchRate => 'Match rate';

  @override
  String get landingStatRating => 'Rating';

  @override
  String get landingGetStarted => 'Get started — completely free';

  @override
  String get landingHaveAccount => 'I already have an account';

  @override
  String get landingTerms =>
      'By continuing you agree to our Terms and Privacy Policy';

  @override
  String get signupFinish => 'Finish — Let\'s play 🎾';

  @override
  String get signupContinue => 'Continue';

  @override
  String get signupStep1Title => 'Tell us about yourself';

  @override
  String get signupStep1Subtitle => 'Help players find you';

  @override
  String get signupNameLabel => 'FULL NAME';

  @override
  String get signupNameHint => 'e.g. Leyla Garayli';

  @override
  String get signupLocationLabel => 'NEIGHBORHOOD / CITY';

  @override
  String get signupLocationHint => 'e.g. Beşiktaş, Istanbul';

  @override
  String get signupStep2Title => 'Which sports do you play?';

  @override
  String get signupStep2Subtitle => 'Select all that apply';

  @override
  String get signupStep3Title => 'What\'s your level?';

  @override
  String get signupStep3Subtitle =>
      'Be honest — it helps find the best matches';

  @override
  String get signupStep4Title => 'When are you usually available?';

  @override
  String get signupStep4Subtitle => 'Pick your typical availability';

  @override
  String get signupDaysHeader => 'DAYS';

  @override
  String get signupTimeOfDayHeader => 'TIME OF DAY';

  @override
  String get profileSaveFailed =>
      'Couldn\'t save your profile. Please try again.';

  @override
  String get editAboutLabel => 'ABOUT ME';

  @override
  String get editAboutHint => 'Your playing style, favorite courts…';

  @override
  String get editSportsLabel => 'SPORTS';

  @override
  String get editLevelLabel => 'LEVEL';

  @override
  String get editDaysLabel => 'AVAILABLE DAYS';

  @override
  String get save => 'Save';

  @override
  String get createGameQuestion => 'What would you like to do?';

  @override
  String get createGameSubtitle => 'Pick an option and get started.';

  @override
  String get createGameStartMatch => 'Start a Match';

  @override
  String get createGameStartMatchSub =>
      'Set up a date with a specific opponent.';

  @override
  String get createGamePublishOpen => 'Publish an Open Match';

  @override
  String get createGamePublishOpenSub =>
      'Create a public slot and wait for an opponent.';

  @override
  String get errorNotSignedIn => 'You need to be signed in';

  @override
  String get errorRecipientNotRegistered =>
      'This player isn\'t registered, so you can\'t message them';

  @override
  String get errorMatchUpdateDenied =>
      'Couldn\'t update the match (not permitted)';

  @override
  String get errorUnknown => 'Something went wrong. Please try again.';

  @override
  String get matchRequestTitle => 'Match Request';

  @override
  String get format => 'Format';

  @override
  String get dateAndTime => 'Date & Time';

  @override
  String get court => 'Court';

  @override
  String get pastTimeNotAllowed => 'You can\'t pick a time in the past';

  @override
  String matchRequestSentTo(String name) {
    return 'Match request sent to $name!';
  }

  @override
  String requestFailed(String reason) {
    return 'Couldn\'t send the request: $reason';
  }

  @override
  String get requestSent => 'Request Sent ✓';

  @override
  String get sendRequest => 'Send Request 🎾';

  @override
  String get badgeFirstMatch => 'First Match';

  @override
  String get badgeFirstMatchDesc => 'You played your first game';

  @override
  String get badgeWinStreak => 'Winning Streak';

  @override
  String get badgeWinStreakDesc => '3 wins in a row';

  @override
  String get badgeFiveStar => '5-Star Player';

  @override
  String get badgeFiveStarDesc => 'Average rating 4.8+';

  @override
  String get badgeSocialButterfly => 'Social Butterfly';

  @override
  String get badgeSocialButterflyDesc => 'Connected with 10 players';

  @override
  String get badgeRegularPlayer => 'Regular Player';

  @override
  String get badgeRegularPlayerDesc => '10+ matches played';

  @override
  String get badgeChampion => 'Champion';

  @override
  String get badgeChampionDesc => '25+ wins';

  @override
  String get badgeQuickReply => 'Quick Reply';

  @override
  String get badgeQuickReplyDesc => 'Replied within 1 hour';

  @override
  String get badgeExplorer => 'Explorer';

  @override
  String get badgeExplorerDesc => 'Played on 5 different courts';

  @override
  String get badgeCommunicator => 'Communicator';

  @override
  String get badgeCommunicatorDesc => 'Sent 50 messages';

  @override
  String get badgeSharpshooter => 'Sharpshooter';

  @override
  String get badgeSharpshooterDesc => '80%+ win rate';

  @override
  String get badgeSharer => 'Sharer';

  @override
  String get badgeSharerDesc => 'Shared 5 match results';

  @override
  String get badgeElite => 'Elite';

  @override
  String get badgeEliteDesc => 'Reached Advanced level';

  @override
  String get badgeTournamentPro => 'Tournament Pro';

  @override
  String get badgeTournamentProDesc => 'Join a tournament';

  @override
  String get badgeLegend => 'Legend';

  @override
  String get badgeLegendDesc => '100 matches played';

  @override
  String get badgeGrandSlam => 'Grand Slam';

  @override
  String get badgeGrandSlamDesc => 'Win on 4 different courts';

  @override
  String get badgeDoublesKing => 'Doubles King';

  @override
  String get badgeDoublesKingDesc => 'Won 10 doubles matches';

  @override
  String get badgeAllRounder => 'All-Rounder';

  @override
  String get badgeAllRounderDesc => 'Played all 4 sports';

  @override
  String get badgeRocket => 'Rocket';

  @override
  String get badgeRocketDesc => 'Rating up by 200+';

  @override
  String achievementsEarnedOf(int earned, int total) {
    return '$earned of $total';
  }

  @override
  String get achievementsEarnedLabel => 'Achievements earned';

  @override
  String get achievementsEarnedHeader => 'EARNED';

  @override
  String get achievementsLockedHeader => 'LOCKED';

  @override
  String get prefMatchRequests => 'Match Requests';

  @override
  String get prefMatchRequestsSub => 'When someone wants to play you';

  @override
  String get prefMatchConfirmations => 'Match Confirmations';

  @override
  String get prefMatchConfirmationsSub => 'When a request is accepted';

  @override
  String get prefMatchReminders => 'Match Reminders';

  @override
  String get prefMatchRemindersSub => 'Reminder before a scheduled match';

  @override
  String get prefMatchCancellations => 'Cancellation Alerts';

  @override
  String get prefMatchCancellationsSub => 'When a match is cancelled';

  @override
  String get prefMessages => 'Messages';

  @override
  String get prefMessagesSub => 'New messages from other players';

  @override
  String get prefNewReviews => 'New Reviews';

  @override
  String get prefNewReviewsSub => 'When someone reviews you';

  @override
  String get prefResultConfirmed => 'Result Confirmed';

  @override
  String get prefResultConfirmedSub => 'When your opponent confirms the result';

  @override
  String get prefNearbyPlayers => 'Nearby Players';

  @override
  String get prefNearbyPlayersSub => 'When new players join your area';

  @override
  String get prefMarketing => 'App Updates & Tips';

  @override
  String get prefMarketingSub => 'New features and gameplay tips';

  @override
  String get prefSaved => 'Saved ✓';

  @override
  String get prefSectionMatches => 'MATCHES';

  @override
  String get prefSectionSocial => 'SOCIAL';

  @override
  String get prefSectionUpdates => 'UPDATES';

  @override
  String get skillAnyLevel => 'Any level';

  @override
  String get lobbyCreated => 'Open lobby created! Players can now join.';

  @override
  String lobbyCreateFailed(String reason) {
    return 'Couldn\'t create the lobby: $reason';
  }

  @override
  String get openLobbyTitle => 'Open Lobby';

  @override
  String get openLobbyHeadline => 'Create an open slot';

  @override
  String get openLobbySubtitle =>
      'Other players can request to join your session';

  @override
  String get openLobbySport => 'SPORT';

  @override
  String get openLobbyInvitedLevel => 'INVITED LEVEL';

  @override
  String get openLobbyDateTime => 'DATE & TIME';

  @override
  String get pickDate => 'Pick a date';

  @override
  String get pickTime => 'Pick a time';

  @override
  String get openLobbyCourt => 'COURT';

  @override
  String get openLobbyNotes => 'NOTES (OPTIONAL)';

  @override
  String get openLobbyNotesHint =>
      'e.g. \"Bring your own balls, relaxed game, beginners welcome\"';

  @override
  String get openLobbyPublic => 'Public lobby';

  @override
  String get openLobbyPublicSub => 'Anyone can request to join';

  @override
  String get openLobbyCreateButton => 'Create Lobby 🎾';

  @override
  String get onboardingGotIt => 'Got it!';

  @override
  String get onboardingFind1 =>
      'Find players at your level and send match requests.';

  @override
  String get onboardingFind2 => 'Sort by NTRP, win rate and availability.';

  @override
  String get onboardingFind3 => 'Filter, explore, hit the court.';

  @override
  String get onboardingMessages1 =>
      'Message your opponent directly before and after the match.';

  @override
  String get onboardingMessages2 =>
      'Follow all your conversations in one place.';

  @override
  String get onboardingMessages3 => 'Easily share court details and time.';

  @override
  String get onboardingNotifications1 =>
      'Accept or decline incoming match requests.';

  @override
  String get onboardingNotifications2 =>
      'See score updates and reminders here.';

  @override
  String get onboardingNotifications3 =>
      'Stay instantly informed of everything important.';

  @override
  String get onboardingProfile1 =>
      'View your NTRP level, stats and achievements.';

  @override
  String get onboardingProfile2 =>
      'Track your match history and schedule here.';

  @override
  String get onboardingProfile3 =>
      'Edit notification preferences and account settings.';

  @override
  String get reviewCommentEmre =>
      'Great rallies, very sporty — can\'t wait for a rematch!';

  @override
  String get reviewCommentSelin =>
      'Excellent player, always on time and very fair. Highly recommended.';

  @override
  String get reviewCommentZeynep =>
      'Nice match, closely fought. Very competitive but always friendly.';

  @override
  String get reviewCommentBerk =>
      'I really enjoyed the match. Gave great tips too!';

  @override
  String get reviewTagPunctual => 'Punctual';

  @override
  String get reviewTagSporty => 'Sporty';

  @override
  String get reviewTagGoodComm => 'Good communication';

  @override
  String get reviewTagFairPlay => 'Fair play';

  @override
  String get reviewTagCompetitive => 'Competitive';

  @override
  String get reviewTagFriendly => 'Friendly';

  @override
  String get reviewTagHelpful => 'Helpful';

  @override
  String get reputationMine => 'My Reputation';

  @override
  String reputationOf(String name) {
    return '$name\'s Reputation';
  }

  @override
  String reviewsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reviews',
      one: '1 review',
    );
    return '$_temp0';
  }

  @override
  String get resultWon => 'Won';

  @override
  String get resultLost => 'Lost';

  @override
  String ratingPoints(String delta) {
    return '$delta pts';
  }

  @override
  String get gamesTitle => 'Matches';

  @override
  String get tabUpcoming => 'Upcoming';

  @override
  String get tabPast => 'Past';

  @override
  String get newMatch => 'New Match';

  @override
  String get emptyUpcomingHint => 'Schedule a new match to get started';

  @override
  String get message => 'Message';

  @override
  String get notifFilterAll => 'All';

  @override
  String get notifFilterMatches => 'Matches';

  @override
  String get notifFilterOther => 'Other';

  @override
  String actionFailed(String reason) {
    return 'Action failed: $reason';
  }

  @override
  String get groupToday => 'Today';

  @override
  String get groupYesterday => 'Yesterday';

  @override
  String get groupThisWeek => 'This Week';

  @override
  String get markAllRead => 'Mark all read';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get decline => 'Decline';

  @override
  String get accept => 'Accept';

  @override
  String get dispute => 'Dispute';

  @override
  String get confirm => 'Confirm';

  @override
  String minutesAgo(int minutes) {
    return '$minutes min ago';
  }

  @override
  String hoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String get inboxFilterUnread => 'Unread';

  @override
  String get inboxFilterMatchPartners => 'Match Partners';

  @override
  String get editConversationsSoon => 'Editing conversations coming soon';

  @override
  String get searchNameOrMessage => 'Search by name or message…';

  @override
  String get noResults => 'No results found';

  @override
  String get noMessagesYet => 'No messages yet';

  @override
  String minutesShort(int minutes) {
    return '${minutes}m';
  }

  @override
  String get messageSendFailed =>
      'Message couldn\'t be sent. Tap the message to retry.';

  @override
  String get online => 'Online';

  @override
  String messageHint(String name) {
    return 'Message $name…';
  }

  @override
  String get back => 'Back';

  @override
  String matchPercentTag(int percent) {
    return '🎾 $percent% match';
  }

  @override
  String get profileWins => 'Wins';

  @override
  String get profileLosses => 'Losses';

  @override
  String get profilePlayed => 'Played';

  @override
  String get profileWinPct => 'Win %';

  @override
  String get seeAllReviews => '4.9 · See all reviews';

  @override
  String get sectionAvailability => 'AVAILABILITY';

  @override
  String get sectionPreferredCourts => 'PREFERRED COURTS';

  @override
  String get playerSavedSoon => 'Player saved — coming soon';

  @override
  String get slotFullDay => 'Full';

  @override
  String get slotMorning => 'AM';

  @override
  String get slotAfternoon => 'PM';

  @override
  String get nearbyPlayersTitle => 'Nearby Players';

  @override
  String get mapMeMarker => 'Me';

  @override
  String get viewProfile => 'View Profile';

  @override
  String logResultFailed(String reason) {
    return 'Couldn\'t save the result: $reason';
  }

  @override
  String get logOpponentLabel => 'OPPONENT';

  @override
  String get logGuestPlayer => 'Unregistered Player';

  @override
  String get logGuestPhoneHint => 'Phone number (required)';

  @override
  String get logGuestNameHint => 'Name (optional)';

  @override
  String get logYou => 'You';

  @override
  String get logOpponentShort => 'Opponent';

  @override
  String logSetN(int n) {
    return 'SET $n';
  }

  @override
  String get logAddSet3 => 'Add 3rd set';

  @override
  String get logWinnerLabel => 'WINNER';

  @override
  String get logIWon => 'I won 🏆';

  @override
  String get logOpponentWon => 'Opponent won';

  @override
  String get logYouWonMatch => 'You won this match!';

  @override
  String logNameWon(String name) {
    return '$name won';
  }

  @override
  String get change => 'Change';

  @override
  String get logSaveResult => 'Save Result';

  @override
  String get courtUnspecified => 'Not specified';

  @override
  String get scheduleTitle => 'Schedule';

  @override
  String get noMatchToday => 'No matches today';

  @override
  String get noMatchTodayHint => 'Find a new opponent or plan a session';

  @override
  String get findNewMatch => 'Find a new match';

  @override
  String get playersNearYou => '4 players available near you';

  @override
  String get singlesMatchTitle => 'Singles Match';

  @override
  String get doublesMatchTitle => 'Doubles Match';

  @override
  String matchRequestSentToName(String name) {
    return 'Match request sent to $name!';
  }

  @override
  String get doublesInviteSent => 'Doubles invitation sent!';

  @override
  String get pickOpponentLabel => 'CHOOSE OPPONENT';

  @override
  String get partnerLabel => 'YOUR PARTNER';

  @override
  String get sendMatchRequestButton => 'Send Match Request 🎾';

  @override
  String get sendInviteButton => 'Send Invitation 🎾';

  @override
  String get shareText => 'My match result on Rallly 🎾';

  @override
  String get shareFailed => 'Couldn\'t share. Please try again.';

  @override
  String get matchResultTitle => 'Match Result';

  @override
  String get sharing => 'Sharing…';

  @override
  String get shareResult => 'Share Result 🎾';

  @override
  String get done => 'Done';

  @override
  String get victory => 'Victory 🏆';

  @override
  String get defeat => 'Defeat';

  @override
  String get errorOwnLobby => 'This is your own lobby';

  @override
  String get errorAlreadyRequested => 'You already asked to join this lobby';

  @override
  String get lobbyYours => 'Your lobby';

  @override
  String get lobbyRequested => 'Request sent';

  @override
  String get errorLobbyQueueFull =>
      'This lobby has reached its limit of waiting requests. Try again once the organiser answers some.';

  @override
  String get errorLobbyFull => 'This lobby\'s roster is full.';

  @override
  String get errorLobbyClosed => 'This lobby no longer takes requests.';

  @override
  String get openLobbyFormat => 'Match type';

  @override
  String get lobbyQueueFull => 'Full for now';

  @override
  String get lobbyQueueFullHint => 'A spot opens when the organiser answers';

  @override
  String get lobbyRosterFull => 'Roster full';

  @override
  String get lobbyManage => 'Manage';

  @override
  String lobbyCounts(int accepted, int capacity, int pending) {
    return '$accepted/$capacity accepted · $pending waiting';
  }

  @override
  String get lobbyManageTitle => 'Manage lobby';

  @override
  String get lobbyPendingSection => 'Waiting requests';

  @override
  String get lobbyAcceptedSection => 'Accepted';

  @override
  String get lobbyNoParticipants => 'No requests yet.';

  @override
  String get lobbyAccept => 'Accept';

  @override
  String get lobbyDecline => 'Decline';

  @override
  String get lobbyMessage => 'Message';

  @override
  String get lobbyRemove => 'Remove';

  @override
  String get lobbyRemoveTitle => 'Remove player?';

  @override
  String lobbyRemoveBody(String name) {
    return '$name will be removed from the lobby, their match cancelled, and they\'ll be notified.';
  }

  @override
  String get lobbyClose => 'Close lobby';

  @override
  String get lobbyCloseTitle => 'Close this lobby?';

  @override
  String get lobbyCloseBody =>
      'No new requests, and waiting requests are declined. Matches you already accepted stay.';

  @override
  String get lobbyClosedDone => 'Lobby closed.';

  @override
  String get lobbyRemovedDone => 'Player removed from the lobby.';

  @override
  String get lobbyAcceptedDone => 'Request accepted.';

  @override
  String get lobbyDeclinedDone => 'Request declined.';

  @override
  String get lobbyJoined => 'You\'re in';

  @override
  String get lobbyMatched => 'Matched';

  @override
  String lobbyIncomingRequests(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count requests',
      one: '1 request',
    );
    return '$_temp0';
  }

  @override
  String get requestIncomingLabel => 'Request for you';

  @override
  String get requestSentLabel => 'Awaiting reply';

  @override
  String get matchDetailRespondHint =>
      'Accept or decline from the Notifications tab.';

  @override
  String get signupNameNeedsSurname => 'Enter your first and last name';

  @override
  String get signupSaveFailed =>
      'Couldn\'t save your profile, please try again';

  @override
  String get emptyPastHint => 'Completed matches will show up here';
}
