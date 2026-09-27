import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/data_service.dart';
import '../theme/app_theme.dart';
import '../main.dart' show CourtThemeProvider;
import 'shared_widgets.dart';

/// Opens the real match-request sheet for [player]. Every "Maç İste" entry
/// point (Match tab, player profile, conversation, map) must go through this
/// so the request is actually written via `dataService.sendMatchRequest`.
Future<void> showMatchRequestSheet(
  BuildContext context,
  Player player, {
  bool alreadySent = false,
  VoidCallback? onSent,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => MatchRequestSheet(
      player: player,
      alreadySent: alreadySent,
      onSent: onSent ?? () {},
    ),
  );
}

// ─── Request match sheet ──────────────────────────────────────────────────────
class MatchRequestSheet extends StatefulWidget {
  final Player player;
  final bool alreadySent;
  final VoidCallback onSent;
  const MatchRequestSheet({
    super.key,
    required this.player,
    required this.alreadySent,
    required this.onSent,
  });

  @override
  State<MatchRequestSheet> createState() => _MatchRequestSheetState();
}

class _MatchRequestSheetState extends State<MatchRequestSheet> {
  final String _selectedFormat = 'Tekler';
  final String _selectedTime = 'Cumartesi 10:00';
  final String _selectedCourt = 'Caddebostan Tenis Kortları';
  late bool _sent = widget.alreadySent;
  bool _loading = false;

  Future<void> _sendRequest() async {
    if (_sent || _loading) return;
    setState(() => _loading = true);
    final cp = CourtThemeProvider.of(context);
    try {
      final proposedDate = DateTime.now().add(const Duration(days: 7));
      await dataService.sendMatchRequest(
        opponentId: widget.player.id,
        proposedDate: proposedDate,
        court: _selectedCourt,
        format: _selectedFormat == 'Tekler' ? 'singles' : 'doubles',
      );
      if (!mounted) return;
      setState(() {
        _sent = true;
        _loading = false;
      });
      widget.onSent();
      final nav = Navigator.of(context);
      final messenger = ScaffoldMessenger.of(context);
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) {
          nav.pop();
          messenger.showSnackBar(SnackBar(
            content:
                Text('${widget.player.name} oyuncusuna maç isteği gönderildi!'),
            backgroundColor: cp.accent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ));
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('İstek gönderilemedi: $e'),
        backgroundColor: RallyColors.accent2,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cp = CourtThemeProvider.of(context);
    return Container(
      decoration: BoxDecoration(
        color: cp.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
          24,
          16,
          24,
          MediaQuery.of(context).viewInsets.bottom +
              MediaQuery.of(context).padding.bottom +
              28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: cp.muted2,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              PlayerAvatar(
                initials: widget.player.initials,
                gradientStart: widget.player.avatarGradientStart,
                gradientEnd: widget.player.avatarGradientEnd,
                size: 46,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Maç İsteği',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700, color: cp.text)),
                  Text(widget.player.name,
                      style: TextStyle(color: cp.text2, fontSize: 13)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SheetRow(
              cp: cp,
              icon: Icons.sports_tennis,
              label: 'Format',
              value: _selectedFormat,
              onTap: () {}),
          Divider(height: 1, color: cp.border),
          _SheetRow(
              cp: cp,
              icon: Icons.schedule,
              label: 'Saat',
              value: _selectedTime,
              onTap: () {}),
          Divider(height: 1, color: cp.border),
          _SheetRow(
              cp: cp,
              icon: Icons.location_on_outlined,
              label: 'Kort',
              value: _selectedCourt,
              onTap: () {}),
          const SizedBox(height: 24),
          RallyButton(
            label: _sent ? 'İstek Gönderildi ✓' : 'İstek Gönder 🎾',
            loading: _loading,
            onPressed: (_sent || _loading) ? null : _sendRequest,
          ),
        ],
      ),
    );
  }
}

class _SheetRow extends StatelessWidget {
  final CourtPalette cp;
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _SheetRow(
      {required this.cp,
      required this.icon,
      required this.label,
      required this.value,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 18, color: cp.muted),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(color: cp.text2, fontSize: 14)),
            const Spacer(),
            Text(value,
                style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14, color: cp.text)),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 18, color: cp.muted),
          ],
        ),
      ),
    );
  }
}
