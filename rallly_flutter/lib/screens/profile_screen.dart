import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/profile_completeness.dart';
import '../models/models.dart';
import '../services/data_service.dart';
import '../main.dart' show supabase, CourtThemeProvider, courtThemeNotifier;
import 'reputation_screen.dart';
import 'achievements_screen.dart';
import 'notifications_preferences_screen.dart';
import 'log_result_screen.dart';
import 'my_results_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _bannerDismissed = false;
  static const int _completeness = 65;
  static const _missingFields = ['fotoğraf', 'biyografi', 'müsaitlik'];

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
    final cp = CourtThemeProvider.of(context);
    final upcoming = dataService.getUpcomingSessions()
        .where((s) => s.status == MatchStatus.confirmed).toList();
    final past = dataService.getUpcomingSessions()
        .where((s) => s.status == MatchStatus.completed).toList();
    final pending = dataService.getUpcomingSessions()
        .where((s) => s.status == MatchStatus.pending).toList();

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
              'Profilim',
              style: TextStyle(
                fontFamily: 'InstrumentSerif',
                fontSize: 22,
                color: cp.text,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.palette_outlined, color: cp.text),
                tooltip: 'Kort Teması',
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
                      CompletenessRing(score: _completeness, size: 100, strokeWidth: 3.5),
                      const PlayerAvatar(
                        initials: 'LG',
                        gradientStart: '#7b4fa6',
                        gradientEnd: '#a97fcb',
                        size: 84,
                      ),
                      Positioned(
                        bottom: 2, right: 2,
                        child: GestureDetector(
                          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Fotoğraf yükleme yakında'),
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
                    'Leyla Garayli',
                    style: TextStyle(
                      fontFamily: 'InstrumentSerif',
                      fontSize: 28,
                      letterSpacing: -1,
                      color: cp.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on_outlined, size: 13, color: cp.text2),
                      const SizedBox(width: 3),
                      Text(
                        'Beşiktaş, İstanbul',
                        style: TextStyle(fontSize: 13, color: cp.text2),
                      ),
                    ],
                  ),
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
                      '🎾  NTRP 3.5 — Orta Seviye',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: cp.text2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profil düzenleme yakında'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 9),
                      decoration: BoxDecoration(
                        color: cp.accent,
                        borderRadius: BorderRadius.circular(RallyRadius.pill),
                      ),
                      child: Text(
                        'Profili Düzenle',
                        style: RallyType.titleSM.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Profile completeness banner ────────────────────────────────
          if (!_bannerDismissed)
            SliverToBoxAdapter(
              child: ProfileCompletenessBanner(
                score: _completeness,
                missing: _missingFields,
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profil düzenleme yakında'),
                    behavior: SnackBarBehavior.floating,
                  ),
                ),
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
                  _StatBox(value: '18', label: 'GALİBİYET',
                    color: cp.accent, cp: cp),
                  _StatBox(value: '7', label: 'MAĞLUBIYET',
                    color: cp.text, cp: cp),
                  _StatBox(value: '25', label: 'OYNANDI',
                    color: cp.text, cp: cp),
                  _StatBox(value: '4.8★', label: 'PUAN',
                    color: cp.accent, cp: cp),
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
                'MAÇLARIM',
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
                    Tab(text: 'Yaklaşan (${upcoming.length})'),
                    Tab(text: 'Geçmiş (${past.length})'),
                    Tab(text: 'Bekleyen (${pending.length})'),
                  ],
                ),
              ),
            ),
          ),

          // Tab content
          SliverToBoxAdapter(
            child: SizedBox(
              height: 220,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _SessionList(sessions: upcoming, cp: cp, emptyLabel: 'Yaklaşan maç yok'),
                  _SessionList(sessions: past, cp: cp, emptyLabel: 'Geçmiş maç yok'),
                  _SessionList(sessions: pending, cp: cp, emptyLabel: 'Bekleyen istek yok'),
                ],
              ),
            ),
          ),

          // ── Settings ───────────────────────────────────────────────────
          SliverList(
            delegate: SliverChildListDelegate([
              _SettingsSection(title: 'OYUNUM', cp: cp),
              _SettingsItem(
                icon: Icons.star_outline,
                label: 'İtibar',
                sub: '4.9 puan · 4 değerlendirme',
                cp: cp,
                onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ReputationScreen())),
              ),
              _SettingsItem(
                icon: Icons.emoji_events_outlined,
                label: 'Başarılar',
                sub: '18 üzerinden 12 kazanıldı',
                cp: cp,
                onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AchievementsScreen())),
              ),
              _SettingsItem(
                icon: Icons.bar_chart,
                label: 'Sonuçlarım',
                sub: 'Maç geçmişi ve skorlar',
                cp: cp,
                onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const MyResultsScreen())),
              ),
              _SettingsItem(
                icon: Icons.sports_score,
                label: 'Sonuç Kaydet',
                sub: 'Son maçını kaydet',
                cp: cp,
                onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const LogResultScreen())),
              ),
              _SettingsSection(title: 'HESAP', cp: cp),
              _SettingsItem(
                icon: Icons.person_outline,
                label: 'Profili Düzenle',
                sub: 'Ad, fotoğraf, biyografi güncelle',
                cp: cp,
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profil düzenleme yakında'),
                    behavior: SnackBarBehavior.floating,
                  ),
                ),
              ),
              _SettingsItem(
                icon: Icons.sports_tennis_outlined,
                label: 'Oyun Tercihleri',
                sub: 'Seviye, kort türü, format',
                cp: cp,
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Oyun tercihleri yakında'),
                    behavior: SnackBarBehavior.floating,
                  ),
                ),
              ),
              _SettingsItem(
                icon: Icons.calendar_today_outlined,
                label: 'Müsaitlik',
                sub: 'Haftalık programını ayarla',
                cp: cp,
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Müsaitlik ayarları yakında'),
                    behavior: SnackBarBehavior.floating,
                  ),
                ),
              ),
              _SettingsSection(title: 'UYGULAMA', cp: cp),
              _SettingsItem(
                icon: Icons.notifications_outlined,
                label: 'Bildirimler',
                sub: 'Maç istekleri, hatırlatmalar',
                cp: cp,
                onTap: () => Navigator.push(context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationPreferencesScreen())),
              ),
              _SettingsItem(
                icon: Icons.palette_outlined,
                label: 'Kort Teması',
                sub: 'Toprak / Sert Kort / Çim',
                cp: cp,
                onTap: () => _showThemePicker(context, cp),
              ),
              _SettingsItem(
                icon: Icons.lock_outline,
                label: 'Gizlilik ve Güvenlik',
                sub: 'Profil görünürlüğü',
                cp: cp,
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Gizlilik ayarları yakında'),
                    behavior: SnackBarBehavior.floating,
                  ),
                ),
              ),
              _SettingsSection(title: 'HAKKINDA', cp: cp),
              _SettingsItem(
                icon: Icons.description_outlined,
                label: 'Şartlar ve Gizlilik',
                cp: cp,
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Şartlar ve Gizlilik yakında'),
                    behavior: SnackBarBehavior.floating,
                  ),
                ),
              ),
              _SettingsItem(
                icon: Icons.logout,
                label: 'Çıkış Yap',
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
            Text('Kort Teması',
              style: RallyType.displaySM.copyWith(color: current.text)),
            const SizedBox(height: 4),
            Text('Uygulamanın renk temasını seç',
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
                            Text(palette.displayName,
                              style: RallyType.titleMD.copyWith(
                                color: palette.text)),
                            Text(
                              palette.theme == CourtTheme.clay
                                  ? 'Roland-Garros tarzı'
                                  : palette.theme == CourtTheme.hard
                                      ? 'US Open tarzı'
                                      : 'Wimbledon tarzı',
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
      return Center(
        child: Text(emptyLabel,
          style: RallyType.body.copyWith(color: cp.muted)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        Spacing.gutter, Spacing.sm, Spacing.gutter, Spacing.sm),
      itemCount: sessions.length,
      itemBuilder: (context, i) => _SessionCard(
        session: sessions[i], cp: cp),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cp.surface,
        borderRadius: BorderRadius.circular(RallyRadius.lg),
        border: Border.all(color: cp.border),
        boxShadow: RallyElevation.card,
      ),
      child: Row(
        children: [
          // Time column
          SizedBox(
            width: 52,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('HH:mm').format(dt),
                  style: RallyType.displaySM.copyWith(
                    color: cp.text, fontSize: 20),
                ),
                Text(
                  DateFormat('EEE').format(dt).toUpperCase(),
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
                  'vs ${session.opponent.name}',
                  style: RallyType.titleMD.copyWith(color: cp.text),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  session.court,
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
              _statusLabel(session.status),
              style: RallyType.micro.copyWith(
                color: cp.accentStrong, letterSpacing: 0.3),
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(MatchStatus s) {
    switch (s) {
      case MatchStatus.confirmed:  return 'YAKLAŞAN';
      case MatchStatus.completed:  return 'TAMAMLANDI';
      case MatchStatus.pending:    return 'BEKLİYOR';
      case MatchStatus.cancelled:  return 'İPTAL';
    }
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
