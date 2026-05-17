import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';
import '../widgets/shared_widgets.dart';
import '../models/models.dart';
import '../services/data_service.dart';
import '../main.dart' show CourtThemeProvider;
import 'player_profile_screen.dart';

// ─── Inbox screen ─────────────────────────────────────────────────────────────
class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  String _searchQuery = '';
  String _filter = 'Tümü'; // Tümü | Okunmamış | Maç Eşleri
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Conversation> get _filtered {
    var list = dataService.getConversations();
    if (_filter == 'Okunmamış') {
      list = list.where((c) =>
        !dataService.isConversationRead(c.id) &&
        c.unreadCount(dataService.currentUserId) > 0).toList();
    } else if (_filter == 'Maç Eşleri') {
      final matchOpponentIds = dataService.getUpcomingSessions()
          .map((s) => s.opponent.id)
          .toSet();
      list = list.where((c) => matchOpponentIds.contains(c.other.id)).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((c) =>
        c.other.name.toLowerCase().contains(q) ||
        (c.lastMessage?.text.toLowerCase().contains(q) ?? false)).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final cp = CourtThemeProvider.of(context);
    final convos = _filtered;

    return Scaffold(
      backgroundColor: cp.bg,
      appBar: AppBar(
        backgroundColor: cp.bg.withValues(alpha: 0.96),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Mesajlar',
          style: TextStyle(
            fontFamily: 'InstrumentSerif',
            fontSize: 22,
            color: cp.text,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit_outlined, color: cp.text),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Konuşma düzenleme yakında'),
                behavior: SnackBarBehavior.floating,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: cp.border),
        ),
      ),
      body: Column(
        children: [
          // ── Search bar ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.gutter, Spacing.md, Spacing.gutter, Spacing.sm),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              decoration: BoxDecoration(
                color: cp.surface,
                borderRadius: BorderRadius.circular(RallyRadius.md),
                border: Border.all(color: cp.border),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, size: 18, color: cp.muted),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v.trim()),
                      style: RallyType.body.copyWith(color: cp.text),
                      decoration: InputDecoration(
                        hintText: 'İsim veya mesaj ara…',
                        hintStyle: RallyType.body.copyWith(color: cp.muted2),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Filter chips ──────────────────────────────────────────────
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.gutter),
              children: ['Tümü', 'Okunmamış', 'Maç Eşleri'].map((f) {
                final active = _filter == f;
                final unreadCount = f == 'Okunmamış'
                    ? dataService.getConversations().where((c) =>
                        !dataService.isConversationRead(c.id) &&
                        c.unreadCount(dataService.currentUserId) > 0).length
                    : 0;
                return Padding(
                  padding: const EdgeInsets.only(right: Spacing.sm),
                  child: GestureDetector(
                    onTap: () => setState(() => _filter = f),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: active ? cp.accent : cp.surface,
                        borderRadius: BorderRadius.circular(RallyRadius.pill),
                        border: Border.all(
                          color: active ? cp.accent : cp.border2,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            f,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: active ? Colors.white : cp.text,
                            ),
                          ),
                          if (!active && unreadCount > 0) ...[
                            const SizedBox(width: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: cp.accent,
                                borderRadius: BorderRadius.circular(
                                  RallyRadius.pill),
                              ),
                              child: Text(
                                '$unreadCount',
                                style: RallyType.micro.copyWith(
                                  color: Colors.white),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: Spacing.sm),

          // ── Conversation list ─────────────────────────────────────────
          Expanded(
            child: convos.isEmpty
                ? Center(
                    child: Text(
                      _searchQuery.isNotEmpty
                          ? 'Sonuç bulunamadı'
                          : 'Henüz mesaj yok',
                      style: RallyType.body.copyWith(color: cp.muted),
                    ),
                  )
                : ListView.builder(
                    itemCount: convos.length,
                    itemBuilder: (context, i) {
                      final convo = convos[i];
                      return _InboxTile(
                        conversation: convo,
                        cp: cp,
                        onTap: () {
                          dataService.markConversationRead(convo.id);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ConversationScreen(
                                conversation: convo),
                            ),
                          ).then((_) => setState(() {}));
                        },
                      ).animate().fadeIn(delay: (i * 40).ms);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Inbox tile ───────────────────────────────────────────────────────────────
class _InboxTile extends StatelessWidget {
  final Conversation conversation;
  final CourtPalette cp;
  final VoidCallback onTap;

  const _InboxTile({
    required this.conversation,
    required this.cp,
    required this.onTap,
  });

  String _timeLabel(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inHours < 1) {
      return '${diff.inMinutes.abs()}m';
    }
    if (now.difference(dt).inHours < 24) {
      return DateFormat('HH:mm').format(dt);
    }
    return DateFormat('d MMM').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final last = conversation.lastMessage;
    final unread = !dataService.isConversationRead(conversation.id) &&
        conversation.unreadCount(dataService.currentUserId) > 0;
    final count = conversation.unreadCount(dataService.currentUserId);

    return InkWell(
      onTap: onTap,
      child: Container(
        color: unread ? cp.accentTint : Colors.transparent,
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.gutter, vertical: 12),
        child: Row(
          children: [
            // Avatar + online dot
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) =>
                  PlayerProfileScreen(player: conversation.other)),
              ),
              child: Stack(
                children: [
                  PlayerAvatar(
                    initials: conversation.other.initials,
                    gradientStart: conversation.other.avatarGradientStart,
                    gradientEnd: conversation.other.avatarGradientEnd,
                    size: 52,
                  ),
                  if (conversation.isOnline)
                    Positioned(
                      bottom: 1, right: 1,
                      child: Container(
                        width: 12, height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2BAA4A),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: unread ? cp.accentTint : cp.bg,
                            width: 2),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Name + last message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conversation.other.name,
                    style: RallyType.titleMD.copyWith(
                      color: cp.text,
                      fontWeight: unread
                          ? FontWeight.w700
                          : FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (last != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      last.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: RallyType.bodySM.copyWith(
                        color: unread ? cp.text2 : cp.muted,
                        fontWeight: unread
                            ? FontWeight.w500
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Time + unread badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (last != null)
                  Text(
                    _timeLabel(last.timestamp),
                    style: RallyType.caption.copyWith(
                      color: unread ? cp.accent : cp.muted,
                      fontWeight: unread
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                  ),
                if (unread && count > 0) ...[
                  const SizedBox(height: Spacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: cp.accent,
                      borderRadius: BorderRadius.circular(RallyRadius.pill),
                    ),
                    child: Text(
                      '$count',
                      style: RallyType.micro.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Conversation screen ──────────────────────────────────────────────────────
class ConversationScreen extends StatefulWidget {
  final Conversation conversation;

  const ConversationScreen({super.key, required this.conversation});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  late List<ChatMessage> _messages;
  final _deliveredIds = <String>{};

  @override
  void initState() {
    super.initState();
    _messages = List.from(widget.conversation.messages.reversed);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final msgId = DateTime.now().toIso8601String();
    setState(() {
      _messages.insert(
        0,
        ChatMessage(
          id: msgId,
          senderId: dataService.currentUserId,
          text: text,
          timestamp: DateTime.now(),
          isRead: false,
        ),
      );
    });
    _controller.clear();

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client.from('messages').insert({
          'sender_id': user.id,
          'text': text,
        });
        if (mounted) setState(() => _deliveredIds.add(msgId));
      }
    } catch (_) {
      // Mock mode — no real auth/profiles yet
    }
  }

  @override
  Widget build(BuildContext context) {
    final cp = CourtThemeProvider.of(context);

    return Scaffold(
      backgroundColor: cp.bg,
      appBar: AppBar(
        backgroundColor: cp.bg.withValues(alpha: 0.96),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 18, color: cp.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) =>
              PlayerProfileScreen(player: widget.conversation.other),
          )),
          child: Row(
            children: [
              Stack(
                children: [
                  PlayerAvatar(
                    initials: widget.conversation.other.initials,
                    gradientStart: widget.conversation.other.avatarGradientStart,
                    gradientEnd: widget.conversation.other.avatarGradientEnd,
                    size: 36,
                  ),
                  if (widget.conversation.isOnline)
                    Positioned(
                      bottom: 0, right: 0,
                      child: Container(
                        width: 10, height: 10,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2BAA4A),
                          shape: BoxShape.circle,
                          border: Border.all(color: cp.bg, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.conversation.other.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: cp.text,
                    )),
                  if (widget.conversation.isOnline)
                    const Text('Çevrimiçi',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF2BAA4A),
                        fontWeight: FontWeight.w500,
                      )),
                ],
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Maç İste',
            icon: Icon(Icons.sports_tennis, color: cp.accent),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${widget.conversation.other.name.split(' ').first} oyuncusuna maç isteği gönderildi! 🎾'),
                backgroundColor: cp.accent,
                behavior: SnackBarBehavior.floating,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: cp.border),
        ),
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: ListView.builder(
              reverse: true,
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.lg, vertical: Spacing.md),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final msg = _messages[i];
                final isMe = msg.senderId == dataService.currentUserId;
                return Align(
                  alignment: isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: Spacing.sm),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isMe ? cp.accent : cp.surface,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(isMe ? 18 : 4),
                        bottomRight: Radius.circular(isMe ? 4 : 18),
                      ),
                      border: isMe
                          ? null
                          : Border.all(color: cp.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          msg.text,
                          style: TextStyle(
                            fontSize: 14,
                            color: isMe ? Colors.white : cp.text,
                            height: 1.4,
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(height: 2),
                          Icon(
                            _deliveredIds.contains(msg.id) || msg.isRead
                                ? Icons.done_all
                                : Icons.check,
                            size: 13,
                            color: _deliveredIds.contains(msg.id) || msg.isRead
                                ? Colors.white
                                : Colors.white60,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Input bar
          Container(
            padding: EdgeInsets.fromLTRB(
              Spacing.lg, 10, Spacing.lg,
              MediaQuery.of(context).padding.bottom + 10,
            ),
            decoration: BoxDecoration(
              color: cp.surface,
              border: Border(top: BorderSide(color: cp.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: RallyType.body.copyWith(color: cp.text),
                    decoration: InputDecoration(
                      hintText:
                        '${widget.conversation.other.name.split(' ').first} ile mesajlaş…',
                      hintStyle: RallyType.body.copyWith(color: cp.muted),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(RallyRadius.pill),
                        borderSide: BorderSide(color: cp.border2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(RallyRadius.pill),
                        borderSide: BorderSide(color: cp.border2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(RallyRadius.pill),
                        borderSide: BorderSide(color: cp.accent),
                      ),
                      fillColor: cp.surface,
                      filled: true,
                    ),
                    onSubmitted: (_) => _send(),
                    textInputAction: TextInputAction.send,
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                GestureDetector(
                  onTap: _send,
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: cp.accent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: cp.accent.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
