import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnon,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  await courtThemeNotifier.load();

  runApp(
    CourtThemeProvider(
      child: ThemeModeProvider(
        child: const RallyApp(),
      ),
    ),
  );
}

// Convenience accessor
final supabase = Supabase.instance.client;

// ── Court palette notifier ────────────────────────────────────────────────────
class CourtThemeNotifier extends ValueNotifier<CourtPalette> {
  CourtThemeNotifier() : super(CourtPalette.grass);

  static const _prefsKey = 'court_theme';

  static const _byName = {
    'clay': CourtPalette.clay,
    'hard': CourtPalette.hard,
    'grass': CourtPalette.grass,
  };

  // Loads the last-selected court theme, called once before runApp.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    super.value = _byName[saved] ?? CourtPalette.grass;
  }

  @override
  set value(CourtPalette newValue) {
    super.value = newValue;
    SharedPreferences.getInstance()
        .then((prefs) => prefs.setString(_prefsKey, newValue.theme.name));
  }
}

final courtThemeNotifier = CourtThemeNotifier();

class CourtThemeProvider extends StatelessWidget {
  final Widget child;
  const CourtThemeProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<CourtPalette>(
      valueListenable: courtThemeNotifier,
      builder: (_, palette, __) => _CourtThemeScope(palette: palette, child: child),
    );
  }

  static CourtPalette of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_CourtThemeScope>()!.palette;
}

class _CourtThemeScope extends InheritedWidget {
  final CourtPalette palette;
  const _CourtThemeScope({required this.palette, required super.child});

  @override
  bool updateShouldNotify(_CourtThemeScope old) => old.palette != palette;
}
// ─────────────────────────────────────────────────────────────────────────────

// Lightweight ValueNotifier-based theme provider
class ThemeModeNotifier extends ValueNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system);
}

final themeModeNotifier = ThemeModeNotifier();

class ThemeModeProvider extends StatelessWidget {
  final Widget child;
  const ThemeModeProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (_, mode, __) => _ThemeModeScope(mode: mode, child: child),
    );
  }
}

class _ThemeModeScope extends InheritedWidget {
  final ThemeMode mode;
  const _ThemeModeScope({required this.mode, required super.child});

  static _ThemeModeScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ThemeModeScope>()!;

  @override
  bool updateShouldNotify(_ThemeModeScope old) => old.mode != mode;
}

class RallyApp extends StatelessWidget {
  const RallyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = _ThemeModeScope.of(context).mode;

    return MaterialApp.router(
      title: 'RallyMatch',
      debugShowCheckedModeBanner: false,
      theme: RallyTheme.light,
      darkTheme: RallyTheme.dark,
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
