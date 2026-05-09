import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class LandingScreen extends StatelessWidget {
  final VoidCallback onGetStarted;
  final VoidCallback onSignIn;

  const LandingScreen({
    super.key,
    required this.onGetStarted,
    required this.onSignIn,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // ── Hero gradient background ──────────────────────────────────────
          Container(
            width: double.infinity,
            height: size.height * 0.65,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2A1F14),
                  Color(0xFF3D2B1A),
                  Color(0xFF2A1F14),
                ],
              ),
            ),
          ),

          // ── Court texture overlay ─────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.65,
            child: CustomPaint(painter: _CourtPainter()),
          ),

          // ── Content ───────────────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // Logo bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
                  child: Row(
                    children: [
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Rall',
                              style: TextStyle(
                                fontFamily: 'InstrumentSerif',
                                fontSize: 28,
                                color: Color(0xFF8DB600),
                                letterSpacing: -0.5,
                              ),
                            ),
                            TextSpan(
                              text: 'l',
                              style: TextStyle(
                                fontFamily: 'InstrumentSerif',
                                fontSize: 28,
                                color: Colors.white,
                                fontStyle: FontStyle.italic,
                                letterSpacing: -0.5,
                              ),
                            ),
                            TextSpan(
                              text: 'y',
                              style: TextStyle(
                                fontFamily: 'InstrumentSerif',
                                fontSize: 28,
                                color: Color(0xFF8DB600),
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: onSignIn,
                        child: const Text(
                          'Giriş Yap',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 100.ms),

                // Hero text
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 48, 28, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mükemmel\nrakibini bul.',
                        style: TextStyle(
                          fontFamily: 'InstrumentSerif',
                          fontSize: 52,
                          color: Colors.white,
                          letterSpacing: -2,
                          height: 1.05,
                        ),
                      ).animate().fadeIn(delay: 200.ms).slideY(
                            begin: 0.2,
                            end: 0,
                            delay: 200.ms,
                            curve: Curves.easeOut,
                          ),
                      const SizedBox(height: 18),
                      const Text(
                        'Seviyenizde tenis oyuncuları bulun, '
                        'kort rezervasyonu yapın ve gelişiminizi takip edin.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          height: 1.6,
                        ),
                      ).animate().fadeIn(delay: 350.ms),
                    ],
                  ),
                ),

                const Spacer(),

                // ── Stats row ────────────────────────────────────────────────
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 28),
                  child: Row(
                    children: [
                      _StatChip(value: '2.400+', label: 'Oyuncu'),
                      SizedBox(width: 10),
                      _StatChip(value: '98%', label: 'Uyum oranı'),
                      SizedBox(width: 10),
                      _StatChip(value: '4.9★', label: 'Puan'),
                    ],
                  ),
                ).animate().fadeIn(delay: 450.ms),

                const SizedBox(height: 28),

                // ── CTA card ──────────────────────────────────────────────────
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: RallyColors.bg,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 40,
                        offset: const Offset(0, -10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      RallyButton(
                        label: 'Başla — tamamen ücretsiz',
                        onPressed: onGetStarted,
                        icon: Icons.sports_tennis,
                      ),
                      const SizedBox(height: 12),
                      RallyButton(
                        label: 'Zaten hesabım var',
                        onPressed: onSignIn,
                        outlined: true,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Devam ederek Şartlarımızı ve Gizlilik Politikamızı kabul etmiş olursunuz',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: RallyColors.muted,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 500.ms).slideY(
                      begin: 0.1,
                      end: 0,
                      delay: 500.ms,
                      curve: Curves.easeOut,
                    ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String value;
  final String label;
  const _StatChip({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Column(
          children: [
            Text(
              value,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'InstrumentSerif',
                fontSize: 20,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white54,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Court line painter ───────────────────────────────────────────────────────
class _CourtPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Baseline
    canvas.drawLine(
      Offset(0, size.height * 0.75),
      Offset(size.width, size.height * 0.75),
      paint,
    );
    // Service line
    canvas.drawLine(
      Offset(0, size.height * 0.45),
      Offset(size.width, size.height * 0.45),
      paint,
    );
    // Center line
    canvas.drawLine(
      Offset(size.width / 2, size.height * 0.45),
      Offset(size.width / 2, size.height * 0.75),
      paint,
    );
    // Sidelines
    canvas.drawLine(
      Offset(size.width * 0.1, 0),
      Offset(size.width * 0.1, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.9, 0),
      Offset(size.width * 0.9, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
