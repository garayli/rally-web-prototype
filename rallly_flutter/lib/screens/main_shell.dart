import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/data_service.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/onboarding_overlay.dart';
import 'match_screen.dart';
import 'schedule_screen.dart';
import 'messages_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const _prefsKey = 'onboarding_seen';
  List<bool> _seen = List.filled(5, true); // default true → hide until prefs load
  bool _prefsLoaded = false;

  final _screens = const [
    MatchScreen(),
    ScheduleScreen(),
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
      _seen = List.generate(5, (i) => seenIndices.contains('$i'));
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
    // Force light status bar icons on cream background
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
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: RallyColors.border)),
          boxShadow: [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 24,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: ValueListenableBuilder<int>(
          valueListenable: dataService.unreadNotifier,
          builder: (context, unreadCount, _) => BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.sports_tennis_outlined),
                activeIcon: Icon(Icons.sports_tennis),
                label: 'Maç',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today_outlined),
                activeIcon: Icon(Icons.calendar_today),
                label: 'Takvim',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline),
                activeIcon: Icon(Icons.chat_bubble),
                label: 'Mesajlar',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.notifications_outlined),
                    Positioned(
                      top: -2,
                      right: -4,
                      child: NotifBadge(count: unreadCount),
                    ),
                  ],
                ),
                activeIcon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.notifications),
                    Positioned(
                      top: -2,
                      right: -4,
                      child: NotifBadge(count: unreadCount),
                    ),
                  ],
                ),
                label: 'Bildirim',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
