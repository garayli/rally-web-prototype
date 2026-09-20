import 'package:flutter/foundation.dart';
import '../models/models.dart';
import 'mock_data.dart';

// ─── Abstract data interface ──────────────────────────────────────────────────
// All screens talk to DataService, never to MockData directly.
// To connect Supabase: implement SupabaseDataService and swap the global below.
abstract class DataService {
  /// The current user's ID. In mock mode this is the sentinel 'me'.
  /// Replace with supabase.auth.currentUser!.id in SupabaseDataService.
  String get currentUserId;

  List<Player> getPlayers();
  List<Conversation> getConversations();
  List<MatchSession> getUpcomingSessions();

  /// Returns a mutable copy — callers may mutate it locally without affecting
  /// the source list (important for NotificationsScreen accept/decline logic).
  List<AppNotification> getNotifications();

  /// Number of unread notifications — drives badge counts across the app.
  int getUnreadCount();

  /// Mark all notifications as read in the shared data layer.
  void markAllRead();

  /// Reactive unread count — listen to this to auto-update badges anywhere.
  ValueNotifier<int> get unreadNotifier;

  /// Notification preferences — persisted in memory (Supabase when ready).
  Map<String, bool> getNotifPrefs();
  void saveNotifPrefs(Map<String, bool> prefs);

  /// Mark a conversation as read (all incoming messages seen).
  void markConversationRead(String conversationId);
  bool isConversationRead(String conversationId);
}

// ─── Mock implementation ──────────────────────────────────────────────────────
class MockDataService implements DataService {
  // Tracks IDs marked read this session (persists across screen pushes/pops).
  final Set<String> _readIds = {};

  late final ValueNotifier<int> _unreadNotifier =
      ValueNotifier(_countUnread());

  @override
  ValueNotifier<int> get unreadNotifier => _unreadNotifier;

  int _countUnread() => MockData.notifications
      .where((n) => !n.isRead && !_readIds.contains(n.id))
      .length;

  @override
  String get currentUserId => 'me'; // sentinel; see mock_data.dart

  @override
  List<Player> getPlayers() => MockData.players;

  @override
  List<Conversation> getConversations() => MockData.conversations;

  @override
  List<MatchSession> getUpcomingSessions() => MockData.upcomingSessions;

  @override
  List<AppNotification> getNotifications() => List.from(MockData.notifications);

  @override
  int getUnreadCount() => _countUnread();

  @override
  void markAllRead() {
    for (final n in MockData.notifications) {
      _readIds.add(n.id);
    }
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
  void markConversationRead(String conversationId) =>
      _readConversationIds.add(conversationId);

  @override
  bool isConversationRead(String conversationId) =>
      _readConversationIds.contains(conversationId);
}

// ─── Global accessor ──────────────────────────────────────────────────────────
// Swap MockDataService → SupabaseDataService here when ready.
// ignore: library_private_types_in_public_api
final DataService dataService = MockDataService();
