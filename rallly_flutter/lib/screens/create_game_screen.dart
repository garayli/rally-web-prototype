import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import 'doubles_organise_screen.dart';
import 'open_lobby_screen.dart';

class CreateGameScreen extends StatelessWidget {
  const CreateGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RallyColors.bg,
      appBar: AppBar(
        title: const Text('New Game', style: TextStyle(fontFamily: 'InstrumentSerif', fontSize: 22)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'What kind of game?',
              style: TextStyle(fontFamily: 'InstrumentSerif', fontSize: 32, letterSpacing: -1.5, height: 1.1),
            ).animate().fadeIn(),
            const SizedBox(height: 8),
            const Text(
              'Choose your format to get started',
              style: TextStyle(color: RallyColors.textSecondary, fontSize: 15),
            ).animate().fadeIn(delay: 80.ms),
            const SizedBox(height: 36),

            _GameTypeCard(
              icon: '👤',
              title: 'Singles',
              subtitle: 'Challenge a specific player 1v1',
              gradient: const [Color(0xFF5A8A00), Color(0xFF8DB600)],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DoublesOrganiseScreen(isSingles: true)),
              ),
            ).animate().fadeIn(delay: 120.ms).slideY(begin: 0.06, end: 0),

            const SizedBox(height: 12),

            _GameTypeCard(
              icon: '👥',
              title: 'Doubles',
              subtitle: 'Organise a 2v2 doubles match',
              gradient: const [Color(0xFF1A7ABF), Color(0xFF5BA8E0)],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DoublesOrganiseScreen(isSingles: false)),
              ),
            ).animate().fadeIn(delay: 180.ms).slideY(begin: 0.06, end: 0),

            const SizedBox(height: 12),

            _GameTypeCard(
              icon: '🔓',
              title: 'Open Lobby',
              subtitle: 'Create a public slot for anyone to join',
              gradient: const [Color(0xFFC8431A), Color(0xFFF4956D)],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OpenLobbyScreen()),
              ),
            ).animate().fadeIn(delay: 240.ms).slideY(begin: 0.06, end: 0),
          ],
        ),
      ),
    );
  }
}

class _GameTypeCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _GameTypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(child: Text(icon, style: const TextStyle(fontSize: 24))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18, fontFamily: 'InstrumentSerif'),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white.withValues(alpha: 0.7), size: 18),
          ],
        ),
      ),
    );
  }
}
