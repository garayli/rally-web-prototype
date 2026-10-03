import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rallly/l10n/app_localizations.dart';
import 'package:rallly/l10n/option_labels.dart';
import 'package:rallly/main.dart' show CourtThemeProvider;
import 'package:rallly/models/models.dart';
import 'package:rallly/screens/achievements_screen.dart';
import 'package:rallly/screens/create_game_screen.dart';
import 'package:rallly/screens/edit_profile_screen.dart';
import 'package:rallly/screens/notifications_preferences_screen.dart';
import 'package:rallly/screens/reputation_screen.dart';
import 'package:rallly/screens/log_result_screen.dart';
import 'package:rallly/utils/uuid.dart';
import 'package:rallly/screens/match_screen.dart';
import 'package:rallly/screens/my_results_screen.dart';
import 'package:rallly/screens/games_screen.dart';
import 'package:rallly/screens/notifications_screen.dart';
import 'package:rallly/theme/app_theme.dart';

// ignore_for_file: unused_import

// ── Helpers ──────────────────────────────────────────────────────────────────

// CourtThemeProvider is required — RallyButton and other shared widgets read
// CourtThemeProvider.of(context), same ancestor the real app provides in main.dart.
Widget _wrap(Widget child, {Locale locale = const Locale('tr')}) =>
    CourtThemeProvider(
      child: MaterialApp(
        theme: RallyTheme.light,
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
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
    // skillLabel is the canonical value stored in profiles.skill_level — it is
    // Turkish regardless of UI language; screens localize it for display via
    // skillLevelLabel().
    test('returns Başlangıç for NTRP < 3.0', () {
      expect(_player(ntrp: 2.0).skillLabel, 'Başlangıç');
      expect(_player(ntrp: 2.9).skillLabel, 'Başlangıç');
    });

    test('returns Orta Seviye for NTRP 3.0–4.4', () {
      expect(_player(ntrp: 3.0).skillLabel, 'Orta Seviye');
      expect(_player(ntrp: 4.4).skillLabel, 'Orta Seviye');
    });

    test('returns İleri Seviye for NTRP >= 4.5', () {
      expect(_player(ntrp: 4.5).skillLabel, 'İleri Seviye');
      expect(_player(ntrp: 5.0).skillLabel, 'İleri Seviye');
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
      expect(p.sports, isEmpty);
      expect(p.skillLevel, isNull);
      expect(p.availableDays, isEmpty);
      expect(p.timePrefs, isEmpty);
    });

    test('fromJson reads signup profile fields', () {
      final p = Player.fromJson({
        'id': 'x',
        'name': 'Bob',
        'ntrp_rating': 3.5,
        'sports': ['Tenis', 'Padel'],
        'skill_level': 'Orta Seviye',
        'available_days': ['Pzt', 'Cmt'],
        'time_prefs': ['Akşam'],
      });
      expect(p.sports, ['Tenis', 'Padel']);
      expect(p.skillLevel, 'Orta Seviye');
      expect(p.availableDays, ['Pzt', 'Cmt']);
      expect(p.timePrefs, ['Akşam']);
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

      // Winner banner should show "Bu maçı kazandınız!"
      expect(find.text('Bu maçı kazandınız!'), findsOneWidget);
    });

    testWidgets('winner banner is localized (en)', (tester) async {
      await tester.pumpWidget(
          _wrap(const LogResultScreen(), locale: const Locale('en')));
      await tester.pump();

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), '6');
      await tester.enterText(fields.at(1), '4');
      await tester.enterText(fields.at(2), '6');
      await tester.enterText(fields.at(3), '3');
      await tester.pump();

      expect(find.text('You won this match!'), findsOneWidget);
      expect(find.text('Bu maçı kazandınız!'), findsNothing);
    });

    testWidgets('submit button disabled until both sets filled', (tester) async {
      await tester.pumpWidget(_wrap(const LogResultScreen()));
      await tester.pump();

      // Button text is "Sonucu Kaydet"
      expect(find.text('Sonucu Kaydet'), findsOneWidget);

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

// ── 5. isUuid: distinguishes real opponent ids from mock ids ────────────────

  group('isUuid', () {
    test('rejects mock/demo player ids', () {
      expect(isUuid('1'), false);
      expect(isUuid('p1'), false);
      expect(isUuid('guest'), false);
    });

    test('accepts a real uuid', () {
      expect(isUuid('550e8400-e29b-41d4-a716-446655440000'), true);
    });
  });

// ── 6. MatchScreen: skill filter ─────────────────────────────────────────────

  group('MatchScreen skill filter', () {
    // Player.getPlayers() is Supabase-backed now (data_service.dart) — with
    // no authenticated session in this widget test, the cache is empty, so
    // this only verifies the screen renders without crashing.
    testWidgets('renders without crashing when player cache is empty', (tester) async {
      await tester.pumpWidget(_wrap(const MatchScreen()));
      await tester.pump();

      expect(find.byType(Card).evaluate().length, 0);
    });

    testWidgets('selecting Beginner filter hides Advanced/Intermediate players', (tester) async {
      await tester.pumpWidget(_wrap(const MatchScreen()));
      await tester.pump();

      // Tap the beginner filter chip (short label, 'Başl.' in Turkish)
      final beginnerChip = find.text('Başl.');
      if (beginnerChip.evaluate().isNotEmpty) {
        await tester.tap(beginnerChip);
        await tester.pump();
        // After filtering, Advanced players should not appear
        expect(find.text('İLERİ'), findsNothing);
      }
    });
  });

// ── 7. EditProfileScreen ─────────────────────────────────────────────────────

  group('EditProfileScreen', () {
    const me = Player(
      id: 'me',
      name: 'Leyla Garayli',
      initials: 'LG',
      ntrpRating: 3.5,
      location: 'Beşiktaş',
      about: 'Toprak kort sever',
      skillLevel: 'Orta Seviye',
      sports: ['Tenis'],
    );

    testWidgets('prefills current profile values', (tester) async {
      await tester.pumpWidget(_wrap(const EditProfileScreen(player: me)));
      await tester.pump();

      expect(find.text('Leyla Garayli'), findsOneWidget);
      expect(find.text('Beşiktaş'), findsOneWidget);
      expect(find.text('Toprak kort sever'), findsOneWidget);
    });

    testWidgets('save disabled when name is cleared', (tester) async {
      await tester.pumpWidget(_wrap(const EditProfileScreen(player: me)));
      await tester.pump();

      FilledButton saveButton() => tester.widget<FilledButton>(find.byType(FilledButton));
      expect(saveButton().onPressed, isNotNull);

      await tester.enterText(find.text('Leyla Garayli'), '   ');
      await tester.pump();
      expect(saveButton().onPressed, isNull);
    });
  });

// ── 8. Localization ──────────────────────────────────────────────────────────

  group('Localization', () {
    Map<String, dynamic> arb(String lang) => jsonDecode(
        File('lib/l10n/app_$lang.arb').readAsStringSync()) as Map<String, dynamic>;

    test('every Turkish string has an English translation and vice versa', () {
      final tr = arb('tr').keys.where((k) => !k.startsWith('@')).toSet();
      final en = arb('en').keys.where((k) => !k.startsWith('@')).toSet();
      expect(tr.difference(en), isEmpty, reason: 'missing in app_en.arb');
      expect(en.difference(tr), isEmpty, reason: 'missing in app_tr.arb');
    });

    test('stored profile values map to localized labels', () async {
      final tr = await AppLocalizations.delegate.load(const Locale('tr'));
      final en = await AppLocalizations.delegate.load(const Locale('en'));
      expect(skillLevelLabel(tr, 'İleri Seviye'), 'İleri Seviye');
      expect(skillLevelLabel(en, 'İleri Seviye'), 'Advanced');
      expect(dayLabel(en, 'Cmt'), 'Sat');
      expect(timeLabel(en, 'Akşam'), 'Evening');
      expect(sportLabel(en, 'Tenis'), 'Tennis');
      expect(availabilitySlotLabel(en, 'Sal ÖÖ'), 'Tue AM');
      // Unknown values (e.g. from an older client) pass through unchanged.
      expect(skillLevelLabel(en, 'Bilinmeyen'), 'Bilinmeyen');
    });
  });

// ── 9. Layout in both languages ──────────────────────────────────────────────

  // English and Turkish strings differ in length; render each screen on a
  // narrow phone and fail on any overflow / build exception.
  group('Layout at 360x740 in every supported locale', () {
    final screens = <String, Widget Function()>{
      'MatchScreen': () => const MatchScreen(),
      'LogResultScreen': () => const LogResultScreen(),
      'CreateGameScreen': () => const CreateGameScreen(),
      'AchievementsScreen': () => const AchievementsScreen(),
      'ReputationScreen': () => const ReputationScreen(),
      'NotificationPreferencesScreen': () => const NotificationPreferencesScreen(),
    };

    for (final locale in AppLocalizations.supportedLocales) {
      for (final entry in screens.entries) {
        testWidgets('${entry.key} (${locale.languageCode})', (tester) async {
          tester.view.physicalSize = const Size(360, 740);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.reset);

          await tester.pumpWidget(_wrap(entry.value(), locale: locale));
          await tester.pump(const Duration(seconds: 1));

          expect(tester.takeException(), isNull);
        });
      }
    }
  });

  // ── Regression: screens must not assume a minimum number of players ────────
  group('Screens with an empty cache (fewer than 5 players)', () {
    testWidgets('MyResultsScreen shows the empty state instead of RangeError', (tester) async {
      await tester.pumpWidget(_wrap(const MyResultsScreen()));
      await tester.pump(const Duration(seconds: 1));

      expect(tester.takeException(), isNull);
      expect(find.text('Geçmiş maç yok'), findsOneWidget);
    });

    testWidgets('GamesScreen past tab renders without placeholder players', (tester) async {
      await tester.pumpWidget(_wrap(const GamesScreen()));
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text('Geçmiş'));
      await tester.pump(const Duration(seconds: 1));

      expect(tester.takeException(), isNull);
    });
  });

  // ── Regression: iOS has no system back button ───────────────────────────────
  group('NotificationsScreen back button', () {
    testWidgets('shown when pushed onto a route', (tester) async {
      await tester.pumpWidget(_wrap(Builder(
        builder: (context) => TextButton(
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen())),
          child: const Text('open'),
        ),
      )));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();
      expect(find.text('open'), findsOneWidget);
    });

    testWidgets('hidden when used as a root tab', (tester) async {
      await tester.pumpWidget(_wrap(const NotificationsScreen()));
      await tester.pump();

      expect(find.byIcon(Icons.arrow_back_ios_new), findsNothing);
    });
  });
}
