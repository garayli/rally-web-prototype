import 'package:flutter/material.dart';
import '../config/court_options.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/data_service.dart';
import '../theme/app_theme.dart';
import '../main.dart' show CourtThemeProvider;
import 'shared_widgets.dart';
import '../l10n/l10n.dart';
import '../l10n/data_error_message.dart';

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
  static const _formats = ['Tekler', 'Çiftler'];

  String _selectedFormat = 'Tekler';
  late DateTime _selectedDateTime = _nextSaturdayAt10();
  // Default to a court the opponent already plays at, if any.
  late String _selectedCourt = widget.player.preferredCourts
          .where(courtOptions.contains)
          .firstOrNull ??
      courtOptions.first;
  late bool _sent = widget.alreadySent;
  bool _loading = false;

  static DateTime _nextSaturdayAt10() {
    final now = DateTime.now();
    var days = (DateTime.saturday - now.weekday) % 7;
    if (days == 0) days = 7;
    final d = now.add(Duration(days: days));
    return DateTime(d.year, d.month, d.day, 10);
  }

  static String _formatDateTime(DateTime dt, String locale) =>
      DateFormat('EEE dd.MM · HH:mm', locale).format(dt);

  Future<void> _pickFormat() async {
    final picked = await _pickFromList(
        context.l10n.format, _formats, _selectedFormat, _formatLabel);
    if (picked != null) setState(() => _selectedFormat = picked);
  }

  Future<void> _pickCourt() async {
    final picked = await _pickFromList(
        context.l10n.court, courtOptions, _selectedCourt, (_, c) => c);
    if (picked != null) setState(() => _selectedCourt = picked);
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 60)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (time == null) return;
    final picked =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
    if (picked.isBefore(now)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(context.l10n.pastTimeNotAllowed),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    setState(() => _selectedDateTime = picked);
  }

  Future<String?> _pickFromList(String title, List<String> options,
      String current, String Function(AppLocalizations, String) labelOf) {
    final cp = CourtThemeProvider.of(context);
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: cp.bg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: cp.text)),
            ),
            for (final o in options)
              ListTile(
                title: Text(labelOf(context.l10n, o), style: TextStyle(color: cp.text)),
                trailing: o == current
                    ? Icon(Icons.check, color: cp.accent)
                    : null,
                onTap: () => Navigator.pop(context, o),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  static String _formatLabel(AppLocalizations l, String format) =>
      format == 'Tekler' ? l.formatSingles : l.formatDoubles;

  Future<void> _sendRequest() async {
    if (_sent || _loading) return;
    setState(() => _loading = true);
    final cp = CourtThemeProvider.of(context);
    final l = context.l10n;
    try {
      await dataService.sendMatchRequest(
        opponentId: widget.player.id,
        proposedDate: _selectedDateTime,
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
            content: Text(l.matchRequestSentTo(widget.player.name)),
            backgroundColor: cp.accent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ));
        }
      });
    } catch (e) {
      debugPrint('MATCH REQUEST ERROR: $e');
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l.requestFailed(dataErrorMessage(l, e))),
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
                  Text(context.l10n.matchRequestTitle,
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
              label: context.l10n.format,
              value: _formatLabel(context.l10n, _selectedFormat),
              onTap: _sent ? () {} : _pickFormat),
          Divider(height: 1, color: cp.border),
          _SheetRow(
              cp: cp,
              icon: Icons.schedule,
              label: context.l10n.dateAndTime,
              value: _formatDateTime(_selectedDateTime, context.localeName),
              onTap: _sent ? () {} : _pickDateTime),
          Divider(height: 1, color: cp.border),
          _SheetRow(
              cp: cp,
              icon: Icons.location_on_outlined,
              label: context.l10n.court,
              value: _selectedCourt,
              onTap: _sent ? () {} : _pickCourt),
          const SizedBox(height: 24),
          RallyButton(
            label: _sent ? context.l10n.requestSent : context.l10n.sendRequest,
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
            const SizedBox(width: 12),
            // Long court names must ellipsize, not overflow the row.
            Expanded(
              child: Text(value,
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: cp.text)),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 18, color: cp.muted),
          ],
        ),
      ),
    );
  }
}
