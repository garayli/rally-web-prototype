import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/data_service.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/onboarding_overlay.dart';
import '../main.dart' show CourtThemeProvider;
import 'match_screen.dart';
import 'messages_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'create_game_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  // v2 key so users see the new onboarding tour once
  static const _prefsKey = 'onboarding_seen_v2';
  List<bool> _seen = List.filled(4, true);
  bool _prefsLoaded = false;

  static const _screens = [
    MatchScreen(),
    MessagesScreen(),
    NotificationsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadSeenState();
  }

  Future<void> _loadSeenState() async {
    final prefs = await SharedPreferences.getInstance();
    final seenIndices = prefs.getStringList(_prefsKey) ?? [];
    if (!mounted) return;
    setState(() {
      _seen = List.generate(4, (i) => seenIndices.contains('$i'));
      _prefsLoaded = true;
    });
  }

  Future<void> _dismissOverlay(int tabIndex) async {
    setState(() => _seen[tabIndex] = true);
    final prefs = await SharedPreferences.getInstance();
    final seenIndices = prefs.getStringList(_prefsKey) ?? [];
    if (!seenIndices.contains('$tabIndex')) {
      seenIndices.add('$tabIndex');
      await prefs.setStringList(_prefsKey, seenIndices);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cp = CourtThemeProvider.of(context);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          if (_prefsLoaded && !_seen[_currentIndex])
            OnboardingOverlay(
              content: kTabOnboardingContent[_currentIndex],
              onDismiss: () => _dismissOverlay(_currentIndex),
            ),
        ],
      ),

      // FAB — visible only on Discover (tab 0)
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateGameScreen()),
              ),
              backgroundColor: cp.accent,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add, size: 20),
              label: const Text(
                'Maç Oluştur',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              elevation: 6,
              shape: const StadiumBorder(),
            )
          : null,

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: cp.surface,
          border: Border(top: BorderSide(color: cp.border)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 24,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: ValueListenableBuilder<int>(
              valueListenable: dataService.unreadNotifier,
              builder: (context, unreadCount, _) => Row(
                children: [
                  _NavItem(
                    icon: Icons.sports_tennis_outlined,
                    activeIcon: Icons.sports_tennis,
                    label: 'Keşfet',
                    active: _currentIndex == 0,
                    cp: cp,
                    onTap: () => setState(() => _currentIndex = 0),
                  ),
                  _NavItem(
                    icon: Icons.chat_bubble_outline,
                    activeIcon: Icons.chat_bubble,
                    label: 'Mesajlar',
                    active: _currentIndex == 1,
                    cp: cp,
                    onTap: () => setState(() => _currentIndex = 1),
                  ),
                  _NavItem(
                    icon: Icons.notifications_outlined,
                    activeIcon: Icons.notifications,
                    label: 'Bildirim',
                    active: _currentIndex == 2,
                    badge: unreadCount,
                    cp: cp,
                    onTap: () => setState(() => _currentIndex = 2),
                  ),
                  _NavItem(
                    icon: Icons.person_outline,
                    activeIcon: Icons.person,
                    label: 'Profil',
                    active: _currentIndex == 3,
                    cp: cp,
                    onTap: () => setState(() => _currentIndex = 3),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool active;
  final int badge;
  final CourtPalette cp;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.active,
    required this.cp,
    required this.onTap,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? cp.accent : cp.muted;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(active ? activeIcon : icon, color: color, size: 24),
                if (badge > 0)
                  Positioned(
                    top: -2, right: -4,
                    child: NotifBadge(count: badge),
                  ),
              ],
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                color: color,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
