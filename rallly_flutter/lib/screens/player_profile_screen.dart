import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../models/models.dart';
import '../services/data_service.dart';
import 'reputation_screen.dart';
import 'messages_screen.dart';

class PlayerProfileScreen extends StatelessWidget {
  final Player player;

  const PlayerProfileScreen({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RallyColors.bg,
      body: CustomScrollView(
        slivers: [
          // ── Cover / avatar ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF0EBE0), Color(0xFFF5F0E8)],
                ),
                border: Border(
                  bottom: BorderSide(color: RallyColors.border),
                ),
              ),
              padding: EdgeInsets.fromLTRB(
                  20, MediaQuery.of(context).padding.top + 12, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back_ios_new,
                            size: 14, color: RallyColors.textSecondary),
                        SizedBox(width: 4),
                        Text('Back',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: RallyColors.textSecondary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PlayerAvatar(
                        initials: player.initials,
                        gradientStart: player.avatarGradientStart,
                        gradientEnd: player.avatarGradientEnd,
                        size: 76,
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              player.name,
                              style: const TextStyle(
                                fontFamily: 'InstrumentSerif',
                                fontSize: 32,
                                letterSpacing: -1,
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined,
                                    size: 13,
                                    color: RallyColors.textSecondary),
                                const SizedBox(width: 3),
                                Text(player.location,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: RallyColors.textSecondary)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                SkillBadge(label: player.skillLabel),
                                _Tag('NTRP ${player.ntrpDisplay}'),
                                _Tag('🎾 ${player.matchScore}% match'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Stats row ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: RallyColors.border)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      _StatBox(value: '${player.wins}', label: 'Wins', green: true),
                      _StatBox(value: '${player.losses}', label: 'Losses'),
                      _StatBox(value: '${player.matchesPlayed}', label: 'Played'),
                      _StatBox(value: '${player.winRate.round()}%', label: 'Win Rate'),
                    ],
                  ),
                  InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReputationScreen(player: player))),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      color: RallyColors.accentLight,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.star, size: 14, color: Color(0xFFFFD700)),
                          SizedBox(width: 5),
                          Text('4.9 · See all reviews', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: RallyColors.accent)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── About ──────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _InfoTitle('ABOUT'),
                  const SizedBox(height: 10),
                  Text(
                    player.about,
                    style: const TextStyle(
                      fontSize: 14,
                      color: RallyColors.textSecondary,
                      height: 1.75,
                    ),
                  ),
                  const SizedBox(height: 22),
                  const _InfoTitle('AVAILABILITY'),
                  const SizedBox(height: 12),
                  _AvailabilityGrid(availability: player.availability),
                  const SizedBox(height: 22),
                  const _InfoTitle('PREFERRED COURTS'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: player.preferredCourts
                        .map((c) => _Tag('📍 $c'))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),

          // ── CTA ────────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 100),
              child: Row(
                children: [
                  Expanded(
                    child: RallyButton(
                      label: 'Request Match',
                      icon: Icons.sports_tennis,
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Match request sent to ${player.name}!'),
                          backgroundColor: RallyColors.accent,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 52,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () {
                        final existing = dataService.getConversations()
                            .where((c) => c.other.id == player.id)
                            .firstOrNull;
                        final convo = existing ??
                            Conversation(
                              id: 'new_${player.id}',
                              other: player,
                              messages: const [],
                            );
                        Navigator.push(context, MaterialPageRoute(
                            builder: (_) => ConversationScreen(conversation: convo)));
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: const CircleBorder(),
                        side: const BorderSide(
                            color: RallyColors.border2, width: 1.5),
                      ),
                      child: const Icon(Icons.chat_bubble_outline, size: 20),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 52,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Player saved — coming soon'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: const CircleBorder(),
                        side: const BorderSide(
                            color: RallyColors.border2, width: 1.5),
                      ),
                      child: const Icon(Icons.bookmark_border, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: RallyColors.white,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: RallyColors.border2),
      ),
      child: Text(label,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: RallyColors.textSecondary)),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final bool green;

  const _StatBox({required this.value, required this.label, this.green = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: RallyColors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Text(
              value,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'InstrumentSerif',
                fontSize: 26,
                color: green ? RallyColors.accent : RallyColors.textPrimary,
                letterSpacing: -1,
                height: 1,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label.toUpperCase(),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 9,
                color: RallyColors.muted,
                letterSpacing: 0.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTitle extends StatelessWidget {
  final String text;
  const _InfoTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: RallyColors.muted,
        letterSpacing: 1,
      ),
    );
  }
}

class _AvailabilityGrid extends StatelessWidget {
  final List<String> availability;
  const _AvailabilityGrid({required this.availability});

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  String _slotFor(String day) {
    final match = availability.firstWhere(
      (a) => a.startsWith(day),
      orElse: () => '',
    );
    if (match.isEmpty) return '';
    if (match.contains('Full')) return 'Full';
    if (match.contains('AM')) return 'AM';
    if (match.contains('PM')) return 'PM';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _days.map((day) {
        final slot = _slotFor(day);
        Color bg = RallyColors.surface2;
        Color fg = RallyColors.muted;
        if (slot == 'Full') { bg = RallyColors.accent; fg = Colors.white; }
        else if (slot == 'AM') { bg = RallyColors.accentLight; fg = RallyColors.accent; }
        else if (slot == 'PM') { bg = const Color(0xFFFFF4E6); fg = const Color(0xFFC46A00); }

        return Expanded(
          child: Column(
            children: [
              Text(day.substring(0, 1),
                  style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: RallyColors.muted,
                      letterSpacing: 0.5)),
              const SizedBox(height: 5),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                height: 36,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: RallyColors.border),
                ),
                child: Center(
                  child: Text(
                    slot,
                    style: TextStyle(
                        fontSize: 8, fontWeight: FontWeight.w700, color: fg),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
