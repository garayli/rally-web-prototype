import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui' as ui;
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../models/models.dart';

class ResultCardScreen extends StatefulWidget {
  final Player opponent;
  final MatchResult result;

  const ResultCardScreen({
    super.key,
    required this.opponent,
    required this.result,
  });

  @override
  State<ResultCardScreen> createState() => _ResultCardScreenState();
}

class _ResultCardScreenState extends State<ResultCardScreen> {
  final _cardKey = GlobalKey();
  bool _sharing = false;

  bool get _iWon => widget.result.winnerId == 'me';

  String get _scoreString {
    return widget.result.sets
        .map((s) => '${s.player1}–${s.player2}')
        .join(', ');
  }

  Future<void> _shareCard() async {
    setState(() => _sharing = true);
    try {
      final boundary = _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final bytes = byteData.buffer.asUint8List();
      final xFile = XFile.fromData(bytes, mimeType: 'image/png', name: 'rallly-result.png');
      await Share.shareXFiles([xFile], text: 'Match result on Rallly 🎾');
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paylaşılamadı. Tekrar deneyin.')),
        );
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1F14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white70),
          onPressed: () => Navigator.popUntil(context, (r) => r.isFirst || r.settings.name == '/'),
        ),
        title: const Text(
          'Maç Sonucu',
          style: TextStyle(fontFamily: 'InstrumentSerif', fontSize: 22, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: RepaintBoundary(
                    key: _cardKey,
                    child: _ResultCard(
                      opponent: widget.opponent,
                      result: widget.result,
                      iWon: _iWon,
                      scoreString: _scoreString,
                    ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
                  ),
                ),
              ),
            ),

            // Share buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                children: [
                  RallyButton(
                    label: _sharing ? 'Paylaşılıyor…' : 'Sonucu Paylaş 🎾',
                    onPressed: _sharing ? null : _shareCard,
                    loading: _sharing,
                  ).animate().fadeIn(delay: 400.ms),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white38),
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                    child: const Text('Tamam'),
                  ).animate().fadeIn(delay: 450.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Result card widget ───────────────────────────────────────────────────────
class _ResultCard extends StatelessWidget {
  final Player opponent;
  final MatchResult result;
  final bool iWon;
  final String scoreString;

  const _ResultCard({
    required this.opponent,
    required this.result,
    required this.iWon,
    required this.scoreString,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A2818), Color(0xFF0F1A0C), Color(0xFF0A1208)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Rallly',
                style: TextStyle(fontFamily: 'InstrumentSerif', fontSize: 20, color: RallyColors.accent3, letterSpacing: -0.5),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: iWon ? RallyColors.accent.withValues(alpha: 0.2) : RallyColors.accent2.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: iWon ? RallyColors.accent : RallyColors.accent2),
                ),
                child: Text(
                  iWon ? 'Zafer 🏆' : 'Yenilgi',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: iWon ? RallyColors.accent3 : RallyColors.accent2,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Players
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _CardPlayer(label: 'Sen', initials: 'LG', gradientStart: '#7b4fa6', gradientEnd: '#a97fcb', isWinner: iWon),
              Column(
                children: [
                  Text(
                    scoreString,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'InstrumentSerif',
                      fontSize: 22,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text('vs', style: TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              ),
              _CardPlayer(
                label: opponent.name.split(' ').first,
                initials: opponent.initials,
                gradientStart: opponent.avatarGradientStart,
                gradientEnd: opponent.avatarGradientEnd,
                isWinner: !iWon,
              ),
            ],
          ),

          const SizedBox(height: 28),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.1)),
          const SizedBox(height: 16),

          // Rating delta
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                result.ratingDelta > 0 ? Icons.trending_up : Icons.trending_down,
                color: result.ratingDelta > 0 ? RallyColors.accent3 : RallyColors.accent2,
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                '${result.ratingDelta > 0 ? '+' : ''}${result.ratingDelta.toInt()} puan',
                style: TextStyle(
                  fontFamily: 'InstrumentSerif',
                  fontSize: 18,
                  letterSpacing: -0.5,
                  color: result.ratingDelta > 0 ? RallyColors.accent3 : RallyColors.accent2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardPlayer extends StatelessWidget {
  final String label;
  final String initials;
  final String gradientStart;
  final String gradientEnd;
  final bool isWinner;

  const _CardPlayer({
    required this.label,
    required this.initials,
    required this.gradientStart,
    required this.gradientEnd,
    required this.isWinner,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            PlayerAvatar(
              initials: initials,
              gradientStart: gradientStart,
              gradientEnd: gradientEnd,
              size: 60,
            ),
            if (isWinner)
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFFFD700)),
                child: const Center(child: Text('🏆', style: TextStyle(fontSize: 10))),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
