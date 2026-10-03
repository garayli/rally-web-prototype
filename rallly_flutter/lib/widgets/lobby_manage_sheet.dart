import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/data_error_message.dart';
import '../l10n/l10n.dart';
import '../l10n/option_labels.dart';
import '../main.dart' show CourtThemeProvider;
import '../models/models.dart';
import '../screens/messages_screen.dart';
import '../services/data_service.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';
import 'shared_widgets.dart';

/// Organiser's view of one of their lobbies: who is waiting, who is in, with
/// accept / decline / message / remove, and closing the lobby.
void showLobbyManageSheet(BuildContext context, Lobby lobby) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _LobbyManageSheet(
        lobbyId: lobby.id,
        fallback: lobby,
        cp: CourtThemeProvider.of(context)),
  );
}

class _LobbyManageSheet extends StatefulWidget {
  final String lobbyId;
  final Lobby fallback;
  final CourtPalette cp;
  const _LobbyManageSheet(
      {required this.lobbyId, required this.fallback, required this.cp});

  @override
  State<_LobbyManageSheet> createState() => _LobbyManageSheetState();
}

class _LobbyManageSheetState extends State<_LobbyManageSheet> {
  List<LobbyParticipant>? _people;
  bool _busy = false;

  CourtPalette get cp => widget.cp;

  /// Latest counters from the shared cache (the card list refreshes it).
  Lobby get _lobby => dataService
      .getLobbies()
      .firstWhere((b) => b.id == widget.lobbyId, orElse: () => widget.fallback);

  @override
  void initState() {
    super.initState();
    dataService.cacheVersion.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    dataService.cacheVersion.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final people = await dataService.getLobbyParticipants(widget.lobbyId);
      if (mounted) setState(() => _people = people);
    } catch (e) {
      debugPrint('LOBBY PARTICIPANTS ERROR: $e');
      if (mounted) setState(() => _people ??= []);
    }
  }

  Future<void> _run(Future<void> Function() action, String done,
      {bool closeAfter = false}) async {
    final l = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    setState(() => _busy = true);
    try {
      await action();
      messenger.showSnackBar(SnackBar(content: Text(done)));
      if (closeAfter) {
        nav.pop();
        return;
      }
      await _load();
    } catch (e) {
      debugPrint('LOBBY ACTION ERROR: $e');
      messenger.showSnackBar(SnackBar(
        content: Text(l.actionFailed(dataErrorMessage(l, e))),
        backgroundColor: RallyColors.accent2,
      ));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool> _confirm(String title, String body, String action) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(action,
                style: const TextStyle(color: RallyColors.accent2)),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  void _message(Player p) {
    final existing = dataService
        .getConversations()
        .where((c) => c.other.id == p.id)
        .firstOrNull;
    final convo = existing ??
        Conversation(id: 'new_${p.id}', other: p, messages: const []);
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => ConversationScreen(conversation: convo)));
  }

  Widget _iconBtn(IconData icon, String tip, VoidCallback? onTap,
          {Color? color}) =>
      IconButton(
        icon: Icon(icon, size: 20, color: color ?? cp.text),
        tooltip: tip,
        onPressed: _busy ? null : onTap,
        visualDensity: VisualDensity.compact,
      );

  Widget _row(LobbyParticipant p) {
    final l = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
      child: Row(children: [
        PlayerAvatar(
          initials: p.player.initials,
          gradientStart: p.player.avatarGradientStart,
          gradientEnd: p.player.avatarGradientEnd,
          size: 38,
        ),
        const SizedBox(width: Spacing.md),
        Expanded(
          child: Text(p.player.name,
              style: RallyType.titleMD.copyWith(color: cp.text),
              overflow: TextOverflow.ellipsis),
        ),
        _iconBtn(Icons.chat_bubble_outline, l.lobbyMessage,
            () => _message(p.player)),
        if (!p.accepted) ...[
          _iconBtn(
              Icons.close,
              l.lobbyDecline,
              () => _run(
                  () => dataService.respondToMatchRequest(
                      matchId: p.matchId, accept: false),
                  l.lobbyDeclinedDone),
              color: RallyColors.accent2),
          _iconBtn(
              Icons.check,
              l.lobbyAccept,
              () => _run(
                  () => dataService.respondToMatchRequest(
                      matchId: p.matchId, accept: true),
                  l.lobbyAcceptedDone),
              color: RallyColors.accent),
        ] else
          _iconBtn(Icons.person_remove_outlined, l.lobbyRemove, () async {
            if (!await _confirm(l.lobbyRemoveTitle,
                l.lobbyRemoveBody(p.player.name), l.lobbyRemove)) {
              return;
            }
            await _run(() => dataService.removeFromLobby(matchId: p.matchId),
                l.lobbyRemovedDone);
          }, color: RallyColors.accent2),
      ]),
    );
  }

  Widget _section(String title, List<LobbyParticipant> people) {
    if (people.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: Spacing.lg),
        Text(title.toUpperCase(),
            style: RallyType.micro.copyWith(color: cp.muted)),
        const SizedBox(height: Spacing.xs),
        ...people.map(_row),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final lobby = _lobby;
    final people = _people;
    final pending = people?.where((p) => !p.accepted).toList() ?? [];
    final accepted = people?.where((p) => p.accepted).toList() ?? [];
    final dt = lobby.dateTime;
    return SafeArea(
      child: Container(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        decoration: BoxDecoration(
          color: cp.bg,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(RallyRadius.sheet)),
        ),
        padding: const EdgeInsets.fromLTRB(
            Spacing.xl, Spacing.lg, Spacing.xl, Spacing.xl),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: cp.muted2, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: Spacing.xl),
              Text(l.lobbyManageTitle,
                  style: RallyType.titleLG.copyWith(color: cp.text)),
              const SizedBox(height: Spacing.xs),
              Text(
                [
                  '${sportLabel(l, lobby.sport)} · '
                      '${lobby.isDoubles ? l.formatDoubles : l.formatSingles}',
                  if (dt != null)
                    DateFormat('EEE d MMM, HH:mm', context.localeName)
                        .format(dt),
                  lobby.court,
                ].join(' · '),
                style: RallyType.bodySM.copyWith(color: cp.muted),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                l.lobbyCounts(
                    lobby.acceptedCount, lobby.capacity, lobby.pendingCount),
                style: RallyType.caption.copyWith(
                    fontWeight: FontWeight.w600, color: cp.accentStrong),
              ),
              if (people == null)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: Spacing.xl),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (people.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: Spacing.xl),
                  child: Text(l.lobbyNoParticipants,
                      style: RallyType.body.copyWith(color: cp.muted)),
                )
              else ...[
                _section(l.lobbyPendingSection, pending),
                _section(l.lobbyAcceptedSection, accepted),
              ],
              const SizedBox(height: Spacing.xl),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _busy
                      ? null
                      : () async {
                          if (!await _confirm(l.lobbyCloseTitle,
                              l.lobbyCloseBody, l.lobbyClose)) {
                            return;
                          }
                          await _run(
                              () => dataService.closeLobby(widget.lobbyId),
                              l.lobbyClosedDone,
                              closeAfter: true);
                        },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: RallyColors.accent2,
                    side: const BorderSide(color: RallyColors.accent2),
                  ),
                  child: Text(l.lobbyClose),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
