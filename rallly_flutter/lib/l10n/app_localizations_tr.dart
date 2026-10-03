// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'RallyMatch';

  @override
  String get sportTennis => 'Tenis';

  @override
  String get sportTennisSub => 'Tekler & çiftler';

  @override
  String get sportPadel => 'Padel';

  @override
  String get sportPadelSub => 'Raket sporu';

  @override
  String get sportBadminton => 'Badminton';

  @override
  String get sportBadmintonSub => 'İç mekan & açık alan';

  @override
  String get sportSquash => 'Squash';

  @override
  String get sportSquashSub => 'Kort sporu';

  @override
  String get skillBeginner => 'Başlangıç';

  @override
  String get skillBeginnerSub => '1 yıldan az — temelleri öğreniyor';

  @override
  String get skillIntermediate => 'Orta Seviye';

  @override
  String get skillIntermediateSub => '1–4 yıl — rahatça ralli yapıyor';

  @override
  String get skillAdvanced => 'İleri Seviye';

  @override
  String get skillAdvancedSub => 'Rekabetçi — güçlü genel oyun';

  @override
  String get skillExpert => 'Uzman';

  @override
  String get skillExpertSub => 'Turnuva seviyesi — en iyi oyun';

  @override
  String get dayMon => 'Pzt';

  @override
  String get dayTue => 'Sal';

  @override
  String get dayWed => 'Çar';

  @override
  String get dayThu => 'Per';

  @override
  String get dayFri => 'Cum';

  @override
  String get daySat => 'Cmt';

  @override
  String get daySun => 'Paz';

  @override
  String get timeMorning => 'Sabah';

  @override
  String get timeAfternoon => 'Öğleden Sonra';

  @override
  String get timeEvening => 'Akşam';

  @override
  String get courtThemeClay => 'Toprak';

  @override
  String get courtThemeHard => 'Sert Kort';

  @override
  String get courtThemeGrass => 'Çim';

  @override
  String get navFindOpponent => 'Rakip Bul';

  @override
  String get navMessages => 'Mesajlar';

  @override
  String get navNotifications => 'Bildirim';

  @override
  String get navProfile => 'Profil';

  @override
  String get createMatchFab => 'Maç Oluştur';

  @override
  String get matchBadgeLabel => 'EŞLEŞME';

  @override
  String get requestShort => 'İste';

  @override
  String get profileCompleteTitle => 'Profilini tamamla';

  @override
  String profilePercentDone(int percent) {
    return '%$percent tamamlandı';
  }

  @override
  String profileMissing(String items) {
    return 'Eksik: $items';
  }

  @override
  String get missingBio => 'biyografi';

  @override
  String get missingAvailability => 'müsaitlik';

  @override
  String get missingSport => 'spor';

  @override
  String get missingLevel => 'seviye';

  @override
  String get profileSetSchedule => 'Haftalık programını ayarla';

  @override
  String get profileTitle => 'Profilim';

  @override
  String get courtThemeTitle => 'Kort Teması';

  @override
  String get courtThemeSubtitle => 'Uygulamanın renk temasını seç';

  @override
  String get courtThemeClaySub => 'Roland-Garros tarzı';

  @override
  String get courtThemeHardSub => 'US Open tarzı';

  @override
  String get courtThemeGrassSub => 'Wimbledon tarzı';

  @override
  String get photoUploadSoon => 'Fotoğraf yükleme yakında';

  @override
  String profileNtrpLine(String rating, String level) {
    return '🎾  NTRP $rating — $level';
  }

  @override
  String get profileNtrpUnknown => '🎾  NTRP —';

  @override
  String get editProfile => 'Profili Düzenle';

  @override
  String get statWins => 'GALİBİYET';

  @override
  String get statLosses => 'MAĞLUBIYET';

  @override
  String get statPlayed => 'OYNANDI';

  @override
  String get statRating => 'PUAN';

  @override
  String get uploadScore => 'Skorunu Yükle';

  @override
  String get scoreRequests => 'Skor Talepleri';

  @override
  String get myMatchesHeader => 'MAÇLARIM';

  @override
  String tabUpcomingCount(int count) {
    return 'Yaklaşan ($count)';
  }

  @override
  String tabPastCount(int count) {
    return 'Geçmiş ($count)';
  }

  @override
  String tabPendingCount(int count) {
    return 'Bekleyen ($count)';
  }

  @override
  String get emptyUpcoming => 'Yaklaşan maç yok';

  @override
  String get emptyPast => 'Geçmiş maç yok';

  @override
  String get emptyPending => 'Bekleyen istek yok';

  @override
  String get sectionMyGame => 'OYUNUM';

  @override
  String get reputation => 'İtibar';

  @override
  String get reputationSub => '4.9 puan · 4 değerlendirme';

  @override
  String get achievements => 'Başarılar';

  @override
  String get achievementsSub => '18 üzerinden 12 kazanıldı';

  @override
  String get myResults => 'Sonuçlarım';

  @override
  String get myResultsSub => 'Maç geçmişi ve skorlar';

  @override
  String get logResult => 'Sonuç Kaydet';

  @override
  String get logResultSub => 'Son maçını kaydet';

  @override
  String get sectionAccount => 'HESAP';

  @override
  String get editProfileSub => 'Ad, konum, biyografi, seviye güncelle';

  @override
  String get gamePreferences => 'Oyun Tercihleri';

  @override
  String get gamePreferencesSub => 'Seviye, kort türü, format';

  @override
  String get gamePreferencesSoon => 'Oyun tercihleri yakında';

  @override
  String get availability => 'Müsaitlik';

  @override
  String get sectionApp => 'UYGULAMA';

  @override
  String get notifications => 'Bildirimler';

  @override
  String get notificationsSub => 'Maç istekleri, hatırlatmalar';

  @override
  String get courtThemeOptions => 'Toprak / Sert Kort / Çim';

  @override
  String get privacySecurity => 'Gizlilik ve Güvenlik';

  @override
  String get privacySecuritySub => 'Profil görünürlüğü';

  @override
  String get privacySettingsSoon => 'Gizlilik ayarları yakında';

  @override
  String get sectionAbout => 'HAKKINDA';

  @override
  String get termsPrivacy => 'Şartlar ve Gizlilik';

  @override
  String get termsPrivacySoon => 'Şartlar ve Gizlilik yakında';

  @override
  String get signOut => 'Çıkış Yap';

  @override
  String get profileLoadingRetry => 'Profil yükleniyor, lütfen tekrar deneyin';

  @override
  String get profileUpdated => 'Profil güncellendi';

  @override
  String vsOpponent(String name) {
    return 'vs $name';
  }

  @override
  String get statusUpcomingUpper => 'YAKLAŞAN';

  @override
  String get statusCompletedUpper => 'TAMAMLANDI';

  @override
  String get statusPendingUpper => 'BEKLİYOR';

  @override
  String get statusCancelledUpper => 'İPTAL';

  @override
  String get statusConfirmed => 'Onaylandı';

  @override
  String get statusCompleted => 'Tamamlandı';

  @override
  String get statusPending => 'Beklemede';

  @override
  String get statusCancelled => 'İptal Edildi';

  @override
  String get formatDoubles => 'Çiftler';

  @override
  String get formatSingles => 'Tekler';

  @override
  String get requestMatch => 'Maç İste';

  @override
  String get sort => 'Sıralama';

  @override
  String get filter => 'Filtre';

  @override
  String get upcomingMatchesHeader => 'YAKLAŞAN MAÇLAR';

  @override
  String get seeAll => 'Tümünü gör';

  @override
  String nearbyPlayersHeader(int count) {
    return '$count YAKINDA OYUNCU';
  }

  @override
  String get map => 'Harita';

  @override
  String get openLobbiesHeader => 'AÇIK LOBİLER';

  @override
  String get createLobby => 'Lobi Oluştur';

  @override
  String get nearbyPlayersEyebrow => 'YAKINDAKI OYUNCULAR';

  @override
  String playersWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count oyuncu sizi bekliyor',
    );
    return '$_temp0';
  }

  @override
  String get searchNameOrLocation => 'İsim veya konum ara…';

  @override
  String winRatePercent(int percent) {
    return '$percent% galibiyet';
  }

  @override
  String matchesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count maç',
    );
    return '$_temp0';
  }

  @override
  String get skillShortBeginner => 'Başl.';

  @override
  String get skillShortIntermediate => 'Orta';

  @override
  String get skillShortAdvanced => 'İleri';

  @override
  String get skillShortExpert => 'Uzm.';

  @override
  String get tennisBadge => '🎾 TENİS';

  @override
  String get sortDistance => 'Mesafe';

  @override
  String get sortWins => 'Galibiyet';

  @override
  String get sortSheetSubtitle => 'Oyuncuları sıralama kriteri';

  @override
  String get apply => 'Uygula';

  @override
  String get filterTitle => 'Filtrele';

  @override
  String get clear => 'Temizle';

  @override
  String get level => 'Seviye';

  @override
  String get distance => 'Mesafe';

  @override
  String get all => 'Tümü';

  @override
  String get join => 'Katıl';

  @override
  String lobbyJoinSent(String sport) {
    return '$sport lobisine katılma isteği gönderildi!';
  }

  @override
  String get authErrorRateLimit =>
      'Çok fazla kod isteği gönderildi. Lütfen birkaç dakika bekleyip tekrar deneyin.';

  @override
  String get authErrorGeneric =>
      'Bir şeyler yanlış gitti. Lütfen tekrar deneyin.';

  @override
  String get authErrorInvalidEmail =>
      'Lütfen geçerli bir e-posta adresi girin.';

  @override
  String get authErrorCodeInvalidOrExpired =>
      'Kod geçersiz veya süresi dolmuş. Lütfen yeni kod isteyin.';

  @override
  String get authErrorInvalidCode => 'Geçersiz kod. Lütfen tekrar deneyin.';

  @override
  String get authErrorResendFailed =>
      'Kod gönderilemedi. Lütfen tekrar deneyin.';

  @override
  String get authCreateAccount => 'Hesap oluştur';

  @override
  String get authWelcomeBack => 'Tekrar hoş geldiniz';

  @override
  String get authEmailPromptSignUp =>
      'E-posta adresinizi girin, size tek kullanımlık kod göndereceğiz';

  @override
  String get authEmailPromptSignIn =>
      'E-posta adresinize giriş kodu göndereceğiz';

  @override
  String get authEmailLabel => 'E-POSTA ADRESİ';

  @override
  String get authEmailHint => 'siz@ornek.com';

  @override
  String get authSendCode => 'Kodu gönder';

  @override
  String get authHaveAccount => 'Zaten hesabın var mı? ';

  @override
  String get authNoAccount => 'Hesabın yok mu? ';

  @override
  String get authSignIn => 'Giriş yap';

  @override
  String get authSignUp => 'Kayıt ol';

  @override
  String get authCheckEmail => 'E-postanı kontrol et';

  @override
  String get authCodeSentTo => 'E-posta adresinize 8 haneli kod gönderdik:\n';

  @override
  String get authVerify => 'Doğrula';

  @override
  String get authResendCode => 'Kodu tekrar gönder';

  @override
  String authResendIn(int seconds) {
    return '$seconds saniye sonra tekrar gönder';
  }

  @override
  String get landingSignInButton => 'Giriş Yap';

  @override
  String get landingHeadline => 'Mükemmel\nrakibini bul.';

  @override
  String get landingSubtitle =>
      'Seviyenizde tenis oyuncuları bulun, kort rezervasyonu yapın ve gelişiminizi takip edin.';

  @override
  String get landingStatPlayers => 'Oyuncu';

  @override
  String get landingStatMatchRate => 'Uyum oranı';

  @override
  String get landingStatRating => 'Puan';

  @override
  String get landingGetStarted => 'Başla — tamamen ücretsiz';

  @override
  String get landingHaveAccount => 'Zaten hesabım var';

  @override
  String get landingTerms =>
      'Devam ederek Şartlarımızı ve Gizlilik Politikamızı kabul etmiş olursunuz';

  @override
  String get signupFinish => 'Bitir — Oynayalım 🎾';

  @override
  String get signupContinue => 'Devam';

  @override
  String get signupStep1Title => 'Kendinizden bahsedin';

  @override
  String get signupStep1Subtitle => 'Oyuncuların sizi bulmasına yardımcı olun';

  @override
  String get signupNameLabel => 'AD SOYAD';

  @override
  String get signupNameHint => 'örn. Leyla Garayli';

  @override
  String get signupLocationLabel => 'MAHALLE / ŞEHİR';

  @override
  String get signupLocationHint => 'örn. Beşiktaş, İstanbul';

  @override
  String get signupStep2Title => 'Hangi sporları oynuyorsunuz?';

  @override
  String get signupStep2Subtitle => 'Uygun olanları seçin';

  @override
  String get signupStep3Title => 'Seviyeniz nedir?';

  @override
  String get signupStep3Subtitle =>
      'Dürüst olun — bu en iyi maçları bulmaya yardımcı olur';

  @override
  String get signupStep4Title => 'Genellikle ne zaman müsaitsiniz?';

  @override
  String get signupStep4Subtitle => 'Tipik müsaitliğinizi seçin';

  @override
  String get signupDaysHeader => 'GÜNLER';

  @override
  String get signupTimeOfDayHeader => 'GÜNÜN SAATİ';

  @override
  String get profileSaveFailed =>
      'Profil kaydedilemedi. Lütfen tekrar deneyin.';

  @override
  String get editAboutLabel => 'HAKKIMDA';

  @override
  String get editAboutHint => 'Oyun tarzın, sevdiğin kortlar…';

  @override
  String get editSportsLabel => 'SPORLAR';

  @override
  String get editLevelLabel => 'SEVİYE';

  @override
  String get editDaysLabel => 'MÜSAİT GÜNLER';

  @override
  String get save => 'Kaydet';

  @override
  String get createGameQuestion => 'Ne yapmak istersin?';

  @override
  String get createGameSubtitle => 'Bir seçenek seç ve hemen başla.';

  @override
  String get createGameStartMatch => 'Maç Başlat';

  @override
  String get createGameStartMatchSub => 'Belirli bir rakiple randevu oluştur.';

  @override
  String get createGamePublishOpen => 'Açık Maç Yayınla';

  @override
  String get createGamePublishOpenSub =>
      'Herkese açık bir slot oluştur, rakibini bekle.';

  @override
  String get errorNotSignedIn => 'Oturum açmanız gerekiyor';

  @override
  String get errorRecipientNotRegistered =>
      'Bu oyuncu kayıtlı değil, mesaj gönderilemez';

  @override
  String get errorMatchUpdateDenied => 'Maç durumu güncellenemedi (yetki yok)';

  @override
  String get errorUnknown => 'Bir şeyler yanlış gitti. Lütfen tekrar deneyin.';

  @override
  String get matchRequestTitle => 'Maç İsteği';

  @override
  String get format => 'Format';

  @override
  String get dateAndTime => 'Tarih & Saat';

  @override
  String get court => 'Kort';

  @override
  String get pastTimeNotAllowed => 'Geçmiş bir saat seçilemez';

  @override
  String matchRequestSentTo(String name) {
    return '$name oyuncusuna maç isteği gönderildi!';
  }

  @override
  String requestFailed(String reason) {
    return 'İstek gönderilemedi: $reason';
  }

  @override
  String get requestSent => 'İstek Gönderildi ✓';

  @override
  String get sendRequest => 'İstek Gönder 🎾';

  @override
  String get badgeFirstMatch => 'İlk Maç';

  @override
  String get badgeFirstMatchDesc => 'İlk oyununu oynadın';

  @override
  String get badgeWinStreak => 'Seri Galibiyet';

  @override
  String get badgeWinStreakDesc => 'Arka arkaya 3 galibiyet';

  @override
  String get badgeFiveStar => '5 Yıldızlı Oyuncu';

  @override
  String get badgeFiveStarDesc => 'Ortalama puan 4.8+';

  @override
  String get badgeSocialButterfly => 'Sosyal Kelebek';

  @override
  String get badgeSocialButterflyDesc => '10 oyuncuyla bağlantı kuruldu';

  @override
  String get badgeRegularPlayer => 'Düzenli Oyuncu';

  @override
  String get badgeRegularPlayerDesc => '10+ maç oynandı';

  @override
  String get badgeChampion => 'Şampiyon';

  @override
  String get badgeChampionDesc => '25+ galibiyet';

  @override
  String get badgeQuickReply => 'Hızlı Yanıt';

  @override
  String get badgeQuickReplyDesc => '1 saat içinde cevap verdi';

  @override
  String get badgeExplorer => 'Kaşif';

  @override
  String get badgeExplorerDesc => '5 farklı kortta oynandı';

  @override
  String get badgeCommunicator => 'İletişimci';

  @override
  String get badgeCommunicatorDesc => '50 mesaj gönderildi';

  @override
  String get badgeSharpshooter => 'Keskin Nişancı';

  @override
  String get badgeSharpshooterDesc => '80%+ kazanma oranı';

  @override
  String get badgeSharer => 'Paylaş';

  @override
  String get badgeSharerDesc => '5 maç sonucu paylaşıldı';

  @override
  String get badgeElite => 'Elit';

  @override
  String get badgeEliteDesc => 'İleri Seviyeye ulaşıldı';

  @override
  String get badgeTournamentPro => 'Turnuva Profesyoneli';

  @override
  String get badgeTournamentProDesc => 'Bir turnuvaya katıl';

  @override
  String get badgeLegend => 'Efsane';

  @override
  String get badgeLegendDesc => '100 maç oynandı';

  @override
  String get badgeGrandSlam => 'Grand Slam';

  @override
  String get badgeGrandSlamDesc => '4 farklı kortta galibiyet';

  @override
  String get badgeDoublesKing => 'Çiftler Kralı';

  @override
  String get badgeDoublesKingDesc => '10 çiftler maçı kazanıldı';

  @override
  String get badgeAllRounder => 'Çok Yönlü';

  @override
  String get badgeAllRounderDesc => '4 sporun tümü oynanıldı';

  @override
  String get badgeRocket => 'Roket';

  @override
  String get badgeRocketDesc => 'Puan 200+ arttırıldı';

  @override
  String achievementsEarnedOf(int earned, int total) {
    return '$earned / $total';
  }

  @override
  String get achievementsEarnedLabel => 'Başarı kazanıldı';

  @override
  String get achievementsEarnedHeader => 'KAZANILDI';

  @override
  String get achievementsLockedHeader => 'KİLİTLİ';

  @override
  String get prefMatchRequests => 'Maç İstekleri';

  @override
  String get prefMatchRequestsSub => 'Biriyle oynamak istediğinde';

  @override
  String get prefMatchConfirmations => 'Maç Onayları';

  @override
  String get prefMatchConfirmationsSub => 'İstek kabul edildiğinde';

  @override
  String get prefMatchReminders => 'Maç Hatırlatmaları';

  @override
  String get prefMatchRemindersSub => 'Planlanmış maçtan önce hatırlatma';

  @override
  String get prefMatchCancellations => 'İptal Bildirimleri';

  @override
  String get prefMatchCancellationsSub => 'Maç iptal edildiğinde';

  @override
  String get prefMessages => 'Mesajlar';

  @override
  String get prefMessagesSub => 'Diğer oyunculardan yeni mesajlar';

  @override
  String get prefNewReviews => 'Yeni Değerlendirmeler';

  @override
  String get prefNewReviewsSub => 'Biri sizi değerlendirdiğinde';

  @override
  String get prefResultConfirmed => 'Sonuç Onaylandı';

  @override
  String get prefResultConfirmedSub => 'Rakibiniz maç sonucunu onayladığında';

  @override
  String get prefNearbyPlayers => 'Yakındaki Oyuncular';

  @override
  String get prefNearbyPlayersSub => 'Bölgenize yeni oyuncular katıldığında';

  @override
  String get prefMarketing => 'Uygulama Güncellemeleri & İpuçları';

  @override
  String get prefMarketingSub => 'Yeni özellikler ve oyun ipuçları';

  @override
  String get prefSaved => 'Kaydedildi ✓';

  @override
  String get prefSectionMatches => 'MAÇLAR';

  @override
  String get prefSectionSocial => 'SOSYAL';

  @override
  String get prefSectionUpdates => 'GÜNCELLEMELER';

  @override
  String get skillAnyLevel => 'Her seviye';

  @override
  String get lobbyCreated =>
      'Açık lobi oluşturuldu! Oyuncular artık katılabilir.';

  @override
  String lobbyCreateFailed(String reason) {
    return 'Lobi oluşturulamadı: $reason';
  }

  @override
  String get openLobbyTitle => 'Açık Lobi';

  @override
  String get openLobbyHeadline => 'Açık slot oluştur';

  @override
  String get openLobbySubtitle =>
      'Diğer oyuncular oturumuna katılmak için istekte bulunabilir';

  @override
  String get openLobbySport => 'SPOR';

  @override
  String get openLobbyInvitedLevel => 'DAVET EDİLEN SEVİYE';

  @override
  String get openLobbyDateTime => 'TARİH & SAAT';

  @override
  String get pickDate => 'Tarih seç';

  @override
  String get pickTime => 'Saat seç';

  @override
  String get openLobbyCourt => 'KORT';

  @override
  String get openLobbyNotes => 'NOTLAR (OPSİYONEL)';

  @override
  String get openLobbyNotesHint =>
      'ör. \"Kendi topunuzu getirin, rahat bir maç, başlangıç seviyesi hoş geldiniz\"';

  @override
  String get openLobbyPublic => 'Herkese açık lobi';

  @override
  String get openLobbyPublicSub => 'Herkes katılmak için istekte bulunabilir';

  @override
  String get openLobbyCreateButton => 'Lobi Oluştur 🎾';

  @override
  String get onboardingGotIt => 'Anladım!';

  @override
  String get onboardingFind1 =>
      'Seviyene uygun oyuncuları bul ve maç isteği gönder.';

  @override
  String get onboardingFind2 =>
      'NTRP, galibiyet oranı ve müsaitliğe göre sırala.';

  @override
  String get onboardingFind3 => 'Filtrele, keşfet, sahaya çık.';

  @override
  String get onboardingMessages1 =>
      'Maç öncesi ve sonrası rakibinle doğrudan mesajlaş.';

  @override
  String get onboardingMessages2 => 'Tüm konuşmalarını tek ekranda takip et.';

  @override
  String get onboardingMessages3 => 'Kort detaylarını ve saati kolayca paylaş.';

  @override
  String get onboardingNotifications1 =>
      'Gelen maç isteklerini kabul et veya reddet.';

  @override
  String get onboardingNotifications2 =>
      'Skor güncellemelerini ve hatırlatıcıları buradan gör.';

  @override
  String get onboardingNotifications3 =>
      'Tüm önemli gelişmelerden anında haberdar ol.';

  @override
  String get onboardingProfile1 =>
      'NTRP seviyeni, istatistiklerini ve başarılarını görüntüle.';

  @override
  String get onboardingProfile2 =>
      'Maç geçmişini ve takvimini buradan takip et.';

  @override
  String get onboardingProfile3 =>
      'Bildirim tercihlerini ve hesap ayarlarını düzenle.';

  @override
  String get reviewCommentEmre =>
      'Harika ralliler, çok sportif — rövanş için sabırsızlanıyorum!';

  @override
  String get reviewCommentSelin =>
      'Mükemmel oyuncu, her zaman zamanında ve çok adil. Kesinlikle tavsiye ederim.';

  @override
  String get reviewCommentZeynep =>
      'Güzel maç, çekişmeli oyun. Çok rekabetçi ama her zaman dostane.';

  @override
  String get reviewCommentBerk =>
      'Maçtan gerçekten zevk aldım. Harika tavsiyeler de verdi!';

  @override
  String get reviewTagPunctual => 'Dakik';

  @override
  String get reviewTagSporty => 'Sportif';

  @override
  String get reviewTagGoodComm => 'İyi iletişim';

  @override
  String get reviewTagFairPlay => 'Adil oyun';

  @override
  String get reviewTagCompetitive => 'Rekabetçi';

  @override
  String get reviewTagFriendly => 'Dostane';

  @override
  String get reviewTagHelpful => 'Yardımsever';

  @override
  String get reputationMine => 'İtibarım';

  @override
  String reputationOf(String name) {
    return '$name İtibarı';
  }

  @override
  String reviewsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count değerlendirme',
    );
    return '$_temp0';
  }

  @override
  String get resultWon => 'Kazandı';

  @override
  String get resultLost => 'Kaybetti';

  @override
  String ratingPoints(String delta) {
    return '$delta puan';
  }

  @override
  String get gamesTitle => 'Maçlar';

  @override
  String get tabUpcoming => 'Yaklaşan';

  @override
  String get tabPast => 'Geçmiş';

  @override
  String get newMatch => 'Yeni Maç';

  @override
  String get emptyUpcomingHint => 'Başlamak için yeni bir maç planla';

  @override
  String get message => 'Mesaj';

  @override
  String get notifFilterAll => 'Tümü';

  @override
  String get notifFilterMatches => 'Maçlar';

  @override
  String get notifFilterOther => 'Diğer';

  @override
  String actionFailed(String reason) {
    return 'İşlem başarısız: $reason';
  }

  @override
  String get groupToday => 'Bugün';

  @override
  String get groupYesterday => 'Dün';

  @override
  String get groupThisWeek => 'Bu Hafta';

  @override
  String get markAllRead => 'Tümünü oku';

  @override
  String get noNotifications => 'Bildirim yok';

  @override
  String get decline => 'Reddet';

  @override
  String get accept => 'Kabul Et';

  @override
  String get dispute => 'İtiraz Et';

  @override
  String get confirm => 'Onayla';

  @override
  String minutesAgo(int minutes) {
    return '$minutes dk önce';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours sa önce';
  }

  @override
  String get inboxFilterUnread => 'Okunmamış';

  @override
  String get inboxFilterMatchPartners => 'Maç Eşleri';

  @override
  String get editConversationsSoon => 'Konuşma düzenleme yakında';

  @override
  String get searchNameOrMessage => 'İsim veya mesaj ara…';

  @override
  String get noResults => 'Sonuç bulunamadı';

  @override
  String get noMessagesYet => 'Henüz mesaj yok';

  @override
  String minutesShort(int minutes) {
    return '${minutes}m';
  }

  @override
  String get messageSendFailed =>
      'Mesaj gönderilemedi. Tekrar denemek için mesaja dokun.';

  @override
  String get online => 'Çevrimiçi';

  @override
  String messageHint(String name) {
    return '$name ile mesajlaş…';
  }

  @override
  String get back => 'Geri';

  @override
  String matchPercentTag(int percent) {
    return '🎾 %$percent eşleşme';
  }

  @override
  String get profileWins => 'Galibiyet';

  @override
  String get profileLosses => 'Mağlubiyet';

  @override
  String get profilePlayed => 'Oynandı';

  @override
  String get profileWinPct => 'Kazanma %';

  @override
  String get seeAllReviews => '4.9 · Tüm değerlendirmeleri gör';

  @override
  String get sectionAvailability => 'MÜSAİTLİK';

  @override
  String get sectionPreferredCourts => 'TERCİH EDİLEN KORTLAR';

  @override
  String get playerSavedSoon => 'Oyuncu kaydedildi — yakında';

  @override
  String get slotFullDay => 'Tam';

  @override
  String get slotMorning => 'ÖÖ';

  @override
  String get slotAfternoon => 'ÖS';

  @override
  String get nearbyPlayersTitle => 'Yakındaki Oyuncular';

  @override
  String get mapMeMarker => 'Ben';

  @override
  String get viewProfile => 'Profili Gör';

  @override
  String logResultFailed(String reason) {
    return 'Sonuç kaydedilemedi: $reason';
  }

  @override
  String get logOpponentLabel => 'RAKİP';

  @override
  String get logGuestPlayer => 'Kayıtsız Oyuncu';

  @override
  String get logGuestPhoneHint => 'Telefon numarası (zorunlu)';

  @override
  String get logGuestNameHint => 'İsim (opsiyonel)';

  @override
  String get logYou => 'Sen';

  @override
  String get logOpponentShort => 'Rakip';

  @override
  String logSetN(int n) {
    return 'SET $n';
  }

  @override
  String get logAddSet3 => '3. seti ekle';

  @override
  String get logWinnerLabel => 'KAZANAN';

  @override
  String get logIWon => 'Ben kazandım 🏆';

  @override
  String get logOpponentWon => 'Rakip kazandı';

  @override
  String get logYouWonMatch => 'Bu maçı kazandınız!';

  @override
  String logNameWon(String name) {
    return '$name kazandı';
  }

  @override
  String get change => 'Değiştir';

  @override
  String get logSaveResult => 'Sonucu Kaydet';

  @override
  String get courtUnspecified => 'Belirtilmedi';

  @override
  String get scheduleTitle => 'Takvim';

  @override
  String get noMatchToday => 'Bu gün maç yok';

  @override
  String get noMatchTodayHint => 'Yeni rakip bul veya bir seans planla';

  @override
  String get findNewMatch => 'Yeni maç bul';

  @override
  String get playersNearYou => 'Yakınınızda 4 oyuncu mevcut';

  @override
  String get singlesMatchTitle => 'Tekler Maçı';

  @override
  String get doublesMatchTitle => 'Çiftler Maçı';

  @override
  String matchRequestSentToName(String name) {
    return '$name adlı oyuncuya maç isteği gönderildi!';
  }

  @override
  String get doublesInviteSent => 'Çiftler davetiyesi gönderildi!';

  @override
  String get pickOpponentLabel => 'RAKİP SEÇ';

  @override
  String get partnerLabel => 'TAKIMDAŞIN';

  @override
  String get sendMatchRequestButton => 'Maç İsteği Gönder 🎾';

  @override
  String get sendInviteButton => 'Davetiye Gönder 🎾';

  @override
  String get shareText => 'Rallly\'de maç sonucum 🎾';

  @override
  String get shareFailed => 'Paylaşılamadı. Tekrar deneyin.';

  @override
  String get matchResultTitle => 'Maç Sonucu';

  @override
  String get sharing => 'Paylaşılıyor…';

  @override
  String get shareResult => 'Sonucu Paylaş 🎾';

  @override
  String get done => 'Tamam';

  @override
  String get victory => 'Zafer 🏆';

  @override
  String get defeat => 'Yenilgi';
}
