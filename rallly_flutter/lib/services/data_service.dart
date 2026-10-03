import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;
import '../config/profile_options.dart';
import '../models/models.dart';
import '../utils/initials.dart';
import '../utils/profile_check.dart';
import '../utils/uuid.dart';
import '../main.dart' show supabase;

/// Why a DataService write failed. The UI maps these to localized text with
/// `dataErrorMessage()` — never put user-facing strings in the data layer.
enum DataError {
  notSignedIn,
  recipientNotRegistered,
  matchUpdateDenied,
  ownLobby,
  alreadyRequested,
  lobbyQueueFull,
  lobbyFull,
  lobbyClosed,
}

class DataException implements Exception {
  final DataError error;
  const DataException(this.error);

  @override
  String toString() => 'DataException(${error.name})';
}

// ─── Abstract data interface ──────────────────────────────────────────────────
// All screens talk to DataService, never to MockData directly.
// To connect Supabase: implement SupabaseDataService and swap the global below.
abstract class DataService {
  /// The current user's real Supabase auth id; falls back to the 'me'
  /// sentinel only when there's no authenticated session (e.g. widget tests).
  String get currentUserId;

  List<Player> getPlayers();

  /// The signed-in user's own profile, populated by warmCache(); null before
  /// the first successful warmCache() or when there's no authenticated user.
  Player? getCurrentPlayer();
  List<Conversation> getConversations();
  List<MatchSession> getUpcomingSessions();

  /// Fetches players/conversations/sessions from Supabase and populates the
  /// caches backing the getters above. Call once after login (before the
  /// tabbed shell builds) and again after any write that should be reflected
  /// live (e.g. sendMatchRequest). Never throws — failures leave caches empty.
  Future<void> warmCache();

  /// Bumped every time a cache refresh completes — screens kept alive by
  /// IndexedStack can listen to this to know when to re-read the getters.
  ValueNotifier<int> get cacheVersion;

  /// Re-fetches what *other* users can change under us — conversations,
  /// upcoming sessions, notifications — and bumps [cacheVersion] only when
  /// something actually changed. Polled by MainShell (and faster by an open
  /// ConversationScreen); there is no Realtime subscription yet. Never throws.
  Future<void> refreshLive();

  /// Inserts a message to [receiverId] and refreshes the conversation cache
  /// before returning. Throws on failure so the caller can mark it unsent.
  Future<void> sendMessage({required String receiverId, required String text});

  /// Reads real notification rows from Supabase for the current user.
  Future<List<AppNotification>> getNotifications();

  /// Number of unread notifications — drives badge counts across the app.
  int getUnreadCount();

  /// Mark all notifications as read in Supabase.
  Future<void> markAllRead();

  /// Opponent explicitly confirms a pending result.
  Future<void> confirmResult({
    required String matchId,
    required String notificationId,
  });

  /// Opponent explicitly disputes a pending result.
  Future<void> disputeResult({
    required String matchId,
    required String notificationId,
  });

  /// Opponent accepts/declines a match request: sets `matches.status` to
  /// confirmed/cancelled, then rewrites the notification so the choice
  /// survives reloads. Throws if the match row couldn't be updated.
  ///
  /// [notificationId] is the request notification to retire; when null (the
  /// lobby management sheet has no notification in hand) it is looked up by
  /// `action_id`. Accepting into a full lobby throws [DataError.lobbyFull].
  Future<void> respondToMatchRequest({
    required String matchId,
    String? notificationId,
    required bool accept,
  });

  /// Reactive unread count — listen to this to auto-update badges anywhere.
  ValueNotifier<int> get unreadNotifier;

  /// Notification preferences — persisted in memory (Supabase when ready).
  Map<String, bool> getNotifPrefs();
  void saveNotifPrefs(Map<String, bool> prefs);

  /// Mark a conversation as read (all incoming messages seen).
  void markConversationRead(String conversationId);
  bool isConversationRead(String conversationId);

  /// Saves the signed-in user's editable profile fields to `profiles`, then
  /// refreshes getCurrentPlayer() and bumps cacheVersion. Throws on failure
  /// so the caller can show an error.
  Future<void> updateMyProfile({
    required String name,
    required String location,
    required String about,
    required List<String> sports,
    required String? skillLevel,
    required List<String> availableDays,
    required List<String> timePrefs,
  });

  /// Whether the signed-in user already has a named profile row. Decides if a
  /// freshly verified login goes to the signup wizard or straight home. The
  /// `handle_new_user` trigger creates a placeholder row ('New Player') on
  /// auth signup, so a row alone doesn't count as a finished profile.
  Future<bool> hasCompletedProfile();

  /// Asks to join an open lobby. A lobby has no join table, so this is a
  /// match request to the lobby's creator (same RLS, notification and
  /// Kabul/Reddet flow as "Maç İste"). Throws [DataError.ownLobby] for the
  /// user's own lobby, [DataError.alreadyRequested] for a repeat request, and
  /// [DataError.lobbyQueueFull] / [lobbyFull] / [lobbyClosed] when the server
  /// refuses (10 pending requests, roster complete, organiser closed it).
  Future<void> joinLobby({
    required String lobbyId,
    required String creatorId,
    required DateTime dateTime,
    required String court,
    required String sport,
  });

  /// Open/full lobbies visible to the user (cached; refreshed by [refreshLive]).
  List<Lobby> getLobbies();

  /// Pending and accepted players of one of the user's own lobbies.
  Future<List<LobbyParticipant>> getLobbyParticipants(String lobbyId);

  /// Organiser takes an accepted player out again: the match is cancelled, the
  /// spot is freed (the DB reopens a full lobby) and the player is notified.
  Future<void> removeFromLobby({required String matchId});

  /// Organiser stops the lobby: no new requests, pending ones are declined by
  /// the DB (with notifications), accepted players keep their match.
  Future<void> closeLobby(String lobbyId);

  /// Sends a match request to [opponentId]. In mock mode this simulates a
  /// network call; SupabaseDataService will insert into `matches`.
  Future<void> sendMatchRequest({
    required String opponentId,
    required DateTime proposedDate,
    required String court,
    required String format,
  });
}

// ─── Mock implementation ──────────────────────────────────────────────────────
class MockDataService implements DataService {
  // Notifications are the one real (Supabase-backed) slice of this
  // otherwise-mock DataService — see CLAUDE.md's Data Layer section and
  // the result-confirmation feature that needed opponents to actually
  // see their "please confirm" alert in the running app.
  List<AppNotification> _cachedNotifs = [];
  List<Player> _cachedPlayers = [];
  Player? _currentPlayer;
  List<Conversation> _cachedConversations = [];
  List<MatchSession> _cachedUpcomingSessions = [];
  List<Lobby> _cachedLobbies = [];

  final ValueNotifier<int> _unreadNotifier = ValueNotifier(0);
  final ValueNotifier<int> _cacheVersion = ValueNotifier(0);

  MockDataService() {
    unawaited(_refreshNotifications());
  }

  @override
  ValueNotifier<int> get unreadNotifier => _unreadNotifier;

  @override
  ValueNotifier<int> get cacheVersion => _cacheVersion;

  Player _playerFromRow(Map<String, dynamic> row, double myNtrp) {
    final ntrp = (row['ntrp_rating'] as num?)?.toDouble() ?? 3.0;
    final diff = (ntrp - myNtrp).abs();
    final score = (100 - diff * 40).clamp(0, 100).round();
    return Player.fromJson({...row, 'ntrp_rating': ntrp, 'match_score': score});
  }


  Player _guestPlayer(String? name, String? phone) {
    final displayName = (name != null && name.isNotEmpty) ? name : 'Misafir Oyuncu';
    return Player(
      id: 'guest:${phone ?? displayName}',
      name: displayName,
      initials: initialsOf(displayName),
      ntrpRating: 3.0,
      location: '',
    );
  }

  Future<double> _fetchMyNtrp(String uid) async {
    try {
      final me = await supabase
          .from('profiles')
          .select('ntrp_rating')
          .eq('id', uid)
          .maybeSingle();
      return (me?['ntrp_rating'] as num?)?.toDouble() ?? 3.0;
    } catch (_) {
      return 3.0;
    }
  }

  @override
  Future<void> warmCache() async {
    try {
      final uid = supabase.auth.currentUser?.id;
      final myNtrp = uid == null ? 3.0 : await _fetchMyNtrp(uid);
      _myNtrp = myNtrp;
      await Future.wait([
        _refreshPlayers(myNtrp),
        _refreshCurrentPlayer(uid),
        _refreshConversations(myNtrp),
        _refreshUpcomingSessions(myNtrp),
        _refreshLobbies(),
        // The constructor's fetch can run before login (uid == null) and
        // cache an empty list — reload once we know who's signed in.
        _refreshNotifications(),
      ]);
    } catch (e) {
      debugPrint('CACHE WARM ERROR: $e');
    } finally {
      _cacheVersion.value++;
    }
  }

  double _myNtrp = 3.0;
  bool _liveRefreshing = false;

  @override
  Future<void> refreshLive() async {
    if (_liveRefreshing) return; // a slow poll must not stack up behind itself
    _liveRefreshing = true;
    try {
      final before = _liveSignature();
      await Future.wait([
        _refreshConversations(_myNtrp),
        _refreshUpcomingSessions(_myNtrp),
        _refreshLobbies(),
        _refreshNotifications(),
      ]);
      // Only rebuild the IndexedStack tabs when a poll actually saw a change.
      if (_liveSignature() != before) _cacheVersion.value++;
    } catch (e) {
      debugPrint('LIVE REFRESH ERROR: $e');
    } finally {
      _liveRefreshing = false;
    }
  }

  String _liveSignature() => [
        for (final c in _cachedConversations)
          for (final m in c.messages) '${m.id}:${m.isRead}',
        for (final s in _cachedUpcomingSessions)
          '${s.id}:${s.status.name}:${s.result != null}',
        for (final n in _cachedNotifs) '${n.id}:${n.isRead}',
        for (final b in _cachedLobbies)
          '${b.id}:${b.status}:${b.pendingCount}:${b.acceptedCount}',
      ].join('|');

  @override
  Future<void> sendMessage({
    required String receiverId,
    required String text,
  }) async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) throw const DataException(DataError.notSignedIn);
    if (!isUuid(receiverId)) {
      throw const DataException(DataError.recipientNotRegistered);
    }
    await supabase.from('messages').insert({
      'sender_id': uid,
      'receiver_id': receiverId,
      'text': text,
    });
    // The insert succeeded — a failed re-read must not surface as "unsent"
    // (the user would retry and duplicate it); the next poll catches up.
    try {
      await _refreshConversations(_myNtrp);
    } catch (e) {
      debugPrint('CONVERSATIONS REFRESH ERROR: $e');
    }
    _cacheVersion.value++;
  }

  Future<void> _refreshPlayers(double myNtrp) async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) {
      _cachedPlayers = [];
      return;
    }
    final rows = await supabase.from('profiles').select().neq('id', uid);
    _cachedPlayers = (rows as List)
        .map((r) => _playerFromRow(Map<String, dynamic>.from(r as Map), myNtrp))
        .toList();
  }

  Future<void> _refreshCurrentPlayer(String? uid) async {
    if (uid == null) {
      _currentPlayer = null;
      return;
    }
    try {
      final row =
          await supabase.from('profiles').select().eq('id', uid).maybeSingle();
      _currentPlayer =
          row != null ? Player.fromJson(Map<String, dynamic>.from(row)) : null;
    } catch (e) {
      debugPrint('CURRENT PLAYER FETCH ERROR: $e');
    }
  }

  // A poll that started before sendMessage() can finish after it; only the
  // most recently *started* fetch may overwrite the cache.
  int _conversationsFetchSeq = 0;

  Future<void> _refreshConversations(double myNtrp) async {
    final seq = ++_conversationsFetchSeq;
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) {
      _cachedConversations = [];
      return;
    }
    final rows = await supabase
        .from('messages')
        .select()
        .or('sender_id.eq.$uid,receiver_id.eq.$uid')
        .order('created_at');
    final grouped = <String, List<ChatMessage>>{};
    for (final r in rows as List) {
      final row = Map<String, dynamic>.from(r as Map);
      final senderId = row['sender_id'] as String;
      final receiverId = row['receiver_id'] as String?;
      final otherId = senderId == uid ? receiverId : senderId;
      if (otherId == null) continue; // can't attribute to a thread yet
      grouped.putIfAbsent(otherId, () => []).add(ChatMessage(
            id: row['id'] as String,
            senderId: senderId,
            text: row['text'] as String,
            timestamp: DateTime.parse(row['created_at'] as String),
            isRead: row['is_read'] as bool? ?? false,
          ));
    }
    if (grouped.isEmpty) {
      if (seq == _conversationsFetchSeq) _cachedConversations = [];
      return;
    }
    final profileRows =
        await supabase.from('profiles').select().inFilter('id', grouped.keys.toList());
    if (seq != _conversationsFetchSeq) return; // superseded by a newer fetch
    final profileById = {
      for (final r in profileRows as List)
        (r as Map)['id'] as String: _playerFromRow(Map<String, dynamic>.from(r), myNtrp),
    };
    _cachedConversations = grouped.entries
        .map((e) {
          final other = profileById[e.key];
          if (other == null) return null; // counterpart profile missing/deleted
          return Conversation(id: e.key, other: other, messages: e.value);
        })
        .whereType<Conversation>()
        .toList()
      // Inbox order: most recent activity first.
      ..sort((a, b) =>
          b.lastMessage!.timestamp.compareTo(a.lastMessage!.timestamp));
  }

  Future<void> _refreshUpcomingSessions(double myNtrp) async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) {
      _cachedUpcomingSessions = [];
      return;
    }
    final rows = await supabase
        .from('matches')
        .select()
        .or('player1_id.eq.$uid,player2_id.eq.$uid')
        .order('date_time');
    final opponentIds = <String>{};
    for (final r in rows as List) {
      final row = Map<String, dynamic>.from(r as Map);
      final oppId = row['player1_id'] == uid
          ? row['player2_id'] as String?
          : row['player1_id'] as String?;
      if (oppId != null) opponentIds.add(oppId);
    }
    var profileById = <String, Player>{};
    if (opponentIds.isNotEmpty) {
      final profileRows =
          await supabase.from('profiles').select().inFilter('id', opponentIds.toList());
      profileById = {
        for (final r in profileRows as List)
          (r as Map)['id'] as String: _playerFromRow(Map<String, dynamic>.from(r), myNtrp),
      };
    }
    _cachedUpcomingSessions = (rows as List).map((r) {
      final row = Map<String, dynamic>.from(r as Map);
      final oppId = row['player1_id'] == uid
          ? row['player2_id'] as String?
          : row['player1_id'] as String?;
      final opponent = (oppId != null ? profileById[oppId] : null) ??
          _guestPlayer(row['opponent_name'] as String?, row['opponent_phone'] as String?);
      final sets = row['sets'];
      return MatchSession(
        id: row['id'] as String,
        opponent: opponent,
        isRequester: row['player1_id'] == uid,
        lobbyId: row['lobby_id'] as String?,
        dateTime: DateTime.parse(row['date_time'] as String),
        court: row['court'] as String? ?? '',
        status: MatchStatus.values.firstWhere(
          (e) => e.name == row['status'],
          orElse: () => MatchStatus.pending,
        ),
        format: MatchFormat.values.firstWhere(
          (e) => e.name == row['format'],
          orElse: () => MatchFormat.singles,
        ),
        result: sets != null
            ? MatchResult(
                winnerId: row['winner_id'] as String? ?? '',
                sets: (sets as List)
                    .map((s) => SetScore.fromJson(Map<String, dynamic>.from(s as Map)))
                    .toList(),
                ratingDelta: (row['rating_delta'] as num?)?.toDouble() ?? 0,
              )
            : null,
      );
    }).toList();
  }

  AppNotification _notifFromRow(Map<String, dynamic> r) => AppNotification(
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
      );

  Future<void> _refreshNotifications() async {
    // Wraps the `supabase` access itself, not just the query — Supabase
    // may not be initialized yet (e.g. widget tests never call
    // Supabase.initialize()), which throws synchronously on first touch.
    try {
      final uid = supabase.auth.currentUser?.id;
      if (uid == null) {
        _cachedNotifs = [];
        _unreadNotifier.value = 0;
        return;
      }
      final rows = await supabase
          .from('notifications')
          .select()
          .eq('user_id', uid)
          .order('created_at', ascending: false);
      _cachedNotifs = (rows as List)
          .map((r) => _notifFromRow(r as Map<String, dynamic>))
          .toList();
      _unreadNotifier.value = _cachedNotifs.where((n) => !n.isRead).length;
    } catch (e) {
      debugPrint('NOTIFICATIONS FETCH ERROR: $e');
    }
  }

  @override
  String get currentUserId {
    // Supabase isn't initialized in widget tests; the getter touching it
    // throws there, so fall back to the 'me' sentinel like "no session".
    try {
      return supabase.auth.currentUser?.id ?? 'me';
    } catch (_) {
      return 'me';
    }
  }

  @override
  List<Player> getPlayers() => _cachedPlayers;

  @override
  Player? getCurrentPlayer() => _currentPlayer;

  @override
  List<Conversation> getConversations() => _cachedConversations;

  @override
  List<MatchSession> getUpcomingSessions() => _cachedUpcomingSessions;

  @override
  List<Lobby> getLobbies() => _cachedLobbies;

  Future<void> _refreshLobbies() async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) {
      _cachedLobbies = [];
      return;
    }
    try {
      final rows = await supabase
          .from('lobbies')
          .select()
          .inFilter('status', ['open', 'full'])
          .or('is_public.eq.true,creator_id.eq.$uid')
          .order('date_time');
      _cachedLobbies = (rows as List)
          .map((r) => Lobby.fromJson(Map<String, dynamic>.from(r as Map)))
          .toList();
    } catch (e) {
      // Keep the last good list: a flaky poll must not blank the lobby row.
      debugPrint('LOBBIES REFRESH ERROR: $e');
    }
  }

  @override
  Future<List<AppNotification>> getNotifications() async {
    await _refreshNotifications();
    return List.from(_cachedNotifs);
  }

  @override
  int getUnreadCount() => _unreadNotifier.value;

  @override
  Future<void> markAllRead() async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return;
    await supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', uid)
        .eq('is_read', false);
    await _refreshNotifications();
  }

  @override
  Future<void> confirmResult({
    required String matchId,
    required String notificationId,
  }) async {
    await supabase.from('matches').update({
      'result_status': 'confirmed',
      'result_confirmed_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', matchId);
    await supabase
        .from('notifications')
        .update({'is_read': true}).eq('id', notificationId);
    await _refreshNotifications();
  }

  @override
  Future<void> respondToMatchRequest({
    required String matchId,
    String? notificationId,
    required bool accept,
  }) async {
    // RLS filters UPDATEs silently (0 rows, no error) — select the row back
    // so a policy that doesn't let player2 update is reported, not hidden.
    // Only a still-pending request can be answered (a lobby close or a
    // withdrawn request must not be revived by a stale Kabul button).
    final List updated;
    try {
      updated = await supabase
          .from('matches')
          .update({'status': accept ? 'confirmed' : 'cancelled'})
          .eq('id', matchId)
          .eq('status', 'pending')
          .select('player1_id, court');
    } on PostgrestException catch (e) {
      throw _lobbyError(e) ?? e;
    }
    if (updated.isEmpty) {
      throw const DataException(DataError.matchUpdateDenied);
    }
    notificationId ??= await _requestNotificationId(matchId);
    final match = Map<String, dynamic>.from(updated.first as Map);
    await _notifyRequesterOfResponse(
      matchId: matchId,
      requesterId: match['player1_id'] as String,
      court: match['court'] as String? ?? '',
      accept: accept,
    );
    // The match is already updated, so a failure here must not throw.
    // Rewriting the type is what hides the accept/decline buttons on reload.
    final nid = notificationId;
    if (nid != null) {
      try {
        await supabase.from('notifications').update({
          'type': accept ? 'matchConfirmed' : 'matchDeclined',
          'title': accept ? 'Maç Kabul Edildi' : 'Maç Reddedildi',
          'is_read': true,
        }).eq('id', nid);
      } catch (e) {
        debugPrint('MATCH REQUEST NOTIFICATION UPDATE ERROR: $e');
        await supabase
            .from('notifications')
            .update({'is_read': true}).eq('id', nid);
      }
    }
    await refreshLive();
  }

  @override
  Future<void> disputeResult({
    required String matchId,
    required String notificationId,
  }) async {
    await supabase.from('matches').update({
      'result_status': 'disputed',
    }).eq('id', matchId);
    await supabase
        .from('notifications')
        .update({'is_read': true}).eq('id', notificationId);
    await _refreshNotifications();
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
  void markConversationRead(String conversationId) =>
      _readConversationIds.add(conversationId);

  @override
  bool isConversationRead(String conversationId) =>
      _readConversationIds.contains(conversationId);

  @override
  Future<void> updateMyProfile({
    required String name,
    required String location,
    required String about,
    required List<String> sports,
    required String? skillLevel,
    required List<String> availableDays,
    required List<String> timePrefs,
  }) async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) throw const DataException(DataError.notSignedIn);
    // Only reset ntrp_rating when the self-reported level actually changes,
    // so an unrelated edit (e.g. bio) doesn't wipe a rating earned in matches.
    final levelChanged =
        skillLevel != null && skillLevel != _currentPlayer?.skillLevel;
    await supabase.from('profiles').update({
      'name': name,
      'initials': initialsOf(name),
      'location': location,
      'about': about,
      'sports': sports,
      'skill_level': skillLevel,
      if (levelChanged) 'ntrp_rating': ntrpBySkillLevel[skillLevel],
      'available_days': availableDays,
      'time_prefs': timePrefs,
    }).eq('id', uid);
    await _refreshCurrentPlayer(uid);
    _cacheVersion.value++;
  }

  @override
  Future<bool> hasCompletedProfile() async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return false;
    final row = await supabase
        .from('profiles')
        .select('name, location')
        .eq('id', uid)
        .maybeSingle();
    return isProfileComplete(
        row == null ? null : Map<String, dynamic>.from(row));
  }

  /// Maps the lobby trigger's `RAISE EXCEPTION 'lobby_…'` to a [DataError].
  DataException? _lobbyError(PostgrestException e) {
    final m = e.message;
    if (m.contains('lobby_queue_full')) {
      return const DataException(DataError.lobbyQueueFull);
    }
    if (m.contains('lobby_full')) return const DataException(DataError.lobbyFull);
    if (m.contains('lobby_closed') || m.contains('lobby_request_ended')) {
      return const DataException(DataError.lobbyClosed);
    }
    if (m.contains('lobby_already_requested')) {
      return const DataException(DataError.alreadyRequested);
    }
    if (m.contains('lobby_own')) return const DataException(DataError.ownLobby);
    return null;
  }

  Future<String?> _requestNotificationId(String matchId) async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return null;
    try {
      final rows = await supabase
          .from('notifications')
          .select('id')
          .eq('user_id', uid)
          .eq('action_id', matchId)
          .eq('type', 'matchRequest')
          .limit(1);
      return (rows as List).isEmpty ? null : (rows.first as Map)['id'] as String;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> joinLobby({
    required String lobbyId,
    required String creatorId,
    required DateTime dateTime,
    required String court,
    required String sport,
  }) async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) throw const DataException(DataError.notSignedIn);
    if (creatorId == uid) throw const DataException(DataError.ownLobby);
    if (!isUuid(creatorId)) {
      throw const DataException(DataError.recipientNotRegistered);
    }
    // The DB trigger enforces closed / full / 10-pending / duplicate under a
    // row lock, so two people tapping the last slot can't both get in.
    final Map<String, dynamic> inserted;
    try {
      inserted = await supabase.from('matches').insert({
        'player1_id': uid,
        'player2_id': creatorId,
        'lobby_id': lobbyId,
        'date_time': dateTime.toUtc().toIso8601String(),
        'court': court,
        'format': 'singles',
        'status': 'pending',
      }).select('id').single();
    } on PostgrestException catch (e) {
      throw _lobbyError(e) ?? e;
    }
    await _notifyMatchRequest(
      matchId: inserted['id'] as String,
      opponentId: creatorId,
      requesterId: uid,
      court: court,
      body: (name) => '$name, $sport lobine katılmak istiyor ($court).',
    );
    await _refreshUpcomingSessions(await _fetchMyNtrp(uid));
    await _refreshLobbies();
    _cacheVersion.value++;
  }

  @override
  Future<List<LobbyParticipant>> getLobbyParticipants(String lobbyId) async {
    final rows = await supabase
        .from('matches')
        .select('id, player1_id, status')
        .eq('lobby_id', lobbyId)
        .inFilter('status', ['pending', 'confirmed'])
        .order('created_at');
    final list = (rows as List).map((r) => Map<String, dynamic>.from(r as Map)).toList();
    if (list.isEmpty) return [];
    final profiles = await supabase
        .from('profiles')
        .select()
        .inFilter('id', list.map((r) => r['player1_id'] as String).toList());
    final byId = {
      for (final r in profiles as List)
        (r as Map)['id'] as String: _playerFromRow(Map<String, dynamic>.from(r), _myNtrp),
    };
    return [
      for (final r in list)
        if (byId[r['player1_id']] != null)
          LobbyParticipant(
            matchId: r['id'] as String,
            player: byId[r['player1_id']]!,
            accepted: r['status'] == 'confirmed',
          ),
    ];
  }

  @override
  Future<void> removeFromLobby({required String matchId}) async {
    final updated = await supabase
        .from('matches')
        .update({'status': 'cancelled'})
        .eq('id', matchId)
        .eq('status', 'confirmed')
        .select('player1_id, court');
    if ((updated as List).isEmpty) {
      throw const DataException(DataError.matchUpdateDenied);
    }
    final requesterId = (updated.first as Map)['player1_id'] as String;
    // Same insert path as accept/decline replies (RLS: player2 → player1).
    try {
      final name = _currentPlayer?.name ?? 'Organizatör';
      await supabase.from('notifications').insert({
        'user_id': requesterId,
        'type': 'matchDeclined',
        'title': 'Lobiden Çıkarıldın',
        'body': '$name seni lobiden çıkardı.',
        'avatar_initials': _currentPlayer?.initials,
        'avatar_color': _currentPlayer?.avatarGradientStart,
        'action_id': matchId,
      });
    } catch (e) {
      debugPrint('LOBBY REMOVE NOTIFICATION ERROR: $e');
    }
    await refreshLive();
    _cacheVersion.value++;
  }

  @override
  Future<void> closeLobby(String lobbyId) async {
    final updated = await supabase
        .from('lobbies')
        .update({'status': 'closed'})
        .eq('id', lobbyId)
        .select('id');
    if ((updated as List).isEmpty) {
      throw const DataException(DataError.matchUpdateDenied);
    }
    await refreshLive();
    _cacheVersion.value++;
  }

  @override
  Future<void> sendMatchRequest({
    required String opponentId,
    required DateTime proposedDate,
    required String court,
    required String format,
  }) async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) throw const DataException(DataError.notSignedIn);
    final inserted = await supabase.from('matches').insert({
      'player1_id': uid,
      if (isUuid(opponentId)) 'player2_id': opponentId,
      'date_time': proposedDate.toUtc().toIso8601String(),
      'court': court,
      'format': format,
      'status': 'pending',
    }).select('id').single();

    if (isUuid(opponentId)) {
      await _notifyMatchRequest(
        matchId: inserted['id'] as String,
        opponentId: opponentId,
        requesterId: uid,
        court: court,
      );
    }

    await _refreshUpcomingSessions(await _fetchMyNtrp(uid));
    _cacheVersion.value++;
  }

  /// Tells the requester (player1) that their request was accepted/declined.
  /// Allowed by the "Opponent can notify requester of response" RLS policy
  /// (player2 of [matchId] → player1, matchConfirmed/matchDeclined only).
  Future<void> _notifyRequesterOfResponse({
    required String matchId,
    required String requesterId,
    required String court,
    required bool accept,
  }) async {
    try {
      final me = _currentPlayer;
      final name = me?.name ?? 'Rakibiniz';
      await supabase.from('notifications').insert({
        'user_id': requesterId,
        'type': accept ? 'matchConfirmed' : 'matchDeclined',
        'title': accept ? 'Maç İsteğin Kabul Edildi' : 'Maç İsteğin Reddedildi',
        'body': accept
            ? '$name $court maçını kabul etti. 🎾'
            : '$name $court maç isteğini reddetti.',
        'avatar_initials': me?.initials,
        'avatar_color': me?.avatarGradientStart,
        'action_id': matchId,
      });
    } catch (e) {
      // The response itself already succeeded; don't fail it over this.
      debugPrint('MATCH RESPONSE NOTIFICATION ERROR: $e');
    }
  }

  Future<void> _notifyMatchRequest({
    required String matchId,
    required String opponentId,
    required String requesterId,
    required String court,
    String Function(String name)? body,
  }) async {
    try {
      final me = await supabase
          .from('profiles')
          .select('name, initials, avatar_gradient_start')
          .eq('id', requesterId)
          .maybeSingle();
      final name = me?['name'] as String? ?? 'Bir oyuncu';
      await supabase.from('notifications').insert({
        'user_id': opponentId,
        'type': 'matchRequest',
        'title': 'Yeni Maç İsteği',
        'body': body?.call(name) ?? '$name sizinle $court için maç yapmak istiyor.',
        'avatar_initials': me?['initials'],
        'avatar_color': me?['avatar_gradient_start'],
        'action_id': matchId,
      });
    } catch (e) {
      // Match request itself already succeeded; a failed notification
      // insert shouldn't surface as a failure to the requester.
      debugPrint('MATCH REQUEST NOTIFICATION ERROR: $e');
    }
  }
}

// ─── Global accessor ──────────────────────────────────────────────────────────
// Swap MockDataService → SupabaseDataService here when ready.
// ignore: library_private_types_in_public_api
final DataService dataService = MockDataService();
