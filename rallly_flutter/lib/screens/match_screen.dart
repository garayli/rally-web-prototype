import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';
import '../widgets/shared_widgets.dart';
import '../models/models.dart';
import '../services/data_service.dart';
import '../main.dart' show supabase, CourtThemeProvider;
import 'player_profile_screen.dart';
import 'map_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'open_lobby_screen.dart';

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
    final cp = CourtThemeProvider.of(context);
    final upcoming = dataService.getUpcomingSessions().take(5).toList();
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
                child: const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: PlayerAvatar(
                    initials: 'LG',
                    gradientStart: '#7b4fa6',
                    gradientEnd: '#a97fcb',
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
                // ── Court hero ─────────────────────────────────────────────
                _CourtHero(cp: cp, playerCount: players.length),

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
                          label: 'Sıralama',
                          active: _sortBy != 'Mesafe',
                          cp: cp,
                          onTap: () => _showSortSheet(context, cp),
                        ),
                      ),
                      const SizedBox(width: Spacing.sm),
                      Expanded(
                        child: _ActionChip(
                          icon: Icons.tune,
                          label: 'Filtre',
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
                    title: 'YAKLAŞAN MAÇLAR',
                    action: 'Tümünü gör',
                    onAction: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const ProfileScreen())),
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
                  title: '${players.length} YAKINDA OYUNCU',
                  action: 'Harita',
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
                    title: 'AÇIK LOBİLER',
                    action: 'Lobi Oluştur',
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RequestSheet(
        player: player,
        alreadySent: _sentRequests.contains(player.id),
        onSent: () => setState(() => _sentRequests.add(player.id)),
      ),
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

// ─── Court hero strip ─────────────────────────────────────────────────────────
class _CourtHero extends StatelessWidget {
  final CourtPalette cp;
  final int playerCount;
  const _CourtHero({required this.cp, required this.playerCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
          Spacing.gutter, Spacing.lg, Spacing.gutter, 0),
      height: 128,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cp.gradA, cp.gradB],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
              color: cp.gradB.withValues(alpha: 0.30),
              blurRadius: 28,
              offset: const Offset(0, 12))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            Positioned(
              right: -22,
              top: -22,
              child: Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cp.highlight.withValues(alpha: 0.50)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('YAKINDAKI OYUNCULAR',
                      style: RallyType.eyebrow
                          .copyWith(color: Colors.white.withValues(alpha: 0.78))),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Rakip Bul',
                          style: RallyType.displayMD.copyWith(
                              color: Colors.white, letterSpacing: -1.2)),
                      const SizedBox(height: 4),
                      Text('$playerCount oyuncu sizi bekliyor',
                          style: RallyType.bodySM.copyWith(
                              color: Colors.white.withValues(alpha: 0.82))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
                hintText: 'İsim veya konum ara…',
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
                          _abbrevSkill(player.skillLabel),
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
                      '${player.winRate}% galibiyet',
                      style: RallyType.bodySM.copyWith(
                          color: cp.text2, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${player.matchesPlayed} maç',
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
                                  slot,
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
                        'Maç İste',
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

  String _abbrevSkill(String skill) {
    switch (skill) {
      case 'Başlangıç':
        return 'BAŞL.';
      case 'Orta Seviye':
        return 'ORTA';
      case 'İleri Seviye':
        return 'İLERİ';
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
    final dayStr = DateFormat('EEE').format(dt).toUpperCase();
    final timeStr = DateFormat('HH:mm').format(dt);

    return Container(
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
            child: Text('🎾 TENİS',
                style: RallyType.micro
                    .copyWith(color: cp.accentStrong, letterSpacing: 0.4)),
          ),
          const SizedBox(height: Spacing.sm),
          Text('$dayStr $timeStr',
              style: RallyType.displaySM.copyWith(color: cp.text)),
          const SizedBox(height: 2),
          Text('vs ${session.opponent.name}',
              style: RallyType.bodySM
                  .copyWith(color: cp.text2, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis),
        ],
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
          Text('Sıralama',
              style: RallyType.displaySM.copyWith(color: cp.text)),
          const SizedBox(height: 4),
          Text('Oyuncuları sıralama kriteri',
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
                    Text(opt,
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
              child: const Text('Uygula'),
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

  static const _skills = {
    'Tümü': 'Tümü',
    'Başl.': 'Başlangıç',
    'Orta': 'Orta Seviye',
    'İleri': 'İleri Seviye',
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
              Text('Filtrele',
                  style: RallyType.displaySM.copyWith(color: cp.text)),
              const Spacer(),
              GestureDetector(
                onTap: () =>
                    setState(() { _skill = 'Tümü'; _distance = '5 km'; }),
                child: Text('Temizle',
                    style: RallyType.bodySM.copyWith(
                        color: cp.accent, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Seviye', style: RallyType.titleSM.copyWith(color: cp.text)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: cp.surfaceSoft,
              borderRadius: BorderRadius.circular(RallyRadius.md),
            ),
            child: Row(
              children: _skills.entries.map((e) {
                final active = _skill == e.value;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _skill = e.value),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: active ? cp.surface : Colors.transparent,
                        borderRadius: BorderRadius.circular(RallyRadius.sm),
                        boxShadow: active ? RallyElevation.hairline : null,
                      ),
                      child: Text(
                        e.key,
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
          Text('Mesafe', style: RallyType.titleSM.copyWith(color: cp.text)),
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
              child: const Text('Uygula'),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Request match sheet ──────────────────────────────────────────────────────
class _RequestSheet extends StatefulWidget {
  final Player player;
  final bool alreadySent;
  final VoidCallback onSent;
  const _RequestSheet(
      {required this.player, required this.alreadySent, required this.onSent});

  @override
  State<_RequestSheet> createState() => _RequestSheetState();
}

class _RequestSheetState extends State<_RequestSheet> {
  final String _selectedFormat = 'Tekler';
  final String _selectedTime = 'Cumartesi 10:00';
  final String _selectedCourt = 'Caddebostan Tenis Kortları';
  late bool _sent = widget.alreadySent;
  bool _loading = false;

  Future<void> _sendRequest() async {
    if (_sent || _loading) return;
    setState(() => _loading = true);
    try {
      final userId = supabase.auth.currentUser?.id;
      final proposedDate = DateTime.now().add(const Duration(days: 7));
      await supabase.from('matches').insert({
        'player1_id': userId,
        'player2_id': widget.player.id,
        'date_time': proposedDate.toUtc().toIso8601String(),
        'court': _selectedCourt,
        'status': 'pending',
        'format': _selectedFormat == 'Tekler' ? 'singles' : 'doubles',
      });
      if (!mounted) return;
      setState(() {
        _sent = true;
        _loading = false;
      });
      widget.onSent();
      final nav = Navigator.of(context);
      final messenger = ScaffoldMessenger.of(context);
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) {
          nav.pop();
          messenger.showSnackBar(SnackBar(
            content:
                Text('${widget.player.name} oyuncusuna maç isteği gönderildi!'),
            backgroundColor: RallyColors.accent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ));
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('İstek gönderilemedi: $e'),
        backgroundColor: RallyColors.accent2,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cp = CourtThemeProvider.of(context);
    return Container(
      decoration: BoxDecoration(
        color: cp.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
          24,
          16,
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
                  color: RallyColors.muted2,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              PlayerAvatar(
                initials: widget.player.initials,
                gradientStart: widget.player.avatarGradientStart,
                gradientEnd: widget.player.avatarGradientEnd,
                size: 46,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Maç İsteği',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  Text(widget.player.name,
                      style: const TextStyle(
                          color: RallyColors.textSecondary, fontSize: 13)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SheetRow(
              icon: Icons.sports_tennis,
              label: 'Format',
              value: _selectedFormat,
              onTap: () {}),
          const Divider(height: 1),
          _SheetRow(
              icon: Icons.schedule,
              label: 'Saat',
              value: _selectedTime,
              onTap: () {}),
          const Divider(height: 1),
          _SheetRow(
              icon: Icons.location_on_outlined,
              label: 'Kort',
              value: _selectedCourt,
              onTap: () {}),
          const SizedBox(height: 24),
          RallyButton(
            label: _sent ? 'İstek Gönderildi ✓' : 'İstek Gönder 🎾',
            loading: _loading,
            onPressed: (_sent || _loading) ? null : _sendRequest,
          ),
        ],
      ),
    );
  }
}

// ─── Open lobby card ──────────────────────────────────────────────────────────
class _LobbyCard extends StatelessWidget {
  final Map<String, dynamic> lobby;
  final CourtPalette cp;
  const _LobbyCard({required this.lobby, required this.cp});

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
              child: Text(sport,
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
            child: Text(skill,
                style: RallyType.micro.copyWith(color: cp.accentStrong)),
          ),
          const SizedBox(height: 8),
          Text(court,
              style: RallyType.bodySM.copyWith(color: cp.muted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          if (dt != null) ...[
            const SizedBox(height: 3),
            Text(DateFormat('EEE d MMM, HH:mm').format(dt),
                style: RallyType.caption
                    .copyWith(fontWeight: FontWeight.w600, color: cp.text)),
          ],
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () =>
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content:
                    Text('$sport lobisine katılma isteği gönderildi!'),
                backgroundColor: RallyColors.accent,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              )),
              style: FilledButton.styleFrom(
                backgroundColor: cp.accent,
                minimumSize: const Size(0, 32),
                maximumSize: const Size(double.infinity, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.zero,
                textStyle: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600),
              ),
              child: const Text('Katıl'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _SheetRow(
      {required this.icon,
      required this.label,
      required this.value,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 18, color: RallyColors.muted),
            const SizedBox(width: 12),
            Text(label,
                style: const TextStyle(
                    color: RallyColors.textSecondary, fontSize: 14)),
            const Spacer(),
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right,
                size: 18, color: RallyColors.muted),
          ],
        ),
      ),
    );
  }
}
