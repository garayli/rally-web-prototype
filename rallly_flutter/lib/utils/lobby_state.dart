import '../models/models.dart';

enum LobbyCardState {
  own,
  canJoin,
  requested,
  joined,
  queueFull,
  rosterFull,
}

/// What a lobby card shows to [uid]. [mine] is the viewer's own request to
/// this lobby (pending/confirmed), or null. Their own request wins over
/// "full": someone already in or waiting must never see "full".
LobbyCardState lobbyCardState(Lobby lobby, MatchSession? mine, String uid) {
  if (lobby.creatorId == uid) return LobbyCardState.own;
  if (mine != null) {
    return mine.status == MatchStatus.confirmed
        ? LobbyCardState.joined
        : LobbyCardState.requested;
  }
  if (lobby.rosterFull) return LobbyCardState.rosterFull;
  if (lobby.queueFull) return LobbyCardState.queueFull;
  return LobbyCardState.canJoin;
}
