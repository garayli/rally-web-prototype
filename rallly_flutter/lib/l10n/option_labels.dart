// Display labels for the canonical Turkish values stored in `profiles`
// (sports, skill_level, available_days, time_prefs). The stored values must
// not change with the UI language — only what is shown does. Unknown values
// (e.g. written by an older client) fall back to the raw string.
import '../theme/app_theme.dart';
import 'app_localizations.dart';

String sportLabel(AppLocalizations l, String v) => switch (v) {
      'Tenis' => l.sportTennis,
      'Padel' => l.sportPadel,
      'Badminton' => l.sportBadminton,
      'Squash' => l.sportSquash,
      _ => v,
    };

String sportSubtitle(AppLocalizations l, String v) => switch (v) {
      'Tenis' => l.sportTennisSub,
      'Padel' => l.sportPadelSub,
      'Badminton' => l.sportBadmintonSub,
      'Squash' => l.sportSquashSub,
      _ => '',
    };

String skillLevelLabel(AppLocalizations l, String v) => switch (v) {
      'Başlangıç' => l.skillBeginner,
      'Orta Seviye' => l.skillIntermediate,
      'İleri Seviye' => l.skillAdvanced,
      'Uzman' => l.skillExpert,
      'Her seviye' => l.skillAnyLevel,
      _ => v,
    };

String skillSubtitle(AppLocalizations l, String v) => switch (v) {
      'Başlangıç' => l.skillBeginnerSub,
      'Orta Seviye' => l.skillIntermediateSub,
      'İleri Seviye' => l.skillAdvancedSub,
      'Uzman' => l.skillExpertSub,
      _ => '',
    };

/// [v] is one of `dayOptions` ('Pzt' … 'Paz').
String dayLabel(AppLocalizations l, String v) => switch (v) {
      'Pzt' => l.dayMon,
      'Sal' => l.dayTue,
      'Çar' => l.dayWed,
      'Per' => l.dayThu,
      'Cum' => l.dayFri,
      'Cmt' => l.daySat,
      'Paz' => l.daySun,
      _ => v,
    };

/// A player's availability slot, e.g. 'Pzt Tam' / 'Sal ÖÖ' / 'Cmt ÖS'.
String availabilitySlotLabel(AppLocalizations l, String slot) {
  final parts = slot.split(' ');
  if (parts.length != 2) return slot;
  return '${dayLabel(l, parts[0])} ${slotPartLabel(l, parts[1])}';
}

/// 'Tam' = full day, 'ÖÖ' = morning, 'ÖS' = afternoon.
String slotPartLabel(AppLocalizations l, String v) => switch (v) {
      'Tam' => l.slotFullDay,
      'ÖÖ' => l.slotMorning,
      'ÖS' => l.slotAfternoon,
      _ => v,
    };

/// `matches.court` holds 'Belirtilmedi' when no court was chosen.
String courtDisplay(AppLocalizations l, String court) =>
    court == 'Belirtilmedi' ? l.courtUnspecified : court;

String timeLabel(AppLocalizations l, String v) => switch (v) {
      'Sabah' => l.timeMorning,
      'Öğleden Sonra' => l.timeAfternoon,
      'Akşam' => l.timeEvening,
      _ => v,
    };

String courtThemeLabel(AppLocalizations l, CourtTheme t) => switch (t) {
      CourtTheme.clay => l.courtThemeClay,
      CourtTheme.hard => l.courtThemeHard,
      CourtTheme.grass => l.courtThemeGrass,
    };
