import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/match_request_sheet.dart';
import '../models/models.dart';
import '../services/data_service.dart';
import '../main.dart' show supabase, CourtThemeProvider;
import 'player_profile_screen.dart';
import 'map_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'open_lobby_screen.dart';
import 'games_screen.dart';
import '../widgets/match_detail_sheet.dart';
import '../l10n/data_error_message.dart';
import '../l10n/l10n.dart';
import '../l10n/option_labels.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  String _filter = 'Tümü';
  String _sortBy = 'Mesafe';
  String _searchQuery = '';
  final _searchController = TextEditingController();
  final _sentRequests = <String>{};
  List<Map<String, dynamic>> _lobbies = [];
  bool _lobbiesLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLobbies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLobbies() async {
    try {
      final data = await supabase
          .from('lobbies')
          .select()
          .eq('is_public', true)
          .eq('status', 'open')
          .order('date_time');
      if (mounted) {
        setState(() {
          _lobbies = List<Map<String, dynamic>>.from(data);
          _lobbiesLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _lobbiesLoading = false);
    }
  }

  List<Player> get _filteredPlayers {
    var list = _filter == 'Tümü'
        ? dataService.getPlayers()
        : dataService.getPlayers().where((p) => p.skillLabel == _filter).toList();
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where((p) =>
              p.name.toLowerCase().contains(q) ||
              p.location.toLowerCase().contains(q))
          .toList();
    }
    switch (_sortBy) {
      case 'NTRP':
        list.sort((a, b) => b.ntrpRating.compareTo(a.ntrpRating));
      case 'Galibiyet':
        list.sort((a, b) => b.winRate.compareTo(a.winRate));
      default:
        break;
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: dataService.cacheVersion,
      builder: (context, _, __) => _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    final cp = CourtThemeProvider.of(context);
    final l = context.l10n;
    final me = dataService.getCurrentPlayer();
    final upcoming = dataService
        .getUpcomingSessions()
        .where((s) => s.isUpcoming)
        .take(5)
        .toList();
    final players = _filteredPlayers;

    return Scaffold(
      backgroundColor: cp.bg,
      body: CustomScrollView(
        slivers: [
          // ── App bar ──────────────────────────────────────────────────────
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: cp.bg.withValues(alpha: 0.96),
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: _Wordmark(cp: cp),
            actions: [
              ValueListenableBuilder<int>(
                valueListenable: dataService.unreadNotifier,
                builder: (context, count, _) => Stack(
                  children: [
                    IconButton(
                      icon: Icon(Icons.notifications_outlined, color: cp.text),
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => const NotificationsScreen())),
                    ),
                    Positioned(
                        top: 8, right: 8, child: NotifBadge(count: count)),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                borderRadius: BorderRadius.circular(17),
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen())),
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: PlayerAvatar(
                    initials: me?.initials ?? '?',
                    gradientStart: me?.avatarGradientStart ?? '#7b4fa6',
                    gradientEnd: me?.avatarGradientEnd ?? '#a97fcb',
                    size: 34,
                  ),
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Divider(height: 1, color: cp.border),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Search bar ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      Spacing.gutter, Spacing.lg, Spacing.gutter, Spacing.sm),
                  child: _SearchBar(
                    cp: cp,
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v.trim()),
                  ),
                ),

                // ── Sıralama + Filtre buttons ──────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      Spacing.gutter, 0, Spacing.gutter, Spacing.lg),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ActionChip(
                          icon: Icons.swap_vert,
                          label: l.sort,
                          active: _sortBy != 'Mesafe',
                          cp: cp,
                          onTap: () => _showSortSheet(context, cp),
                        ),
                      ),
                      const SizedBox(width: Spacing.sm),
                      Expanded(
                        child: _ActionChip(
                          icon: Icons.tune,
                          label: l.filter,
                          active: _filter != 'Tümü',
                          cp: cp,
                          onTap: () => _showFilterSheet(context, cp),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Upcoming matches rail ──────────────────────────────────
                if (upcoming.isNotEmpty) ...[
                  _SectionHeader(
                    cp: cp,
                    title: l.upcomingMatchesHeader,
                    action: l.seeAll,
                    onAction: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const GamesScreen())),
                  ),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(
                          Spacing.gutter, 0, Spacing.gutter, Spacing.sm),
                      itemCount: upcoming.length,
                      itemBuilder: (context, i) =>
                          _UpcomingCard(session: upcoming[i], cp: cp),
                    ),
                  ),
                ],

                // ── Players header ─────────────────────────────────────────
                _SectionHeader(
                  cp: cp,
                  title: l.nearbyPlayersHeader(players.length),
                  action: l.map,
                  onAction: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const MapScreen())),
                ),
              ],
            ),
          ),

          // ── Player list ────────────────────────────────────────────────
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final player = players[i];
                return _PlayerCardV2(
                  player: player,
                  cp: cp,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => PlayerProfileScreen(player: player))),
                  onRequest: () => _showRequestSheet(context, player),
                ).animate()
                  .fadeIn(delay: (i * 50).ms)
                  .slideY(begin: 0.08, end: 0, delay: (i * 50).ms);
              },
              childCount: players.length,
            ),
          ),

          // ── Open lobbies rail ──────────────────────────────────────────
          if (!_lobbiesLoading && _lobbies.isNotEmpty)
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(
                    cp: cp,
                    title: l.openLobbiesHeader,
                    action: l.createLobby,
                    onAction: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => const OpenLobbyScreen()))
                        .then((_) => _loadLobbies()),
                  ),
                  SizedBox(
                    height: 172,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(
                          Spacing.gutter, 0, Spacing.gutter, Spacing.sm),
                      itemCount: _lobbies.length,
                      itemBuilder: (context, i) =>
                          _LobbyCard(lobby: _lobbies[i], cp: cp),
                    ),
                  ),
                ],
              ),
            ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context, CourtPalette cp) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(
        cp: cp,
        currentFilter: _filter,
        onApply: (f) => setState(() => _filter = f),
      ),
    );
  }

  void _showSortSheet(BuildContext context, CourtPalette cp) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SortSheet(
        cp: cp,
        currentSort: _sortBy,
        onApply: (s) => setState(() => _sortBy = s),
      ),
    );
  }

  void _showRequestSheet(BuildContext context, Player player) {
    showMatchRequestSheet(
      context,
      player,
      alreadySent: _sentRequests.contains(player.id),
      onSent: () => setState(() => _sentRequests.add(player.id)),
    );
  }
}

// ─── Wordmark ─────────────────────────────────────────────────────────────────
class _Wordmark extends StatelessWidget {
  final CourtPalette cp;
  const _Wordmark({required this.cp});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(children: [
        TextSpan(
          text: 'Rall',
          style: TextStyle(
              fontFamily: 'InstrumentSerif', fontSize: 24, color: cp.accent)),
        TextSpan(
          text: 'l',
          style: TextStyle(
              fontFamily: 'InstrumentSerif',
              fontSize: 24,
              color: cp.text,
              fontStyle: FontStyle.italic)),
        TextSpan(
          text: 'y',
          style: TextStyle(
              fontFamily: 'InstrumentSerif', fontSize: 24, color: cp.accent)),
      ]),
    );
  }
}

// ─── Search bar (StatefulWidget for focus-controlled border) ──────────────────
class _SearchBar extends StatefulWidget {
  final CourtPalette cp;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({
    required this.cp,
    required this.controller,
    required this.onChanged,
  });

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus != _focused) {
        setState(() => _focused = _focusNode.hasFocus);
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cp = widget.cp;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cp.surface,
        borderRadius: BorderRadius.circular(RallyRadius.xl),
        border: Border.all(
          color: _focused ? cp.accent : cp.border2,
          width: _focused ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.search,
              size: 20, color: _focused ? cp.accent : cp.muted),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              onChanged: widget.onChanged,
              style: RallyType.body.copyWith(color: cp.text),
              decoration: InputDecoration(
                hintText: context.l10n.searchNameOrLocation,
                hintStyle: RallyType.body.copyWith(color: cp.muted2),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (widget.controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                widget.controller.clear();
                widget.onChanged('');
              },
              child: Icon(Icons.close, size: 18, color: cp.muted),
            ),
        ],
      ),
    );
  }
}

// ─── Action chip (Sıralama / Filtre) ─────────────────────────────────────────
class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final CourtPalette cp;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.active,
    required this.cp,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? cp.accent : cp.surface,
          borderRadius: BorderRadius.circular(RallyRadius.pill),
          border: Border.all(color: active ? cp.accent : cp.border2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: active ? Colors.white : cp.text2),
            const SizedBox(width: 6),
            Text(
              label,
              style: RallyType.bodySM.copyWith(
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : cp.text2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final CourtPalette cp;
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const _SectionHeader({
    required this.cp,
    required this.title,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Spacing.gutter, Spacing.xl, Spacing.gutter, Spacing.sm),
      child: Row(
        children: [
          Text(title,
              style: RallyType.eyebrow
                  .copyWith(color: cp.muted, letterSpacing: 1.4)),
          const Spacer(),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(action!,
                  style: RallyType.caption.copyWith(
                      color: cp.accent, fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }
}

// ─── V2 Player card ───────────────────────────────────────────────────────────
class _PlayerCardV2 extends StatelessWidget {
  final Player player;
  final CourtPalette cp;
  final VoidCallback onTap;
  final VoidCallback onRequest;

  const _PlayerCardV2({
    required this.player,
    required this.cp,
    required this.onTap,
    required this.onRequest,
  });

  @override
  Widget build(BuildContext context) {
    final availability = player.availability.take(3).toList();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(
            Spacing.gutter, 0, Spacing.gutter, Spacing.sm),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cp.surface,
          borderRadius: BorderRadius.circular(RallyRadius.xl),
          border: Border.all(color: cp.border),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0A000000), blurRadius: 14, offset: Offset(0, 4))
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PlayerAvatar(
              initials: player.initials,
              gradientStart: player.avatarGradientStart,
              gradientEnd: player.avatarGradientEnd,
              size: 52,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + skill + NTRP
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          player.name,
                          style: RallyType.titleMD.copyWith(color: cp.text),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: cp.skillBg,
                          borderRadius:
                              BorderRadius.circular(RallyRadius.pill),
                        ),
                        child: Text(
                          _abbrevSkill(context.l10n, player.skillLabel),
                          style: RallyType.micro.copyWith(color: cp.skillFg),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'NTRP ${player.ntrpRating.toStringAsFixed(1)}',
                        style: RallyType.micro.copyWith(
                            color: cp.text2, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Location
                  Row(children: [
                    Icon(Icons.location_on_outlined,
                        size: 12, color: cp.muted),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        player.location,
                        style: RallyType.bodySM.copyWith(color: cp.muted),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 4),
                  // Stats
                  Row(children: [
                    Icon(Icons.emoji_events_outlined,
                        size: 12, color: cp.accent),
                    const SizedBox(width: 3),
                    Text(
                      context.l10n.winRatePercent(player.winRate.round()),
                      style: RallyType.bodySM.copyWith(
                          color: cp.text2, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      context.l10n.matchesCount(player.matchesPlayed),
                      style: RallyType.bodySM.copyWith(color: cp.muted),
                    ),
                  ]),
                  // Availability
                  if (availability.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: availability
                          .map((slot) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: cp.accentTint,
                                  borderRadius: BorderRadius.circular(
                                      RallyRadius.pill),
                                ),
                                child: Text(
                                  availabilitySlotLabel(context.l10n, slot),
                                  style: RallyType.micro.copyWith(
                                      color: cp.accentStrong, fontSize: 10),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 10),
                  // Maç İste button
                  GestureDetector(
                    onTap: onRequest,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: cp.accent,
                        borderRadius:
                            BorderRadius.circular(RallyRadius.pill),
                      ),
                      child: Text(
                        context.l10n.requestMatch,
                        style: RallyType.micro.copyWith(
                            color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _abbrevSkill(AppLocalizations l, String skill) {
    switch (skill) {
      case 'Başlangıç':
        return l.skillShortBeginner.toUpperCase();
      case 'Orta Seviye':
        return l.skillShortIntermediate.toUpperCase();
      case 'İleri Seviye':
        return l.skillShortAdvanced.toUpperCase();
      case 'Uzman':
        return l.skillShortExpert.toUpperCase();
      default:
        return skill.toUpperCase();
    }
  }
}

// ─── Upcoming match card ──────────────────────────────────────────────────────
class _UpcomingCard extends StatelessWidget {
  final MatchSession session;
  final CourtPalette cp;
  const _UpcomingCard({required this.session, required this.cp});

  @override
  Widget build(BuildContext context) {
    final dt = session.dateTime;
    final dayStr = DateFormat('EEE', context.localeName).format(dt).toUpperCase();
    final timeStr = DateFormat('HH:mm', context.localeName).format(dt);

    return GestureDetector(
      onTap: () => showMatchDetailSheet(context, session),
      child: Container(
      width: 160,
      margin: const EdgeInsets.only(right: Spacing.sm),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cp.surface,
        borderRadius: BorderRadius.circular(RallyRadius.xl),
        border: Border.all(color: cp.border),
        boxShadow: RallyElevation.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: cp.accentTint,
              borderRadius: BorderRadius.circular(RallyRadius.pill),
            ),
            child: Text(context.l10n.tennisBadge,
                style: RallyType.micro
                    .copyWith(color: cp.accentStrong, letterSpacing: 0.4)),
          ),
          const SizedBox(height: Spacing.sm),
          Text('$dayStr $timeStr',
              style: RallyType.displaySM.copyWith(color: cp.text)),
          const SizedBox(height: 2),
          Text(context.l10n.vsOpponent(session.opponent.name),
              style: RallyType.bodySM
                  .copyWith(color: cp.text2, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis),
          if (session.status == MatchStatus.pending)
            Text(sessionStatusLabel(context.l10n, session),
                style: RallyType.micro.copyWith(color: cp.accentStrong),
                overflow: TextOverflow.ellipsis),
        ],
      ),
    ),
    );
  }
}

// ─── Sort sheet ───────────────────────────────────────────────────────────────
class _SortSheet extends StatefulWidget {
  final CourtPalette cp;
  final String currentSort;
  final ValueChanged<String> onApply;
  const _SortSheet(
      {required this.cp, required this.currentSort, required this.onApply});

  @override
  State<_SortSheet> createState() => _SortSheetState();
}

class _SortSheetState extends State<_SortSheet> {
  late String _sort;
  static const _options = ['Mesafe', 'NTRP', 'Galibiyet'];

  static String _label(AppLocalizations l, String opt) => switch (opt) {
        'Mesafe' => l.sortDistance,
        'Galibiyet' => l.sortWins,
        _ => opt,
      };

  @override
  void initState() {
    super.initState();
    _sort = widget.currentSort;
  }

  @override
  Widget build(BuildContext context) {
    final cp = widget.cp;
    return Container(
      decoration: BoxDecoration(color: cp.bg, borderRadius: RR.sheetTop),
      padding: EdgeInsets.fromLTRB(
          24,
          12,
          24,
          MediaQuery.of(context).viewInsets.bottom +
              MediaQuery.of(context).padding.bottom +
              28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: cp.muted2, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Text(context.l10n.sort,
              style: RallyType.displaySM.copyWith(color: cp.text)),
          const SizedBox(height: 4),
          Text(context.l10n.sortSheetSubtitle,
              style: RallyType.bodySM.copyWith(color: cp.text2)),
          const SizedBox(height: 20),
          ..._options.map((opt) {
            final active = _sort == opt;
            return GestureDetector(
              onTap: () => setState(() => _sort = opt),
              child: Container(
                margin: const EdgeInsets.only(bottom: Spacing.sm),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: active ? cp.accentTint : cp.surface,
                  borderRadius: BorderRadius.circular(RallyRadius.lg),
                  border: Border.all(
                    color: active ? cp.accent : cp.border,
                    width: active ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(_label(context.l10n, opt),
                        style: RallyType.titleMD.copyWith(
                            color: active ? cp.accentStrong : cp.text)),
                    const Spacer(),
                    if (active)
                      Icon(Icons.check_circle, color: cp.accent, size: 20),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                widget.onApply(_sort);
                Navigator.pop(context);
              },
              style: FilledButton.styleFrom(
                backgroundColor: cp.accent,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(context.l10n.apply),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Filter sheet ─────────────────────────────────────────────────────────────
class _FilterSheet extends StatefulWidget {
  final CourtPalette cp;
  final String currentFilter;
  final ValueChanged<String> onApply;
  const _FilterSheet(
      {required this.cp, required this.currentFilter, required this.onApply});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String _skill;
  String _distance = '5 km';

  // Values are the canonical skill labels used to filter players.
  static const _skills = ['Tümü', 'Başlangıç', 'Orta Seviye', 'İleri Seviye'];

  static String _skillChip(AppLocalizations l, String v) => switch (v) {
        'Tümü' => l.all,
        'Başlangıç' => l.skillShortBeginner,
        'Orta Seviye' => l.skillShortIntermediate,
        'İleri Seviye' => l.skillShortAdvanced,
        _ => v,
      };
  static const _distances = ['1 km', '3 km', '5 km', '10 km'];

  @override
  void initState() {
    super.initState();
    _skill = widget.currentFilter;
  }

  @override
  Widget build(BuildContext context) {
    final cp = widget.cp;
    return Container(
      decoration: BoxDecoration(color: cp.bg, borderRadius: RR.sheetTop),
      padding: EdgeInsets.fromLTRB(
          24,
          12,
          24,
          MediaQuery.of(context).viewInsets.bottom +
              MediaQuery.of(context).padding.bottom +
              28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: cp.muted2, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(context.l10n.filterTitle,
                  style: RallyType.displaySM.copyWith(color: cp.text)),
              const Spacer(),
              GestureDetector(
                onTap: () =>
                    setState(() { _skill = 'Tümü'; _distance = '5 km'; }),
                child: Text(context.l10n.clear,
                    style: RallyType.bodySM.copyWith(
                        color: cp.accent, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(context.l10n.level, style: RallyType.titleSM.copyWith(color: cp.text)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: cp.surfaceSoft,
              borderRadius: BorderRadius.circular(RallyRadius.md),
            ),
            child: Row(
              children: _skills.map((value) {
                final active = _skill == value;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _skill = value),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: active ? cp.surface : Colors.transparent,
                        borderRadius: BorderRadius.circular(RallyRadius.sm),
                        boxShadow: active ? RallyElevation.hairline : null,
                      ),
                      child: Text(
                        _skillChip(context.l10n, value),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: active ? cp.text : cp.text2,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          Text(context.l10n.distance, style: RallyType.titleSM.copyWith(color: cp.text)),
          const SizedBox(height: 10),
          Row(
            children: _distances.map((d) {
              final active = _distance == d;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _distance = d),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: active ? cp.accent : cp.surface,
                        borderRadius: BorderRadius.circular(RallyRadius.md),
                        border: Border.all(
                            color: active ? cp.accent : cp.border),
                      ),
                      child: Text(
                        d,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: active ? Colors.white : cp.text2,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                widget.onApply(_skill);
                Navigator.pop(context);
              },
              style: FilledButton.styleFrom(
                backgroundColor: cp.accent,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(context.l10n.apply),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Open lobby card ──────────────────────────────────────────────────────────
class _LobbyCard extends StatefulWidget {
  final Map<String, dynamic> lobby;
  final CourtPalette cp;
  const _LobbyCard({required this.lobby, required this.cp});

  @override
  State<_LobbyCard> createState() => _LobbyCardState();
}

class _LobbyCardState extends State<_LobbyCard> {
  bool _joined = false;
  bool _joining = false;

  Map<String, dynamic> get lobby => widget.lobby;
  CourtPalette get cp => widget.cp;

  bool get _isMine => lobby['creator_id'] == dataService.currentUserId;

  Future<void> _join(DateTime dt, String sport, String court) async {
    final l = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _joining = true);
    try {
      await dataService.joinLobby(
        creatorId: lobby['creator_id'] as String,
        dateTime: dt,
        court: court,
        sport: sportLabel(l, sport),
      );
      if (!mounted) return;
      setState(() {
        _joined = true;
        _joining = false;
      });
      messenger.showSnackBar(SnackBar(
        content: Text(l.lobbyJoinSent(sportLabel(l, sport))),
        backgroundColor: RallyColors.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    } catch (e) {
      debugPrint('LOBBY JOIN ERROR: $e');
      if (!mounted) return;
      final already = e is DataException && e.error == DataError.alreadyRequested;
      setState(() {
        _joined = already;
        _joining = false;
      });
      messenger.showSnackBar(SnackBar(
        content: Text(l.actionFailed(dataErrorMessage(l, e))),
        backgroundColor: RallyColors.accent2,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  static const _sportEmojis = {
    'Tenis': '🎾',
    'Padel': '🏓',
    'Badminton': '🏸',
    'Squash': '🟡',
  };

  @override
  Widget build(BuildContext context) {
    final dt =
        DateTime.tryParse(lobby['date_time'] as String? ?? '')?.toLocal();
    final sport = lobby['sport'] as String? ?? 'Tenis';
    final court = lobby['court'] as String? ?? '';
    final skill = lobby['skill_level'] as String? ?? '';

    return Container(
      width: 178,
      margin: const EdgeInsets.only(right: Spacing.sm),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cp.surface,
        borderRadius: BorderRadius.circular(RallyRadius.xl),
        border: Border.all(color: cp.border),
        boxShadow: RallyElevation.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            Text(_sportEmojis[sport] ?? '🎾',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(sportLabel(context.l10n, sport),
                  style: RallyType.titleSM.copyWith(color: cp.text),
                  overflow: TextOverflow.ellipsis),
            ),
          ]),
          const SizedBox(height: 6),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: cp.accentTint,
              borderRadius: BorderRadius.circular(RallyRadius.pill),
            ),
            child: Text(skillLevelLabel(context.l10n, skill),
                style: RallyType.micro.copyWith(color: cp.accentStrong)),
          ),
          const SizedBox(height: 8),
          Text(court,
              style: RallyType.bodySM.copyWith(color: cp.muted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          if (dt != null) ...[
            const SizedBox(height: 3),
            Text(DateFormat('EEE d MMM, HH:mm', context.localeName).format(dt),
                style: RallyType.caption
                    .copyWith(fontWeight: FontWeight.w600, color: cp.text)),
          ],
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              // Own lobby, already-sent and in-flight requests can't be tapped.
              onPressed: (_isMine || _joined || _joining || dt == null)
                  ? null
                  : () => _join(dt, sport, court),
              style: FilledButton.styleFrom(
                backgroundColor: cp.accent,
                minimumSize: const Size(0, 32),
                maximumSize: const Size(double.infinity, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.zero,
                textStyle: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600),
              ),
              child: Text(_isMine
                  ? context.l10n.lobbyYours
                  : _joined
                      ? context.l10n.lobbyRequested
                      : context.l10n.join),
            ),
          ),
        ],
      ),
    );
  }
}
