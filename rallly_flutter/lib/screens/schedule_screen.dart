import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../models/models.dart';
import '../services/data_service.dart';
import 'games_screen.dart';
import 'create_game_screen.dart';
import 'match_screen.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late DateTime _selectedDay;
  late List<DateTime> _days;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    final today = DateTime.now();
    _days = List.generate(14, (i) => today.add(Duration(days: i - 2)));
  }

  List<MatchSession> get _sessionsForDay =>
      dataService.getUpcomingSessions().where((s) {
        final d = s.dateTime;
        return d.year == _selectedDay.year &&
            d.month == _selectedDay.month &&
            d.day == _selectedDay.day;
      }).toList();

  bool _hasEvent(DateTime day) => dataService.getUpcomingSessions().any((s) {
        final d = s.dateTime;
        return d.year == day.year &&
            d.month == day.month &&
            d.day == day.day;
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RallyColors.bg,
      body: CustomScrollView(
        slivers: [
          // ── App bar ────────────────────────────────────────────────────────
          SliverAppBar(
            floating: true,
            snap: true,
            title: const Text('Schedule',
                style: TextStyle(
                    fontFamily: 'InstrumentSerif', fontSize: 22)),
            actions: [
              TextButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GamesScreen()),
                ),
                icon: const Icon(Icons.sports_tennis, size: 16),
                label: const Text('Games', style: TextStyle(fontWeight: FontWeight.w700)),
                style: TextButton.styleFrom(foregroundColor: RallyColors.accent),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateGameScreen()),
                ),
              ),
              const SizedBox(width: 8),
            ],
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(1),
              child: Divider(height: 1, color: RallyColors.border),
            ),
          ),

          // ── Month label ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
              child: Text(
                DateFormat('MMMM yyyy').format(_selectedDay),
                style: const TextStyle(
                  fontFamily: 'InstrumentSerif',
                  fontSize: 18,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),

          // ── Calendar strip ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: 84,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _days.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final day = _days[i];
                  final isActive = day.day == _selectedDay.day &&
                      day.month == _selectedDay.month;
                  final hasEvent = _hasEvent(day);

                  return GestureDetector(
                    onTap: () => setState(() => _selectedDay = day),
                    child: AnimatedContainer(
                      duration: 200.ms,
                      width: 50,
                      decoration: BoxDecoration(
                        color: isActive ? RallyColors.accent : RallyColors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isActive
                              ? RallyColors.accent
                              : RallyColors.border,
                        ),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: RallyColors.accent.withValues(alpha: 0.2),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('EEE').format(day).toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: isActive
                                  ? Colors.white70
                                  : RallyColors.muted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${day.day}',
                            style: TextStyle(
                              fontFamily: 'InstrumentSerif',
                              fontSize: 22,
                              color: isActive
                                  ? Colors.white
                                  : RallyColors.textPrimary,
                            ),
                          ),
                          if (hasEvent)
                            Container(
                              width: 4,
                              height: 4,
                              margin: const EdgeInsets.only(top: 3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isActive
                                    ? Colors.white70
                                    : RallyColors.accent2,
                              ),
                            )
                          else
                            const SizedBox(height: 7),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // ── Sessions or empty ──────────────────────────────────────────────
          if (_sessionsForDay.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  children: [
                    const Text('🎾', style: TextStyle(fontSize: 44)),
                    const SizedBox(height: 12),
                    const Text(
                      'No matches this day',
                      style: TextStyle(
                        fontFamily: 'InstrumentSerif',
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Find a new opponent or schedule a session',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: RallyColors.muted, fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    RallyButton(
                      label: 'Find a new match',
                      icon: Icons.search,
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const MatchScreen())),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => _SessionCard(
                  session: _sessionsForDay[i],
                ).animate().fadeIn(delay: (i * 80).ms),
                childCount: _sessionsForDay.length,
              ),
            ),

          // ── Find new match banner ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const MatchScreen())),
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [RallyColors.accent, RallyColors.accent3],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: RallyColors.accent.withValues(alpha: 0.18),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('🎾', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Find a new match',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '4 players available near you',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right,
                        color: Colors.white70, size: 22),
                  ],
                ),
              ),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }
}

// ─── Session card ─────────────────────────────────────────────────────────────
class _SessionCard extends StatelessWidget {
  final MatchSession session;

  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final isConfirmed = session.status == MatchStatus.confirmed;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RallyColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RallyColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Time
          SizedBox(
            width: 56,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('h:mm').format(session.dateTime),
                  style: const TextStyle(
                    fontFamily: 'InstrumentSerif',
                    fontSize: 20,
                    letterSpacing: -0.5,
                    height: 1,
                  ),
                ),
                Text(
                  DateFormat('a').format(session.dateTime),
                  style: const TextStyle(
                    fontSize: 11,
                    color: RallyColors.muted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 36,
            color: RallyColors.border,
            margin: const EdgeInsets.symmetric(horizontal: 14),
          ),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'vs ${session.opponent.name}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
                Text(
                  session.court,
                  style: const TextStyle(
                      fontSize: 12, color: RallyColors.muted),
                ),
              ],
            ),
          ),
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isConfirmed
                  ? RallyColors.accentLight
                  : RallyColors.accent2Light,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              isConfirmed ? 'Confirmed' : 'Pending',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isConfirmed
                    ? RallyColors.accent
                    : RallyColors.accent2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
