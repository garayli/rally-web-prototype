import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../models/models.dart';
import '../services/data_service.dart';
import 'create_game_screen.dart';
import 'log_result_screen.dart';
import 'player_profile_screen.dart';
import '../l10n/l10n.dart';
import '../l10n/option_labels.dart';

class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      backgroundColor: RallyColors.bg,
      appBar: AppBar(
        title: Text(l.gamesTitle, style: const TextStyle(fontFamily: 'InstrumentSerif', fontSize: 22)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: RallyColors.accent,
          unselectedLabelColor: RallyColors.muted,
          indicatorColor: RallyColors.accent,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: [Tab(text: l.tabUpcoming), Tab(text: l.tabPast)],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateGameScreen()),
        ),
        backgroundColor: RallyColors.accent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(l.newMatch, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _UpcomingTab(),
          _PastTab(),
        ],
      ),
    );
  }
}

// ─── Upcoming tab ─────────────────────────────────────────────────────────────
class _UpcomingTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: dataService.cacheVersion,
      builder: (context, _, __) {
        final sessions = dataService.getUpcomingSessions();
        if (sessions.isEmpty) {
          return _EmptyGames(
            icon: '📅',
            title: context.l10n.emptyUpcoming,
            subtitle: context.l10n.emptyUpcomingHint,
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          itemCount: sessions.length,
          itemBuilder: (context, i) => _UpcomingCard(
            session: sessions[i],
          ).animate().fadeIn(delay: (i * 60).ms),
        );
      },
    );
  }
}

class _UpcomingCard extends StatelessWidget {
  final MatchSession session;
  const _UpcomingCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final isConfirmed = session.status == MatchStatus.confirmed;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: RallyColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: RallyColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => PlayerProfileScreen(player: session.opponent),
                  )),
                  child: PlayerAvatar(
                    initials: session.opponent.initials,
                    gradientStart: session.opponent.avatarGradientStart,
                    gradientEnd: session.opponent.avatarGradientEnd,
                    size: 50,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.vsOpponent(session.opponent.name),
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${DateFormat('EEE, MMM d', context.localeName).format(session.dateTime)} · ${DateFormat.jm(context.localeName).format(session.dateTime)}',
                        style: const TextStyle(fontSize: 12, color: RallyColors.muted),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        courtDisplay(context.l10n, session.court),
                        style: const TextStyle(fontSize: 12, color: RallyColors.muted),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isConfirmed ? RallyColors.accentLight : RallyColors.accent2Light,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    isConfirmed ? context.l10n.statusConfirmed : context.l10n.statusPending,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isConfirmed ? RallyColors.accent : RallyColors.accent2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isConfirmed) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => LogResultScreen(opponent: session.opponent),
                      )),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          color: RallyColors.accent,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Center(
                          child: Text(context.l10n.logResult, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: RallyColors.border2, width: 1.5),
                      ),
                      child: Center(
                        child: Text(context.l10n.message, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Past tab ─────────────────────────────────────────────────────────────────
class _PastTab extends StatelessWidget {
  static final List<Map<String, dynamic>> _pastGames = () {
    final players = dataService.getPlayers();
    return [
      {
        'opponent': players[0],
        'date': DateTime.now().subtract(const Duration(days: 5)),
        'court': 'Beşiktaş JK Tenis Kortları',
        'won': true,
        'score': '6-4, 7-5',
      },
      {
        'opponent': players[2],
        'date': DateTime.now().subtract(const Duration(days: 12)),
        'court': 'Galatasaray Tenis Kulübü',
        'won': false,
        'score': '4-6, 5-7',
      },
      {
        'opponent': players[3],
        'date': DateTime.now().subtract(const Duration(days: 20)),
        'court': 'Acıbadem Tenis Kulübü',
        'won': true,
        'score': '6-2, 6-3',
      },
    ];
  }();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      itemCount: _pastGames.length,
      itemBuilder: (context, i) {
        final g = _pastGames[i];
        final won = g['won'] as bool;
        final player = g['opponent'] as Player;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: RallyColors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: RallyColors.border),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => PlayerProfileScreen(player: player),
                )),
                child: PlayerAvatar(
                  initials: player.initials,
                  gradientStart: player.avatarGradientStart,
                  gradientEnd: player.avatarGradientEnd,
                  size: 50,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.l10n.vsOpponent(player.name), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15), overflow: TextOverflow.ellipsis, maxLines: 1),
                    Text(DateFormat('EEE, MMM d', context.localeName).format(g['date'] as DateTime), style: const TextStyle(fontSize: 12, color: RallyColors.muted), overflow: TextOverflow.ellipsis, maxLines: 1),
                    Text(g['court'] as String, style: const TextStyle(fontSize: 12, color: RallyColors.muted), overflow: TextOverflow.ellipsis, maxLines: 1),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: won ? RallyColors.accentLight : RallyColors.accent2Light,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      won ? context.l10n.resultWon : context.l10n.resultLost,
                      style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700,
                        color: won ? RallyColors.accent : RallyColors.accent2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(g['score'] as String, style: const TextStyle(fontFamily: 'InstrumentSerif', fontSize: 15, letterSpacing: -0.5)),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(delay: (i * 60).ms);
      },
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────
class _EmptyGames extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;

  const _EmptyGames({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 14),
            Text(title, style: const TextStyle(fontFamily: 'InstrumentSerif', fontSize: 22)),
            const SizedBox(height: 6),
            Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: RallyColors.muted, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
