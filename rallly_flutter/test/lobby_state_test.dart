import 'package:flutter_test/flutter_test.dart';
import 'package:rallly/models/models.dart';
import 'package:rallly/utils/lobby_state.dart';

Lobby lobby({
  bool doubles = false,
  String status = 'open',
  int pending = 0,
  int accepted = 0,
}) =>
    Lobby(
      id: 'l1',
      creatorId: 'org',
      sport: 'Tenis',
      skillLevel: 'Her seviye',
      dateTime: DateTime(2026, 10, 10, 10),
      court: 'Kort 1',
      isDoubles: doubles,
      status: status,
      pendingCount: pending,
      acceptedCount: accepted,
    );

MatchSession request(MatchStatus status) => MatchSession(
      id: 'm1',
      opponent: const Player(
          id: 'org', name: 'Org', initials: 'O', ntrpRating: 3, location: ''),
      dateTime: DateTime(2026, 10, 10, 10),
      court: 'Kort 1',
      status: status,
      lobbyId: 'l1',
    );

void main() {
  test('capacity: 1 singles, 3 doubles', () {
    expect(lobby().capacity, 1);
    expect(lobby(doubles: true).capacity, 3);
  });

  test('organiser always sees own', () {
    expect(
        lobbyCardState(
            lobby(pending: 10, accepted: 1, status: 'full'), null, 'org'),
        LobbyCardState.own);
  });

  test('9 pending can still join, 10 cannot', () {
    expect(lobbyCardState(lobby(pending: 9), null, 'u'), LobbyCardState.canJoin);
    expect(
        lobbyCardState(lobby(pending: 10), null, 'u'), LobbyCardState.queueFull);
  });

  test('10 pending, 1 accepted (doubles) → 9 pending → one more can join', () {
    final b = lobby(doubles: true, pending: 9, accepted: 1);
    expect(lobbyCardState(b, null, 'u'), LobbyCardState.canJoin);
  });

  test('roster full beats queue full for outsiders', () {
    final b = lobby(status: 'full', pending: 10, accepted: 1);
    expect(lobbyCardState(b, null, 'u'), LobbyCardState.rosterFull);
  });

  test('doubles needs 3 accepted to be full', () {
    expect(lobbyCardState(lobby(doubles: true, accepted: 2), null, 'u'),
        LobbyCardState.canJoin);
    expect(lobbyCardState(lobby(doubles: true, accepted: 3), null, 'u'),
        LobbyCardState.rosterFull);
  });

  test('own request wins over full', () {
    final full = lobby(status: 'full', pending: 10, accepted: 1);
    expect(lobbyCardState(full, request(MatchStatus.pending), 'u'),
        LobbyCardState.requested);
    expect(lobbyCardState(full, request(MatchStatus.confirmed), 'u'),
        LobbyCardState.joined);
  });
}
