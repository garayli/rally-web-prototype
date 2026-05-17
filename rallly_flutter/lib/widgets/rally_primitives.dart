import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';
import '../main.dart' show CourtThemeProvider;

// ─── RallyCard ───────────────────────────────────────────────────────────────
class RallyCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double radius;
  final Color? color;
  final BoxBorder? border;
  final List<BoxShadow>? shadow;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const RallyCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Spacing.lg),
    this.margin = EdgeInsets.zero,
    this.radius = RallyRadius.lg,
    this.color,
    this.border,
    this.shadow,
    this.onTap,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cp = CourtThemeProvider.of(context);
    final resolved = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(radius),
        border: border ?? Border.all(color: cp.border),
        boxShadow: shadow ?? RallyElevation.card,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Padding(padding: padding, child: child),
      ),
    );

    if (onTap == null) return resolved;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: resolved,
      ),
    );
  }
}

// ─── RallyChip ───────────────────────────────────────────────────────────────
class RallyChip extends StatelessWidget {
  final String label;
  final bool active;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool compact;

  const RallyChip({
    super.key,
    required this.label,
    this.active = false,
    this.icon,
    this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final h = compact ? Spacing.md : 18.0;
    final v = compact ? 6.0 : 10.0;
    final fg = active ? Colors.white : RallyColors.textPrimary;
    final bg = active ? RallyColors.accent : RallyColors.white;
    final borderColor = active ? RallyColors.accent : RallyColors.border2;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(horizontal: h, vertical: v),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: RR.pill,
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: active ? RallyElevation.hairline : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: compact ? 14 : 16, color: fg),
              SizedBox(width: compact ? 4 : 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: compact ? 12 : 13,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── EmptyState ──────────────────────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final IconData? icon;
  final String? emoji;
  final String title;
  final String? message;
  final String? ctaLabel;
  final VoidCallback? onCta;
  final EdgeInsetsGeometry padding;

  const EmptyState({
    super.key,
    this.icon,
    this.emoji,
    required this.title,
    this.message,
    this.ctaLabel,
    this.onCta,
    this.padding = const EdgeInsets.symmetric(
      horizontal: Spacing.xl,
      vertical: Spacing.xxl,
    ),
  }) : assert(icon != null || emoji != null,
      'EmptyState needs either an icon or an emoji');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        children: [
          if (emoji != null)
            Text(emoji!, style: const TextStyle(fontSize: 44))
          else
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: RallyColors.surface2,
                shape: BoxShape.circle,
                border: Border.all(color: RallyColors.border),
              ),
              child: Icon(icon, size: 28, color: RallyColors.textSecondary),
            ),
          const SizedBox(height: Spacing.md),
          Text(title, style: RallyType.displaySM, textAlign: TextAlign.center),
          if (message != null) ...[
            const SizedBox(height: Spacing.xs + 2),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: RallyType.body.copyWith(color: RallyColors.muted),
            ),
          ],
          if (ctaLabel != null) ...[
            const SizedBox(height: Spacing.lg),
            FilledButton(
              onPressed: onCta,
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 44),
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.xl,
                  vertical: 10,
                ),
              ),
              child: Text(ctaLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── RallyAppBar ─────────────────────────────────────────────────────────────
class RallyAppBar extends StatelessWidget {
  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showDivider;
  final bool pinned;
  final bool floating;

  const RallyAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.showDivider = true,
    this.pinned = false,
    this.floating = true,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: pinned,
      floating: floating,
      snap: floating,
      automaticallyImplyLeading: false,
      leading: leading,
      title: title,
      actions: actions,
      bottom: showDivider
          ? PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Divider(height: 1, color: CourtThemeProvider.of(context).border),
            )
          : null,
    );
  }
}

// ─── RallyWordmark ───────────────────────────────────────────────────────────
class RallyWordmark extends StatelessWidget {
  final double size;
  const RallyWordmark({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontFamily: 'InstrumentSerif',
      fontSize: size,
      height: 1,
    );
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: 'Rall', style: style.copyWith(color: RallyColors.accent)),
          TextSpan(
            text: 'l',
            style: style.copyWith(
              color: RallyColors.textPrimary,
              fontStyle: FontStyle.italic,
            ),
          ),
          TextSpan(text: 'y', style: style.copyWith(color: RallyColors.accent)),
        ],
      ),
    );
  }
}
