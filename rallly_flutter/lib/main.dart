import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'theme/app_theme.dart';
import 'screens/landing_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/main_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnon,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  runApp(const RalllyApp());
}

// Convenience accessor
final supabase = Supabase.instance.client;

class RalllyApp extends StatelessWidget {
  const RalllyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rallly',
      debugShowCheckedModeBanner: false,
      theme: RallyTheme.light,
      darkTheme: RallyTheme.dark,
      themeMode: ThemeMode.light,
      home: const _AppRouter(),
    );
  }
}

// ─── Auth router ─────────────────────────────────────────────────────────────
class _AppRouter extends StatefulWidget {
  const _AppRouter();

  @override
  State<_AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<_AppRouter> {
  _AppPage _page = _AppPage.landing;
  bool _isSignUp = true;
  String? _otpEmail;

  @override
  void initState() {
    super.initState();
    // If a valid session already exists, skip straight to home
    final session = supabase.auth.currentSession;
    if (session != null) _page = _AppPage.home;
  }

  @override
  Widget build(BuildContext context) {
    return switch (_page) {
      _AppPage.landing => LandingScreen(
          onGetStarted: () => setState(() {
            _isSignUp = true;
            _page = _AppPage.authEmail;
          }),
          onSignIn: () => setState(() {
            _isSignUp = false;
            _page = _AppPage.authEmail;
          }),
        ),

      _AppPage.authEmail => AuthEmailScreen(
          isSignUp: _isSignUp,
          onOtpSent: (email) => setState(() {
            _otpEmail = email;
            _page = _AppPage.authOtp;
          }),
          onBack: () => setState(() => _page = _AppPage.landing),
        ),

      _AppPage.authOtp => AuthOtpScreen(
          email: _otpEmail ?? '',
          isSignUp: _isSignUp,
          onVerified: () => setState(
              () => _page = _isSignUp ? _AppPage.signup : _AppPage.home),
          onBack: () => setState(() => _page = _AppPage.authEmail),
        ),

      _AppPage.signup => SignupScreen(
          onComplete: () => setState(() => _page = _AppPage.home),
        ),

      _AppPage.home => const MainShell(),
    };
  }
}

enum _AppPage { landing, authEmail, authOtp, signup, home }
