import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../models/models.dart';
import '../services/mock_data.dart';
import 'player_profile_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _mapCtrl = MapController();

  // London-area coordinates (matching the mock data in the HTML prototype)
  static const _center = LatLng(51.5461, -0.1059); // Islington

  static final List<_MapPlayer> _mapPlayers = [
    _MapPlayer(pos: const LatLng(51.5461, -0.1059), player: MockData.players[0]),
    _MapPlayer(pos: const LatLng(51.5350, -0.0576), player: MockData.players[1]),
    _MapPlayer(pos: const LatLng(51.5297, -0.1409), player: MockData.players[2]),
    _MapPlayer(pos: const LatLng(51.5236, -0.0786), player: MockData.players[3]),
  ];

  static const _courts = [
    _MapCourt(pos: LatLng(51.5461, -0.1085), name: 'Highbury Fields'),
    _MapCourt(pos: LatLng(51.5387, -0.0467), name: 'London Fields'),
    _MapCourt(pos: LatLng(51.5266, -0.1540), name: "Regent's Park"),
    _MapCourt(pos: LatLng(51.5321, -0.0408), name: 'Victoria Park'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RallyColors.bg,
      appBar: AppBar(
        title: const Text('Nearby Players', style: TextStyle(fontFamily: 'InstrumentSerif', fontSize: 22)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () => _mapCtrl.move(_center, 14),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FlutterMap(
        mapController: _mapCtrl,
        options: const MapOptions(
          initialCenter: _center,
          initialZoom: 13.5,
          minZoom: 10,
          maxZoom: 18,
        ),
        children: [
          // OpenStreetMap tile layer
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'io.rallly.app',
          ),

          // Court markers
          MarkerLayer(
            markers: _courts.map((c) => Marker(
              point: c.pos,
              width: 36,
              height: 36,
              child: _CourtMarker(name: c.name),
            )).toList(),
          ),

          // Player markers
          MarkerLayer(
            markers: _mapPlayers.map((mp) => Marker(
              point: mp.pos,
              width: 56,
              height: 56,
              child: GestureDetector(
                onTap: () => _showPlayerSheet(mp.player),
                child: _PlayerMapMarker(player: mp.player),
              ),
            )).toList(),
          ),

          // "You are here" marker
          const MarkerLayer(
            markers: [
              Marker(
                point: _center,
                width: 44,
                height: 44,
                child: _YouMarker(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPlayerSheet(Player player) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _PlayerMapSheet(
        player: player,
        onViewProfile: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PlayerProfileScreen(player: player)),
          );
        },
      ),
    );
  }
}

// ─── Map marker widgets ───────────────────────────────────────────────────────
class _PlayerMapMarker extends StatelessWidget {
  final Player player;
  const _PlayerMapMarker({required this.player});

  static Color _hex(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_hex(player.avatarGradientStart), _hex(player.avatarGradientEnd)],
            ),
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))],
          ),
          child: Center(
            child: Text(player.initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
          ),
        ),
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 3)],
          ),
        ),
      ],
    );
  }
}

class _CourtMarker extends StatelessWidget {
  final String name;
  const _CourtMarker({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: RallyColors.accent3,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: const Center(child: Text('🎾', style: TextStyle(fontSize: 14))),
    );
  }
}

class _YouMarker extends StatelessWidget {
  const _YouMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue.shade600,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
      ),
      child: const Center(
        child: Text('You', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 10)),
      ),
    );
  }
}

// ─── Player bottom sheet ──────────────────────────────────────────────────────
class _PlayerMapSheet extends StatelessWidget {
  final Player player;
  final VoidCallback onViewProfile;

  const _PlayerMapSheet({required this.player, required this.onViewProfile});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: RallyColors.bg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 6),
          Container(width: 36, height: 4, decoration: BoxDecoration(color: RallyColors.muted2, borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    PlayerAvatar(
                      initials: player.initials,
                      gradientStart: player.avatarGradientStart,
                      gradientEnd: player.avatarGradientEnd,
                      size: 56,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(player.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                              const SizedBox(width: 8),
                              SkillBadge(label: player.skillLabel),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(player.location, style: const TextStyle(fontSize: 13, color: RallyColors.muted)),
                        ],
                      ),
                    ),
                    MatchScoreBadge(score: player.matchScore),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: RallyButton(
                        label: 'View Profile',
                        outlined: true,
                        onPressed: onViewProfile,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: RallyButton(
                        label: 'Request Match',
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Match request sent to ${player.name}!'),
                              backgroundColor: RallyColors.accent,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    ).animate().slideY(begin: 0.1, end: 0).fadeIn();
  }
}

// ─── Data classes ─────────────────────────────────────────────────────────────
class _MapPlayer {
  final LatLng pos;
  final Player player;
  const _MapPlayer({required this.pos, required this.player});
}

class _MapCourt {
  final LatLng pos;
  final String name;
  const _MapCourt({required this.pos, required this.name});
}
