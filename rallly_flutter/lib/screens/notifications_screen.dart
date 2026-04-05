import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/models.dart';
import '../services/mock_data.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<AppNotification> _notifs;

  @override
  void initState() {
    super.initState();
    _notifs = List.from(MockData.notifications);
  }

  void _accept(AppNotification n) {
    setState(() {
      final i = _notifs.indexOf(n);
      _notifs[i] = AppNotification(
        id: n.id,
        type: NotifType.matchConfirmed,
        title: 'Match Accepted ✓',
        body: n.body,
        timestamp: n.timestamp,
        isRead: true,
        avatarInitials: n.avatarInitials,
        avatarColor: n.avatarColor,
      );
    });
  }

  void _decline(AppNotification n) {
    setState(() {
      _notifs.removeWhere((x) => x.id == n.id);
    });
  }

  String _groupLabel(AppNotification n) {
    final now = DateTime.now();
    final diff = now.difference(n.timestamp);
    if (diff.inHours < 24) return 'Today';
    if (diff.inHours < 48) return 'Yesterday';
    return 'This Week';
  }

  @override
  Widget build(BuildContext context) {
    // Group notifications
    final Map<String, List<AppNotification>> groups = {};
    for (final n in _notifs) {
      final g = _groupLabel(n);
      groups.putIfAbsent(g, () => []).add(n);
    }
    final groupOrder = ['Today', 'Yesterday', 'This Week'];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(
        title: const Text('Notifications',
            style: TextStyle(fontFamily: 'InstrumentSerif', fontSize: 22)),
        actions: [
          TextButton(
            onPressed: () => setState(
                () => _notifs = _notifs.map((n) => AppNotification(
                      id: n.id,
                      type: n.type,
                      title: n.title,
                      body: n.body,
                      timestamp: n.timestamp,
                      isRead: true,
                      avatarInitials: n.avatarInitials,
                      avatarColor: n.avatarColor,
                      actionId: n.actionId,
                    )).toList()),
            child: const Text('Mark all read',
                style: TextStyle(
                    color: Color(0xFF5A8A00), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: ListView(
        children: [
          for (final group in groupOrder)
            if (groups.containsKey(group)) ...[
              _GroupHeader(title: group),
              for (final n in groups[group]!)
                _NotifTile(
                  notif: n,
                  onAccept: () => _accept(n),
                  onDecline: () => _decline(n),
                ).animate().fadeIn(delay: 60.ms),
            ],
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

// ─── Group header ─────────────────────────────────────────────────────────────
class _GroupHeader extends StatelessWidget {
  final String title;
  const _GroupHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF9CA3AF),
          letterSpacing: 1,
        ),
      ),
    );
  }
}

// ─── Notification tile ────────────────────────────────────────────────────────
class _NotifTile extends StatelessWidget {
  final AppNotification notif;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _NotifTile({
    required this.notif,
    required this.onAccept,
    required this.onDecline,
  });

  static Color _hex(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  IconData get _icon {
    switch (notif.type) {
      case NotifType.matchRequest: return Icons.sports_tennis;
      case NotifType.matchConfirmed: return Icons.check_circle_outline;
      case NotifType.matchDeclined: return Icons.cancel_outlined;
      case NotifType.resultConfirmed: return Icons.emoji_events_outlined;
      case NotifType.review: return Icons.star_outline;
      case NotifType.reminder: return Icons.alarm;
      case NotifType.nearbyPlayer: return Icons.person_add_outlined;
      case NotifType.cancellation: return Icons.event_busy;
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarColor = notif.avatarColor != null
        ? _hex(notif.avatarColor!)
        : const Color(0xFF5A8A00);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: notif.isRead ? Colors.white : const Color(0xFFF0F6F0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0D8CC)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: avatarColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: avatarColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Center(
                    child: notif.avatarInitials?.length == 1
                        ? Text(notif.avatarInitials!,
                            style: const TextStyle(fontSize: 20))
                        : Text(
                            notif.avatarInitials ?? '?',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: avatarColor,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(notif.title,
                                style: TextStyle(
                                  fontWeight: notif.isRead
                                      ? FontWeight.w600
                                      : FontWeight.w700,
                                  fontSize: 14,
                                )),
                          ),
                          if (!notif.isRead)
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF5A8A00),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(notif.body,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF4B5563),
                            height: 1.4,
                          )),
                      const SizedBox(height: 5),
                      Text(
                        _timeAgo(notif.timestamp),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Action buttons for match requests
            if (notif.hasActions &&
                notif.type == NotifType.matchRequest) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _ActionBtn(
                      label: 'Decline',
                      outlined: true,
                      onTap: onDecline,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ActionBtn(
                      label: 'Accept',
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
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('MMM d').format(dt);
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final bool outlined;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    this.outlined = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : const Color(0xFF5A8A00),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: outlined
                ? const Color(0xFFD4C8B8)
                : const Color(0xFF5A8A00),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: outlined
                  ? const Color(0xFF111827)
                  : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
