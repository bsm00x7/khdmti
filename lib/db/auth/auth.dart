import 'dart:async';
import 'package:flutter/material.dart';
import 'package:khdmti_project/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Enhanced Authentication Service with comprehensive features
class Auth extends ChangeNotifier {
  static final _supabase = Supabase.instance.client;

  // Auth state stream
  static Stream<AuthState> get authStateChanges =>
      _supabase.auth.onAuthStateChange;

  // Current user getter
  User? get currentUser => _supabase.auth.currentUser;
  static User? get user => _supabase.auth.currentUser;

  // Current session getter
  Session? get currentSession => _supabase.auth.currentSession;
  static Session? get session => _supabase.auth.currentSession;

  // Check if user is authenticated
  static bool get isAuthenticated => _supabase.auth.currentUser != null;

  // Check if email is verified
  static bool get isEmailVerified =>
      _supabase.auth.currentUser?.emailConfirmedAt != null;

  /// Create a new user account with enhanced error handling
  static Future<AuthResponse> createNewUser({
    required UserModel user,
    Map<String, dynamic>? additionalData,
    String? redirectTo,
  }) async {
    try {
      // Validate input
      _validateUserInput(user);

      // Prepare metadata
      final metadata = {
        'name': user.fullname,
        'created_at': DateTime.now().toIso8601String(),
        ...?additionalData,
      };

      // Create user with timeout
      final response = await _supabase.auth
          .signUp(
            email: user.email.trim().toLowerCase(),
            password: user.password,
            data: metadata,
            emailRedirectTo: redirectTo,
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () =>
                throw TimeoutException('Sign up request timed out'),
          );

      // Check if user was created
      if (response.user == null) {
        throw AuthException('Failed to create user account');
      }

      return response;
    } on AuthException {
      rethrow;
    } on TimeoutException {
      rethrow;
    } catch (e) {
      throw AuthException('Failed to create account: ${e.toString()}');
    }
  }

  /// Sign in user with email and password
  static Future<AuthResponse> loginUser({
    required UserModel user,
    bool rememberMe = true,
  }) async {
    try {
      // Validate input
      _validateLoginInput(user);

      // Sign in with timeout
      final response = await _supabase.auth
          .signInWithPassword(
            email: user.email.trim().toLowerCase(),
            password: user.password,
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw TimeoutException('Login request timed out'),
          );

      // Check if login was successful
      if (response.user == null || response.session == null) {
        throw AuthException('Login failed. Please check your credentials.');
      }

      return response;
    } on AuthException {
      rethrow;
    } on TimeoutException {
      rethrow;
    } catch (e) {
      throw AuthException('Login failed: ${e.toString()}');
    }
  }

  /// Sign out the current user
  static Future<void> signOut() async {
    try {
      await _supabase.auth.signOut().timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw TimeoutException('Sign out timed out'),
          );
    } on AuthException {
      rethrow;
    } on TimeoutException {
      rethrow;
    } catch (e) {
      throw AuthException('Sign out failed: ${e.toString()}');
    }
  }

  /// Send password reset email
  static Future<void> resetPassword({
    required String email,
    String? redirectTo,
  }) async {
    try {
      if (email.trim().isEmpty) {
        throw AuthException('Email is required');
      }

      if (!_isValidEmail(email)) {
        throw AuthException('Invalid email format');
      }

      await _supabase.auth
          .resetPasswordForEmail(
            email.trim().toLowerCase(),
            redirectTo: redirectTo,
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () =>
                throw TimeoutException('Password reset request timed out'),
          );
    } on AuthException {
      rethrow;
    } on TimeoutException {
      rethrow;
    } catch (e) {
      throw AuthException('Password reset failed: ${e.toString()}');
    }
  }

  /// Update password for authenticated user
  static Future<UserResponse> updatePassword({
    required String newPassword,
  }) async {
    try {
      if (!isAuthenticated) {
        throw AuthException('User must be authenticated to update password');
      }

      if (newPassword.isEmpty || newPassword.length < 6) {
        throw AuthException('Password must be at least 6 characters');
      }

      final response = await _supabase.auth
          .updateUser(
            UserAttributes(password: newPassword),
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () =>
                throw TimeoutException('Update password request timed out'),
          );

      if (response.user == null) {
        throw AuthException('Failed to update password');
      }

      return response;
    } on AuthException {
      rethrow;
    } on TimeoutException {
      rethrow;
    } catch (e) {
      throw AuthException('Password update failed: ${e.toString()}');
    }
  }

  /// Update user profile (name, metadata)
  static Future<UserResponse> updateProfile({
    String? fullname,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      if (!isAuthenticated) {
        throw AuthException('User must be authenticated to update profile');
      }

      final data = <String, dynamic>{};
      if (fullname != null && fullname.trim().isNotEmpty) {
        data['name'] = fullname.trim();
      }
      if (additionalData != null) {
        data.addAll(additionalData);
      }

      if (data.isEmpty) {
        throw AuthException('No data provided for update');
      }

      final response =
          await _supabase.auth.updateUser(UserAttributes(data: data)).timeout(
                const Duration(seconds: 15),
                onTimeout: () =>
                    throw TimeoutException('Update profile request timed out'),
              );

      if (response.user == null) {
        throw AuthException('Failed to update profile');
      }

      return response;
    } on AuthException {
      rethrow;
    } on TimeoutException {
      rethrow;
    } catch (e) {
      throw AuthException('Profile update failed: ${e.toString()}');
    }
  }

  /// Update user email
  static Future<UserResponse> updateEmail({
    required String newEmail,
    String? redirectTo,
  }) async {
    try {
      if (!isAuthenticated) {
        throw AuthException('User must be authenticated to update email');
      }

      if (!_isValidEmail(newEmail)) {
        throw AuthException('Invalid email format');
      }

      final response = await _supabase.auth
          .updateUser(
            UserAttributes(
              email: newEmail.trim().toLowerCase(),
            ),
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () =>
                throw TimeoutException('Update email request timed out'),
          );

      if (response.user == null) {
        throw AuthException('Failed to update email');
      }

      return response;
    } on AuthException {
      rethrow;
    } on TimeoutException {
      rethrow;
    } catch (e) {
      throw AuthException('Email update failed: ${e.toString()}');
    }
  }

  /// Resend email verification
  static Future<void> resendVerificationEmail({
    String? email,
  }) async {
    try {
      final emailToUse = email ?? _supabase.auth.currentUser?.email;

      if (emailToUse == null || emailToUse.isEmpty) {
        throw AuthException('Email is required');
      }

      await _supabase.auth
          .resend(
            type: OtpType.signup,
            email: emailToUse.trim().toLowerCase(),
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () =>
                throw TimeoutException('Resend verification timed out'),
          );
    } on AuthException {
      rethrow;
    } on TimeoutException {
      rethrow;
    } catch (e) {
      throw AuthException('Failed to resend verification: ${e.toString()}');
    }
  }

  /// Refresh the current session
  static Future<AuthResponse> refreshSession() async {
    try {
      if (!isAuthenticated) {
        throw AuthException('No active session to refresh');
      }

      final response = await _supabase.auth.refreshSession().timeout(
            const Duration(seconds: 15),
            onTimeout: () =>
                throw TimeoutException('Session refresh timed out'),
          );

      if (response.session == null) {
        throw AuthException('Failed to refresh session');
      }

      return response;
    } on AuthException {
      rethrow;
    } on TimeoutException {
      rethrow;
    } catch (e) {
      throw AuthException('Session refresh failed: ${e.toString()}');
    }
  }

  /// Get user metadata
  static Map<String, dynamic>? getUserMetadata() {
    return _supabase.auth.currentUser?.userMetadata;
  }

  /// Get user's display name
  static String? getUserDisplayName() {
    final metadata = getUserMetadata();
    return metadata?['name'] as String?;
  }

  /// Get user's email
  static String? getUserEmail() {
    return _supabase.auth.currentUser?.email;
  }

  /// Get user's ID
  static String? getUserId() {
    return _supabase.auth.currentUser?.id;
  }

  /// Check if session is expired
  static bool isSessionExpired() {
    final session = _supabase.auth.currentSession;
    if (session == null) return true;

    final expiresAt = session.expiresAt;
    if (expiresAt == null) return false;

    return DateTime.now().isAfter(
      DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000),
    );
  }

  /// Delete user account (requires reauthentication in production)
  static Future<void> deleteAccount() async {
    try {
      if (!isAuthenticated) {
        throw AuthException('User must be authenticated to delete account');
      }

      // Note: This requires admin privileges in Supabase
      // In production, you should call a secure API endpoint
      throw AuthException(
        'Account deletion must be done through support or a secure backend endpoint',
      );
    } catch (e) {
      throw AuthException('Account deletion failed: ${e.toString()}');
    }
  }

  /// Sign in with Magic Link (passwordless)
  static Future<void> signInWithMagicLink({
    required String email,
    String? redirectTo,
  }) async {
    try {
      if (!_isValidEmail(email)) {
        throw AuthException('Invalid email format');
      }

      await _supabase.auth
          .signInWithOtp(
            email: email.trim().toLowerCase(),
            emailRedirectTo: redirectTo,
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () =>
                throw TimeoutException('Magic link request timed out'),
          );
    } on AuthException {
      rethrow;
    } on TimeoutException {
      rethrow;
    } catch (e) {
      throw AuthException('Magic link failed: ${e.toString()}');
    }
  }

  /// Verify OTP (for magic link or phone auth)
  static Future<AuthResponse> verifyOTP({
    required String email,
    required String token,
    required OtpType type,
  }) async {
    try {
      final response = await _supabase.auth
          .verifyOTP(
            email: email.trim().toLowerCase(),
            token: token,
            type: type,
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () =>
                throw TimeoutException('OTP verification timed out'),
          );

      if (response.user == null || response.session == null) {
        throw AuthException('OTP verification failed');
      }

      return response;
    } on AuthException {
      rethrow;
    } on TimeoutException {
      rethrow;
    } catch (e) {
      throw AuthException('OTP verification failed: ${e.toString()}');
    }
  }

  // ============ Private Helper Methods ============

  /// Validate user input for sign up
  static void _validateUserInput(UserModel user) {
    if (user.email.trim().isEmpty) {
      throw AuthException('Email is required');
    }

    if (!_isValidEmail(user.email)) {
      throw AuthException('Invalid email format');
    }

    if (user.password.isEmpty) {
      throw AuthException('Password is required');
    }

    if (user.password.length < 6) {
      throw AuthException('Password must be at least 6 characters');
    }

    if (user.password.length > 72) {
      throw AuthException('Password must be less than 72 characters');
    }

    if (user.fullname!.trim().isEmpty) {
      throw AuthException('Full name is required');
    }

    if (user.fullname!.trim().length < 2) {
      throw AuthException('Full name must be at least 2 characters');
    }
  }

  /// Validate login input
  static void _validateLoginInput(UserModel user) {
    if (user.email.trim().isEmpty) {
      throw AuthException('Email is required');
    }

    if (!_isValidEmail(user.email)) {
      throw AuthException('Invalid email format');
    }

    if (user.password.isEmpty) {
      throw AuthException('Password is required');
    }
  }

  /// Validate email format
  static bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email.trim());
  }

  /// Get authentication error message
  static String getAuthErrorMessage(dynamic error) {
    if (error is AuthException) {
      return error.message;
    } else if (error is TimeoutException) {
      return 'Request timed out. Please check your connection and try again.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }
}

/// Extension for easy auth state checking
extension AuthStateExtension on User {
  bool get isEmailVerified => emailConfirmedAt != null;

  String get displayName => userMetadata?['name'] as String? ?? email ?? 'User';
}

/// Auth Event Listener Helper
class AuthStateListener {
  StreamSubscription<AuthState>? _subscription;

  /// Start listening to auth state changes
  void listen({
    required Function(User? user) onAuthStateChanged,
    Function(AuthChangeEvent event)? onSpecificEvent,
  }) {
    _subscription = Auth.authStateChanges.listen((data) {
      onAuthStateChanged(data.session?.user);
      onSpecificEvent?.call(data.event);
    });
  }

  /// Stop listening
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
