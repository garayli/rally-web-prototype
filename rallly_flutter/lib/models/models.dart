// ─── models/player.dart ─────────────────────────────────────────────────────
class Player {
  final String id;
  final String name;
  final String initials;
  final String? avatarUrl;
  final double ntrpRating;
  final String location;
  final String about;
  final int wins;
  final int losses;
  final int matchesPlayed;
  final double winRate;
  final List<String> availability;   // e.g. ['Mon AM', 'Wed PM', 'Sat Full']
  final List<String> preferredCourts;
  final int matchScore;              // % compatibility
  final String avatarGradientStart;
  final String avatarGradientEnd;

  const Player({
    required this.id,
    required this.name,
    required this.initials,
    this.avatarUrl,
    required this.ntrpRating,
    required this.location,
    this.about = '',
    this.wins = 0,
    this.losses = 0,
    this.matchesPlayed = 0,
    this.winRate = 0,
    this.availability = const [],
    this.preferredCourts = const [],
    this.matchScore = 0,
    this.avatarGradientStart = '#5a8a00',
    this.avatarGradientEnd = '#8db600',
  });

  String get skillLabel {
    if (ntrpRating >= 4.5) return 'Advanced';
    if (ntrpRating >= 3.0) return 'Intermediate';
    return 'Beginner';
  }

  String get ntrpDisplay => ntrpRating.toStringAsFixed(1);
}

// ─── models/match.dart ───────────────────────────────────────────────────────
enum MatchStatus { confirmed, pending, completed, cancelled }
enum MatchFormat { singles, doubles }

class MatchSession {
  final String id;
  final Player opponent;
  final DateTime dateTime;
  final String court;
  final MatchStatus status;
  final MatchFormat format;
  final MatchResult? result;

  const MatchSession({
    required this.id,
    required this.opponent,
    required this.dateTime,
    required this.court,
    required this.status,
    this.format = MatchFormat.singles,
    this.result,
  });
}

class MatchResult {
  final String winnerId;
  final List<SetScore> sets;
  final double ratingDelta;

  const MatchResult({
    required this.winnerId,
    required this.sets,
    required this.ratingDelta,
  });
}

class SetScore {
  final int player1;
  final int player2;
  const SetScore(this.player1, this.player2);
}

// ─── models/notification.dart ────────────────────────────────────────────────
enum NotifType {
  matchRequest,
  matchConfirmed,
  matchDeclined,
  resultConfirmed,
  review,
  reminder,
  nearbyPlayer,
  cancellation,
}

class AppNotification {
  final String id;
  final NotifType type;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final String? avatarInitials;
  final String? avatarColor;
  final String? actionId;   // matchId, playerId etc.

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    this.avatarInitials,
    this.avatarColor,
    this.actionId,
  });

  bool get hasActions =>
      type == NotifType.matchRequest || type == NotifType.resultConfirmed;
}

// ─── models/message.dart ─────────────────────────────────────────────────────
class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool isRead;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.isRead = false,
  });
}

class Conversation {
  final String id;
  final Player other;
  final List<ChatMessage> messages;
  final bool isOnline;

  const Conversation({
    required this.id,
    required this.other,
    required this.messages,
    this.isOnline = false,
  });

  ChatMessage? get lastMessage => messages.isEmpty ? null : messages.last;
  int get unreadCount => messages.where((m) => !m.isRead && m.senderId != 'me').length;
}
