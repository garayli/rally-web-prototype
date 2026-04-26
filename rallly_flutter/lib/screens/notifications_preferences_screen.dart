import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/data_service.dart';
import '../theme/app_theme.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() => _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState extends State<NotificationPreferencesScreen> {
  late final Map<String, bool> _prefs = dataService.getNotifPrefs();

  bool _saved = false;

  void _save() {
    dataService.saveNotifPrefs(_prefs);
    setState(() => _saved = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _saved = false);
    });
    // TODO: persist to Supabase profiles.notification_prefs
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RallyColors.bg,
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontFamily: 'InstrumentSerif', fontSize: 22)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(
              _saved ? 'Saved ✓' : 'Save',
              style: TextStyle(
                color: _saved ? RallyColors.accent : RallyColors.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 40),
        children: [
          const _SectionHeader('MATCHES'),
          _PrefTile(
            icon: '🎾',
            title: 'Match Requests',
            subtitle: 'When someone wants to play with you',
            value: _prefs['match_requests']!,
            onChanged: (v) => setState(() => _prefs['match_requests'] = v),
          ).animate().fadeIn(delay: 60.ms),
          _PrefTile(
            icon: '✅',
            title: 'Match Confirmations',
            subtitle: 'When a request is accepted',
            value: _prefs['match_confirmations']!,
            onChanged: (v) => setState(() => _prefs['match_confirmations'] = v),
          ).animate().fadeIn(delay: 80.ms),
          _PrefTile(
            icon: '⏰',
            title: 'Match Reminders',
            subtitle: 'Reminder before your scheduled match',
            value: _prefs['match_reminders']!,
            onChanged: (v) => setState(() => _prefs['match_reminders'] = v),
          ).animate().fadeIn(delay: 100.ms),
          _PrefTile(
            icon: '❌',
            title: 'Cancellations',
            subtitle: 'When a match is cancelled',
            value: _prefs['match_cancellations']!,
            onChanged: (v) => setState(() => _prefs['match_cancellations'] = v),
          ).animate().fadeIn(delay: 120.ms),

          const _SectionHeader('SOCIAL'),
          _PrefTile(
            icon: '💬',
            title: 'Messages',
            subtitle: 'New messages from other players',
            value: _prefs['messages']!,
            onChanged: (v) => setState(() => _prefs['messages'] = v),
          ).animate().fadeIn(delay: 160.ms),
          _PrefTile(
            icon: '⭐',
            title: 'New Reviews',
            subtitle: 'When someone reviews you',
            value: _prefs['new_reviews']!,
            onChanged: (v) => setState(() => _prefs['new_reviews'] = v),
          ).animate().fadeIn(delay: 180.ms),
          _PrefTile(
            icon: '🏆',
            title: 'Result Confirmed',
            subtitle: 'When your opponent confirms a match result',
            value: _prefs['result_confirmed']!,
            onChanged: (v) => setState(() => _prefs['result_confirmed'] = v),
          ).animate().fadeIn(delay: 200.ms),
          _PrefTile(
            icon: '👋',
            title: 'Nearby Players',
            subtitle: 'When new players join your area',
            value: _prefs['nearby_players']!,
            onChanged: (v) => setState(() => _prefs['nearby_players'] = v),
          ).animate().fadeIn(delay: 220.ms),

          const _SectionHeader('UPDATES'),
          _PrefTile(
            icon: '📢',
            title: 'App Updates & Tips',
            subtitle: 'New features and playing tips',
            value: _prefs['marketing']!,
            onChanged: (v) => setState(() => _prefs['marketing'] = v),
          ).animate().fadeIn(delay: 260.ms),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: RallyColors.muted, letterSpacing: 0.8),
      ),
    );
  }
}

class _PrefTile extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final bool value;
  final void Function(bool) onChanged;

  const _PrefTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: RallyColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RallyColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: RallyColors.surface2, borderRadius: BorderRadius.circular(12)),
          child: Center(child: Text(icon, style: const TextStyle(fontSize: 18))),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: RallyColors.muted)),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: RallyColors.accent,
        ),
      ),
    );
  }
}
