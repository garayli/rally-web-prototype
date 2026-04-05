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
  redirect: (context, state) {
    final isLoggedIn = supabase.auth.currentSession != null;
    final onPublic = state.matchedLocation == AppRoutes.landing ||
        state.matchedLocation.startsWith('/auth') ||
        state.matchedLocation == AppRoutes.signup;

    if (isLoggedIn && onPublic) return AppRoutes.home;
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
          onVerified: () =>
              context.go(isSignUp ? AppRoutes.signup : AppRoutes.home),
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
      builder: (context, state) => const MainShell(),
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
