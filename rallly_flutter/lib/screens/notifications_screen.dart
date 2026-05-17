import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/models.dart';
import '../services/data_service.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';
import '../main.dart' show CourtThemeProvider;

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<AppNotification> _notifs;
  String _filter = 'Tümü';

  static const _filters = ['Tümü', 'Maç İstekleri', 'Sistem'];

  @override
  void initState() {
    super.initState();
    _notifs = dataService.getNotifications();
  }

  List<AppNotification> get _filtered {
    if (_filter == 'Maç İstekleri') {
      return _notifs
          .where((n) =>
              n.type == NotifType.matchRequest ||
              n.type == NotifType.matchConfirmed ||
              n.type == NotifType.matchDeclined ||
              n.type == NotifType.resultConfirmed)
          .toList();
    }
    if (_filter == 'Sistem') {
      return _notifs
          .where((n) =>
              n.type == NotifType.review ||
              n.type == NotifType.reminder ||
              n.type == NotifType.nearbyPlayer ||
              n.type == NotifType.cancellation)
          .toList();
    }
    return _notifs;
  }

  void _accept(AppNotification n) {
    setState(() {
      final i = _notifs.indexOf(n);
      _notifs[i] = AppNotification(
        id: n.id,
        type: NotifType.matchConfirmed,
        title: 'Maç Kabul Edildi',
        body: n.body,
        timestamp: n.timestamp,
        isRead: true,
        avatarInitials: n.avatarInitials,
        avatarColor: n.avatarColor,
      );
    });
  }

  void _decline(AppNotification n) {
    setState(() => _notifs.removeWhere((x) => x.id == n.id));
  }

  void _markAllRead() {
    dataService.markAllRead();
    setState(() {
      _notifs = _notifs
          .map((n) => AppNotification(
                id: n.id,
                type: n.type,
                title: n.title,
                body: n.body,
                timestamp: n.timestamp,
                isRead: true,
                avatarInitials: n.avatarInitials,
                avatarColor: n.avatarColor,
                actionId: n.actionId,
              ))
          .toList();
    });
  }

  String _groupLabel(AppNotification n) {
    final diff = DateTime.now().difference(n.timestamp);
    if (diff.inHours < 24) return 'Bugün';
    if (diff.inHours < 48) return 'Dün';
    return 'Bu Hafta';
  }

  @override
  Widget build(BuildContext context) {
    final cp = CourtThemeProvider.of(context);
    final notifs = _filtered;

    final Map<String, List<AppNotification>> groups = {};
    for (final n in notifs) {
      groups.putIfAbsent(_groupLabel(n), () => []).add(n);
    }
    const groupOrder = ['Bugün', 'Dün', 'Bu Hafta'];
    final unreadCount = _notifs.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: cp.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  Spacing.gutter, Spacing.lg, Spacing.md, Spacing.sm),
              child: Row(
                children: [
                  Text(
                    'Bildirimler',
                    style: TextStyle(
                      fontFamily: 'InstrumentSerif',
                      fontSize: 24,
                      color: cp.text,
                    ),
                  ),
                  if (unreadCount > 0) ...[
                    const SizedBox(width: Spacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: cp.accent,
                        borderRadius: BorderRadius.circular(RallyRadius.pill),
                      ),
                      child: Text(
                        '$unreadCount',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (unreadCount > 0)
                    GestureDetector(
                      onTap: _markAllRead,
                      child: Text(
                        'Tümünü oku',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: cp.accent,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ─── Filter chips ────────────────────────────────────────────
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: Spacing.gutter),
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: Spacing.sm),
                itemBuilder: (context, i) {
                  final f = _filters[i];
                  final active = _filter == f;
                  return GestureDetector(
                    onTap: () => setState(() => _filter = f),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.lg, vertical: 8),
                      decoration: BoxDecoration(
                        color: active ? cp.accent : cp.surface,
                        borderRadius:
                            BorderRadius.circular(RallyRadius.pill),
                        border: Border.all(
                          color: active ? cp.accent : cp.border,
                        ),
                      ),
                      child: Text(
                        f,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: active ? Colors.white : cp.muted,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: Spacing.md),

            // ─── List ────────────────────────────────────────────────────
            Expanded(
              child: notifs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.notifications_none,
                              size: 48, color: cp.muted),
                          const SizedBox(height: Spacing.md),
                          Text(
                            'Bildirim yok',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: cp.muted,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      padding:
                          const EdgeInsets.only(bottom: 100),
                      children: [
                        for (final group in groupOrder)
                          if (groups.containsKey(group)) ...[
                            _GroupHeader(title: group, cp: cp),
                            for (final n in groups[group]!)
                              _NotifTile(
                                notif: n,
                                cp: cp,
                                onAccept: () => _accept(n),
                                onDecline: () => _decline(n),
                              )
                                  .animate()
                                  .fadeIn(delay: 50.ms)
                                  .slideY(begin: 0.04, end: 0),
                          ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Group header ──────────────────────────────────────────────────────────────
class _GroupHeader extends StatelessWidget {
  final String title;
  final CourtPalette cp;
  const _GroupHeader({required this.title, required this.cp});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Spacing.gutter, Spacing.lg, Spacing.gutter, Spacing.sm),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: cp.muted,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ─── Notification tile ─────────────────────────────────────────────────────────
class _NotifTile extends StatelessWidget {
  final AppNotification notif;
  final CourtPalette cp;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _NotifTile({
    required this.notif,
    required this.cp,
    required this.onAccept,
    required this.onDecline,
  });

  static Color _hex(String hex, Color fallback) {
    try {
      final h = hex.replaceFirst('#', '');
      if (h.length != 6) return fallback;
      return Color(int.parse('FF$h', radix: 16));
    } catch (_) {
      return fallback;
    }
  }

  IconData get _icon {
    switch (notif.type) {
      case NotifType.matchRequest:
        return Icons.sports_tennis;
      case NotifType.matchConfirmed:
        return Icons.check_circle_outline;
      case NotifType.matchDeclined:
        return Icons.cancel_outlined;
      case NotifType.resultConfirmed:
        return Icons.emoji_events_outlined;
      case NotifType.review:
        return Icons.star_outline;
      case NotifType.reminder:
        return Icons.alarm_outlined;
      case NotifType.nearbyPlayer:
        return Icons.person_add_outlined;
      case NotifType.cancellation:
        return Icons.event_busy_outlined;
    }
  }

  bool get _isWarning =>
      notif.type == NotifType.matchDeclined ||
      notif.type == NotifType.cancellation;

  bool get _isSuccess =>
      notif.type == NotifType.matchConfirmed ||
      notif.type == NotifType.resultConfirmed;

  @override
  Widget build(BuildContext context) {
    final Color iconBg = _isWarning
        ? const Color(0xFFFEE2E2)
        : _isSuccess
            ? cp.accentTint
            : cp.accentTint;
    final Color iconFg = _isWarning
        ? const Color(0xFFDC2626)
        : cp.accentStrong;

    final avatarColor = notif.avatarColor != null
        ? _hex(notif.avatarColor!, cp.accent)
        : cp.accent;

    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: Spacing.gutter, vertical: 4),
      decoration: BoxDecoration(
        color: notif.isRead ? cp.surface : cp.accentTint,
        borderRadius: BorderRadius.circular(RallyRadius.xl),
        border: Border.all(
          color: notif.isRead ? cp.border : cp.accent.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon circle
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: notif.avatarInitials != null
                        ? avatarColor.withValues(alpha: 0.12)
                        : iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: notif.avatarInitials != null
                        ? Text(
                            notif.avatarInitials!,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: notif.avatarInitials!.length == 1
                                  ? 20
                                  : 13,
                              color: avatarColor,
                            ),
                          )
                        : Icon(_icon, size: 20, color: iconFg),
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              notif.title,
                              style: TextStyle(
                                fontWeight: notif.isRead
                                    ? FontWeight.w600
                                    : FontWeight.w700,
                                fontSize: 14,
                                color: cp.text,
                              ),
                            ),
                          ),
                          const SizedBox(width: Spacing.sm),
                          if (!notif.isRead)
                            Container(
                              width: 7,
                              height: 7,
                              margin: const EdgeInsets.only(top: 4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: cp.accent,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        notif.body,
                        style: TextStyle(
                          fontSize: 13,
                          color: cp.text2,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _timeAgo(notif.timestamp),
                        style: TextStyle(fontSize: 11, color: cp.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Action buttons for match requests
            if (notif.hasActions && notif.type == NotifType.matchRequest) ...[
              const SizedBox(height: Spacing.md),
              Row(
                children: [
                  Expanded(
                    child: _ActionBtn(
                      label: 'Reddet',
                      outlined: true,
                      cp: cp,
                      onTap: onDecline,
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: _ActionBtn(
                      label: 'Kabul Et',
                      cp: cp,
                      onTap: onAccept,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} dk önce';
    if (diff.inHours < 24) return '${diff.inHours} sa önce';
    return DateFormat('d MMM').format(dt);
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final bool outlined;
  final CourtPalette cp;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    this.outlined = false,
    required this.cp,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : cp.accent,
          borderRadius: BorderRadius.circular(RallyRadius.pill),
          border: Border.all(
            color: outlined ? cp.border : cp.accent,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: outlined ? cp.text : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
