import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../models/models.dart';
import '../services/data_service.dart';
import '../main.dart' show supabase;
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
  String _searchQuery = '';
  final _filters = ['Tümü', 'Başlangıç', 'Orta Seviye', 'İleri Seviye'];
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
      list = list.where((p) =>
          p.name.toLowerCase().contains(q) ||
          p.location.toLowerCase().contains(q)).toList();
    }
    return list;
  }

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
            title: RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'Rall',
                    style: TextStyle(
                      fontFamily: 'InstrumentSerif',
                      fontSize: 24,
                      color: RallyColors.accent,
                    ),
                  ),
                  TextSpan(
                    text: 'l',
                    style: TextStyle(
                      fontFamily: 'InstrumentSerif',
                      fontSize: 24,
                      color: RallyColors.textPrimary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  TextSpan(
                    text: 'y',
                    style: TextStyle(
                      fontFamily: 'InstrumentSerif',
                      fontSize: 24,
                      color: RallyColors.accent,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              ValueListenableBuilder<int>(
                valueListenable: dataService.unreadNotifier,
                builder: (context, count, _) => Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: NotifBadge(count: count),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                borderRadius: BorderRadius.circular(17),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                ),
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
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(1),
              child: Divider(height: 1, color: RallyColors.border),
            ),
          ),

          // ── Search bar ─────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v.trim()),
                decoration: InputDecoration(
                  hintText: 'İsim veya konum ara…',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.tune, size: 20),
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Gelişmiş filtreler yakında'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Filter chips ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final active = _filters[i] == _filter;
                  return GestureDetector(
                    onTap: () => setState(() => _filter = _filters[i]),
                    child: AnimatedContainer(
                      duration: 200.ms,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: active ? RallyColors.accent : RallyColors.white,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: active
                              ? RallyColors.accent
                              : RallyColors.border2,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        _filters[i],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: active ? Colors.white : RallyColors.textPrimary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // ── Open lobbies ───────────────────────────────────────────────────
          if (_lobbiesLoading || _lobbies.isNotEmpty)
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    title: 'AÇIK LOBİLER',
                    action: 'Lobi Oluştur',
                    onAction: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const OpenLobbyScreen()),
                    ).then((_) => _loadLobbies()),
                  ),
                  if (_lobbiesLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else
                    SizedBox(
                      height: 180,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                        itemCount: _lobbies.length,
                        itemBuilder: (context, i) =>
                            _LobbyCard(lobby: _lobbies[i]),
                      ),
                    ),
                ],
              ),
            ),

          // ── Players header ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: SectionHeader(
              title: '${_filteredPlayers.length} YAKINDA OYUNCU',
              action: 'Harita',
              onAction: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MapScreen()),
              ),
            ),
          ),

          // ── Player list ────────────────────────────────────────────────────
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final player = _filteredPlayers[i];
                return PlayerCard(
                  player: player,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlayerProfileScreen(player: player),
                    ),
                  ),
                  onRequest: () => _showRequestSheet(context, player),
                ).animate().fadeIn(delay: (i * 60).ms).slideY(
                      begin: 0.1, end: 0, delay: (i * 60).ms);
              },
              childCount: _filteredPlayers.length,
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
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

// ─── Request match bottom sheet ───────────────────────────────────────────────
class _RequestSheet extends StatefulWidget {
  final Player player;
  final bool alreadySent;
  final VoidCallback onSent;
  const _RequestSheet({required this.player, required this.alreadySent, required this.onSent});

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
        'player2_id': null, // mock player IDs are not UUIDs — populated when real profiles exist
        'date_time': proposedDate.toUtc().toIso8601String(),
        'court': _selectedCourt,
        'status': 'pending',
        'format': _selectedFormat == 'Tekler' ? 'singles' : 'doubles',
      });
      if (!mounted) return;
      setState(() { _sent = true; _loading = false; });
      widget.onSent();
      final nav = Navigator.of(context);
      final messenger = ScaffoldMessenger.of(context);
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) {
          nav.pop();
          messenger.showSnackBar(SnackBar(
            content: Text('${widget.player.name} oyuncusuna maç isteği gönderildi!'),
            backgroundColor: RallyColors.accent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    return Container(
      decoration: const BoxDecoration(
        color: RallyColors.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24, 16, 24,
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
                borderRadius: BorderRadius.circular(2),
              ),
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
                  Text(
                    'Maç İsteği',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  Text(
                    widget.player.name,
                    style: const TextStyle(
                      color: RallyColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          _SheetRow(
            icon: Icons.sports_tennis,
            label: 'Format',
            value: _selectedFormat,
            onTap: () {},
          ),
          const Divider(height: 1),
          _SheetRow(
            icon: Icons.schedule,
            label: 'Saat',
            value: _selectedTime,
            onTap: () {},
          ),
          const Divider(height: 1),
          _SheetRow(
            icon: Icons.location_on_outlined,
            label: 'Kort',
            value: _selectedCourt,
            onTap: () {},
          ),

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

// ─── Open lobby card ─────────────────────────────────────────────────────────
class _LobbyCard extends StatelessWidget {
  final Map<String, dynamic> lobby;
  const _LobbyCard({required this.lobby});

  static const _sportEmojis = {
    'Tenis': '🎾', 'Padel': '🏓', 'Badminton': '🏸', 'Squash': '🟡',
  };

  @override
  Widget build(BuildContext context) {
    final dt = DateTime.tryParse(lobby['date_time'] as String? ?? '')?.toLocal();
    final sport = lobby['sport'] as String? ?? 'Tenis';
    final court = lobby['court'] as String? ?? '';
    final skill = lobby['skill_level'] as String? ?? '';

    return Container(
      width: 178,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: RallyColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RallyColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(_sportEmojis[sport] ?? '🎾', style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(sport,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: RallyColors.accentLight,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(skill,
                style: const TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w600, color: RallyColors.accent)),
          ),
          const SizedBox(height: 8),
          Text(court,
              style: const TextStyle(fontSize: 11, color: RallyColors.muted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          if (dt != null) ...[
            const SizedBox(height: 3),
            Text(DateFormat('EEE d MMM, HH:mm').format(dt),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          ],
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('$sport lobisine katılma isteği gönderildi!'),
                backgroundColor: RallyColors.accent,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              )),
              style: FilledButton.styleFrom(
                backgroundColor: RallyColors.accent,
                minimumSize: const Size(0, 32),
                padding: EdgeInsets.zero,
                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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

  const _SheetRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

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
            const Icon(Icons.chevron_right, size: 18, color: RallyColors.muted),
          ],
        ),
      ),
    );
  }
}
