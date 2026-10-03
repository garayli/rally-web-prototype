import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';
import '../main.dart' show CourtThemeProvider;
import '../screens/log_result_screen.dart';
import '../screens/player_profile_screen.dart';
import '../l10n/l10n.dart';
import '../l10n/option_labels.dart';
import 'shared_widgets.dart';

/// Localized status text for a session, aware of who sent a pending request.
String sessionStatusLabel(AppLocalizations l, MatchSession s) {
  switch (s.status) {
    case MatchStatus.confirmed:
      return l.statusConfirmed;
    case MatchStatus.completed:
      return l.statusCompleted;
    case MatchStatus.cancelled:
      return l.statusCancelled;
    case MatchStatus.pending:
      return s.isRequester ? l.requestSentLabel : l.requestIncomingLabel;
  }
}

/// Details of one of the signed-in user's matches. Every match card in the app
/// (Match tab rail, Games list, Profile tabs) opens this.
void showMatchDetailSheet(BuildContext context, MatchSession session) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) =>
        _MatchDetailSheet(session: session, cp: CourtThemeProvider.of(context)),
  );
}

class _MatchDetailSheet extends StatelessWidget {
  final MatchSession session;
  final CourtPalette cp;

  const _MatchDetailSheet({required this.session, required this.cp});

  Widget _row(IconData icon, String label) => Padding(
    padding: const EdgeInsets.only(bottom: Spacing.md),
    child: Row(
      children: [
        Icon(icon, size: 18, color: cp.muted),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: Text(label, style: RallyType.body.copyWith(color: cp.text)),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final dt = session.dateTime;
    final opponent = session.opponent;
    final sets = session.setsForMe();
    final isGuest = opponent.id.startsWith('guest:');
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: cp.bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(RallyRadius.sheet)),
        ),
        padding: const EdgeInsets.fromLTRB(
          Spacing.xl, Spacing.lg, Spacing.xl, Spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: cp.muted2,
                  borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: Spacing.xl),
            GestureDetector(
              onTap: isGuest
                  ? null
                  : () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => PlayerProfileScreen(player: opponent)));
                    },
              child: Row(
                children: [
                  PlayerAvatar(
                    initials: opponent.initials,
                    gradientStart: opponent.avatarGradientStart,
                    gradientEnd: opponent.avatarGradientEnd,
                    size: 48,
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.l10n.vsOpponent(opponent.name),
                          style: RallyType.titleLG.copyWith(color: cp.text)),
                        const SizedBox(height: 2),
                        Text(sessionStatusLabel(context.l10n, session),
                          style: RallyType.bodySM.copyWith(color: cp.accentStrong)),
                      ],
                    ),
                  ),
                  if (!isGuest) Icon(Icons.chevron_right, color: cp.muted),
                ],
              ),
            ),
            const SizedBox(height: Spacing.xl),
            _row(Icons.calendar_today_outlined, DateFormat('EEEE, d MMMM', context.localeName).format(dt)),
            _row(Icons.access_time, DateFormat('HH:mm', context.localeName).format(dt)),
            _row(Icons.place_outlined, courtDisplay(context.l10n, session.court)),
            _row(Icons.sports_tennis_outlined,
              session.format == MatchFormat.doubles
                  ? context.l10n.formatDoubles
                  : context.l10n.formatSingles),
            if (sets.isNotEmpty) ...[
              const SizedBox(height: Spacing.sm),
              _row(Icons.emoji_events_outlined,
                sets.map((s) => '${s.player1}-${s.player2}').join(', ')),
            ],
            if (session.isIncomingRequest)
              Text(context.l10n.matchDetailRespondHint,
                  style: RallyType.bodySM.copyWith(color: cp.text2)),
            if (session.status == MatchStatus.confirmed) ...[
              const SizedBox(height: Spacing.md),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: cp.accent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(RallyRadius.pill)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => LogResultScreen(opponent: opponent)));
                  },
                  child: Text(context.l10n.logResult,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
