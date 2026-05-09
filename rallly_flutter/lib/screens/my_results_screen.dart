import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../models/models.dart';
import '../services/data_service.dart';
import 'player_profile_screen.dart';

class MyResultsScreen extends StatelessWidget {
  const MyResultsScreen({super.key});

  static final List<_PastMatch> _results = () {
    final players = dataService.getPlayers();
    return [
      _PastMatch(
        opponent: players[0],
        date: DateTime.now().subtract(const Duration(days: 5)),
        court: 'Beşiktaş JK Tenis Kortları',
        won: true,
        sets: const [SetScore(6, 4), SetScore(7, 5)],
        ratingDelta: 12,
      ),
      _PastMatch(
        opponent: players[2],
        date: DateTime.now().subtract(const Duration(days: 12)),
        court: 'Galatasaray Tenis Kulübü',
        won: false,
        sets: const [SetScore(4, 6), SetScore(5, 7)],
        ratingDelta: -8,
      ),
      _PastMatch(
        opponent: players[3],
        date: DateTime.now().subtract(const Duration(days: 20)),
        court: 'Acıbadem Tenis Kulübü',
        won: true,
        sets: const [SetScore(6, 2), SetScore(6, 3)],
        ratingDelta: 15,
      ),
      _PastMatch(
        opponent: players[1],
        date: DateTime.now().subtract(const Duration(days: 34)),
        court: 'Caddebostan Tenis Kortları',
        won: true,
        sets: const [SetScore(7, 5), SetScore(4, 6), SetScore(10, 8)],
        ratingDelta: 18,
      ),
      _PastMatch(
        opponent: players[0],
        date: DateTime.now().subtract(const Duration(days: 48)),
        court: 'Levent Tenis Kulübü',
        won: false,
        sets: const [SetScore(3, 6), SetScore(6, 4), SetScore(5, 7)],
        ratingDelta: -10,
      ),
    ];
  }();

  int get _wins => _results.where((r) => r.won).length;
  int get _losses => _results.where((r) => !r.won).length;
  int get _totalPoints => _results.fold(0, (s, r) => s + r.ratingDelta);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RallyColors.bg,
      appBar: AppBar(
        title: const Text('Sonuçlarım', style: TextStyle(fontFamily: 'InstrumentSerif', fontSize: 22)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: CustomScrollView(
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
                  _Stat(label: 'GALİBİYET', value: '$_wins', light: true),
                  Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.25)),
                  _Stat(label: 'MAĞLUBIYET', value: '$_losses', light: true),
                  Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.25)),
                  _Stat(
                    label: 'PUAN',
                    value: '${_totalPoints > 0 ? '+' : ''}$_totalPoints',
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
                (context, i) => _ResultCard(match: _results[i]).animate().fadeIn(delay: (i * 60).ms),
                childCount: _results.length,
              ),
            ),
          ),
        ],
      ),
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
                    DateFormat('d MMM y').format(match.date),
                    style: const TextStyle(fontSize: 12, color: RallyColors.muted),
                  ),
                  Text(
                    match.court,
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
                    match.won ? 'Kazandı' : 'Kaybetti',
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
                  '${match.ratingDelta > 0 ? '+' : ''}${match.ratingDelta} puan',
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
