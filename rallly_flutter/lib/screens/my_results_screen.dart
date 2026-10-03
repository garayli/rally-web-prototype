import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../models/models.dart';
import '../services/data_service.dart';
import 'player_profile_screen.dart';
import '../l10n/l10n.dart';
import '../l10n/option_labels.dart';

class MyResultsScreen extends StatelessWidget {
  const MyResultsScreen({super.key});

  /// Completed matches that carry a score, newest first. Built from the live
  /// cache — never from a fixed player index, so any number of players works.
  static List<_PastMatch> _loadResults() {
    final me = dataService.currentUserId;
    final results = <_PastMatch>[
      for (final s in dataService.getUpcomingSessions())
        if (s.status == MatchStatus.completed && s.wonBy(me) != null)
          _PastMatch(
            opponent: s.opponent,
            date: s.dateTime,
            court: s.court,
            won: s.wonBy(me)!,
            sets: s.setsForMe(),
            ratingDelta: s.ratingDeltaForMe().round(),
          ),
    ]..sort((a, b) => b.date.compareTo(a.date));
    return results;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      backgroundColor: RallyColors.bg,
      appBar: AppBar(
        title: Text(l.myResults, style: const TextStyle(fontFamily: 'InstrumentSerif', fontSize: 22)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ValueListenableBuilder<int>(
        valueListenable: dataService.cacheVersion,
        builder: (context, _, __) => _body(context, _loadResults()),
      ),
    );
  }

  Widget _body(BuildContext context, List<_PastMatch> results) {
    final l = context.l10n;
    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🏆', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 14),
              Text(l.emptyPast, style: const TextStyle(fontFamily: 'InstrumentSerif', fontSize: 22)),
              const SizedBox(height: 6),
              Text(l.emptyPastHint, textAlign: TextAlign.center, style: const TextStyle(color: RallyColors.muted, fontSize: 14)),
            ],
          ),
        ),
      );
    }
    final wins = results.where((r) => r.won).length;
    final losses = results.length - wins;
    final totalPoints = results.fold(0, (sum, r) => sum + r.ratingDelta);
    return CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [RallyColors.accent, RallyColors.accent3],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: RallyColors.accent.withValues(alpha: 0.25), blurRadius: 20, offset: const Offset(0, 6))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _Stat(label: l.statWins, value: '$wins', light: true),
                  Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.25)),
                  _Stat(label: l.statLosses, value: '$losses', light: true),
                  Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.25)),
                  _Stat(
                    label: l.statRating,
                    value: '${totalPoints > 0 ? '+' : ''}$totalPoints',
                    light: true,
                  ),
                ],
              ),
            ).animate().fadeIn(),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 60),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => _ResultCard(match: results[i]).animate().fadeIn(delay: (i * 60).ms),
                childCount: results.length,
              ),
            ),
          ),
        ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final bool light;
  const _Stat({required this.label, required this.value, this.light = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: 'InstrumentSerif',
            fontSize: 34,
            color: light ? Colors.white : RallyColors.textPrimary,
            letterSpacing: -1,
            height: 1,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: light ? Colors.white70 : RallyColors.muted,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  final _PastMatch match;
  const _ResultCard({required this.match});

  @override
  Widget build(BuildContext context) {
    final scoreStr = match.sets.map((s) => '${s.player1}–${s.player2}').join(', ');
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PlayerProfileScreen(player: match.opponent)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: RallyColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: RallyColors.border),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Row(
          children: [
            PlayerAvatar(
              initials: match.opponent.initials,
              gradientStart: match.opponent.avatarGradientStart,
              gradientEnd: match.opponent.avatarGradientEnd,
              size: 48,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    match.opponent.name,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('d MMM y', context.localeName).format(match.date),
                    style: const TextStyle(fontSize: 12, color: RallyColors.muted),
                  ),
                  Text(
                    courtDisplay(context.l10n, match.court),
                    style: const TextStyle(fontSize: 12, color: RallyColors.muted),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: match.won ? RallyColors.accentLight : RallyColors.accent2Light,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    match.won ? context.l10n.resultWon : context.l10n.resultLost,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: match.won ? RallyColors.accent : RallyColors.accent2,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  scoreStr,
                  style: const TextStyle(fontFamily: 'InstrumentSerif', fontSize: 15, letterSpacing: -0.5),
                ),
                const SizedBox(height: 2),
                Text(
                  context.l10n.ratingPoints('${match.ratingDelta > 0 ? '+' : ''}${match.ratingDelta}'),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: match.ratingDelta > 0 ? RallyColors.accent : RallyColors.accent2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PastMatch {
  final Player opponent;
  final DateTime date;
  final String court;
  final bool won;
  final List<SetScore> sets;
  final int ratingDelta;

  const _PastMatch({
    required this.opponent,
    required this.date,
    required this.court,
    required this.won,
    required this.sets,
    required this.ratingDelta,
  });
}
