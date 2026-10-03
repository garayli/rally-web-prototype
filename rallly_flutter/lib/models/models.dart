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
  // Self-reported during signup; editable from EditProfileScreen.
  final List<String> sports;
  final String? skillLevel;          // one of skillOptions values
  final List<String> availableDays;  // e.g. ['Pzt', 'Cmt']
  final List<String> timePrefs;      // e.g. ['Sabah', 'Akşam']

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
    this.sports = const [],
    this.skillLevel,
    this.availableDays = const [],
    this.timePrefs = const [],
  });

  String get skillLabel {
    if (ntrpRating >= 4.5) return 'İleri Seviye';
    if (ntrpRating >= 3.0) return 'Orta Seviye';
    return 'Başlangıç';
  }

  String get ntrpDisplay => ntrpRating.toStringAsFixed(1);

  factory Player.fromJson(Map<String, dynamic> j) => Player(
        id: j['id'] as String,
        name: j['name'] as String,
        initials: j['initials'] as String? ?? '',
        avatarUrl: j['avatar_url'] as String?,
        ntrpRating: (j['ntrp_rating'] as num).toDouble(),
        location: j['location'] as String? ?? '',
        about: j['about'] as String? ?? '',
        wins: j['wins'] as int? ?? 0,
        losses: j['losses'] as int? ?? 0,
        matchesPlayed: j['matches_played'] as int? ?? 0,
        winRate: (j['win_rate'] as num?)?.toDouble() ?? 0,
        availability: List<String>.from(j['availability'] as List? ?? []),
        preferredCourts: List<String>.from(j['preferred_courts'] as List? ?? []),
        matchScore: j['match_score'] as int? ?? 0,
        avatarGradientStart: j['avatar_gradient_start'] as String? ?? '#5a8a00',
        avatarGradientEnd: j['avatar_gradient_end'] as String? ?? '#8db600',
        sports: List<String>.from(j['sports'] as List? ?? []),
        skillLevel: j['skill_level'] as String?,
        availableDays: List<String>.from(j['available_days'] as List? ?? []),
        timePrefs: List<String>.from(j['time_prefs'] as List? ?? []),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'initials': initials,
        'avatar_url': avatarUrl,
        'ntrp_rating': ntrpRating,
        'location': location,
        'about': about,
        'wins': wins,
        'losses': losses,
        'matches_played': matchesPlayed,
        'win_rate': winRate,
        'availability': availability,
        'preferred_courts': preferredCourts,
        'match_score': matchScore,
        'avatar_gradient_start': avatarGradientStart,
        'avatar_gradient_end': avatarGradientEnd,
        'sports': sports,
        'skill_level': skillLevel,
        'available_days': availableDays,
        'time_prefs': timePrefs,
      };
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

  /// True when the signed-in user created the row (player1). Request status,
  /// set scores and the rating delta are all stored from player1's side.
  final bool isRequester;

  /// Set when the row is a request to join a lobby (`matches.lobby_id`).
  final String? lobbyId;

  const MatchSession({
    required this.id,
    required this.opponent,
    required this.dateTime,
    required this.court,
    required this.status,
    this.format = MatchFormat.singles,
    this.result,
    this.isRequester = true,
    this.lobbyId,
  });

  /// Still ahead of us: confirmed or awaiting an answer, and not long past.
  bool get isUpcoming =>
      (status == MatchStatus.confirmed || status == MatchStatus.pending) &&
      dateTime.isAfter(DateTime.now().subtract(const Duration(hours: 3)));

  /// A request someone else sent me that I haven't answered yet.
  bool get isIncomingRequest => status == MatchStatus.pending && !isRequester;

  /// Whether [userId] won; null while there is no result. `log_result_screen`
  /// stores `winner_id` only when player1 won, so for player2 an empty winner
  /// means player2 won.
  bool? wonBy(String userId) {
    final r = result;
    if (r == null) return null;
    if (r.winnerId == userId) return true;
    return !isRequester && r.winnerId.isEmpty;
  }

  /// Set scores from the signed-in user's point of view (own games first).
  List<SetScore> setsForMe() => result == null
      ? const []
      : isRequester
          ? result!.sets
          : [for (final s in result!.sets) SetScore(s.player2, s.player1)];

  /// Rating change from the signed-in user's point of view.
  double ratingDeltaForMe() => result == null
      ? 0
      : isRequester
          ? result!.ratingDelta
          : -result!.ratingDelta;

  factory MatchSession.fromJson(Map<String, dynamic> j) => MatchSession(
        id: j['id'] as String,
        opponent: Player.fromJson(j['opponent'] as Map<String, dynamic>),
        dateTime: DateTime.parse(j['date_time'] as String),
        court: j['court'] as String,
        status: MatchStatus.values.firstWhere(
          (e) => e.name == j['status'],
          orElse: () => MatchStatus.pending,
        ),
        format: MatchFormat.values.firstWhere(
          (e) => e.name == j['format'],
          orElse: () => MatchFormat.singles,
        ),
        result: j['result'] == null
            ? null
            : MatchResult.fromJson(j['result'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'opponent': opponent.toJson(),
        'date_time': dateTime.toIso8601String(),
        'court': court,
        'status': status.name,
        'format': format.name,
        'result': result?.toJson(),
      };
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

  factory MatchResult.fromJson(Map<String, dynamic> j) => MatchResult(
        winnerId: j['winner_id'] as String,
        sets: (j['sets'] as List)
            .map((s) => SetScore.fromJson(s as Map<String, dynamic>))
            .toList(),
        ratingDelta: (j['rating_delta'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'winner_id': winnerId,
        'sets': sets.map((s) => s.toJson()).toList(),
        'rating_delta': ratingDelta,
      };
}

class SetScore {
  final int player1;
  final int player2;
  const SetScore(this.player1, this.player2);

  factory SetScore.fromJson(Map<String, dynamic> j) =>
      SetScore(j['player1'] as int, j['player2'] as int);

  Map<String, dynamic> toJson() => {'player1': player1, 'player2': player2};
}

// ─── models/notification.dart ────────────────────────────────────────────────
enum NotifType {
  matchRequest,
  matchConfirmed,
  matchDeclined,
  resultConfirmed,
  resultPending,
  resultDisputed,
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
      type == NotifType.matchRequest || type == NotifType.resultPending;

  static NotifType _typeFromString(String s) =>
      NotifType.values.firstWhere((e) => e.name == s,
          orElse: () => NotifType.reminder);

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
        id: j['id'] as String,
        type: _typeFromString(j['type'] as String),
        title: j['title'] as String,
        body: j['body'] as String,
        timestamp: DateTime.parse(j['timestamp'] as String),
        isRead: j['is_read'] as bool? ?? false,
        avatarInitials: j['avatar_initials'] as String?,
        avatarColor: j['avatar_color'] as String?,
        actionId: j['action_id'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'title': title,
        'body': body,
        'timestamp': timestamp.toIso8601String(),
        'is_read': isRead,
        'avatar_initials': avatarInitials,
        'avatar_color': avatarColor,
        'action_id': actionId,
      };
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

  factory ChatMessage.fromJson(Map<String, dynamic> j) => ChatMessage(
        id: j['id'] as String,
        senderId: j['sender_id'] as String,
        text: j['text'] as String,
        timestamp: DateTime.parse(j['timestamp'] as String),
        isRead: j['is_read'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'sender_id': senderId,
        'text': text,
        'timestamp': timestamp.toIso8601String(),
        'is_read': isRead,
      };
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

  /// Pass the current user's ID so this works with real auth, not just the
  /// 'me' sentinel used in mock data.
  int unreadCount(String currentUserId) =>
      messages.where((m) => !m.isRead && m.senderId != currentUserId).length;

  factory Conversation.fromJson(Map<String, dynamic> j) => Conversation(
        id: j['id'] as String,
        other: Player.fromJson(j['other'] as Map<String, dynamic>),
        messages: (j['messages'] as List)
            .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
            .toList(),
        isOnline: j['is_online'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'other': other.toJson(),
        'messages': messages.map((m) => m.toJson()).toList(),
        'is_online': isOnline,
      };
}


/// An open game somebody organises. Counters come from DB triggers (see
/// `docs/migrations/2026-10-04_lobby_v2.sql`) so every user can see "full"
/// without being able to read other people's matches.
class Lobby {
  /// Max requests waiting for an answer before nobody else can ask.
  static const maxPending = 10;

  final String id;
  final String creatorId;
  final String sport;
  final String skillLevel;
  final DateTime? dateTime;
  final String court;
  final String? notes;
  final bool isDoubles;
  final String status; // open | full | closed | cancelled
  final int pendingCount;
  final int acceptedCount;

  const Lobby({
    required this.id,
    required this.creatorId,
    required this.sport,
    required this.skillLevel,
    required this.dateTime,
    required this.court,
    this.notes,
    this.isDoubles = false,
    this.status = 'open',
    this.pendingCount = 0,
    this.acceptedCount = 0,
  });

  /// Accepted players besides the organiser: 1 singles, 3 doubles.
  int get capacity => isDoubles ? 3 : 1;
  bool get rosterFull => status == 'full' || acceptedCount >= capacity;
  bool get queueFull => pendingCount >= maxPending;

  factory Lobby.fromJson(Map<String, dynamic> j) => Lobby(
        id: j['id'] as String,
        creatorId: j['creator_id'] as String,
        sport: j['sport'] as String? ?? 'Tenis',
        skillLevel: j['skill_level'] as String? ?? '',
        dateTime: DateTime.tryParse(j['date_time'] as String? ?? '')?.toLocal(),
        court: j['court'] as String? ?? '',
        notes: j['notes'] as String?,
        isDoubles: j['format'] == 'doubles',
        status: j['status'] as String? ?? 'open',
        pendingCount: (j['pending_count'] as num?)?.toInt() ?? 0,
        acceptedCount: (j['accepted_count'] as num?)?.toInt() ?? 0,
      );
}

/// Someone who asked to join a lobby (pending) or was accepted (confirmed).
class LobbyParticipant {
  final String matchId;
  final Player player;
  final bool accepted;
  const LobbyParticipant({
    required this.matchId,
    required this.player,
    required this.accepted,
  });
}
