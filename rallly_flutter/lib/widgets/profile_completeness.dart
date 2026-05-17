import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';

/// Banner shown on Discover post-login when profile is incomplete.
class ProfileCompletenessBanner extends StatelessWidget {
  final int score;
  final List<String> missing;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const ProfileCompletenessBanner({
    super.key,
    required this.score,
    required this.missing,
    this.onTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = score.clamp(0, 100);
    final preview = missing.take(2).join(', ');
    final extra = missing.length > 2 ? ' +${missing.length - 2}' : '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(Spacing.gutter, Spacing.md, Spacing.gutter, Spacing.sm),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(RallyRadius.lg),
          child: Container(
            padding: const EdgeInsets.fromLTRB(Spacing.md, Spacing.md, Spacing.sm, Spacing.md),
            decoration: BoxDecoration(
              color: RallyColors.accentLight,
              borderRadius: BorderRadius.circular(RallyRadius.lg),
              border: Border.all(color: RallyColors.border),
            ),
            child: Row(
              children: [
                _CompletenessRing(score: clamped, size: 44),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profilini tamamla',
                        style: RallyType.titleMD.copyWith(color: RallyColors.textPrimary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        missing.isEmpty
                            ? '%$clamped tamamlandı'
                            : 'Eksik: $preview$extra',
                        style: RallyType.bodySM.copyWith(color: RallyColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (onDismiss != null)
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    color: RallyColors.muted,
                    visualDensity: VisualDensity.compact,
                    onPressed: onDismiss,
                  )
                else
                  const Icon(Icons.chevron_right, size: 20, color: RallyColors.muted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Circular ring shown around the avatar on the Profile screen.
class CompletenessRing extends StatelessWidget {
  final int score;
  final double size;
  final double strokeWidth;

  const CompletenessRing({
    super.key,
    required this.score,
    this.size = 92,
    this.strokeWidth = 3,
  });

  @override
  Widget build(BuildContext context) => _CompletenessRing(
        score: score.clamp(0, 100),
        size: size,
        strokeWidth: strokeWidth,
      );
}

class _CompletenessRing extends StatelessWidget {
  final int score;
  final double size;
  final double strokeWidth;

  const _CompletenessRing({
    required this.score,
    required this.size,
    this.strokeWidth = 3,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: strokeWidth,
              valueColor: const AlwaysStoppedAnimation(RallyColors.border),
            ),
          ),
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: score / 100,
              strokeWidth: strokeWidth,
              strokeCap: StrokeCap.round,
              valueColor: const AlwaysStoppedAnimation(RallyColors.accent),
            ),
          ),
          Text(
            '%$score',
            style: TextStyle(
              fontFamily: 'InstrumentSerif',
              fontSize: size * 0.32,
              color: RallyColors.accent,
              letterSpacing: -0.5,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
