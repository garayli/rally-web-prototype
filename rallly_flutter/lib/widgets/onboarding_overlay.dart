import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../l10n/l10n.dart';
import '../theme/app_theme.dart';
import 'shared_widgets.dart';

class TabOnboardingContent {
  final IconData icon;
  final String title;
  final List<String> bullets;
  const TabOnboardingContent({
    required this.icon,
    required this.title,
    required this.bullets,
  });
}

List<TabOnboardingContent> tabOnboardingContent(AppLocalizations l) => [
  TabOnboardingContent(
    icon: Icons.sports_tennis,
    title: l.navFindOpponent,
    bullets: [
      l.onboardingFind1,
      l.onboardingFind2,
      l.onboardingFind3,
    ],
  ),
  TabOnboardingContent(
    icon: Icons.chat_bubble,
    title: l.navMessages,
    bullets: [
      l.onboardingMessages1,
      l.onboardingMessages2,
      l.onboardingMessages3,
    ],
  ),
  TabOnboardingContent(
    icon: Icons.notifications,
    title: l.notifications,
    bullets: [
      l.onboardingNotifications1,
      l.onboardingNotifications2,
      l.onboardingNotifications3,
    ],
  ),
  TabOnboardingContent(
    icon: Icons.person,
    title: l.profileTitle,
    bullets: [
      l.onboardingProfile1,
      l.onboardingProfile2,
      l.onboardingProfile3,
    ],
  ),
];

class OnboardingOverlay extends StatelessWidget {
  final TabOnboardingContent content;
  final VoidCallback onDismiss;

  const OnboardingOverlay({
    super.key,
    required this.content,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDismiss,
      child: Stack(
        children: [
          const SizedBox.expand(
            child: ColoredBox(color: Colors.black54),
          ),
          Center(
            child: GestureDetector(
              onTap: () {},
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: RallyColors.bg,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x28000000),
                        blurRadius: 32,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(content.icon, size: 52, color: RallyColors.accent),
                      const SizedBox(height: 16),
                      Text(
                        content.title,
                        style: const TextStyle(
                          fontFamily: 'InstrumentSerif',
                          fontSize: 22,
                          color: RallyColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...content.bullets.map((b) => _BulletRow(text: b)),
                      const SizedBox(height: 24),
                      RallyButton(label: context.l10n.onboardingGotIt, onPressed: onDismiss),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 250.ms);
  }
}

class _BulletRow extends StatelessWidget {
  final String text;
  const _BulletRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, size: 16, color: RallyColors.accent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: RallyColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
