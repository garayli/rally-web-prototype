import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('tr')
  ];

  /// No description provided for @appName.
  ///
  /// In tr, this message translates to:
  /// **'RallyMatch'**
  String get appName;

  /// No description provided for @sportTennis.
  ///
  /// In tr, this message translates to:
  /// **'Tenis'**
  String get sportTennis;

  /// No description provided for @sportTennisSub.
  ///
  /// In tr, this message translates to:
  /// **'Tekler & çiftler'**
  String get sportTennisSub;

  /// No description provided for @sportPadel.
  ///
  /// In tr, this message translates to:
  /// **'Padel'**
  String get sportPadel;

  /// No description provided for @sportPadelSub.
  ///
  /// In tr, this message translates to:
  /// **'Raket sporu'**
  String get sportPadelSub;

  /// No description provided for @sportBadminton.
  ///
  /// In tr, this message translates to:
  /// **'Badminton'**
  String get sportBadminton;

  /// No description provided for @sportBadmintonSub.
  ///
  /// In tr, this message translates to:
  /// **'İç mekan & açık alan'**
  String get sportBadmintonSub;

  /// No description provided for @sportSquash.
  ///
  /// In tr, this message translates to:
  /// **'Squash'**
  String get sportSquash;

  /// No description provided for @sportSquashSub.
  ///
  /// In tr, this message translates to:
  /// **'Kort sporu'**
  String get sportSquashSub;

  /// No description provided for @skillBeginner.
  ///
  /// In tr, this message translates to:
  /// **'Başlangıç'**
  String get skillBeginner;

  /// No description provided for @skillBeginnerSub.
  ///
  /// In tr, this message translates to:
  /// **'1 yıldan az — temelleri öğreniyor'**
  String get skillBeginnerSub;

  /// No description provided for @skillIntermediate.
  ///
  /// In tr, this message translates to:
  /// **'Orta Seviye'**
  String get skillIntermediate;

  /// No description provided for @skillIntermediateSub.
  ///
  /// In tr, this message translates to:
  /// **'1–4 yıl — rahatça ralli yapıyor'**
  String get skillIntermediateSub;

  /// No description provided for @skillAdvanced.
  ///
  /// In tr, this message translates to:
  /// **'İleri Seviye'**
  String get skillAdvanced;

  /// No description provided for @skillAdvancedSub.
  ///
  /// In tr, this message translates to:
  /// **'Rekabetçi — güçlü genel oyun'**
  String get skillAdvancedSub;

  /// No description provided for @skillExpert.
  ///
  /// In tr, this message translates to:
  /// **'Uzman'**
  String get skillExpert;

  /// No description provided for @skillExpertSub.
  ///
  /// In tr, this message translates to:
  /// **'Turnuva seviyesi — en iyi oyun'**
  String get skillExpertSub;

  /// No description provided for @dayMon.
  ///
  /// In tr, this message translates to:
  /// **'Pzt'**
  String get dayMon;

  /// No description provided for @dayTue.
  ///
  /// In tr, this message translates to:
  /// **'Sal'**
  String get dayTue;

  /// No description provided for @dayWed.
  ///
  /// In tr, this message translates to:
  /// **'Çar'**
  String get dayWed;

  /// No description provided for @dayThu.
  ///
  /// In tr, this message translates to:
  /// **'Per'**
  String get dayThu;

  /// No description provided for @dayFri.
  ///
  /// In tr, this message translates to:
  /// **'Cum'**
  String get dayFri;

  /// No description provided for @daySat.
  ///
  /// In tr, this message translates to:
  /// **'Cmt'**
  String get daySat;

  /// No description provided for @daySun.
  ///
  /// In tr, this message translates to:
  /// **'Paz'**
  String get daySun;

  /// No description provided for @timeMorning.
  ///
  /// In tr, this message translates to:
  /// **'Sabah'**
  String get timeMorning;

  /// No description provided for @timeAfternoon.
  ///
  /// In tr, this message translates to:
  /// **'Öğleden Sonra'**
  String get timeAfternoon;

  /// No description provided for @timeEvening.
  ///
  /// In tr, this message translates to:
  /// **'Akşam'**
  String get timeEvening;

  /// No description provided for @courtThemeClay.
  ///
  /// In tr, this message translates to:
  /// **'Toprak'**
  String get courtThemeClay;

  /// No description provided for @courtThemeHard.
  ///
  /// In tr, this message translates to:
  /// **'Sert Kort'**
  String get courtThemeHard;

  /// No description provided for @courtThemeGrass.
  ///
  /// In tr, this message translates to:
  /// **'Çim'**
  String get courtThemeGrass;

  /// No description provided for @navFindOpponent.
  ///
  /// In tr, this message translates to:
  /// **'Rakip Bul'**
  String get navFindOpponent;

  /// No description provided for @navMessages.
  ///
  /// In tr, this message translates to:
  /// **'Mesajlar'**
  String get navMessages;

  /// No description provided for @navNotifications.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim'**
  String get navNotifications;

  /// No description provided for @navProfile.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get navProfile;

  /// No description provided for @createMatchFab.
  ///
  /// In tr, this message translates to:
  /// **'Maç Oluştur'**
  String get createMatchFab;

  /// No description provided for @matchBadgeLabel.
  ///
  /// In tr, this message translates to:
  /// **'EŞLEŞME'**
  String get matchBadgeLabel;

  /// No description provided for @requestShort.
  ///
  /// In tr, this message translates to:
  /// **'İste'**
  String get requestShort;

  /// No description provided for @profileCompleteTitle.
  ///
  /// In tr, this message translates to:
  /// **'Profilini tamamla'**
  String get profileCompleteTitle;

  /// No description provided for @profilePercentDone.
  ///
  /// In tr, this message translates to:
  /// **'%{percent} tamamlandı'**
  String profilePercentDone(int percent);

  /// No description provided for @profileMissing.
  ///
  /// In tr, this message translates to:
  /// **'Eksik: {items}'**
  String profileMissing(String items);

  /// No description provided for @missingBio.
  ///
  /// In tr, this message translates to:
  /// **'biyografi'**
  String get missingBio;

  /// No description provided for @missingAvailability.
  ///
  /// In tr, this message translates to:
  /// **'müsaitlik'**
  String get missingAvailability;

  /// No description provided for @missingSport.
  ///
  /// In tr, this message translates to:
  /// **'spor'**
  String get missingSport;

  /// No description provided for @missingLevel.
  ///
  /// In tr, this message translates to:
  /// **'seviye'**
  String get missingLevel;

  /// No description provided for @profileSetSchedule.
  ///
  /// In tr, this message translates to:
  /// **'Haftalık programını ayarla'**
  String get profileSetSchedule;

  /// No description provided for @profileTitle.
  ///
  /// In tr, this message translates to:
  /// **'Profilim'**
  String get profileTitle;

  /// No description provided for @courtThemeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kort Teması'**
  String get courtThemeTitle;

  /// No description provided for @courtThemeSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Uygulamanın renk temasını seç'**
  String get courtThemeSubtitle;

  /// No description provided for @courtThemeClaySub.
  ///
  /// In tr, this message translates to:
  /// **'Roland-Garros tarzı'**
  String get courtThemeClaySub;

  /// No description provided for @courtThemeHardSub.
  ///
  /// In tr, this message translates to:
  /// **'US Open tarzı'**
  String get courtThemeHardSub;

  /// No description provided for @courtThemeGrassSub.
  ///
  /// In tr, this message translates to:
  /// **'Wimbledon tarzı'**
  String get courtThemeGrassSub;

  /// No description provided for @photoUploadSoon.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraf yükleme yakında'**
  String get photoUploadSoon;

  /// No description provided for @profileNtrpLine.
  ///
  /// In tr, this message translates to:
  /// **'🎾  NTRP {rating} — {level}'**
  String profileNtrpLine(String rating, String level);

  /// No description provided for @profileNtrpUnknown.
  ///
  /// In tr, this message translates to:
  /// **'🎾  NTRP —'**
  String get profileNtrpUnknown;

  /// No description provided for @editProfile.
  ///
  /// In tr, this message translates to:
  /// **'Profili Düzenle'**
  String get editProfile;

  /// No description provided for @statWins.
  ///
  /// In tr, this message translates to:
  /// **'GALİBİYET'**
  String get statWins;

  /// No description provided for @statLosses.
  ///
  /// In tr, this message translates to:
  /// **'MAĞLUBIYET'**
  String get statLosses;

  /// No description provided for @statPlayed.
  ///
  /// In tr, this message translates to:
  /// **'OYNANDI'**
  String get statPlayed;

  /// No description provided for @statRating.
  ///
  /// In tr, this message translates to:
  /// **'PUAN'**
  String get statRating;

  /// No description provided for @uploadScore.
  ///
  /// In tr, this message translates to:
  /// **'Skorunu Yükle'**
  String get uploadScore;

  /// No description provided for @scoreRequests.
  ///
  /// In tr, this message translates to:
  /// **'Skor Talepleri'**
  String get scoreRequests;

  /// No description provided for @myMatchesHeader.
  ///
  /// In tr, this message translates to:
  /// **'MAÇLARIM'**
  String get myMatchesHeader;

  /// No description provided for @tabUpcomingCount.
  ///
  /// In tr, this message translates to:
  /// **'Yaklaşan ({count})'**
  String tabUpcomingCount(int count);

  /// No description provided for @tabPastCount.
  ///
  /// In tr, this message translates to:
  /// **'Geçmiş ({count})'**
  String tabPastCount(int count);

  /// No description provided for @tabPendingCount.
  ///
  /// In tr, this message translates to:
  /// **'Bekleyen ({count})'**
  String tabPendingCount(int count);

  /// No description provided for @emptyUpcoming.
  ///
  /// In tr, this message translates to:
  /// **'Yaklaşan maç yok'**
  String get emptyUpcoming;

  /// No description provided for @emptyPast.
  ///
  /// In tr, this message translates to:
  /// **'Geçmiş maç yok'**
  String get emptyPast;

  /// No description provided for @emptyPending.
  ///
  /// In tr, this message translates to:
  /// **'Bekleyen istek yok'**
  String get emptyPending;

  /// No description provided for @sectionMyGame.
  ///
  /// In tr, this message translates to:
  /// **'OYUNUM'**
  String get sectionMyGame;

  /// No description provided for @reputation.
  ///
  /// In tr, this message translates to:
  /// **'İtibar'**
  String get reputation;

  /// No description provided for @reputationSub.
  ///
  /// In tr, this message translates to:
  /// **'4.9 puan · 4 değerlendirme'**
  String get reputationSub;

  /// No description provided for @achievements.
  ///
  /// In tr, this message translates to:
  /// **'Başarılar'**
  String get achievements;

  /// No description provided for @achievementsSub.
  ///
  /// In tr, this message translates to:
  /// **'18 üzerinden 12 kazanıldı'**
  String get achievementsSub;

  /// No description provided for @myResults.
  ///
  /// In tr, this message translates to:
  /// **'Sonuçlarım'**
  String get myResults;

  /// No description provided for @myResultsSub.
  ///
  /// In tr, this message translates to:
  /// **'Maç geçmişi ve skorlar'**
  String get myResultsSub;

  /// No description provided for @logResult.
  ///
  /// In tr, this message translates to:
  /// **'Sonuç Kaydet'**
  String get logResult;

  /// No description provided for @logResultSub.
  ///
  /// In tr, this message translates to:
  /// **'Son maçını kaydet'**
  String get logResultSub;

  /// No description provided for @sectionAccount.
  ///
  /// In tr, this message translates to:
  /// **'HESAP'**
  String get sectionAccount;

  /// No description provided for @editProfileSub.
  ///
  /// In tr, this message translates to:
  /// **'Ad, konum, biyografi, seviye güncelle'**
  String get editProfileSub;

  /// No description provided for @gamePreferences.
  ///
  /// In tr, this message translates to:
  /// **'Oyun Tercihleri'**
  String get gamePreferences;

  /// No description provided for @gamePreferencesSub.
  ///
  /// In tr, this message translates to:
  /// **'Seviye, kort türü, format'**
  String get gamePreferencesSub;

  /// No description provided for @gamePreferencesSoon.
  ///
  /// In tr, this message translates to:
  /// **'Oyun tercihleri yakında'**
  String get gamePreferencesSoon;

  /// No description provided for @availability.
  ///
  /// In tr, this message translates to:
  /// **'Müsaitlik'**
  String get availability;

  /// No description provided for @sectionApp.
  ///
  /// In tr, this message translates to:
  /// **'UYGULAMA'**
  String get sectionApp;

  /// No description provided for @notifications.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get notifications;

  /// No description provided for @notificationsSub.
  ///
  /// In tr, this message translates to:
  /// **'Maç istekleri, hatırlatmalar'**
  String get notificationsSub;

  /// No description provided for @courtThemeOptions.
  ///
  /// In tr, this message translates to:
  /// **'Toprak / Sert Kort / Çim'**
  String get courtThemeOptions;

  /// No description provided for @privacySecurity.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik ve Güvenlik'**
  String get privacySecurity;

  /// No description provided for @privacySecuritySub.
  ///
  /// In tr, this message translates to:
  /// **'Profil görünürlüğü'**
  String get privacySecuritySub;

  /// No description provided for @privacySettingsSoon.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik ayarları yakında'**
  String get privacySettingsSoon;

  /// No description provided for @sectionAbout.
  ///
  /// In tr, this message translates to:
  /// **'HAKKINDA'**
  String get sectionAbout;

  /// No description provided for @termsPrivacy.
  ///
  /// In tr, this message translates to:
  /// **'Şartlar ve Gizlilik'**
  String get termsPrivacy;

  /// No description provided for @termsPrivacySoon.
  ///
  /// In tr, this message translates to:
  /// **'Şartlar ve Gizlilik yakında'**
  String get termsPrivacySoon;

  /// No description provided for @signOut.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış Yap'**
  String get signOut;

  /// No description provided for @profileLoadingRetry.
  ///
  /// In tr, this message translates to:
  /// **'Profil yükleniyor, lütfen tekrar deneyin'**
  String get profileLoadingRetry;

  /// No description provided for @profileUpdated.
  ///
  /// In tr, this message translates to:
  /// **'Profil güncellendi'**
  String get profileUpdated;

  /// No description provided for @vsOpponent.
  ///
  /// In tr, this message translates to:
  /// **'vs {name}'**
  String vsOpponent(String name);

  /// No description provided for @statusUpcomingUpper.
  ///
  /// In tr, this message translates to:
  /// **'YAKLAŞAN'**
  String get statusUpcomingUpper;

  /// No description provided for @statusCompletedUpper.
  ///
  /// In tr, this message translates to:
  /// **'TAMAMLANDI'**
  String get statusCompletedUpper;

  /// No description provided for @statusPendingUpper.
  ///
  /// In tr, this message translates to:
  /// **'BEKLİYOR'**
  String get statusPendingUpper;

  /// No description provided for @statusCancelledUpper.
  ///
  /// In tr, this message translates to:
  /// **'İPTAL'**
  String get statusCancelledUpper;

  /// No description provided for @statusConfirmed.
  ///
  /// In tr, this message translates to:
  /// **'Onaylandı'**
  String get statusConfirmed;

  /// No description provided for @statusCompleted.
  ///
  /// In tr, this message translates to:
  /// **'Tamamlandı'**
  String get statusCompleted;

  /// No description provided for @statusPending.
  ///
  /// In tr, this message translates to:
  /// **'Beklemede'**
  String get statusPending;

  /// No description provided for @statusCancelled.
  ///
  /// In tr, this message translates to:
  /// **'İptal Edildi'**
  String get statusCancelled;

  /// No description provided for @formatDoubles.
  ///
  /// In tr, this message translates to:
  /// **'Çiftler'**
  String get formatDoubles;

  /// No description provided for @formatSingles.
  ///
  /// In tr, this message translates to:
  /// **'Tekler'**
  String get formatSingles;

  /// No description provided for @requestMatch.
  ///
  /// In tr, this message translates to:
  /// **'Maç İste'**
  String get requestMatch;

  /// No description provided for @sort.
  ///
  /// In tr, this message translates to:
  /// **'Sıralama'**
  String get sort;

  /// No description provided for @filter.
  ///
  /// In tr, this message translates to:
  /// **'Filtre'**
  String get filter;

  /// No description provided for @upcomingMatchesHeader.
  ///
  /// In tr, this message translates to:
  /// **'YAKLAŞAN MAÇLAR'**
  String get upcomingMatchesHeader;

  /// No description provided for @seeAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümünü gör'**
  String get seeAll;

  /// No description provided for @nearbyPlayersHeader.
  ///
  /// In tr, this message translates to:
  /// **'{count} YAKINDA OYUNCU'**
  String nearbyPlayersHeader(int count);

  /// No description provided for @map.
  ///
  /// In tr, this message translates to:
  /// **'Harita'**
  String get map;

  /// No description provided for @openLobbiesHeader.
  ///
  /// In tr, this message translates to:
  /// **'AÇIK LOBİLER'**
  String get openLobbiesHeader;

  /// No description provided for @createLobby.
  ///
  /// In tr, this message translates to:
  /// **'Lobi Oluştur'**
  String get createLobby;

  /// No description provided for @nearbyPlayersEyebrow.
  ///
  /// In tr, this message translates to:
  /// **'YAKINDAKI OYUNCULAR'**
  String get nearbyPlayersEyebrow;

  /// No description provided for @playersWaiting.
  ///
  /// In tr, this message translates to:
  /// **'{count, plural, other{{count} oyuncu sizi bekliyor}}'**
  String playersWaiting(int count);

  /// No description provided for @searchNameOrLocation.
  ///
  /// In tr, this message translates to:
  /// **'İsim veya konum ara…'**
  String get searchNameOrLocation;

  /// No description provided for @winRatePercent.
  ///
  /// In tr, this message translates to:
  /// **'{percent}% galibiyet'**
  String winRatePercent(int percent);

  /// No description provided for @matchesCount.
  ///
  /// In tr, this message translates to:
  /// **'{count, plural, other{{count} maç}}'**
  String matchesCount(int count);

  /// No description provided for @skillShortBeginner.
  ///
  /// In tr, this message translates to:
  /// **'Başl.'**
  String get skillShortBeginner;

  /// No description provided for @skillShortIntermediate.
  ///
  /// In tr, this message translates to:
  /// **'Orta'**
  String get skillShortIntermediate;

  /// No description provided for @skillShortAdvanced.
  ///
  /// In tr, this message translates to:
  /// **'İleri'**
  String get skillShortAdvanced;

  /// No description provided for @skillShortExpert.
  ///
  /// In tr, this message translates to:
  /// **'Uzm.'**
  String get skillShortExpert;

  /// No description provided for @tennisBadge.
  ///
  /// In tr, this message translates to:
  /// **'🎾 TENİS'**
  String get tennisBadge;

  /// No description provided for @sortDistance.
  ///
  /// In tr, this message translates to:
  /// **'Mesafe'**
  String get sortDistance;

  /// No description provided for @sortWins.
  ///
  /// In tr, this message translates to:
  /// **'Galibiyet'**
  String get sortWins;

  /// No description provided for @sortSheetSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Oyuncuları sıralama kriteri'**
  String get sortSheetSubtitle;

  /// No description provided for @apply.
  ///
  /// In tr, this message translates to:
  /// **'Uygula'**
  String get apply;

  /// No description provided for @filterTitle.
  ///
  /// In tr, this message translates to:
  /// **'Filtrele'**
  String get filterTitle;

  /// No description provided for @clear.
  ///
  /// In tr, this message translates to:
  /// **'Temizle'**
  String get clear;

  /// No description provided for @level.
  ///
  /// In tr, this message translates to:
  /// **'Seviye'**
  String get level;

  /// No description provided for @distance.
  ///
  /// In tr, this message translates to:
  /// **'Mesafe'**
  String get distance;

  /// No description provided for @all.
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get all;

  /// No description provided for @join.
  ///
  /// In tr, this message translates to:
  /// **'Katıl'**
  String get join;

  /// No description provided for @lobbyJoinSent.
  ///
  /// In tr, this message translates to:
  /// **'{sport} lobisine katılma isteği gönderildi!'**
  String lobbyJoinSent(String sport);

  /// No description provided for @authErrorRateLimit.
  ///
  /// In tr, this message translates to:
  /// **'Çok fazla kod isteği gönderildi. Lütfen birkaç dakika bekleyip tekrar deneyin.'**
  String get authErrorRateLimit;

  /// No description provided for @authErrorGeneric.
  ///
  /// In tr, this message translates to:
  /// **'Bir şeyler yanlış gitti. Lütfen tekrar deneyin.'**
  String get authErrorGeneric;

  /// No description provided for @authErrorInvalidEmail.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen geçerli bir e-posta adresi girin.'**
  String get authErrorInvalidEmail;

  /// No description provided for @authErrorCodeInvalidOrExpired.
  ///
  /// In tr, this message translates to:
  /// **'Kod geçersiz veya süresi dolmuş. Lütfen yeni kod isteyin.'**
  String get authErrorCodeInvalidOrExpired;

  /// No description provided for @authErrorInvalidCode.
  ///
  /// In tr, this message translates to:
  /// **'Geçersiz kod. Lütfen tekrar deneyin.'**
  String get authErrorInvalidCode;

  /// No description provided for @authErrorResendFailed.
  ///
  /// In tr, this message translates to:
  /// **'Kod gönderilemedi. Lütfen tekrar deneyin.'**
  String get authErrorResendFailed;

  /// No description provided for @authCreateAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesap oluştur'**
  String get authCreateAccount;

  /// No description provided for @authWelcomeBack.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar hoş geldiniz'**
  String get authWelcomeBack;

  /// No description provided for @authEmailPromptSignUp.
  ///
  /// In tr, this message translates to:
  /// **'E-posta adresinizi girin, size tek kullanımlık kod göndereceğiz'**
  String get authEmailPromptSignUp;

  /// No description provided for @authEmailPromptSignIn.
  ///
  /// In tr, this message translates to:
  /// **'E-posta adresinize giriş kodu göndereceğiz'**
  String get authEmailPromptSignIn;

  /// No description provided for @authEmailLabel.
  ///
  /// In tr, this message translates to:
  /// **'E-POSTA ADRESİ'**
  String get authEmailLabel;

  /// No description provided for @authEmailHint.
  ///
  /// In tr, this message translates to:
  /// **'siz@ornek.com'**
  String get authEmailHint;

  /// No description provided for @authSendCode.
  ///
  /// In tr, this message translates to:
  /// **'Kodu gönder'**
  String get authSendCode;

  /// No description provided for @authHaveAccount.
  ///
  /// In tr, this message translates to:
  /// **'Zaten hesabın var mı? '**
  String get authHaveAccount;

  /// No description provided for @authNoAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesabın yok mu? '**
  String get authNoAccount;

  /// No description provided for @authSignIn.
  ///
  /// In tr, this message translates to:
  /// **'Giriş yap'**
  String get authSignIn;

  /// No description provided for @authSignUp.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt ol'**
  String get authSignUp;

  /// No description provided for @authCheckEmail.
  ///
  /// In tr, this message translates to:
  /// **'E-postanı kontrol et'**
  String get authCheckEmail;

  /// No description provided for @authCodeSentTo.
  ///
  /// In tr, this message translates to:
  /// **'E-posta adresinize 8 haneli kod gönderdik:\n'**
  String get authCodeSentTo;

  /// No description provided for @authVerify.
  ///
  /// In tr, this message translates to:
  /// **'Doğrula'**
  String get authVerify;

  /// No description provided for @authResendCode.
  ///
  /// In tr, this message translates to:
  /// **'Kodu tekrar gönder'**
  String get authResendCode;

  /// No description provided for @authResendIn.
  ///
  /// In tr, this message translates to:
  /// **'{seconds} saniye sonra tekrar gönder'**
  String authResendIn(int seconds);

  /// No description provided for @landingSignInButton.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get landingSignInButton;

  /// No description provided for @landingHeadline.
  ///
  /// In tr, this message translates to:
  /// **'Mükemmel\nrakibini bul.'**
  String get landingHeadline;

  /// No description provided for @landingSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Seviyenizde tenis oyuncuları bulun, kort rezervasyonu yapın ve gelişiminizi takip edin.'**
  String get landingSubtitle;

  /// No description provided for @landingStatPlayers.
  ///
  /// In tr, this message translates to:
  /// **'Oyuncu'**
  String get landingStatPlayers;

  /// No description provided for @landingStatMatchRate.
  ///
  /// In tr, this message translates to:
  /// **'Uyum oranı'**
  String get landingStatMatchRate;

  /// No description provided for @landingStatRating.
  ///
  /// In tr, this message translates to:
  /// **'Puan'**
  String get landingStatRating;

  /// No description provided for @landingGetStarted.
  ///
  /// In tr, this message translates to:
  /// **'Başla — tamamen ücretsiz'**
  String get landingGetStarted;

  /// No description provided for @landingHaveAccount.
  ///
  /// In tr, this message translates to:
  /// **'Zaten hesabım var'**
  String get landingHaveAccount;

  /// No description provided for @landingTerms.
  ///
  /// In tr, this message translates to:
  /// **'Devam ederek Şartlarımızı ve Gizlilik Politikamızı kabul etmiş olursunuz'**
  String get landingTerms;

  /// No description provided for @signupFinish.
  ///
  /// In tr, this message translates to:
  /// **'Bitir — Oynayalım 🎾'**
  String get signupFinish;

  /// No description provided for @signupContinue.
  ///
  /// In tr, this message translates to:
  /// **'Devam'**
  String get signupContinue;

  /// No description provided for @signupStep1Title.
  ///
  /// In tr, this message translates to:
  /// **'Kendinizden bahsedin'**
  String get signupStep1Title;

  /// No description provided for @signupStep1Subtitle.
  ///
  /// In tr, this message translates to:
  /// **'Oyuncuların sizi bulmasına yardımcı olun'**
  String get signupStep1Subtitle;

  /// No description provided for @signupNameLabel.
  ///
  /// In tr, this message translates to:
  /// **'AD SOYAD'**
  String get signupNameLabel;

  /// No description provided for @signupNameHint.
  ///
  /// In tr, this message translates to:
  /// **'örn. Leyla Garayli'**
  String get signupNameHint;

  /// No description provided for @signupLocationLabel.
  ///
  /// In tr, this message translates to:
  /// **'MAHALLE / ŞEHİR'**
  String get signupLocationLabel;

  /// No description provided for @signupLocationHint.
  ///
  /// In tr, this message translates to:
  /// **'örn. Beşiktaş, İstanbul'**
  String get signupLocationHint;

  /// No description provided for @signupStep2Title.
  ///
  /// In tr, this message translates to:
  /// **'Hangi sporları oynuyorsunuz?'**
  String get signupStep2Title;

  /// No description provided for @signupStep2Subtitle.
  ///
  /// In tr, this message translates to:
  /// **'Uygun olanları seçin'**
  String get signupStep2Subtitle;

  /// No description provided for @signupStep3Title.
  ///
  /// In tr, this message translates to:
  /// **'Seviyeniz nedir?'**
  String get signupStep3Title;

  /// No description provided for @signupStep3Subtitle.
  ///
  /// In tr, this message translates to:
  /// **'Dürüst olun — bu en iyi maçları bulmaya yardımcı olur'**
  String get signupStep3Subtitle;

  /// No description provided for @signupStep4Title.
  ///
  /// In tr, this message translates to:
  /// **'Genellikle ne zaman müsaitsiniz?'**
  String get signupStep4Title;

  /// No description provided for @signupStep4Subtitle.
  ///
  /// In tr, this message translates to:
  /// **'Tipik müsaitliğinizi seçin'**
  String get signupStep4Subtitle;

  /// No description provided for @signupDaysHeader.
  ///
  /// In tr, this message translates to:
  /// **'GÜNLER'**
  String get signupDaysHeader;

  /// No description provided for @signupTimeOfDayHeader.
  ///
  /// In tr, this message translates to:
  /// **'GÜNÜN SAATİ'**
  String get signupTimeOfDayHeader;

  /// No description provided for @profileSaveFailed.
  ///
  /// In tr, this message translates to:
  /// **'Profil kaydedilemedi. Lütfen tekrar deneyin.'**
  String get profileSaveFailed;

  /// No description provided for @editAboutLabel.
  ///
  /// In tr, this message translates to:
  /// **'HAKKIMDA'**
  String get editAboutLabel;

  /// No description provided for @editAboutHint.
  ///
  /// In tr, this message translates to:
  /// **'Oyun tarzın, sevdiğin kortlar…'**
  String get editAboutHint;

  /// No description provided for @editSportsLabel.
  ///
  /// In tr, this message translates to:
  /// **'SPORLAR'**
  String get editSportsLabel;

  /// No description provided for @editLevelLabel.
  ///
  /// In tr, this message translates to:
  /// **'SEVİYE'**
  String get editLevelLabel;

  /// No description provided for @editDaysLabel.
  ///
  /// In tr, this message translates to:
  /// **'MÜSAİT GÜNLER'**
  String get editDaysLabel;

  /// No description provided for @save.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get save;

  /// No description provided for @createGameQuestion.
  ///
  /// In tr, this message translates to:
  /// **'Ne yapmak istersin?'**
  String get createGameQuestion;

  /// No description provided for @createGameSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Bir seçenek seç ve hemen başla.'**
  String get createGameSubtitle;

  /// No description provided for @createGameStartMatch.
  ///
  /// In tr, this message translates to:
  /// **'Maç Başlat'**
  String get createGameStartMatch;

  /// No description provided for @createGameStartMatchSub.
  ///
  /// In tr, this message translates to:
  /// **'Belirli bir rakiple randevu oluştur.'**
  String get createGameStartMatchSub;

  /// No description provided for @createGamePublishOpen.
  ///
  /// In tr, this message translates to:
  /// **'Açık Maç Yayınla'**
  String get createGamePublishOpen;

  /// No description provided for @createGamePublishOpenSub.
  ///
  /// In tr, this message translates to:
  /// **'Herkese açık bir slot oluştur, rakibini bekle.'**
  String get createGamePublishOpenSub;

  /// No description provided for @errorNotSignedIn.
  ///
  /// In tr, this message translates to:
  /// **'Oturum açmanız gerekiyor'**
  String get errorNotSignedIn;

  /// No description provided for @errorRecipientNotRegistered.
  ///
  /// In tr, this message translates to:
  /// **'Bu oyuncu kayıtlı değil, mesaj gönderilemez'**
  String get errorRecipientNotRegistered;

  /// No description provided for @errorMatchUpdateDenied.
  ///
  /// In tr, this message translates to:
  /// **'Maç durumu güncellenemedi (yetki yok)'**
  String get errorMatchUpdateDenied;

  /// No description provided for @errorUnknown.
  ///
  /// In tr, this message translates to:
  /// **'Bir şeyler yanlış gitti. Lütfen tekrar deneyin.'**
  String get errorUnknown;

  /// No description provided for @matchRequestTitle.
  ///
  /// In tr, this message translates to:
  /// **'Maç İsteği'**
  String get matchRequestTitle;

  /// No description provided for @format.
  ///
  /// In tr, this message translates to:
  /// **'Format'**
  String get format;

  /// No description provided for @dateAndTime.
  ///
  /// In tr, this message translates to:
  /// **'Tarih & Saat'**
  String get dateAndTime;

  /// No description provided for @court.
  ///
  /// In tr, this message translates to:
  /// **'Kort'**
  String get court;

  /// No description provided for @pastTimeNotAllowed.
  ///
  /// In tr, this message translates to:
  /// **'Geçmiş bir saat seçilemez'**
  String get pastTimeNotAllowed;

  /// No description provided for @matchRequestSentTo.
  ///
  /// In tr, this message translates to:
  /// **'{name} oyuncusuna maç isteği gönderildi!'**
  String matchRequestSentTo(String name);

  /// No description provided for @requestFailed.
  ///
  /// In tr, this message translates to:
  /// **'İstek gönderilemedi: {reason}'**
  String requestFailed(String reason);

  /// No description provided for @requestSent.
  ///
  /// In tr, this message translates to:
  /// **'İstek Gönderildi ✓'**
  String get requestSent;

  /// No description provided for @sendRequest.
  ///
  /// In tr, this message translates to:
  /// **'İstek Gönder 🎾'**
  String get sendRequest;

  /// No description provided for @badgeFirstMatch.
  ///
  /// In tr, this message translates to:
  /// **'İlk Maç'**
  String get badgeFirstMatch;

  /// No description provided for @badgeFirstMatchDesc.
  ///
  /// In tr, this message translates to:
  /// **'İlk oyununu oynadın'**
  String get badgeFirstMatchDesc;

  /// No description provided for @badgeWinStreak.
  ///
  /// In tr, this message translates to:
  /// **'Seri Galibiyet'**
  String get badgeWinStreak;

  /// No description provided for @badgeWinStreakDesc.
  ///
  /// In tr, this message translates to:
  /// **'Arka arkaya 3 galibiyet'**
  String get badgeWinStreakDesc;

  /// No description provided for @badgeFiveStar.
  ///
  /// In tr, this message translates to:
  /// **'5 Yıldızlı Oyuncu'**
  String get badgeFiveStar;

  /// No description provided for @badgeFiveStarDesc.
  ///
  /// In tr, this message translates to:
  /// **'Ortalama puan 4.8+'**
  String get badgeFiveStarDesc;

  /// No description provided for @badgeSocialButterfly.
  ///
  /// In tr, this message translates to:
  /// **'Sosyal Kelebek'**
  String get badgeSocialButterfly;

  /// No description provided for @badgeSocialButterflyDesc.
  ///
  /// In tr, this message translates to:
  /// **'10 oyuncuyla bağlantı kuruldu'**
  String get badgeSocialButterflyDesc;

  /// No description provided for @badgeRegularPlayer.
  ///
  /// In tr, this message translates to:
  /// **'Düzenli Oyuncu'**
  String get badgeRegularPlayer;

  /// No description provided for @badgeRegularPlayerDesc.
  ///
  /// In tr, this message translates to:
  /// **'10+ maç oynandı'**
  String get badgeRegularPlayerDesc;

  /// No description provided for @badgeChampion.
  ///
  /// In tr, this message translates to:
  /// **'Şampiyon'**
  String get badgeChampion;

  /// No description provided for @badgeChampionDesc.
  ///
  /// In tr, this message translates to:
  /// **'25+ galibiyet'**
  String get badgeChampionDesc;

  /// No description provided for @badgeQuickReply.
  ///
  /// In tr, this message translates to:
  /// **'Hızlı Yanıt'**
  String get badgeQuickReply;

  /// No description provided for @badgeQuickReplyDesc.
  ///
  /// In tr, this message translates to:
  /// **'1 saat içinde cevap verdi'**
  String get badgeQuickReplyDesc;

  /// No description provided for @badgeExplorer.
  ///
  /// In tr, this message translates to:
  /// **'Kaşif'**
  String get badgeExplorer;

  /// No description provided for @badgeExplorerDesc.
  ///
  /// In tr, this message translates to:
  /// **'5 farklı kortta oynandı'**
  String get badgeExplorerDesc;

  /// No description provided for @badgeCommunicator.
  ///
  /// In tr, this message translates to:
  /// **'İletişimci'**
  String get badgeCommunicator;

  /// No description provided for @badgeCommunicatorDesc.
  ///
  /// In tr, this message translates to:
  /// **'50 mesaj gönderildi'**
  String get badgeCommunicatorDesc;

  /// No description provided for @badgeSharpshooter.
  ///
  /// In tr, this message translates to:
  /// **'Keskin Nişancı'**
  String get badgeSharpshooter;

  /// No description provided for @badgeSharpshooterDesc.
  ///
  /// In tr, this message translates to:
  /// **'80%+ kazanma oranı'**
  String get badgeSharpshooterDesc;

  /// No description provided for @badgeSharer.
  ///
  /// In tr, this message translates to:
  /// **'Paylaş'**
  String get badgeSharer;

  /// No description provided for @badgeSharerDesc.
  ///
  /// In tr, this message translates to:
  /// **'5 maç sonucu paylaşıldı'**
  String get badgeSharerDesc;

  /// No description provided for @badgeElite.
  ///
  /// In tr, this message translates to:
  /// **'Elit'**
  String get badgeElite;

  /// No description provided for @badgeEliteDesc.
  ///
  /// In tr, this message translates to:
  /// **'İleri Seviyeye ulaşıldı'**
  String get badgeEliteDesc;

  /// No description provided for @badgeTournamentPro.
  ///
  /// In tr, this message translates to:
  /// **'Turnuva Profesyoneli'**
  String get badgeTournamentPro;

  /// No description provided for @badgeTournamentProDesc.
  ///
  /// In tr, this message translates to:
  /// **'Bir turnuvaya katıl'**
  String get badgeTournamentProDesc;

  /// No description provided for @badgeLegend.
  ///
  /// In tr, this message translates to:
  /// **'Efsane'**
  String get badgeLegend;

  /// No description provided for @badgeLegendDesc.
  ///
  /// In tr, this message translates to:
  /// **'100 maç oynandı'**
  String get badgeLegendDesc;

  /// No description provided for @badgeGrandSlam.
  ///
  /// In tr, this message translates to:
  /// **'Grand Slam'**
  String get badgeGrandSlam;

  /// No description provided for @badgeGrandSlamDesc.
  ///
  /// In tr, this message translates to:
  /// **'4 farklı kortta galibiyet'**
  String get badgeGrandSlamDesc;

  /// No description provided for @badgeDoublesKing.
  ///
  /// In tr, this message translates to:
  /// **'Çiftler Kralı'**
  String get badgeDoublesKing;

  /// No description provided for @badgeDoublesKingDesc.
  ///
  /// In tr, this message translates to:
  /// **'10 çiftler maçı kazanıldı'**
  String get badgeDoublesKingDesc;

  /// No description provided for @badgeAllRounder.
  ///
  /// In tr, this message translates to:
  /// **'Çok Yönlü'**
  String get badgeAllRounder;

  /// No description provided for @badgeAllRounderDesc.
  ///
  /// In tr, this message translates to:
  /// **'4 sporun tümü oynanıldı'**
  String get badgeAllRounderDesc;

  /// No description provided for @badgeRocket.
  ///
  /// In tr, this message translates to:
  /// **'Roket'**
  String get badgeRocket;

  /// No description provided for @badgeRocketDesc.
  ///
  /// In tr, this message translates to:
  /// **'Puan 200+ arttırıldı'**
  String get badgeRocketDesc;

  /// No description provided for @achievementsEarnedOf.
  ///
  /// In tr, this message translates to:
  /// **'{earned} / {total}'**
  String achievementsEarnedOf(int earned, int total);

  /// No description provided for @achievementsEarnedLabel.
  ///
  /// In tr, this message translates to:
  /// **'Başarı kazanıldı'**
  String get achievementsEarnedLabel;

  /// No description provided for @achievementsEarnedHeader.
  ///
  /// In tr, this message translates to:
  /// **'KAZANILDI'**
  String get achievementsEarnedHeader;

  /// No description provided for @achievementsLockedHeader.
  ///
  /// In tr, this message translates to:
  /// **'KİLİTLİ'**
  String get achievementsLockedHeader;

  /// No description provided for @prefMatchRequests.
  ///
  /// In tr, this message translates to:
  /// **'Maç İstekleri'**
  String get prefMatchRequests;

  /// No description provided for @prefMatchRequestsSub.
  ///
  /// In tr, this message translates to:
  /// **'Biriyle oynamak istediğinde'**
  String get prefMatchRequestsSub;

  /// No description provided for @prefMatchConfirmations.
  ///
  /// In tr, this message translates to:
  /// **'Maç Onayları'**
  String get prefMatchConfirmations;

  /// No description provided for @prefMatchConfirmationsSub.
  ///
  /// In tr, this message translates to:
  /// **'İstek kabul edildiğinde'**
  String get prefMatchConfirmationsSub;

  /// No description provided for @prefMatchReminders.
  ///
  /// In tr, this message translates to:
  /// **'Maç Hatırlatmaları'**
  String get prefMatchReminders;

  /// No description provided for @prefMatchRemindersSub.
  ///
  /// In tr, this message translates to:
  /// **'Planlanmış maçtan önce hatırlatma'**
  String get prefMatchRemindersSub;

  /// No description provided for @prefMatchCancellations.
  ///
  /// In tr, this message translates to:
  /// **'İptal Bildirimleri'**
  String get prefMatchCancellations;

  /// No description provided for @prefMatchCancellationsSub.
  ///
  /// In tr, this message translates to:
  /// **'Maç iptal edildiğinde'**
  String get prefMatchCancellationsSub;

  /// No description provided for @prefMessages.
  ///
  /// In tr, this message translates to:
  /// **'Mesajlar'**
  String get prefMessages;

  /// No description provided for @prefMessagesSub.
  ///
  /// In tr, this message translates to:
  /// **'Diğer oyunculardan yeni mesajlar'**
  String get prefMessagesSub;

  /// No description provided for @prefNewReviews.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Değerlendirmeler'**
  String get prefNewReviews;

  /// No description provided for @prefNewReviewsSub.
  ///
  /// In tr, this message translates to:
  /// **'Biri sizi değerlendirdiğinde'**
  String get prefNewReviewsSub;

  /// No description provided for @prefResultConfirmed.
  ///
  /// In tr, this message translates to:
  /// **'Sonuç Onaylandı'**
  String get prefResultConfirmed;

  /// No description provided for @prefResultConfirmedSub.
  ///
  /// In tr, this message translates to:
  /// **'Rakibiniz maç sonucunu onayladığında'**
  String get prefResultConfirmedSub;

  /// No description provided for @prefNearbyPlayers.
  ///
  /// In tr, this message translates to:
  /// **'Yakındaki Oyuncular'**
  String get prefNearbyPlayers;

  /// No description provided for @prefNearbyPlayersSub.
  ///
  /// In tr, this message translates to:
  /// **'Bölgenize yeni oyuncular katıldığında'**
  String get prefNearbyPlayersSub;

  /// No description provided for @prefMarketing.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama Güncellemeleri & İpuçları'**
  String get prefMarketing;

  /// No description provided for @prefMarketingSub.
  ///
  /// In tr, this message translates to:
  /// **'Yeni özellikler ve oyun ipuçları'**
  String get prefMarketingSub;

  /// No description provided for @prefSaved.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedildi ✓'**
  String get prefSaved;

  /// No description provided for @prefSectionMatches.
  ///
  /// In tr, this message translates to:
  /// **'MAÇLAR'**
  String get prefSectionMatches;

  /// No description provided for @prefSectionSocial.
  ///
  /// In tr, this message translates to:
  /// **'SOSYAL'**
  String get prefSectionSocial;

  /// No description provided for @prefSectionUpdates.
  ///
  /// In tr, this message translates to:
  /// **'GÜNCELLEMELER'**
  String get prefSectionUpdates;

  /// No description provided for @skillAnyLevel.
  ///
  /// In tr, this message translates to:
  /// **'Her seviye'**
  String get skillAnyLevel;

  /// No description provided for @lobbyCreated.
  ///
  /// In tr, this message translates to:
  /// **'Açık lobi oluşturuldu! Oyuncular artık katılabilir.'**
  String get lobbyCreated;

  /// No description provided for @lobbyCreateFailed.
  ///
  /// In tr, this message translates to:
  /// **'Lobi oluşturulamadı: {reason}'**
  String lobbyCreateFailed(String reason);

  /// No description provided for @openLobbyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Açık Lobi'**
  String get openLobbyTitle;

  /// No description provided for @openLobbyHeadline.
  ///
  /// In tr, this message translates to:
  /// **'Açık slot oluştur'**
  String get openLobbyHeadline;

  /// No description provided for @openLobbySubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Diğer oyuncular oturumuna katılmak için istekte bulunabilir'**
  String get openLobbySubtitle;

  /// No description provided for @openLobbySport.
  ///
  /// In tr, this message translates to:
  /// **'SPOR'**
  String get openLobbySport;

  /// No description provided for @openLobbyInvitedLevel.
  ///
  /// In tr, this message translates to:
  /// **'DAVET EDİLEN SEVİYE'**
  String get openLobbyInvitedLevel;

  /// No description provided for @openLobbyDateTime.
  ///
  /// In tr, this message translates to:
  /// **'TARİH & SAAT'**
  String get openLobbyDateTime;

  /// No description provided for @pickDate.
  ///
  /// In tr, this message translates to:
  /// **'Tarih seç'**
  String get pickDate;

  /// No description provided for @pickTime.
  ///
  /// In tr, this message translates to:
  /// **'Saat seç'**
  String get pickTime;

  /// No description provided for @openLobbyCourt.
  ///
  /// In tr, this message translates to:
  /// **'KORT'**
  String get openLobbyCourt;

  /// No description provided for @openLobbyNotes.
  ///
  /// In tr, this message translates to:
  /// **'NOTLAR (OPSİYONEL)'**
  String get openLobbyNotes;

  /// No description provided for @openLobbyNotesHint.
  ///
  /// In tr, this message translates to:
  /// **'ör. \"Kendi topunuzu getirin, rahat bir maç, başlangıç seviyesi hoş geldiniz\"'**
  String get openLobbyNotesHint;

  /// No description provided for @openLobbyPublic.
  ///
  /// In tr, this message translates to:
  /// **'Herkese açık lobi'**
  String get openLobbyPublic;

  /// No description provided for @openLobbyPublicSub.
  ///
  /// In tr, this message translates to:
  /// **'Herkes katılmak için istekte bulunabilir'**
  String get openLobbyPublicSub;

  /// No description provided for @openLobbyCreateButton.
  ///
  /// In tr, this message translates to:
  /// **'Lobi Oluştur 🎾'**
  String get openLobbyCreateButton;

  /// No description provided for @onboardingGotIt.
  ///
  /// In tr, this message translates to:
  /// **'Anladım!'**
  String get onboardingGotIt;

  /// No description provided for @onboardingFind1.
  ///
  /// In tr, this message translates to:
  /// **'Seviyene uygun oyuncuları bul ve maç isteği gönder.'**
  String get onboardingFind1;

  /// No description provided for @onboardingFind2.
  ///
  /// In tr, this message translates to:
  /// **'NTRP, galibiyet oranı ve müsaitliğe göre sırala.'**
  String get onboardingFind2;

  /// No description provided for @onboardingFind3.
  ///
  /// In tr, this message translates to:
  /// **'Filtrele, keşfet, sahaya çık.'**
  String get onboardingFind3;

  /// No description provided for @onboardingMessages1.
  ///
  /// In tr, this message translates to:
  /// **'Maç öncesi ve sonrası rakibinle doğrudan mesajlaş.'**
  String get onboardingMessages1;

  /// No description provided for @onboardingMessages2.
  ///
  /// In tr, this message translates to:
  /// **'Tüm konuşmalarını tek ekranda takip et.'**
  String get onboardingMessages2;

  /// No description provided for @onboardingMessages3.
  ///
  /// In tr, this message translates to:
  /// **'Kort detaylarını ve saati kolayca paylaş.'**
  String get onboardingMessages3;

  /// No description provided for @onboardingNotifications1.
  ///
  /// In tr, this message translates to:
  /// **'Gelen maç isteklerini kabul et veya reddet.'**
  String get onboardingNotifications1;

  /// No description provided for @onboardingNotifications2.
  ///
  /// In tr, this message translates to:
  /// **'Skor güncellemelerini ve hatırlatıcıları buradan gör.'**
  String get onboardingNotifications2;

  /// No description provided for @onboardingNotifications3.
  ///
  /// In tr, this message translates to:
  /// **'Tüm önemli gelişmelerden anında haberdar ol.'**
  String get onboardingNotifications3;

  /// No description provided for @onboardingProfile1.
  ///
  /// In tr, this message translates to:
  /// **'NTRP seviyeni, istatistiklerini ve başarılarını görüntüle.'**
  String get onboardingProfile1;

  /// No description provided for @onboardingProfile2.
  ///
  /// In tr, this message translates to:
  /// **'Maç geçmişini ve takvimini buradan takip et.'**
  String get onboardingProfile2;

  /// No description provided for @onboardingProfile3.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim tercihlerini ve hesap ayarlarını düzenle.'**
  String get onboardingProfile3;

  /// No description provided for @reviewCommentEmre.
  ///
  /// In tr, this message translates to:
  /// **'Harika ralliler, çok sportif — rövanş için sabırsızlanıyorum!'**
  String get reviewCommentEmre;

  /// No description provided for @reviewCommentSelin.
  ///
  /// In tr, this message translates to:
  /// **'Mükemmel oyuncu, her zaman zamanında ve çok adil. Kesinlikle tavsiye ederim.'**
  String get reviewCommentSelin;

  /// No description provided for @reviewCommentZeynep.
  ///
  /// In tr, this message translates to:
  /// **'Güzel maç, çekişmeli oyun. Çok rekabetçi ama her zaman dostane.'**
  String get reviewCommentZeynep;

  /// No description provided for @reviewCommentBerk.
  ///
  /// In tr, this message translates to:
  /// **'Maçtan gerçekten zevk aldım. Harika tavsiyeler de verdi!'**
  String get reviewCommentBerk;

  /// No description provided for @reviewTagPunctual.
  ///
  /// In tr, this message translates to:
  /// **'Dakik'**
  String get reviewTagPunctual;

  /// No description provided for @reviewTagSporty.
  ///
  /// In tr, this message translates to:
  /// **'Sportif'**
  String get reviewTagSporty;

  /// No description provided for @reviewTagGoodComm.
  ///
  /// In tr, this message translates to:
  /// **'İyi iletişim'**
  String get reviewTagGoodComm;

  /// No description provided for @reviewTagFairPlay.
  ///
  /// In tr, this message translates to:
  /// **'Adil oyun'**
  String get reviewTagFairPlay;

  /// No description provided for @reviewTagCompetitive.
  ///
  /// In tr, this message translates to:
  /// **'Rekabetçi'**
  String get reviewTagCompetitive;

  /// No description provided for @reviewTagFriendly.
  ///
  /// In tr, this message translates to:
  /// **'Dostane'**
  String get reviewTagFriendly;

  /// No description provided for @reviewTagHelpful.
  ///
  /// In tr, this message translates to:
  /// **'Yardımsever'**
  String get reviewTagHelpful;

  /// No description provided for @reputationMine.
  ///
  /// In tr, this message translates to:
  /// **'İtibarım'**
  String get reputationMine;

  /// No description provided for @reputationOf.
  ///
  /// In tr, this message translates to:
  /// **'{name} İtibarı'**
  String reputationOf(String name);

  /// No description provided for @reviewsCount.
  ///
  /// In tr, this message translates to:
  /// **'{count, plural, other{{count} değerlendirme}}'**
  String reviewsCount(int count);

  /// No description provided for @resultWon.
  ///
  /// In tr, this message translates to:
  /// **'Kazandı'**
  String get resultWon;

  /// No description provided for @resultLost.
  ///
  /// In tr, this message translates to:
  /// **'Kaybetti'**
  String get resultLost;

  /// No description provided for @ratingPoints.
  ///
  /// In tr, this message translates to:
  /// **'{delta} puan'**
  String ratingPoints(String delta);

  /// No description provided for @gamesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Maçlar'**
  String get gamesTitle;

  /// No description provided for @tabUpcoming.
  ///
  /// In tr, this message translates to:
  /// **'Yaklaşan'**
  String get tabUpcoming;

  /// No description provided for @tabPast.
  ///
  /// In tr, this message translates to:
  /// **'Geçmiş'**
  String get tabPast;

  /// No description provided for @newMatch.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Maç'**
  String get newMatch;

  /// No description provided for @emptyUpcomingHint.
  ///
  /// In tr, this message translates to:
  /// **'Başlamak için yeni bir maç planla'**
  String get emptyUpcomingHint;

  /// No description provided for @message.
  ///
  /// In tr, this message translates to:
  /// **'Mesaj'**
  String get message;

  /// No description provided for @notifFilterAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get notifFilterAll;

  /// No description provided for @notifFilterMatches.
  ///
  /// In tr, this message translates to:
  /// **'Maçlar'**
  String get notifFilterMatches;

  /// No description provided for @notifFilterOther.
  ///
  /// In tr, this message translates to:
  /// **'Diğer'**
  String get notifFilterOther;

  /// No description provided for @actionFailed.
  ///
  /// In tr, this message translates to:
  /// **'İşlem başarısız: {reason}'**
  String actionFailed(String reason);

  /// No description provided for @groupToday.
  ///
  /// In tr, this message translates to:
  /// **'Bugün'**
  String get groupToday;

  /// No description provided for @groupYesterday.
  ///
  /// In tr, this message translates to:
  /// **'Dün'**
  String get groupYesterday;

  /// No description provided for @groupThisWeek.
  ///
  /// In tr, this message translates to:
  /// **'Bu Hafta'**
  String get groupThisWeek;

  /// No description provided for @markAllRead.
  ///
  /// In tr, this message translates to:
  /// **'Tümünü oku'**
  String get markAllRead;

  /// No description provided for @noNotifications.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim yok'**
  String get noNotifications;

  /// No description provided for @decline.
  ///
  /// In tr, this message translates to:
  /// **'Reddet'**
  String get decline;

  /// No description provided for @accept.
  ///
  /// In tr, this message translates to:
  /// **'Kabul Et'**
  String get accept;

  /// No description provided for @dispute.
  ///
  /// In tr, this message translates to:
  /// **'İtiraz Et'**
  String get dispute;

  /// No description provided for @confirm.
  ///
  /// In tr, this message translates to:
  /// **'Onayla'**
  String get confirm;

  /// No description provided for @minutesAgo.
  ///
  /// In tr, this message translates to:
  /// **'{minutes} dk önce'**
  String minutesAgo(int minutes);

  /// No description provided for @hoursAgo.
  ///
  /// In tr, this message translates to:
  /// **'{hours} sa önce'**
  String hoursAgo(int hours);

  /// No description provided for @inboxFilterUnread.
  ///
  /// In tr, this message translates to:
  /// **'Okunmamış'**
  String get inboxFilterUnread;

  /// No description provided for @inboxFilterMatchPartners.
  ///
  /// In tr, this message translates to:
  /// **'Maç Eşleri'**
  String get inboxFilterMatchPartners;

  /// No description provided for @editConversationsSoon.
  ///
  /// In tr, this message translates to:
  /// **'Konuşma düzenleme yakında'**
  String get editConversationsSoon;

  /// No description provided for @searchNameOrMessage.
  ///
  /// In tr, this message translates to:
  /// **'İsim veya mesaj ara…'**
  String get searchNameOrMessage;

  /// No description provided for @noResults.
  ///
  /// In tr, this message translates to:
  /// **'Sonuç bulunamadı'**
  String get noResults;

  /// No description provided for @noMessagesYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz mesaj yok'**
  String get noMessagesYet;

  /// No description provided for @minutesShort.
  ///
  /// In tr, this message translates to:
  /// **'{minutes}m'**
  String minutesShort(int minutes);

  /// No description provided for @messageSendFailed.
  ///
  /// In tr, this message translates to:
  /// **'Mesaj gönderilemedi. Tekrar denemek için mesaja dokun.'**
  String get messageSendFailed;

  /// No description provided for @online.
  ///
  /// In tr, this message translates to:
  /// **'Çevrimiçi'**
  String get online;

  /// No description provided for @messageHint.
  ///
  /// In tr, this message translates to:
  /// **'{name} ile mesajlaş…'**
  String messageHint(String name);

  /// No description provided for @back.
  ///
  /// In tr, this message translates to:
  /// **'Geri'**
  String get back;

  /// No description provided for @matchPercentTag.
  ///
  /// In tr, this message translates to:
  /// **'🎾 %{percent} eşleşme'**
  String matchPercentTag(int percent);

  /// No description provided for @profileWins.
  ///
  /// In tr, this message translates to:
  /// **'Galibiyet'**
  String get profileWins;

  /// No description provided for @profileLosses.
  ///
  /// In tr, this message translates to:
  /// **'Mağlubiyet'**
  String get profileLosses;

  /// No description provided for @profilePlayed.
  ///
  /// In tr, this message translates to:
  /// **'Oynandı'**
  String get profilePlayed;

  /// No description provided for @profileWinPct.
  ///
  /// In tr, this message translates to:
  /// **'Kazanma %'**
  String get profileWinPct;

  /// No description provided for @seeAllReviews.
  ///
  /// In tr, this message translates to:
  /// **'4.9 · Tüm değerlendirmeleri gör'**
  String get seeAllReviews;

  /// No description provided for @sectionAvailability.
  ///
  /// In tr, this message translates to:
  /// **'MÜSAİTLİK'**
  String get sectionAvailability;

  /// No description provided for @sectionPreferredCourts.
  ///
  /// In tr, this message translates to:
  /// **'TERCİH EDİLEN KORTLAR'**
  String get sectionPreferredCourts;

  /// No description provided for @playerSavedSoon.
  ///
  /// In tr, this message translates to:
  /// **'Oyuncu kaydedildi — yakında'**
  String get playerSavedSoon;

  /// No description provided for @slotFullDay.
  ///
  /// In tr, this message translates to:
  /// **'Tam'**
  String get slotFullDay;

  /// No description provided for @slotMorning.
  ///
  /// In tr, this message translates to:
  /// **'ÖÖ'**
  String get slotMorning;

  /// No description provided for @slotAfternoon.
  ///
  /// In tr, this message translates to:
  /// **'ÖS'**
  String get slotAfternoon;

  /// No description provided for @nearbyPlayersTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yakındaki Oyuncular'**
  String get nearbyPlayersTitle;

  /// No description provided for @mapMeMarker.
  ///
  /// In tr, this message translates to:
  /// **'Ben'**
  String get mapMeMarker;

  /// No description provided for @viewProfile.
  ///
  /// In tr, this message translates to:
  /// **'Profili Gör'**
  String get viewProfile;

  /// No description provided for @logResultFailed.
  ///
  /// In tr, this message translates to:
  /// **'Sonuç kaydedilemedi: {reason}'**
  String logResultFailed(String reason);

  /// No description provided for @logOpponentLabel.
  ///
  /// In tr, this message translates to:
  /// **'RAKİP'**
  String get logOpponentLabel;

  /// No description provided for @logGuestPlayer.
  ///
  /// In tr, this message translates to:
  /// **'Kayıtsız Oyuncu'**
  String get logGuestPlayer;

  /// No description provided for @logGuestPhoneHint.
  ///
  /// In tr, this message translates to:
  /// **'Telefon numarası (zorunlu)'**
  String get logGuestPhoneHint;

  /// No description provided for @logGuestNameHint.
  ///
  /// In tr, this message translates to:
  /// **'İsim (opsiyonel)'**
  String get logGuestNameHint;

  /// No description provided for @logYou.
  ///
  /// In tr, this message translates to:
  /// **'Sen'**
  String get logYou;

  /// No description provided for @logOpponentShort.
  ///
  /// In tr, this message translates to:
  /// **'Rakip'**
  String get logOpponentShort;

  /// No description provided for @logSetN.
  ///
  /// In tr, this message translates to:
  /// **'SET {n}'**
  String logSetN(int n);

  /// No description provided for @logAddSet3.
  ///
  /// In tr, this message translates to:
  /// **'3. seti ekle'**
  String get logAddSet3;

  /// No description provided for @logWinnerLabel.
  ///
  /// In tr, this message translates to:
  /// **'KAZANAN'**
  String get logWinnerLabel;

  /// No description provided for @logIWon.
  ///
  /// In tr, this message translates to:
  /// **'Ben kazandım 🏆'**
  String get logIWon;

  /// No description provided for @logOpponentWon.
  ///
  /// In tr, this message translates to:
  /// **'Rakip kazandı'**
  String get logOpponentWon;

  /// No description provided for @logYouWonMatch.
  ///
  /// In tr, this message translates to:
  /// **'Bu maçı kazandınız!'**
  String get logYouWonMatch;

  /// No description provided for @logNameWon.
  ///
  /// In tr, this message translates to:
  /// **'{name} kazandı'**
  String logNameWon(String name);

  /// No description provided for @change.
  ///
  /// In tr, this message translates to:
  /// **'Değiştir'**
  String get change;

  /// No description provided for @logSaveResult.
  ///
  /// In tr, this message translates to:
  /// **'Sonucu Kaydet'**
  String get logSaveResult;

  /// No description provided for @courtUnspecified.
  ///
  /// In tr, this message translates to:
  /// **'Belirtilmedi'**
  String get courtUnspecified;

  /// No description provided for @scheduleTitle.
  ///
  /// In tr, this message translates to:
  /// **'Takvim'**
  String get scheduleTitle;

  /// No description provided for @noMatchToday.
  ///
  /// In tr, this message translates to:
  /// **'Bu gün maç yok'**
  String get noMatchToday;

  /// No description provided for @noMatchTodayHint.
  ///
  /// In tr, this message translates to:
  /// **'Yeni rakip bul veya bir seans planla'**
  String get noMatchTodayHint;

  /// No description provided for @findNewMatch.
  ///
  /// In tr, this message translates to:
  /// **'Yeni maç bul'**
  String get findNewMatch;

  /// No description provided for @playersNearYou.
  ///
  /// In tr, this message translates to:
  /// **'Yakınınızda 4 oyuncu mevcut'**
  String get playersNearYou;

  /// No description provided for @singlesMatchTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tekler Maçı'**
  String get singlesMatchTitle;

  /// No description provided for @doublesMatchTitle.
  ///
  /// In tr, this message translates to:
  /// **'Çiftler Maçı'**
  String get doublesMatchTitle;

  /// No description provided for @matchRequestSentToName.
  ///
  /// In tr, this message translates to:
  /// **'{name} adlı oyuncuya maç isteği gönderildi!'**
  String matchRequestSentToName(String name);

  /// No description provided for @doublesInviteSent.
  ///
  /// In tr, this message translates to:
  /// **'Çiftler davetiyesi gönderildi!'**
  String get doublesInviteSent;

  /// No description provided for @pickOpponentLabel.
  ///
  /// In tr, this message translates to:
  /// **'RAKİP SEÇ'**
  String get pickOpponentLabel;

  /// No description provided for @partnerLabel.
  ///
  /// In tr, this message translates to:
  /// **'TAKIMDAŞIN'**
  String get partnerLabel;

  /// No description provided for @sendMatchRequestButton.
  ///
  /// In tr, this message translates to:
  /// **'Maç İsteği Gönder 🎾'**
  String get sendMatchRequestButton;

  /// No description provided for @sendInviteButton.
  ///
  /// In tr, this message translates to:
  /// **'Davetiye Gönder 🎾'**
  String get sendInviteButton;

  /// No description provided for @shareText.
  ///
  /// In tr, this message translates to:
  /// **'Rallly\'de maç sonucum 🎾'**
  String get shareText;

  /// No description provided for @shareFailed.
  ///
  /// In tr, this message translates to:
  /// **'Paylaşılamadı. Tekrar deneyin.'**
  String get shareFailed;

  /// No description provided for @matchResultTitle.
  ///
  /// In tr, this message translates to:
  /// **'Maç Sonucu'**
  String get matchResultTitle;

  /// No description provided for @sharing.
  ///
  /// In tr, this message translates to:
  /// **'Paylaşılıyor…'**
  String get sharing;

  /// No description provided for @shareResult.
  ///
  /// In tr, this message translates to:
  /// **'Sonucu Paylaş 🎾'**
  String get shareResult;

  /// No description provided for @done.
  ///
  /// In tr, this message translates to:
  /// **'Tamam'**
  String get done;

  /// No description provided for @victory.
  ///
  /// In tr, this message translates to:
  /// **'Zafer 🏆'**
  String get victory;

  /// No description provided for @defeat.
  ///
  /// In tr, this message translates to:
  /// **'Yenilgi'**
  String get defeat;

  /// No description provided for @errorOwnLobby.
  ///
  /// In tr, this message translates to:
  /// **'Bu senin kendi lobin'**
  String get errorOwnLobby;

  /// No description provided for @errorAlreadyRequested.
  ///
  /// In tr, this message translates to:
  /// **'Bu lobiye zaten katılma isteği gönderdin'**
  String get errorAlreadyRequested;

  /// No description provided for @lobbyYours.
  ///
  /// In tr, this message translates to:
  /// **'Senin lobin'**
  String get lobbyYours;

  /// No description provided for @lobbyRequested.
  ///
  /// In tr, this message translates to:
  /// **'İstek gönderildi'**
  String get lobbyRequested;

  /// No description provided for @requestIncomingLabel.
  ///
  /// In tr, this message translates to:
  /// **'Sana gelen istek'**
  String get requestIncomingLabel;

  /// No description provided for @requestSentLabel.
  ///
  /// In tr, this message translates to:
  /// **'Yanıt bekleniyor'**
  String get requestSentLabel;

  /// No description provided for @matchDetailRespondHint.
  ///
  /// In tr, this message translates to:
  /// **'Kabul veya Reddet için Bildirimler sekmesine bak.'**
  String get matchDetailRespondHint;

  /// No description provided for @signupNameNeedsSurname.
  ///
  /// In tr, this message translates to:
  /// **'Adını ve soyadını birlikte yaz'**
  String get signupNameNeedsSurname;

  /// No description provided for @signupSaveFailed.
  ///
  /// In tr, this message translates to:
  /// **'Profilin kaydedilemedi, tekrar dene'**
  String get signupSaveFailed;

  /// No description provided for @emptyPastHint.
  ///
  /// In tr, this message translates to:
  /// **'Tamamlanan maçların burada görünür'**
  String get emptyPastHint;
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
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
