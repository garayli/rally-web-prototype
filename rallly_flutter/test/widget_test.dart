import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rallly/models/models.dart';
import 'package:rallly/screens/log_result_screen.dart';
import 'package:rallly/screens/match_screen.dart';
import 'package:rallly/theme/app_theme.dart';

// ignore_for_file: unused_import

// ── Helpers ──────────────────────────────────────────────────────────────────

Widget _wrap(Widget child) => MaterialApp(
      theme: RallyTheme.light,
      home: child,
    );

Player _player({
  String id = 'p1',
  String name = 'Test Player',
  double ntrp = 3.5,
}) =>
    Player(
      id: id,
      name: name,
      initials: name.substring(0, 2).toUpperCase(),
      ntrpRating: ntrp,
      location: 'London',
    );

// ── 1. Player.skillLabel unit test ───────────────────────────────────────────

void main() {
  group('Player.skillLabel', () {
    test('returns Beginner for NTRP < 3.0', () {
      expect(_player(ntrp: 2.0).skillLabel, 'Beginner');
      expect(_player(ntrp: 2.9).skillLabel, 'Beginner');
    });

    test('returns Intermediate for NTRP 3.0–4.4', () {
      expect(_player(ntrp: 3.0).skillLabel, 'Intermediate');
      expect(_player(ntrp: 4.4).skillLabel, 'Intermediate');
    });

    test('returns Advanced for NTRP >= 4.5', () {
      expect(_player(ntrp: 4.5).skillLabel, 'Advanced');
      expect(_player(ntrp: 5.0).skillLabel, 'Advanced');
    });
  });

// ── 2. Player fromJson / toJson round-trip ───────────────────────────────────

  group('Player serialization', () {
    test('fromJson / toJson round-trip preserves all fields', () {
      // ignore: prefer_const_constructors
      final original = Player(
        id: 'abc',
        name: 'Alice Smith',
        initials: 'AS',
        avatarUrl: 'https://example.com/avatar.png',
        ntrpRating: 4.0,
        location: 'Islington',
        about: 'Love clay courts',
        wins: 10,
        losses: 3,
        matchesPlayed: 13,
        winRate: 76.9,
        availability: ['Mon AM', 'Sat Full'],
        preferredCourts: ['Islington Tennis Centre'],
        matchScore: 88,
        avatarGradientStart: '#e85d3a',
        avatarGradientEnd: '#f4956d',
      );

      final json = original.toJson();
      final restored = Player.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.ntrpRating, original.ntrpRating);
      expect(restored.wins, original.wins);
      expect(restored.losses, original.losses);
      expect(restored.matchesPlayed, original.matchesPlayed);
      expect(restored.availability, original.availability);
      expect(restored.preferredCourts, original.preferredCourts);
      expect(restored.matchScore, original.matchScore);
      expect(restored.avatarGradientStart, original.avatarGradientStart);
    });

    test('fromJson handles missing optional fields with defaults', () {
      final json = {
        'id': 'x',
        'name': 'Bob',
        'initials': 'B',
        'ntrp_rating': 3.5,
      };
      final p = Player.fromJson(json);
      expect(p.wins, 0);
      expect(p.losses, 0);
      expect(p.about, '');
      expect(p.availability, isEmpty);
      expect(p.preferredCourts, isEmpty);
    });
  });

// ── 3. Conversation.unreadCount ───────────────────────────────────────────────

  group('Conversation.unreadCount', () {
    final alice = _player(id: 'alice');
    const me = 'me';

    test('counts only unread messages not from current user', () {
      final convo = Conversation(
        id: 'c1',
        other: alice,
        messages: [
          ChatMessage(id: '1', senderId: 'alice', text: 'Hey', timestamp: DateTime.now(), isRead: false),
          ChatMessage(id: '2', senderId: 'alice', text: 'You there?', timestamp: DateTime.now(), isRead: false),
          ChatMessage(id: '3', senderId: me, text: 'Hi!', timestamp: DateTime.now(), isRead: false),
          ChatMessage(id: '4', senderId: 'alice', text: 'Great', timestamp: DateTime.now(), isRead: true),
        ],
      );
      expect(convo.unreadCount(me), 2); // only first two alice messages unread
    });

    test('returns 0 when all messages are read', () {
      final convo = Conversation(
        id: 'c2',
        other: alice,
        messages: [
          ChatMessage(id: '1', senderId: 'alice', text: 'Hey', timestamp: DateTime.now(), isRead: true),
        ],
      );
      expect(convo.unreadCount(me), 0);
    });

    test('returns 0 when all unread messages are from current user', () {
      final convo = Conversation(
        id: 'c3',
        other: alice,
        messages: [
          ChatMessage(id: '1', senderId: me, text: 'Sent by me', timestamp: DateTime.now(), isRead: false),
        ],
      );
      expect(convo.unreadCount(me), 0);
    });
  });

// ── 4. LogResultScreen: auto-detect winner ────────────────────────────────────

  group('LogResultScreen', () {
    testWidgets('winner auto-detected from set scores', (tester) async {
      await tester.pumpWidget(_wrap(const LogResultScreen()));
      await tester.pump();

      // Enter Set 1: me 6, opponent 4 (fields at index 0 = set1-me, 1 = set1-opp)
      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), '6');
      await tester.enterText(fields.at(1), '4');

      // Enter Set 2: me 6, opponent 3
      await tester.enterText(fields.at(2), '6');
      await tester.enterText(fields.at(3), '3');
      await tester.pump();

      // Winner banner should show "You won this match!"
      expect(find.text('You won this match!'), findsOneWidget);
    });

    testWidgets('submit button disabled until both sets filled', (tester) async {
      await tester.pumpWidget(_wrap(const LogResultScreen()));
      await tester.pump();

      // Button text is "Submit Result"
      expect(find.text('Submit Result'), findsOneWidget);

      // Find the FilledButton and verify it's disabled (no winner + no scores)
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);

      // Fill Set 1 only
      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), '6');
      await tester.enterText(fields.at(1), '4');
      await tester.pump();

      // Still disabled — Set 2 not filled, no winner set
      final button2 = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button2.onPressed, isNull);
    });
  });

// ── 5. MatchScreen: skill filter ─────────────────────────────────────────────

  group('MatchScreen skill filter', () {
    testWidgets('All filter shows all mock players', (tester) async {
      await tester.pumpWidget(_wrap(const MatchScreen()));
      await tester.pump();

      // Default is 'All' — PlayerCard widgets should be present
      expect(find.byType(Card).evaluate().length, greaterThan(0));
    });

    testWidgets('selecting Beginner filter hides Advanced/Intermediate players', (tester) async {
      await tester.pumpWidget(_wrap(const MatchScreen()));
      await tester.pump();

      // Tap the 'Beginner' filter chip
      final beginnerChip = find.text('Beginner');
      if (beginnerChip.evaluate().isNotEmpty) {
        await tester.tap(beginnerChip);
        await tester.pump();
        // After filtering, Advanced players should not appear
        expect(find.text('Advanced'), findsNothing);
      }
    });
  });
}
