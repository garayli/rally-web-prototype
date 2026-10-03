import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';
import '../main.dart' show CourtThemeProvider;
import 'doubles_organise_screen.dart';
import 'open_lobby_screen.dart';
import '../l10n/l10n.dart';

class CreateGameScreen extends StatelessWidget {
  const CreateGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cp = CourtThemeProvider.of(context);

    return Scaffold(
      backgroundColor: cp.bg,
      appBar: AppBar(
        backgroundColor: cp.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 18, color: cp.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.l10n.createMatchFab,
          style: TextStyle(
            fontFamily: 'InstrumentSerif',
            fontSize: 22,
            color: cp.text,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: cp.border),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(
            Spacing.gutter, Spacing.xl, Spacing.gutter, Spacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.createGameQuestion,
              style: TextStyle(
                fontFamily: 'InstrumentSerif',
                fontSize: 28,
                letterSpacing: -0.5,
                color: cp.text,
              ),
            ).animate().fadeIn(),
            const SizedBox(height: Spacing.sm),
            Text(
              context.l10n.createGameSubtitle,
              style: TextStyle(fontSize: 14, color: cp.text2),
            ).animate().fadeIn(delay: 60.ms),
            const SizedBox(height: Spacing.xl),

            _GameOptionCard(
              icon: Icons.sports_tennis,
              title: context.l10n.createGameStartMatch,
              subtitle: context.l10n.createGameStartMatchSub,
              accentColor: cp.accent,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const DoublesOrganiseScreen(isSingles: true)),
              ),
              cp: cp,
            ).animate().fadeIn(delay: 120.ms).slideY(begin: 0.06, end: 0),

            const SizedBox(height: Spacing.md),

            _GameOptionCard(
              icon: Icons.public_outlined,
              title: context.l10n.createGamePublishOpen,
              subtitle: context.l10n.createGamePublishOpenSub,
              accentColor: const Color(0xFFC8431A),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OpenLobbyScreen()),
              ),
              cp: cp,
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.06, end: 0),
          ],
        ),
      ),
    );
  }
}

class _GameOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;
  final CourtPalette cp;

  const _GameOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
    required this.cp,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(Spacing.lg),
        decoration: BoxDecoration(
          color: cp.surface,
          borderRadius: BorderRadius.circular(RallyRadius.xl),
          border: Border.all(color: cp.border),
          boxShadow: RallyElevation.card,
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(RallyRadius.md),
              ),
              child: Icon(icon, size: 24, color: accentColor),
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'InstrumentSerif',
                      fontSize: 18,
                      color: cp.text,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: cp.text2, height: 1.3),
                  ),
                ],
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Icon(Icons.arrow_forward_ios,
                size: 16, color: cp.muted),
          ],
        ),
      ),
    );
  }
}
