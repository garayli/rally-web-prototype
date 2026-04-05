import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../models/models.dart';
import '../services/data_service.dart';
import 'player_profile_screen.dart';
import 'map_screen.dart';
import 'notifications_screen.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  String _filter = 'All';
  String _searchQuery = '';
  final _filters = ['All', 'Beginner', 'Intermediate', 'Advanced'];
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Player> get _filteredPlayers {
    var list = _filter == 'All'
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
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                  ),
                  const Positioned(
                    top: 8,
                    right: 8,
                    child: NotifBadge(count: 3),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              const Padding(
                padding: EdgeInsets.only(right: 16),
                child: PlayerAvatar(
                  initials: 'AW',
                  gradientStart: '#e85d3a',
                  gradientEnd: '#f4956d',
                  size: 34,
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
                  hintText: 'Search by name or location…',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.tune, size: 20),
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Advanced filters coming soon'),
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

          // ── Players header ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: SectionHeader(
              title: '${_filteredPlayers.length} PLAYERS NEARBY',
              action: 'Map view',
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
      builder: (_) => _RequestSheet(player: player),
    );
  }
}

// ─── Request match bottom sheet ───────────────────────────────────────────────
class _RequestSheet extends StatefulWidget {
  final Player player;
  const _RequestSheet({required this.player});

  @override
  State<_RequestSheet> createState() => _RequestSheetState();
}

class _RequestSheetState extends State<_RequestSheet> {
  final String _selectedFormat = 'Singles';
  final String _selectedTime = 'Saturday 10:00am';
  final String _selectedCourt = 'London Fields';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: RallyColors.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 28),
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
                    'Request match',
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
            label: 'Time',
            value: _selectedTime,
            onTap: () {},
          ),
          const Divider(height: 1),
          _SheetRow(
            icon: Icons.location_on_outlined,
            label: 'Court',
            value: _selectedCourt,
            onTap: () {},
          ),

          const SizedBox(height: 24),
          RallyButton(
            label: 'Send Request 🎾',
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Match request sent to ${widget.player.name}!'),
                  backgroundColor: RallyColors.accent,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
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
