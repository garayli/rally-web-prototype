import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/profile_completeness.dart';
import '../models/models.dart';
import '../services/data_service.dart';
import '../main.dart' show supabase, CourtThemeProvider, courtThemeNotifier;
import 'edit_profile_screen.dart';
import 'reputation_screen.dart';
import 'achievements_screen.dart';
import 'notifications_preferences_screen.dart';
import 'log_result_screen.dart';
import 'my_results_screen.dart';
import '../widgets/match_detail_sheet.dart';
import '../l10n/l10n.dart';
import '../l10n/option_labels.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _bannerDismissed = false;

  // Fields EditProfileScreen can fill beyond the required name/location.
  // Photo is left out until upload exists, so the banner never asks for
  // something the user can't provide.
  static const _optionalFieldCount = 4;

  static List<String> _missingFieldsOf(Player me, AppLocalizations l) => [
        if (me.about.isEmpty) l.missingBio,
        if (me.availableDays.isEmpty) l.missingAvailability,
        if (me.sports.isEmpty) l.missingSport,
        if (me.skillLevel == null) l.missingLevel,
      ];

  static int _completenessOf(List<String> missing) =>
      (100 * (1 - missing.length / (_optionalFieldCount + 2))).round();

  static String _availabilitySummary(Player? me, AppLocalizations l) {
    if (me == null || me.availableDays.isEmpty) return l.profileSetSchedule;
    final days = me.availableDays.map((d) => dayLabel(l, d)).join(', ');
    return me.timePrefs.isEmpty
        ? days
        : '$days · ${me.timePrefs.map((t) => timeLabel(l, t)).join(', ')}';
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: dataService.cacheVersion,
      builder: (context, _, __) => _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    final cp = CourtThemeProvider.of(context);
    final me = dataService.getCurrentPlayer();
    final l = context.l10n;
    final missing = me == null ? const <String>[] : _missingFieldsOf(me, l);
    final completeness = me == null ? 0 : _completenessOf(missing);
    final upcoming = dataService.getUpcomingSessions()
        .where((s) => s.status == MatchStatus.confirmed).toList();
    final past = dataService.getUpcomingSessions()
        .where((s) => s.status == MatchStatus.completed).toList();
    final pending = dataService.getUpcomingSessions()
        .where((s) => s.status == MatchStatus.pending).toList();
    // Record from the user's own logged results (not placeholder numbers).
    final myId = dataService.currentUserId;
    final decided = past.where((s) => s.wonBy(myId) != null).toList();
    final wins = decided.where((s) => s.wonBy(myId)!).length;

    return Scaffold(
      backgroundColor: cp.bg,
      body: CustomScrollView(
        slivers: [
          // ── App bar ────────────────────────────────────────────────────
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: cp.bg.withValues(alpha: 0.96),
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Text(
              l.profileTitle,
              style: TextStyle(
                fontFamily: 'InstrumentSerif',
                fontSize: 22,
                color: cp.text,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.palette_outlined, color: cp.text),
                tooltip: l.courtThemeTitle,
                onPressed: () => _showThemePicker(context, cp),
              ),
              const SizedBox(width: 8),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Divider(height: 1, color: cp.border),
            ),
          ),

          // ── Profile hero ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [cp.accentTint, cp.bg],
                ),
                border: Border(bottom: BorderSide(color: cp.border)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Column(
                children: [
                  // Avatar with completeness ring
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CompletenessRing(score: completeness, size: 100, strokeWidth: 3.5),
                      PlayerAvatar(
                        initials: me?.initials ?? '?',
                        gradientStart: me?.avatarGradientStart ?? '#7b4fa6',
                        gradientEnd: me?.avatarGradientEnd ?? '#a97fcb',
                        size: 84,
                      ),
                      Positioned(
                        bottom: 2, right: 2,
                        child: GestureDetector(
                          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l.photoUploadSoon),
                              behavior: SnackBarBehavior.floating,
                            ),
                          ),
                          child: Container(
                            width: 28, height: 28,
                            decoration: BoxDecoration(
                              color: cp.surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: cp.border2, width: 1.5),
                              boxShadow: RallyElevation.card,
                            ),
                            child: Icon(Icons.camera_alt,
                              size: 14, color: cp.text2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    me?.name ?? '...',
                    style: TextStyle(
                      fontFamily: 'InstrumentSerif',
                      fontSize: 28,
                      letterSpacing: -1,
                      color: cp.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (me != null && me.location.isNotEmpty)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_on_outlined, size: 13, color: cp.text2),
                        const SizedBox(width: 3),
                        Text(
                          me.location,
                          style: TextStyle(fontSize: 13, color: cp.text2),
                        ),
                      ],
                    ),
                  if (me != null && me.about.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      me.about,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: RallyType.bodySM.copyWith(color: cp.text2),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: cp.surface,
                      borderRadius: BorderRadius.circular(RallyRadius.pill),
                      border: Border.all(color: cp.border),
                    ),
                    child: Text(
                      me != null
                          ? l.profileNtrpLine(me.ntrpRating.toStringAsFixed(1), skillLevelLabel(l, me.skillLabel))
                          : l.profileNtrpUnknown,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: cp.text2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: _openEditProfile,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 9),
                      decoration: BoxDecoration(
                        color: cp.accent,
                        borderRadius: BorderRadius.circular(RallyRadius.pill),
                      ),
                      child: Text(
                        l.editProfile,
                        style: RallyType.titleSM.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Profile completeness banner ────────────────────────────────
          if (!_bannerDismissed && missing.isNotEmpty)
            SliverToBoxAdapter(
              child: ProfileCompletenessBanner(
                score: completeness,
                missing: missing,
                onTap: _openEditProfile,
                onDismiss: () => setState(() => _bannerDismissed = true),
              ),
            ),

          // ── Stats row ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: cp.surface,
                border: Border(
                  top: BorderSide(color: cp.border),
                  bottom: BorderSide(color: cp.border),
                ),
              ),
              child: Row(
                children: [
                  _StatBox(value: '$wins', label: l.statWins,
                    color: cp.accent, cp: cp),
                  _StatBox(value: '${decided.length - wins}', label: l.statLosses,
                    color: cp.text, cp: cp),
                  _StatBox(value: '${decided.length}', label: l.statPlayed,
                    color: cp.text, cp: cp),
                  _StatBox(value: me?.ntrpDisplay ?? '–', label: 'NTRP',
                    color: cp.accent, cp: cp),
                ],
              ),
            ),
          ),

          // ── Quick actions row ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  Spacing.gutter, Spacing.lg, Spacing.gutter, 0),
              child: Row(
                children: [
                  Expanded(
                    child: _QuickActionBtn(
                      icon: Icons.upload_outlined,
                      label: l.uploadScore,
                      cp: cp,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const LogResultScreen()),
                      ),
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: _QuickActionBtn(
                      icon: Icons.pending_actions_outlined,
                      label: l.scoreRequests,
                      cp: cp,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const MyResultsScreen()),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Maçlarım section ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.gutter, Spacing.xl, Spacing.gutter, Spacing.sm),
              child: Text(
                l.myMatchesHeader,
                style: RallyType.eyebrow.copyWith(
                  color: cp.muted, letterSpacing: 1.4),
              ),
            ),
          ),

          // Tab bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.gutter),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: cp.surfaceSoft,
                  borderRadius: BorderRadius.circular(RallyRadius.md),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: cp.surface,
                    borderRadius: BorderRadius.circular(RallyRadius.sm),
                    boxShadow: RallyElevation.hairline,
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: cp.text,
                  unselectedLabelColor: cp.text2,
                  labelStyle: RallyType.titleSM,
                  unselectedLabelStyle: RallyType.bodySM,
                  tabs: [
                    Tab(text: l.tabUpcomingCount(upcoming.length)),
                    Tab(text: l.tabPastCount(past.length)),
                    Tab(text: l.tabPendingCount(pending.length)),
                  ],
                ),
              ),
            ),
          ),

          // Tab content — sized to fit whatever the active tab holds, so a
          // single session doesn't leave a tall empty box below it.
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _tabController,
              builder: (context, _) {
                const lists = ['upcoming', 'past', 'pending'];
                final sessions = switch (lists[_tabController.index]) {
                  'upcoming' => upcoming,
                  'past' => past,
                  _ => pending,
                };
                final emptyLabel = switch (lists[_tabController.index]) {
                  'upcoming' => l.emptyUpcoming,
                  'past' => l.emptyPast,
                  _ => l.emptyPending,
                };
                return _SessionList(
                    sessions: sessions, cp: cp, emptyLabel: emptyLabel);
              },
            ),
          ),

          // ── Settings ───────────────────────────────────────────────────
          SliverList(
            delegate: SliverChildListDelegate([
              _SettingsSection(title: l.sectionMyGame, cp: cp),
              _SettingsItem(
                icon: Icons.star_outline,
                label: l.reputation,
                sub: l.reputationSub,
                cp: cp,
                onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ReputationScreen())),
              ),
              _SettingsItem(
                icon: Icons.emoji_events_outlined,
                label: l.achievements,
                sub: l.achievementsSub,
                cp: cp,
                onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AchievementsScreen())),
              ),
              _SettingsItem(
                icon: Icons.bar_chart,
                label: l.myResults,
                sub: l.myResultsSub,
                cp: cp,
                onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const MyResultsScreen())),
              ),
              _SettingsItem(
                icon: Icons.sports_score,
                label: l.logResult,
                sub: l.logResultSub,
                cp: cp,
                onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const LogResultScreen())),
              ),
              _SettingsSection(title: l.sectionAccount, cp: cp),
              _SettingsItem(
                icon: Icons.person_outline,
                label: l.editProfile,
                sub: l.editProfileSub,
                cp: cp,
                onTap: _openEditProfile,
              ),
              _SettingsItem(
                icon: Icons.sports_tennis_outlined,
                label: l.gamePreferences,
                sub: l.gamePreferencesSub,
                cp: cp,
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l.gamePreferencesSoon),
                    behavior: SnackBarBehavior.floating,
                  ),
                ),
              ),
              _SettingsItem(
                icon: Icons.calendar_today_outlined,
                label: l.availability,
                sub: _availabilitySummary(me, l),
                cp: cp,
                onTap: _openEditProfile,
              ),
              _SettingsSection(title: l.sectionApp, cp: cp),
              _SettingsItem(
                icon: Icons.notifications_outlined,
                label: l.notifications,
                sub: l.notificationsSub,
                cp: cp,
                onTap: () => Navigator.push(context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationPreferencesScreen())),
              ),
              _SettingsItem(
                icon: Icons.palette_outlined,
                label: l.courtThemeTitle,
                sub: l.courtThemeOptions,
                cp: cp,
                onTap: () => _showThemePicker(context, cp),
              ),
              _SettingsItem(
                icon: Icons.lock_outline,
                label: l.privacySecurity,
                sub: l.privacySecuritySub,
                cp: cp,
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l.privacySettingsSoon),
                    behavior: SnackBarBehavior.floating,
                  ),
                ),
              ),
              _SettingsSection(title: l.sectionAbout, cp: cp),
              _SettingsItem(
                icon: Icons.description_outlined,
                label: l.termsPrivacy,
                cp: cp,
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l.termsPrivacySoon),
                    behavior: SnackBarBehavior.floating,
                  ),
                ),
              ),
              _SettingsItem(
                icon: Icons.logout,
                label: l.signOut,
                cp: cp,
                onTap: () async { await supabase.auth.signOut(); },
                isDestructive: true,
              ),
              const SizedBox(height: 100),
            ]),
          ),
        ],
      ),
    );
  }

  Future<void> _openEditProfile() async {
    final me = dataService.getCurrentPlayer();
    if (me == null) {
      // Profile row not loaded yet (or warmCache failed) — retry the fetch.
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(context.l10n.profileLoadingRetry),
        behavior: SnackBarBehavior.floating,
      ));
      unawaited(dataService.warmCache());
      return;
    }
    final saved = await Navigator.push<bool>(context,
      MaterialPageRoute(builder: (_) => EditProfileScreen(player: me)));
    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(context.l10n.profileUpdated),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  void _showThemePicker(BuildContext context, CourtPalette current) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: current.bg,
          borderRadius: RR.sheetTop,
        ),
        padding: EdgeInsets.fromLTRB(
          24, 12, 24,
          MediaQuery.of(context).padding.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: current.muted2,
                  borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text(context.l10n.courtThemeTitle,
              style: RallyType.displaySM.copyWith(color: current.text)),
            const SizedBox(height: 4),
            Text(context.l10n.courtThemeSubtitle,
              style: RallyType.bodySM.copyWith(color: current.text2)),
            const SizedBox(height: 20),
            ...([CourtPalette.clay, CourtPalette.hard, CourtPalette.grass])
              .map((palette) {
                final isActive = courtThemeNotifier.value.theme == palette.theme;
                return GestureDetector(
                  onTap: () {
                    courtThemeNotifier.value = palette;
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: Spacing.sm),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: palette.surface,
                      borderRadius: BorderRadius.circular(RallyRadius.lg),
                      border: Border.all(
                        color: isActive ? palette.accent : palette.border,
                        width: isActive ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [palette.gradA, palette.gradB]),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(courtThemeLabel(context.l10n, palette.theme),
                              style: RallyType.titleMD.copyWith(
                                color: palette.text)),
                            Text(
                              switch (palette.theme) {
                                CourtTheme.clay => context.l10n.courtThemeClaySub,
                                CourtTheme.hard => context.l10n.courtThemeHardSub,
                                CourtTheme.grass => context.l10n.courtThemeGrassSub,
                              },
                              style: RallyType.bodySM.copyWith(
                                color: palette.muted)),
                          ],
                        ),
                        const Spacer(),
                        if (isActive)
                          Icon(Icons.check_circle,
                            color: palette.accent, size: 20),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

// ─── Session list in Maçlarım tabs ───────────────────────────────────────────
class _SessionList extends StatelessWidget {
  final List<MatchSession> sessions;
  final CourtPalette cp;
  final String emptyLabel;

  const _SessionList({
    required this.sessions,
    required this.cp,
    required this.emptyLabel,
  });

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return SizedBox(
        height: 96,
        child: Center(
          child: Text(emptyLabel,
            style: RallyType.body.copyWith(color: cp.muted)),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.gutter, Spacing.sm, Spacing.gutter, Spacing.sm),
      child: Column(
        children: [
          for (final s in sessions) _SessionCard(session: s, cp: cp),
        ],
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final MatchSession session;
  final CourtPalette cp;

  const _SessionCard({required this.session, required this.cp});

  @override
  Widget build(BuildContext context) {
    final dt = session.dateTime;
    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      decoration: BoxDecoration(
        color: cp.surface,
        borderRadius: BorderRadius.circular(RallyRadius.lg),
        border: Border.all(color: cp.border),
        boxShadow: RallyElevation.card,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(RallyRadius.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(RallyRadius.lg),
          onTap: () => showMatchDetailSheet(context, session),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Time column
                SizedBox(
                  width: 52,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('HH:mm', context.localeName).format(dt),
                        style: RallyType.displaySM.copyWith(
                          color: cp.text, fontSize: 20),
                      ),
                      Text(
                        DateFormat('EEE', context.localeName).format(dt).toUpperCase(),
                        style: RallyType.micro.copyWith(
                          color: cp.muted, letterSpacing: 0.4),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 36, color: cp.border,
                  margin: const EdgeInsets.symmetric(horizontal: 12)),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.vsOpponent(session.opponent.name),
                        style: RallyType.titleMD.copyWith(color: cp.text),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        courtDisplay(context.l10n, session.court),
                        style: RallyType.bodySM.copyWith(color: cp.muted),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: cp.accentTint,
                    borderRadius: BorderRadius.circular(RallyRadius.pill),
                  ),
                  child: Text(
                    session.status == MatchStatus.pending
                        ? sessionStatusLabel(context.l10n, session).toUpperCase()
                        : _statusLabel(context.l10n, session.status),
                    style: RallyType.micro.copyWith(
                      color: cp.accentStrong, letterSpacing: 0.3),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, size: 18, color: cp.muted),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _statusLabel(AppLocalizations l, MatchStatus s) {
    switch (s) {
      case MatchStatus.confirmed:  return l.statusUpcomingUpper;
      case MatchStatus.completed:  return l.statusCompletedUpper;
      case MatchStatus.pending:    return l.statusPendingUpper;
      case MatchStatus.cancelled:  return l.statusCancelledUpper;
    }
  }
}

// ─── Quick action button ──────────────────────────────────────────────────────
class _QuickActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final CourtPalette cp;
  final VoidCallback onTap;

  const _QuickActionBtn({
    required this.icon,
    required this.label,
    required this.cp,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: cp.surface,
          borderRadius: BorderRadius.circular(RallyRadius.lg),
          border: Border.all(color: cp.border),
          boxShadow: RallyElevation.card,
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: cp.accent),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: cp.text,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Stat box ─────────────────────────────────────────────────────────────────
class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final CourtPalette cp;

  const _StatBox({
    required this.value,
    required this.label,
    required this.color,
    required this.cp,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: cp.border)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontFamily: 'InstrumentSerif',
                fontSize: 26,
                color: color,
                letterSpacing: -1,
                height: 1,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: RallyType.micro.copyWith(color: cp.muted),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Settings section ─────────────────────────────────────────────────────────
class _SettingsSection extends StatelessWidget {
  final String title;
  final CourtPalette cp;
  const _SettingsSection({required this.title, required this.cp});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Spacing.gutter, Spacing.xl,
        Spacing.gutter, Spacing.sm),
      child: Text(
        title,
        style: RallyType.eyebrow.copyWith(
          color: cp.muted, letterSpacing: 1.4),
      ),
    );
  }
}

// ─── Settings item ────────────────────────────────────────────────────────────
class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? sub;
  final CourtPalette cp;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SettingsItem({
    required this.icon,
    required this.label,
    this.sub,
    required this.cp,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = isDestructive ? RallyColors.accent2 : cp.accentStrong;
    final iconBg = isDestructive
        ? const Color(0xFFFEF2EE)
        : cp.accentTint;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.gutter, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(RallyRadius.sm),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: RallyType.titleMD.copyWith(
                      color: isDestructive
                          ? RallyColors.accent2
                          : cp.text,
                    ),
                  ),
                  if (sub != null)
                    Text(sub!,
                      style: RallyType.bodySM.copyWith(color: cp.muted)),
                ],
              ),
            ),
            if (!isDestructive)
              Icon(Icons.chevron_right, color: cp.muted2, size: 20),
          ],
        ),
      ),
    );
  }
}
