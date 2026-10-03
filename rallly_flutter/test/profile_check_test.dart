import 'package:flutter_test/flutter_test.dart';
import 'package:rallly/models/models.dart';
import 'package:rallly/utils/profile_check.dart';

Player _opp() => const Player(
    id: 'o', name: 'Rakip', initials: 'R', ntrpRating: 3.0, location: '');

MatchSession _session({required bool requester, String winnerId = ''}) =>
    MatchSession(
      id: 'm',
      opponent: _opp(),
      dateTime: DateTime(2026, 1, 1),
      court: 'x',
      status: MatchStatus.completed,
      isRequester: requester,
      result: MatchResult(
          winnerId: winnerId, sets: const [SetScore(6, 4)], ratingDelta: 12),
    );

void main() {
  group('isProfileComplete (profiles persist across logins)', () {
    test('no row → incomplete', () => expect(isProfileComplete(null), isFalse));

    test('auth-trigger placeholder row → incomplete', () {
      expect(isProfileComplete({'name': 'New Player', 'location': ''}), isFalse);
    });

    test('named but no location → incomplete', () {
      expect(isProfileComplete({'name': 'Ayşe Aslan', 'location': ''}), isFalse);
    });

    test('name and location → complete', () {
      expect(
          isProfileComplete({'name': 'Ayşe Aslan', 'location': 'Beşiktaş'}),
          isTrue);
    });
  });

  group('MatchSession perspective', () {
    test('requester who won', () {
      final s = _session(requester: true, winnerId: 'me');
      expect(s.wonBy('me'), isTrue);
      expect(s.setsForMe().first.player1, 6);
      expect(s.ratingDeltaForMe(), 12);
    });

    test('requester who lost (winner_id stored as null → empty)', () {
      expect(_session(requester: true).wonBy('me'), isFalse);
    });

    test('opponent view is mirrored', () {
      final s = _session(requester: false);
      expect(s.wonBy('them'), isTrue); // requester logged "opponent won"
      expect(s.setsForMe().first.player1, 4);
      expect(s.ratingDeltaForMe(), -12);
    });

    test('pending request from someone else is incoming', () {
      final s = MatchSession(
        id: 'm',
        opponent: _opp(),
        dateTime: DateTime.now().add(const Duration(days: 1)),
        court: 'x',
        status: MatchStatus.pending,
        isRequester: false,
      );
      expect(s.isIncomingRequest, isTrue);
      expect(s.isUpcoming, isTrue);
    });
  });
}
