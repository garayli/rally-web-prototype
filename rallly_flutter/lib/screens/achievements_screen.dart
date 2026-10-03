import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  static List<_Badge> _badges(AppLocalizations l) => [
    _Badge(icon: '🎾', title: l.badgeFirstMatch, desc: l.badgeFirstMatchDesc, earned: true, color: const Color(0xFF5A8A00)),
    _Badge(icon: '🔥', title: l.badgeWinStreak, desc: l.badgeWinStreakDesc, earned: true, color: const Color(0xFFC8431A)),
    _Badge(icon: '⭐', title: l.badgeFiveStar, desc: l.badgeFiveStarDesc, earned: true, color: const Color(0xFFFFD700)),
    _Badge(icon: '🤝', title: l.badgeSocialButterfly, desc: l.badgeSocialButterflyDesc, earned: true, color: const Color(0xFF7B4FA6)),
    _Badge(icon: '📅', title: l.badgeRegularPlayer, desc: l.badgeRegularPlayerDesc, earned: true, color: const Color(0xFF1A7ABF)),
    _Badge(icon: '🏆', title: l.badgeChampion, desc: l.badgeChampionDesc, earned: true, color: const Color(0xFF8DB600)),
    _Badge(icon: '⚡', title: l.badgeQuickReply, desc: l.badgeQuickReplyDesc, earned: true, color: const Color(0xFFC8431A)),
    _Badge(icon: '🌍', title: l.badgeExplorer, desc: l.badgeExplorerDesc, earned: true, color: const Color(0xFF5A8A00)),
    _Badge(icon: '💬', title: l.badgeCommunicator, desc: l.badgeCommunicatorDesc, earned: true, color: const Color(0xFF7B4FA6)),
    _Badge(icon: '🎯', title: l.badgeSharpshooter, desc: l.badgeSharpshooterDesc, earned: true, color: const Color(0xFF1A7ABF)),
    _Badge(icon: '📸', title: l.badgeSharer, desc: l.badgeSharerDesc, earned: true, color: const Color(0xFFFFD700)),
    _Badge(icon: '🌟', title: l.badgeElite, desc: l.badgeEliteDesc, earned: true, color: const Color(0xFFFFD700)),
    _Badge(icon: '🏅', title: l.badgeTournamentPro, desc: l.badgeTournamentProDesc, earned: false, color: const Color(0xFF9CA3AF)),
    _Badge(icon: '👑', title: l.badgeLegend, desc: l.badgeLegendDesc, earned: false, color: const Color(0xFF9CA3AF)),
    _Badge(icon: '🎪', title: l.badgeGrandSlam, desc: l.badgeGrandSlamDesc, earned: false, color: const Color(0xFF9CA3AF)),
    _Badge(icon: '🤺', title: l.badgeDoublesKing, desc: l.badgeDoublesKingDesc, earned: false, color: const Color(0xFF9CA3AF)),
    _Badge(icon: '🌈', title: l.badgeAllRounder, desc: l.badgeAllRounderDesc, earned: false, color: const Color(0xFF9CA3AF)),
    _Badge(icon: '🚀', title: l.badgeRocket, desc: l.badgeRocketDesc, earned: false, color: const Color(0xFF9CA3AF)),
  ];

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final badges = _badges(l);
    final earned = badges.where((b) => b.earned).toList();
    final locked = badges.where((b) => !b.earned).toList();
    final earnedCount = earned.length;

    return Scaffold(
      backgroundColor: RallyColors.bg,
      appBar: AppBar(
        title: Text(l.achievements, style: const TextStyle(fontFamily: 'InstrumentSerif', fontSize: 22)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // ── Summary ────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [RallyColors.accent, RallyColors.accent3],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: RallyColors.accent.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 6))],
              ),
              child: Row(
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 40)),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.achievementsEarnedOf(earnedCount, badges.length),
                        style: const TextStyle(fontFamily: 'InstrumentSerif', fontSize: 32, color: Colors.white, letterSpacing: -1, height: 1),
                      ),
                      Text(l.achievementsEarnedLabel, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                    ],
                  ),
                  const Spacer(),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 56,
                        height: 56,
                        child: CircularProgressIndicator(
                          value: earnedCount / badges.length,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          valueColor: const AlwaysStoppedAnimation(Colors.white),
                          strokeWidth: 5,
                        ),
                      ),
                      Text(
                        '${(earnedCount / badges.length * 100).round()}%',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(),
          ),

          // ── Earned ─────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Text(
                l.achievementsEarnedHeader,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: RallyColors.muted, letterSpacing: 0.8),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.68,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) => _BadgeCard(badge: earned[i]).animate().fadeIn(delay: (i * 40).ms),
                childCount: earned.length,
              ),
            ),
          ),

          // ── Locked ─────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Text(
                l.achievementsLockedHeader,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: RallyColors.muted, letterSpacing: 0.8),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.68,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) => _BadgeCard(badge: locked[i]).animate().fadeIn(delay: (i * 40).ms),
                childCount: locked.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final _Badge badge;
  const _BadgeCard({required this.badge});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: badge.earned ? RallyColors.white : RallyColors.surface2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: badge.earned ? RallyColors.border : RallyColors.border2,
        ),
        boxShadow: badge.earned
            ? [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 3))]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: badge.earned ? badge.color.withValues(alpha: 0.12) : RallyColors.muted2.withValues(alpha: 0.3),
                ),
                child: Center(
                  child: badge.earned
                      ? Text(badge.icon, style: const TextStyle(fontSize: 26))
                      : ColorFiltered(
                          colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                          child: Text(badge.icon, style: const TextStyle(fontSize: 26)),
                        ),
                ),
              ),
              if (!badge.earned)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: RallyColors.muted),
                    child: const Icon(Icons.lock, size: 10, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            badge.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 11,
              color: badge.earned ? RallyColors.textPrimary : RallyColors.muted,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            badge.desc,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9,
              color: badge.earned ? RallyColors.muted : RallyColors.muted2,
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge {
  final String icon;
  final String title;
  final String desc;
  final bool earned;
  final Color color;

  const _Badge({
    required this.icon,
    required this.title,
    required this.desc,
    required this.earned,
    required this.color,
  });
}
