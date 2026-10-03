import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart' show supabase;
import '../screens/landing_screen.dart';
import '../screens/auth_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/main_shell.dart';
import '../screens/notifications_screen.dart';
import '../screens/player_profile_screen.dart';
import '../screens/messages_screen.dart';
import '../models/models.dart';
import '../services/analytics_service.dart';
import '../services/data_service.dart';
import '../theme/app_theme.dart';

// ── Auth refresh listenable ───────────────────────────────────────────────────

class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream() {
    _sub = supabase.auth.onAuthStateChange.listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

// ── Route paths ───────────────────────────────────────────────────────────────

class AppRoutes {
  static const landing = '/';
  static const authEmail = '/auth/email';
  static const authOtp = '/auth/otp';
  static const signup = '/signup';
  static const home = '/home';
  static const notifications = '/home/notifications';
  static const player = '/home/player';
  static const conversation = '/home/conversation';
}

// ── Router ────────────────────────────────────────────────────────────────────

final _refreshListenable = _GoRouterRefreshStream();

final appRouter = GoRouter(
  initialLocation: AppRoutes.landing,
  refreshListenable: _refreshListenable,
  observers: [analyticsService.observer],
  redirect: (context, state) {
    final isLoggedIn = supabase.auth.currentSession != null;
    // Signup is post-auth onboarding (only reached after OTP verification),
    // not a pre-auth route — it must not be in the "bounce logged-in users
    // away" set below, or the auth-state redirect fires before the signup
    // wizard ever renders and skips profile setup entirely.
    final onPreAuth = state.matchedLocation == AppRoutes.landing ||
        state.matchedLocation.startsWith('/auth');
    final onPublic = onPreAuth || state.matchedLocation == AppRoutes.signup;

    if (isLoggedIn && onPreAuth) return AppRoutes.home;
    if (!isLoggedIn && !onPublic) return AppRoutes.landing;
    return null;
  },
  routes: [
    // ── Public routes ────────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.landing,
      builder: (context, state) => LandingScreen(
        onGetStarted: () => context.go(
          AppRoutes.authEmail,
          extra: {'isSignUp': true},
        ),
        onSignIn: () => context.go(
          AppRoutes.authEmail,
          extra: {'isSignUp': false},
        ),
      ),
    ),

    GoRoute(
      path: AppRoutes.authEmail,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final isSignUp = extra['isSignUp'] as bool? ?? true;
        return AuthEmailScreen(
          isSignUp: isSignUp,
          onOtpSent: (email) => context.go(
            AppRoutes.authOtp,
            extra: {'email': email, 'isSignUp': isSignUp},
          ),
          onBack: () => context.go(AppRoutes.landing),
        );
      },
    ),

    GoRoute(
      path: AppRoutes.authOtp,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final email = extra['email'] as String? ?? '';
        final isSignUp = extra['isSignUp'] as bool? ?? true;
        return AuthOtpScreen(
          email: email,
          isSignUp: isSignUp,
          // /home decides: _ProfileGate sends users without a saved profile
          // to the wizard, so "Başla" on an existing account can't re-run it
          // (and overwrite the profile).
          onVerified: () => context.go(AppRoutes.home),
          onBack: () => context.go(
            AppRoutes.authEmail,
            extra: {'isSignUp': isSignUp},
          ),
        );
      },
    ),

    GoRoute(
      path: AppRoutes.signup,
      builder: (context, state) => SignupScreen(
        onComplete: () => context.go(AppRoutes.home),
      ),
    ),

    // ── Authenticated routes ─────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const _ProfileGate(child: MainShell()),
    ),

    GoRoute(
      path: AppRoutes.notifications,
      builder: (context, state) => const NotificationsScreen(),
    ),

    GoRoute(
      path: AppRoutes.player,
      builder: (context, state) {
        final player = state.extra as Player;
        return PlayerProfileScreen(player: player);
      },
    ),

    GoRoute(
      path: AppRoutes.conversation,
      builder: (context, state) {
        final conversation = state.extra as Conversation;
        return ConversationScreen(conversation: conversation);
      },
    ),
  ],
);

// ── Profile gate ──────────────────────────────────────────────────────────────

/// Sends a signed-in user whose profile was never saved (signup abandoned or
/// its save failed) back to the signup wizard instead of into an app that has
/// no profile to show. Works for every entry — fresh OTP login, "sign in" on
/// an unfinished account, or a restored session on app start.
class _ProfileGate extends StatefulWidget {
  final Widget child;
  const _ProfileGate({required this.child});

  @override
  State<_ProfileGate> createState() => _ProfileGateState();
}

class _ProfileGateState extends State<_ProfileGate> {
  late final Future<bool> _complete = _check();

  Future<bool> _check() async {
    try {
      return await dataService.hasCompletedProfile();
    } catch (e) {
      // Offline or a transient error must not lock anyone out of the app.
      debugPrint('PROFILE CHECK ERROR: $e');
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _complete,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: RallyColors.bg,
            body: Center(
                child: CircularProgressIndicator(color: RallyColors.accent)),
          );
        }
        if (snap.data == false) {
          // Can't navigate during build; hop to the next frame.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) context.go(AppRoutes.signup);
          });
          return const Scaffold(backgroundColor: RallyColors.bg);
        }
        return widget.child;
      },
    );
  }
}
