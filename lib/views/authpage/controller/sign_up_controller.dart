// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:khdmti_project/db/auth/auth.dart';
import 'package:khdmti_project/db/database/db.dart';
import 'package:khdmti_project/model/user_model.dart';
import 'package:khdmti_project/utils/widgets/custom_error_widget.dart';
import 'package:khdmti_project/utils/widgets/looding_indicator.dart';
import 'package:khdmti_project/utils/widgets/success.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpController extends ChangeNotifier {
  final formKeySignUp = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // State Management
  bool _isLoading = false;
  bool _isResendingEmail = false;
  bool _isPasswordVisible = false;
  String? _lastRegisteredEmail;
  DateTime? _lastResendTime;
  int _resendAttempts = 0;

  // Rate Limit Protection
  DateTime? _lastSignupAttempt;
  int _signupAttempts = 0;
  static const int _maxSignupAttempts = 3;
  static const int _signupCooldownSeconds = 60;

  // Password Strength
  PasswordStrength _passwordStrength = PasswordStrength.weak;

  // Getters
  bool get isLoading => _isLoading;
  bool get isResendingEmail => _isResendingEmail;
  bool get isPasswordVisible => _isPasswordVisible;
  PasswordStrength get passwordStrength => _passwordStrength;

  bool get canResendEmail {
    if (_lastResendTime == null) return true;
    final difference = DateTime.now().difference(_lastResendTime!);
    return difference.inSeconds >= 60;
  }

  int get remainingResendSeconds {
    if (_lastResendTime == null) return 0;
    final difference = DateTime.now().difference(_lastResendTime!);
    final remaining = 60 - difference.inSeconds;
    return remaining > 0 ? remaining : 0;
  }

  // Rate limit check
  bool get canAttemptSignup {
    if (_lastSignupAttempt == null) return true;
    final difference = DateTime.now().difference(_lastSignupAttempt!);

    // Reset counter after cooldown period
    if (difference.inSeconds >= _signupCooldownSeconds) {
      _signupAttempts = 0;
      return true;
    }

    return _signupAttempts < _maxSignupAttempts;
  }

  int get remainingSignupCooldown {
    if (_lastSignupAttempt == null) return 0;
    final difference = DateTime.now().difference(_lastSignupAttempt!);
    final remaining = _signupCooldownSeconds - difference.inSeconds;
    return remaining > 0 ? remaining : 0;
  }

  // Password visibility toggle
  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  // Password strength calculator
  void updatePasswordStrength(String password) {
    if (password.isEmpty) {
      _passwordStrength = PasswordStrength.weak;
    } else if (password.length < 6) {
      _passwordStrength = PasswordStrength.weak;
    } else if (password.length < 8) {
      _passwordStrength = PasswordStrength.medium;
    } else {
      bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
      bool hasLowercase = password.contains(RegExp(r'[a-z]'));
      bool hasDigits = password.contains(RegExp(r'[0-9]'));
      bool hasSpecialCharacters =
          password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

      int complexityScore = 0;
      if (hasUppercase) complexityScore++;
      if (hasLowercase) complexityScore++;
      if (hasDigits) complexityScore++;
      if (hasSpecialCharacters) complexityScore++;

      if (password.length >= 12 && complexityScore >= 3) {
        _passwordStrength = PasswordStrength.strong;
      } else if (password.length >= 8 && complexityScore >= 2) {
        _passwordStrength = PasswordStrength.medium;
      } else {
        _passwordStrength = PasswordStrength.weak;
      }
    }
    notifyListeners();
  }

  // Validation helpers
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.trim().length > 50) {
      return 'Name must be less than 50 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (value.length > 72) {
      return 'Password must be less than 72 characters';
    }
    return null;
  }

  // Main signup method with rate limit protection
  Future<void> onPressed({required BuildContext context}) async {
    // Prevent multiple submissions
    if (_isLoading) {
      debugPrint('SignUp: Already loading, ignoring duplicate submission');
      return;
    }

    // Check rate limit
    if (!canAttemptSignup) {
      _showRateLimitError(context);
      return;
    }

    // Validate form
    if (!(formKeySignUp.currentState?.validate() ?? false)) {
      debugPrint('SignUp: Form validation failed');
      _showValidationError(context);
      return;
    }

    // Track signup attempt
    _lastSignupAttempt = DateTime.now();
    _signupAttempts++;
    debugPrint('SignUp: Attempt $_signupAttempts of $_maxSignupAttempts');

    // Start loading
    _setLoading(true);

    try {
      if (context.mounted) {
        LoadingIndicator.setLoading(context, true);
      }

      // Prepare user data
      final userData = UserModel(
        fullname: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      debugPrint(
          'SignUp: Attempting to create user for email: ${userData.email}');

      // Create user with timeout
      final AuthResponse response =
          await Auth.createNewUser(user: userData).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('SignUp: Request timed out');
          throw TimeoutException('Request timed out after 30 seconds');
        },
      );
      await DataBase().insertToDataBase(response);

      debugPrint('SignUp: User created successfully');
      debugPrint('SignUp: Session exists: ${response.session != null}');
      debugPrint('SignUp: User exists: ${response.user != null}');
      debugPrint('SignUp: Email confirmed: ${response.user?.emailConfirmedAt}');

      // SUCCESS - Reset rate limit counter
      _signupAttempts = 0;

      if (!context.mounted) {
        debugPrint('SignUp: Context no longer mounted, aborting');
        return;
      }

      LoadingIndicator.setLoading(context, false);
      _lastRegisteredEmail = emailController.text.trim();

      await _handleSignUpResponse(context, response);
    } on AuthException catch (e) {
      debugPrint(
          'SignUp: AuthException - Code: ${e.statusCode}, Message: ${e.message}');

      // Don't count rate limit errors against the user
      if (e.statusCode == '429') {
        _signupAttempts = _maxSignupAttempts; // Force cooldown
      }

      await _handleError(context, () => _handleAuthException(context, e));
    } on SocketException catch (e) {
      debugPrint('SignUp: SocketException - $e');
      await _handleError(context, () => _showNetworkError(context));
    } on TimeoutException catch (e) {
      debugPrint('SignUp: TimeoutException - $e');
      await _handleError(context, () => _showTimeoutError(context));
    } on FormatException catch (e) {
      debugPrint('SignUp: FormatException - $e');
      await _handleError(
        context,
        () => CustomErrorWidgetNew.showError(
          context,
          'Invalid data format. Please contact support.',
        ),
      );
    } on PostgrestException catch (e) {
      debugPrint('SignUp: PostgrestException - ${e.message}');
      await _handleError(
        context,
        () => CustomErrorWidgetNew.showError(
          context,
          'Database error: ${e.message}',
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('SignUp: Unexpected error - $e');
      debugPrint('SignUp: Stack trace - $stackTrace');
      await _handleError(context, () => _showGenericError(context, e));
    } finally {
      _setLoading(false);
      if (context.mounted) {
        try {
          LoadingIndicator.setLoading(context, false);
        } catch (e) {
          debugPrint('SignUp: Error stopping loading indicator - $e');
        }
      }
    }
  }

  // Show rate limit error
  void _showRateLimitError(BuildContext context) {
    if (context.mounted) {
      CustomErrorWidgetNew.showError(
        context,
        'Too many signup attempts. Please wait $remainingSignupCooldown seconds before trying again.',
      );
    }
  }

  // Handle signup response
  Future<void> _handleSignUpResponse(
    BuildContext context,
    AuthResponse response,
  ) async {
    try {
      if (response.user == null) {
        debugPrint('SignUp: No user in response');
        if (context.mounted) {
          CustomErrorWidgetNew.showError(
            context,
            'Account creation failed. Please try again.',
          );
        }
        return;
      }

      final isEmailConfirmed = response.user!.emailConfirmedAt != null;
      debugPrint('SignUp: Email confirmed: $isEmailConfirmed');

      if (!isEmailConfirmed) {
        if (context.mounted) {
          await _showEmailVerificationSheet(context);
        }
      } else {
        if (context.mounted) {
          CustomSuccessWidget.showSuccess(
            context,
            'Account created successfully! Welcome aboard 🎉',
          );
          clearControllers();
        }
      }
    } catch (e) {
      debugPrint('SignUp: Error handling response - $e');
      if (context.mounted) {
        CustomErrorWidgetNew.showError(
          context,
          'An error occurred. Please try signing in.',
        );
      }
    }
  }

  // Error handling wrapper
  Future<void> _handleError(
    BuildContext context,
    VoidCallback errorHandler,
  ) async {
    try {
      if (context.mounted) {
        try {
          LoadingIndicator.setLoading(context, false);
        } catch (e) {
          debugPrint('SignUp: Error stopping loading in error handler - $e');
        }
        errorHandler();
      }
    } catch (e) {
      debugPrint('SignUp: Error in error handler - $e');
    }
  }

  // Loading state setter
  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  // Validation error
  void _showValidationError(BuildContext context) {
    if (context.mounted) {
      CustomErrorWidgetNew.showError(
        context,
        'Please fill in all required fields correctly',
      );
    }
  }

  // Network error
  void _showNetworkError(BuildContext context) {
    if (context.mounted) {
      CustomErrorWidgetNew.showError(
        context,
        'No internet connection. Please check your network and try again.',
      );
    }
  }

  // Timeout error
  void _showTimeoutError(BuildContext context) {
    if (context.mounted) {
      CustomErrorWidgetNew.showError(
        context,
        'Connection timeout. The server took too long to respond. Please try again.',
      );
    }
  }

  // Generic error
  void _showGenericError(BuildContext context, dynamic error) {
    if (context.mounted) {
      CustomErrorWidgetNew.showError(
        context,
        'An unexpected error occurred. Please try again later.',
      );
    }
    debugPrint('SignUp Error: $error');
  }

  // Enhanced auth exception handler
  void _handleAuthException(BuildContext context, AuthException e) {
    final errorMessage = _getAuthErrorMessage(e);
    if (context.mounted) {
      CustomErrorWidgetNew.showError(context, errorMessage);
    }
  }

  // Get auth error message with special handling for 429
  String _getAuthErrorMessage(AuthException e) {
    debugPrint('Auth Error: Status=${e.statusCode}, Message=${e.message}');

    switch (e.statusCode) {
      case '400':
        return _handle400Error(e);
      case '409':
        return 'This email is already registered. Please sign in instead or use a different email.';
      case '422':
        return _handle422Error(e);
      case '429':
        // Special handling for rate limit
        return 'Too many signup attempts detected. Please wait a few minutes and try again.';
      case '500':
        return 'Server error. Our team has been notified. Please try again later.';
      case '502':
      case '503':
      case '504':
        return 'Server error. Our team has been notified. Please try again later.';
      default:
        return _handleMessageBasedError(e);
    }
  }

  String _handle400Error(AuthException e) {
    final message = e.message.toLowerCase();
    if (message.contains('email')) {
      return 'Invalid email address. Please check and try again.';
    } else if (message.contains('password')) {
      return 'Password does not meet requirements. Must be at least 6 characters.';
    } else {
      return 'Invalid input. Please check your details and try again.';
    }
  }

  String _handle422Error(AuthException e) {
    final message = e.message.toLowerCase();
    if (message.contains('email')) {
      return 'Invalid email format. Please enter a valid email address.';
    } else if (message.contains('password')) {
      return 'Password must be at least 6 characters long.';
    } else {
      return e.message.isNotEmpty
          ? e.message
          : 'Validation error. Please check your input.';
    }
  }

  String _handleMessageBasedError(AuthException e) {
    final message = e.message.toLowerCase();

    if (message.contains('user already registered') ||
        message.contains('already exists')) {
      return 'This email is already registered. Please sign in instead.';
    } else if (message.contains('invalid email')) {
      return 'Please enter a valid email address.';
    } else if (message.contains('weak password') ||
        message.contains('password is too weak')) {
      return 'Password is too weak. Please use a stronger password with at least 6 characters.';
    } else if (message.contains('network') || message.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    } else if (message.contains('timeout')) {
      return 'Connection timeout. Please try again.';
    } else if (message.contains('rate limit') || message.contains('too many')) {
      return 'Too many attempts. Please wait a few minutes and try again.';
    } else if (message.contains('invalid credentials')) {
      return 'Invalid information provided. Please check your details.';
    } else {
      return e.message.isNotEmpty
          ? e.message
          : 'An error occurred during sign up. Please try again.';
    }
  }

  // Enhanced email verification sheet
  Future<void> _showEmailVerificationSheet(BuildContext context) async {
    if (!context.mounted) return;

    await showModalBottomSheet(
      context: context,
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (builderContext, setState) {
            return Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(builderContext).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: .1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.mark_email_read_outlined,
                        size: 48,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Verify Your Email',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'We\'ve sent a verification link to:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: .05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _lastRegisteredEmail ?? emailController.text.trim(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Please check your inbox and click the verification link to activate your account.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.orange.withValues(alpha: .3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 20,
                            color: Colors.orange[700],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Check your spam folder if you don\'t see the email',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(builderContext);
                          clearControllers();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Got it',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: canResendEmail && !_isResendingEmail
                            ? () async {
                                await _resendVerificationEmail(builderContext);
                                if (builderContext.mounted) {
                                  setState(() {});
                                }
                              }
                            : null,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: _isResendingEmail
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                canResendEmail
                                    ? 'Resend verification email'
                                    : 'Resend in ${remainingResendSeconds}s',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: canResendEmail
                                      ? Colors.blue
                                      : Colors.grey,
                                ),
                              ),
                      ),
                    ),
                    if (_resendAttempts > 0) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Resent: $_resendAttempts time(s)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Resend verification email
  Future<void> _resendVerificationEmail(BuildContext context) async {
    if (!canResendEmail || _isResendingEmail) {
      debugPrint('Resend: Cannot resend - cooldown active or already sending');
      return;
    }

    if (_resendAttempts >= 5) {
      if (context.mounted) {
        CustomErrorWidgetNew.showError(
          context,
          'Maximum resend attempts reached. Please contact support if you need help.',
        );
      }
      return;
    }

    _isResendingEmail = true;
    notifyListeners();

    try {
      final emailToResend = _lastRegisteredEmail ?? emailController.text.trim();
      debugPrint('Resend: Attempting to resend to: $emailToResend');

      await Supabase.instance.client.auth
          .resend(
        type: OtpType.signup,
        email: emailToResend,
      )
          .timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          debugPrint('Resend: Timeout');
          throw TimeoutException('Resend request timed out');
        },
      );

      _lastResendTime = DateTime.now();
      _resendAttempts++;
      debugPrint('Resend: Success - attempt $_resendAttempts');

      if (context.mounted) {
        CustomSuccessWidget.showSuccess(
          context,
          'Verification email resent successfully! ✉️',
        );
      }
    } on AuthException catch (e) {
      debugPrint('Resend: AuthException - ${e.statusCode}: ${e.message}');
      if (context.mounted) {
        CustomErrorWidgetNew.showError(
          context,
          _getResendErrorMessage(e),
        );
      }
    } on TimeoutException catch (e) {
      debugPrint('Resend: TimeoutException - $e');
      if (context.mounted) {
        CustomErrorWidgetNew.showError(
          context,
          'Request timed out. Please try again.',
        );
      }
    } catch (e) {
      debugPrint('Resend: Unexpected error - $e');
      if (context.mounted) {
        CustomErrorWidgetNew.showError(
          context,
          'Failed to resend email. Please try again.',
        );
      }
    } finally {
      _isResendingEmail = false;
      notifyListeners();
    }
  }

  String _getResendErrorMessage(AuthException e) {
    if (e.statusCode == '429') {
      return 'Too many requests. Please wait a moment before trying again.';
    } else if (e.message.toLowerCase().contains('rate limit')) {
      return 'Rate limit exceeded. Please wait before resending.';
    } else {
      return 'Failed to resend email. Please try again.';
    }
  }

  void clearControllers() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    _passwordStrength = PasswordStrength.weak;
    _isPasswordVisible = false;
    notifyListeners();
  }

  void resetResendState() {
    _lastResendTime = null;
    _resendAttempts = 0;
    notifyListeners();
  }

  // Reset rate limit (call this manually if needed)
  void resetRateLimit() {
    _signupAttempts = 0;
    _lastSignupAttempt = null;
    notifyListeners();
    debugPrint('SignUp: Rate limit reset');
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

enum PasswordStrength {
  weak,
  medium,
  strong;

  String get label {
    switch (this) {
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.medium:
        return 'Medium';
      case PasswordStrength.strong:
        return 'Strong';
    }
  }

  Color get color {
    switch (this) {
      case PasswordStrength.weak:
        return Colors.red;
      case PasswordStrength.medium:
        return Colors.orange;
      case PasswordStrength.strong:
        return Colors.green;
    }
  }

  double get progress {
    switch (this) {
      case PasswordStrength.weak:
        return 0.33;
      case PasswordStrength.medium:
        return 0.66;
      case PasswordStrength.strong:
        return 1.0;
    }
  }
}
