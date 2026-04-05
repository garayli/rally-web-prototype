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
}

// ─── Mock implementation ──────────────────────────────────────────────────────
class MockDataService implements DataService {
  const MockDataService();

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
}

// ─── Global accessor ──────────────────────────────────────────────────────────
// Swap MockDataService → SupabaseDataService here when ready.
// ignore: library_private_types_in_public_api
const DataService dataService = MockDataService();
