import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:khdmti_project/views/home/screen/notification_screen.dart';
import 'package:khdmti_project/views/nav/buttom_nav.dart';
import 'package:khdmti_project/views/home/home_screen.dart';
import 'package:khdmti_project/views/authpage/login_screen.dart';
import 'package:khdmti_project/views/authpage/sign_up_screen.dart';
import 'package:khdmti_project/views/profile/profile_screen.dart';
import 'package:khdmti_project/views/splashscreenPage/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── Auth State Notifier ───────────────────────────────────────────────────────
class AuthNotifier extends ChangeNotifier {
  late final StreamSubscription<AuthState> _subscription;

  AuthNotifier() {
    _subscription = Supabase.instance.client.auth.onAuthStateChange.listen(
      (AuthState data) => notifyListeners(),
      onError: (error) {
        if (kDebugMode) print('Auth error: $error');
      },
      cancelOnError: false,
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// ── Auth Check ────────────────────────────────────────────────────────────────
bool _isAuthenticated() {
  final session = Supabase.instance.client.auth.currentSession;
  if (session == null) return false;
  final expiresAt = session.expiresAt;
  if (expiresAt == null) return true;
  return DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000)
      .isAfter(DateTime.now());
}

// ── Route Constants ───────────────────────────────────────────────────────────
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/loginScreen';
  static const String signUp = '/SignUpScreen';
  static const String home = '/HomeScreen';
  static const String bottomNav = '/ButtomNav';
  static const String profile = '/profileScreen';
  static const String notifications = '/notificationScreen';

  static const List<String> _authRoutes = [login, signUp];

  static const List<String> _protectedRoutes = [
    home,
    bottomNav,
    profile,
    notifications, // ✅ protected — requires login
  ];

  static bool isAuthRoute(String path) => _authRoutes.contains(path);
  static bool isProtectedRoute(String path) => _protectedRoutes.contains(path);
}

// ── Router ────────────────────────────────────────────────────────────────────
final router = GoRouter(
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: kDebugMode,
  refreshListenable: AuthNotifier(),
  redirectLimit: 10,
  redirect: (context, state) {
    final isAuthenticated = _isAuthenticated();
    final path = state.matchedLocation;

    // Splash — always accessible
    if (path == AppRoutes.splash) return null;

    // Protected routes — must be logged in
    if (AppRoutes.isProtectedRoute(path)) {
      return isAuthenticated ? null : AppRoutes.login;
    }

    // Auth routes — redirect away if already logged in
    if (AppRoutes.isAuthRoute(path)) {
      return isAuthenticated ? AppRoutes.bottomNav : null;
    }

    return null;
  },
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.signUp,
      name: 'signup',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.bottomNav,
      name: 'bottomNav',
      builder: (context, state) => const BottomNav(),
    ),
    GoRoute(
      path: AppRoutes.profile,
      name: 'profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.notifications,
      name: 'notifications',
      builder: (context, state) => const NotificationScreen(),
    ),
  ],
  errorBuilder: (context, state) {
    if (kDebugMode) print('Navigation error: ${state.error}');
    return const LoginScreen();
  },
);
