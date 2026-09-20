import 'package:firebase_analytics/firebase_analytics.dart';

/// Thin wrapper around FirebaseAnalytics so screens never import the
/// Firebase package directly. Mirrors the DataService pattern in this repo.
class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  Future<void> logEvent(String name, [Map<String, Object>? parameters]) {
    return _analytics.logEvent(name: name, parameters: parameters);
  }

  Future<void> setUserId(String? id) => _analytics.setUserId(id: id);

  // ── Domain-specific events ───────────────────────────────────────────────

  Future<void> logMatchRequested({required String opponentId}) =>
      logEvent('match_requested', {'opponent_id': opponentId});

  Future<void> logResultSubmitted({required String matchId}) =>
      logEvent('result_submitted', {'match_id': matchId});

  Future<void> logGameCreated({required String gameId}) =>
      logEvent('game_created', {'game_id': gameId});
}

final analyticsService = AnalyticsService.instance;
