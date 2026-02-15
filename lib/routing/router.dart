import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:khdmti_project/views/authpage/forget_screen.dart';
import 'package:khdmti_project/views/nav/buttom_nav.dart';
import 'package:khdmti_project/views/home/home_screen.dart';
import 'package:khdmti_project/views/authpage/login_screen.dart';
import 'package:khdmti_project/views/authpage/sign_up_screen.dart';
import 'package:khdmti_project/views/splashscreenPage/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Auth state notifier for GoRouter
class AuthNotifier extends ChangeNotifier {
  late final StreamSubscription<AuthState> _subscription;
  AuthNotifier() {
    _subscription = Supabase.instance.client.auth.onAuthStateChange.listen(
      (AuthState data) {
        notifyListeners();
      },
      onError: (error) {
        if (kDebugMode) {
          print('Auth error: $error');
        }
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

// Helper function to check authentication status
bool _isAuthenticated() {
  final session = Supabase.instance.client.auth.currentSession;
  return session != null && session.user.emailConfirmedAt != null;
}

// GoRouter configuration
final router = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: kDebugMode,
  refreshListenable: AuthNotifier(),
  redirect: (context, state) {
    final isAuthenticated = _isAuthenticated();
    final path = state.matchedLocation;
    // Define route categories
    const splash = '/';
    const authRoutes = ['/loginScreen', '/SignUpScreen'];
    const protectedRoutes = ['/HomeScreen', '/ButtomNav'];
    // Splash screen - redirect if already authenticated
    if (path == splash) {
      if (isAuthenticated) {
        return '/ButtomNav';
      }
      return null; // Allow splash to show initially for non-auth users
    }

    // Protected routes - require authentication
    if (protectedRoutes.contains(path)) {
      if (!isAuthenticated) {
        return '/loginScreen';
      }
      return null;
    }

    // Auth routes - redirect to ButtomNav if already authenticated
    if (authRoutes.contains(path)) {
      if (isAuthenticated) {
        return '/ButtomNav';
      }
      return null;
    }

    // Default: allow access
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/loginScreen',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/SignUpScreen',
      name: 'signup',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/HomeScreen',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/ButtomNav',
      name: 'ButtomNav',
      builder: (context, state) => BottomNav(),
    ),
    GoRoute(
      path: '/forgetPassword',
      name: 'forgetPassword',
      builder: (context, state) => ForgetScreen(),
    ),
  ],
  errorBuilder: (context, state) {
    if (kDebugMode) {
      print('Navigation error: ${state.error}');
    }
    return const LoginScreen();
  },
  redirectLimit: 10,
);
