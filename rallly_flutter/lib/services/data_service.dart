import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

// ─── Abstract data interface ──────────────────────────────────────────────────
// All screens talk to DataService, never to Supabase directly (messages_screen's
// send path is the one deliberate exception, since it needs low-latency optimistic
// inserts). SupabaseDataService below is the only implementation.
abstract class DataService {
  /// The current user's ID — Supabase auth user id.
  String get currentUserId;

  /// Fetches players, matches and conversations from Supabase and populates
  /// the synchronous caches below. Call once (e.g. from MainShell.initState)
  /// before relying on getPlayers()/getConversations()/getUpcomingSessions().
  Future<void> warmCache();

  /// Bumped every time warmCache() (or a mutation that re-warms the cache)
  /// completes — screens listen to this via ValueListenableBuilder to rebuild.
  ValueNotifier<int> get cacheVersion;

  List<Player> getPlayers();

  /// The signed-in user's own profile, or null if warmCache() hasn't
  /// populated the cache yet (e.g. before the auth/signup flow completes).
  Player? getCurrentPlayer();
  List<Conversation> getConversations();
  List<MatchSession> getUpcomingSessions();

  Future<List<AppNotification>> getNotifications();
  int getUnreadCount();
  Future<void> markAllRead();

  /// Reactive unread count — listen to this to auto-update badges anywhere.
  ValueNotifier<int> get unreadNotifier;

  /// Notification preferences — kept in memory; there's no persistence table
  /// for this yet, so it resets on app restart.
  Map<String, bool> getNotifPrefs();
  void saveNotifPrefs(Map<String, bool> prefs);

  /// Mark a conversation as read (all incoming messages seen).
  /// [conversationId] is the other participant's player id.
  void markConversationRead(String conversationId);
  bool isConversationRead(String conversationId);

  Future<void> sendMatchRequest({
    required String opponentId,
    required DateTime proposedDate,
    required String court,
    required String format,
  });

  Future<void> confirmResult({
    required String matchId,
    required String notificationId,
  });

  Future<void> disputeResult({
    required String matchId,
    required String notificationId,
  });
}

// ─── Supabase implementation ───────────────────────────────────────────────────
class SupabaseDataService implements DataService {
  SupabaseClient get _client => Supabase.instance.client;

  @override
  String get currentUserId => _client.auth.currentUser!.id;

  Map<String, Player> _playersById = {};
  List<Player> _players = [];
  List<MatchSession> _sessions = [];
  List<Conversation> _conversations = [];

  final ValueNotifier<int> _cacheVersion = ValueNotifier(0);
  @override
  ValueNotifier<int> get cacheVersion => _cacheVersion;

  final ValueNotifier<int> _unreadNotifier = ValueNotifier(0);
  @override
  ValueNotifier<int> get unreadNotifier => _unreadNotifier;

  @override
  Future<void> warmCache() async {
    final me = currentUserId;

    final profileRows = await _client.from('profiles').select();
    _playersById = {
      for (final r in profileRows) r['id'] as String: Player.fromJson(r),
    };
    _players = _playersById.values.where((p) => p.id != me).toList();

    final matchRows = await _client
        .from('matches')
        .select()
        .or('player1_id.eq.$me,player2_id.eq.$me')
        .order('date_time', ascending: false);
    _sessions = matchRows.map((r) => _matchFromRow(r, me)).toList();

    final messageRows = await _client
        .from('messages')
        .select()
        .or('sender_id.eq.$me,receiver_id.eq.$me')
        .order('created_at');
    _conversations = _buildConversations(messageRows, me);

    await _refreshUnreadCount();
    _cacheVersion.value++;
  }

  MatchSession _matchFromRow(Map<String, dynamic> r, String me) {
    final isPlayer1 = r['player1_id'] == me;
    final opponentId =
        isPlayer1 ? r['player2_id'] as String? : r['player1_id'] as String?;
    final opponent = opponentId != null
        ? (_playersById[opponentId] ?? _placeholderPlayer(opponentId, 'Oyuncu'))
        : _placeholderPlayer(
            'guest_${r['id']}', r['opponent_name'] as String? ?? 'Misafir');

    MatchResult? result;
    final sets = r['sets'] as List?;
    if (r['status'] == 'completed' && sets != null) {
      result = MatchResult(
        winnerId: r['winner_id'] as String? ?? '',
        sets: sets
            .map((s) => SetScore(s['player1'] as int, s['player2'] as int))
            .toList(),
        ratingDelta: (r['rating_delta'] as num?)?.toDouble() ?? 0,
      );
    }

    return MatchSession(
      id: r['id'] as String,
      opponent: opponent,
      dateTime: DateTime.parse(r['date_time'] as String),
      court: r['court'] as String? ?? '',
      status: MatchStatus.values.firstWhere(
        (e) => e.name == r['status'],
        orElse: () => MatchStatus.pending,
      ),
      format: MatchFormat.values.firstWhere(
        (e) => e.name == r['format'],
        orElse: () => MatchFormat.singles,
      ),
      result: result,
    );
  }

  List<Conversation> _buildConversations(
      List<Map<String, dynamic>> rows, String me) {
    final byOther = <String, List<ChatMessage>>{};
    for (final r in rows) {
      final senderId = r['sender_id'] as String;
      final receiverId = r['receiver_id'] as String?;
      final otherId = senderId == me ? receiverId : senderId;
      if (otherId == null) continue;
      (byOther[otherId] ??= []).add(ChatMessage(
        id: r['id'] as String,
        senderId: senderId,
        text: r['text'] as String,
        timestamp: DateTime.parse(r['created_at'] as String),
        isRead: r['is_read'] as bool? ?? false,
      ));
    }
    return byOther.entries.map((e) {
      final other = _playersById[e.key] ?? _placeholderPlayer(e.key, 'Oyuncu');
      return Conversation(id: e.key, other: other, messages: e.value);
    }).toList();
  }

  Player _placeholderPlayer(String id, String name) => Player(
        id: id,
        name: name,
        initials: _initialsFrom(name),
        ntrpRating: 3.0,
        location: '',
      );

  String _initialsFrom(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  Future<void> _refreshUnreadCount() async {
    final rows = await _client
        .from('notifications')
        .select('id')
        .eq('user_id', currentUserId)
        .eq('is_read', false);
    _unreadNotifier.value = rows.length;
  }

  @override
  List<Player> getPlayers() => _players;

  @override
  Player? getCurrentPlayer() => _playersById[currentUserId];

  @override
  List<Conversation> getConversations() => _conversations;

  @override
  List<MatchSession> getUpcomingSessions() => _sessions;

  @override
  Future<List<AppNotification>> getNotifications() async {
    final rows = await _client
        .from('notifications')
        .select()
        .eq('user_id', currentUserId)
        .order('created_at', ascending: false);
    return rows.map((r) => AppNotification(
          id: r['id'] as String,
          type: NotifType.values.firstWhere(
            (e) => e.name == r['type'],
            orElse: () => NotifType.reminder,
          ),
          title: r['title'] as String,
          body: r['body'] as String,
          timestamp: DateTime.parse(r['created_at'] as String),
          isRead: r['is_read'] as bool? ?? false,
          avatarInitials: r['avatar_initials'] as String?,
          avatarColor: r['avatar_color'] as String?,
          actionId: r['action_id'] as String?,
        )).toList();
  }

  @override
  int getUnreadCount() => _unreadNotifier.value;

  @override
  Future<void> markAllRead() async {
    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', currentUserId)
        .eq('is_read', false);
    _unreadNotifier.value = 0;
  }

  final Map<String, bool> _notifPrefs = {
    'match_requests': true,
    'match_confirmations': true,
    'match_reminders': true,
    'match_cancellations': true,
    'messages': true,
    'new_reviews': true,
    'result_confirmed': true,
    'nearby_players': false,
    'marketing': false,
  };

  @override
  Map<String, bool> getNotifPrefs() => Map.from(_notifPrefs);

  @override
  void saveNotifPrefs(Map<String, bool> prefs) => _notifPrefs.addAll(prefs);

  final Set<String> _readConversationIds = {};

  @override
  void markConversationRead(String conversationId) {
    _readConversationIds.add(conversationId);
    _client
        .from('messages')
        .update({'is_read': true})
        .eq('sender_id', conversationId)
        .eq('receiver_id', currentUserId)
        .then((_) {}, onError: (_) {});
  }

  @override
  bool isConversationRead(String conversationId) =>
      _readConversationIds.contains(conversationId);

  @override
  Future<void> sendMatchRequest({
    required String opponentId,
    required DateTime proposedDate,
    required String court,
    required String format,
  }) async {
    await _client.from('matches').insert({
      'player1_id': currentUserId,
      'player2_id': opponentId,
      'date_time': proposedDate.toIso8601String(),
      'court': court,
      'format': format,
      'status': 'pending',
    });
    await warmCache();
  }

  @override
  Future<void> confirmResult({
    required String matchId,
    required String notificationId,
  }) async {
    await _client.from('matches').update({
      'result_status': 'confirmed',
      'result_confirmed_at': DateTime.now().toIso8601String(),
    }).eq('id', matchId);
    await _client
        .from('notifications')
        .update({'is_read': true}).eq('id', notificationId);
    await _refreshUnreadCount();
  }

  @override
  Future<void> disputeResult({
    required String matchId,
    required String notificationId,
  }) async {
    await _client
        .from('matches')
        .update({'result_status': 'disputed'}).eq('id', matchId);
    await _client
        .from('notifications')
        .update({'is_read': true}).eq('id', notificationId);
    await _refreshUnreadCount();
  }
}

// ─── Global accessor ──────────────────────────────────────────────────────────
final DataService dataService = SupabaseDataService();
