import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';

// ─── Gradient Avatar ─────────────────────────────────────────────────────────
class PlayerAvatar extends StatelessWidget {
  final String initials;
  final String gradientStart;
  final String gradientEnd;
  final double size;

  const PlayerAvatar({
    super.key,
    required this.initials,
    this.gradientStart = '#5a8a00',
    this.gradientEnd = '#8db600',
    this.size = 50,
  });

  static Color _hex(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_hex(gradientStart), _hex(gradientEnd)],
        ),
        boxShadow: [
          BoxShadow(
            color: _hex(gradientStart).withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.32,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ─── Skill Badge ─────────────────────────────────────────────────────────────
class SkillBadge extends StatelessWidget {
  final String label;

  const SkillBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    switch (label.toLowerCase()) {
      case 'advanced':
        bg = RallyColors.skillAdvBg; fg = RallyColors.skillAdvFg;
      case 'intermediate':
        bg = RallyColors.skillInterBg; fg = RallyColors.skillInterFg;
      default:
        bg = RallyColors.skillBegBg; fg = RallyColors.skillBegFg;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

// ─── Match % badge ───────────────────────────────────────────────────────────
class MatchScoreBadge extends StatelessWidget {
  final int score;
  const MatchScoreBadge({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '$score%',
          style: const TextStyle(
            fontFamily: 'InstrumentSerif',
            fontSize: 26,
            color: RallyColors.accent,
            letterSpacing: -1,
            height: 1,
          ),
        ),
        const Text(
          'MATCH',
          style: TextStyle(
            fontSize: 9,
            color: RallyColors.muted,
            letterSpacing: 0.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ─── Player List Card ────────────────────────────────────────────────────────
class PlayerCard extends StatelessWidget {
  final Player player;
  final VoidCallback? onTap;
  final VoidCallback? onRequest;

  const PlayerCard({
    super.key,
    required this.player,
    this.onTap,
    this.onRequest,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
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
            PlayerAvatar(
              initials: player.initials,
              gradientStart: player.avatarGradientStart,
              gradientEnd: player.avatarGradientEnd,
              size: 54,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        player.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SkillBadge(label: player.skillLabel),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 12, color: RallyColors.muted),
                      const SizedBox(width: 3),
                      Text(player.location,
                          style: const TextStyle(
                              fontSize: 12, color: RallyColors.muted)),
                      const SizedBox(width: 10),
                      Text('NTRP ${player.ntrpDisplay}',
                          style: const TextStyle(
                              fontSize: 12, color: RallyColors.muted)),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                MatchScoreBadge(score: player.matchScore),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: onRequest,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: RallyColors.accent,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Text(
                      'Request',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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

// ─── Section header ──────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: RallyColors.muted,
              letterSpacing: 1,
            ),
          ),
          const Spacer(),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                action!,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: RallyColors.accent,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Primary button ──────────────────────────────────────────────────────────
class RallyButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool outlined;
  final IconData? icon;
  final bool loading;

  const RallyButton({
    super.key,
    required this.label,
    this.onPressed,
    this.outlined = false,
    this.icon,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Colors.white,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
              Text(label),
            ],
          );

    if (outlined) {
      return OutlinedButton(onPressed: onPressed, child: child);
    }
    return FilledButton(onPressed: onPressed, child: child);
  }
}

// ─── Notification dot badge ──────────────────────────────────────────────────
class NotifBadge extends StatelessWidget {
  final int count;
  const NotifBadge({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: RallyColors.accent2,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
