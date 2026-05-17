import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

const List<TabOnboardingContent> kTabOnboardingContent = [
  TabOnboardingContent(
    icon: Icons.sports_tennis,
    title: 'Keşfet',
    bullets: [
      'Seviyene uygun oyuncuları keşfet ve maç isteği gönder.',
      'Yaklaşan maçlarını hızlıca görüntüle.',
      'Uyum yüzdesine göre sıralanan oyuncuları gör.',
    ],
  ),
  TabOnboardingContent(
    icon: Icons.chat_bubble,
    title: 'Mesajlar',
    bullets: [
      'Maç öncesi ve sonrası rakibinle doğrudan mesajlaş.',
      'Tüm konuşmalarını tek ekranda takip et.',
      'Kort detaylarını ve saati kolayca paylaş.',
    ],
  ),
  TabOnboardingContent(
    icon: Icons.notifications,
    title: 'Bildirimler',
    bullets: [
      'Gelen maç isteklerini kabul et veya reddet.',
      'Skor güncellemelerini ve hatırlatıcıları buradan gör.',
      'Tüm önemli gelişmelerden anında haberdar ol.',
    ],
  ),
  TabOnboardingContent(
    icon: Icons.person,
    title: 'Profilim',
    bullets: [
      'NTRP seviyeni, istatistiklerini ve başarılarını görüntüle.',
      'Maç geçmişini ve takvimini buradan takip et.',
      'Bildirim tercihlerini ve hesap ayarlarını düzenle.',
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
                      RallyButton(label: 'Anladım!', onPressed: onDismiss),
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
