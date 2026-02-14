import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:khdmti_project/db/auth/auth.dart';
import 'package:khdmti_project/model/user_model.dart';
import 'package:khdmti_project/utils/widgets/custom_error_widget.dart';
import 'package:khdmti_project/utils/widgets/looding_indicator.dart';
import 'package:khdmti_project/utils/widgets/success.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginController extends ChangeNotifier {
  final formKeyLogin = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _obscurePassword = true;
  bool get obscurePassword => _obscurePassword;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> onLoginPressed({required BuildContext context}) async {
    // Prevent multiple submissions
    if (_isLoading) return;

    if (formKeyLogin.currentState?.validate() ?? false) {
      _setLoading(true);
      LoadingIndicator.setLoading(context);

      try {
        final AuthResponse response = await Auth.loginUser(
                user: UserModel(
                    email: emailController.text.trim(),
                    password: passwordController.text))
            .timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw TimeoutException('Request timed out');
          },
        );

        if (!context.mounted) return;
        LoadingIndicator.setLoading(context, false);
        _setLoading(false);

        // Check if email is verified
        if (response.session?.user.emailConfirmedAt == null) {
          _showEmailNotVerifiedSheet(context);
        } else {
          // Successful login
          CustomSuccessWidget.showSuccess(
            context,
            'Welcome back!',
          );
          clearControllers();

          // Navigate to home screen
          if (context.mounted) {
            context.go('/HomeScreen');
          }
        }
      } on AuthException catch (e) {
        if (!context.mounted) return;
        LoadingIndicator.setLoading(context, false);
        _setLoading(false);
        _handleAuthException(context, e);
      } on SocketException catch (_) {
        if (!context.mounted) return;
        LoadingIndicator.setLoading(context, false);
        _setLoading(false);
        CustomErrorWidgetNew.showError(
          context,
          'No internet connection. Please check your network and try again.',
        );
      } on TimeoutException catch (_) {
        if (!context.mounted) return;
        LoadingIndicator.setLoading(context, false);
        _setLoading(false);
        CustomErrorWidgetNew.showError(
          context,
          'Connection timeout. Please try again.',
        );
      } on FormatException catch (_) {
        if (!context.mounted) return;
        LoadingIndicator.setLoading(context, false);
        _setLoading(false);
        CustomErrorWidgetNew.showError(
          context,
          'Invalid data format. Please contact support.',
        );
      } on PostgrestException catch (e) {
        if (!context.mounted) return;
        LoadingIndicator.setLoading(context, false);
        _setLoading(false);
        CustomErrorWidgetNew.showError(
          context,
          'Database error: ${e.message}',
        );
      } catch (e) {
        if (!context.mounted) return;
        LoadingIndicator.setLoading(context, false);
        _setLoading(false);
        CustomErrorWidgetNew.showError(
          context,
          'An unexpected error occurred. Please try again.',
        );
      }
    }
  }

  Future<void> onForgotPasswordPressed({required BuildContext context}) async {
    if (emailController.text.trim().isEmpty) {
      CustomErrorWidgetNew.showError(
        context,
        'Please enter your email address first',
      );
      return;
    }

    // Validate email format
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(emailController.text.trim())) {
      CustomErrorWidgetNew.showError(
        context,
        'Please enter a valid email address',
      );
      return;
    }

    LoadingIndicator.setLoading(context);

    try {
      await Supabase.instance.client.auth
          .resetPasswordForEmail(
        emailController.text.trim(),
      )
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Request timed out');
        },
      );

      if (!context.mounted) return;
      LoadingIndicator.setLoading(context, false);

      CustomSuccessWidget.showSuccess(
        context,
        'Password reset link sent to your email!',
      );
    } on AuthException catch (e) {
      if (!context.mounted) return;
      LoadingIndicator.setLoading(context, false);
      _handleAuthException(context, e);
    } on SocketException catch (_) {
      if (!context.mounted) return;
      LoadingIndicator.setLoading(context, false);
      CustomErrorWidgetNew.showError(
        context,
        'No internet connection. Please check your network and try again.',
      );
    } on TimeoutException catch (_) {
      if (!context.mounted) return;
      LoadingIndicator.setLoading(context, false);
      CustomErrorWidgetNew.showError(
        context,
        'Connection timeout. Please try again.',
      );
    } catch (e) {
      if (!context.mounted) return;
      LoadingIndicator.setLoading(context, false);
      CustomErrorWidgetNew.showError(
        context,
        'Failed to send reset email. Please try again.',
      );
    }
  }

  void _showEmailNotVerifiedSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Icon(
                Icons.warning_amber_rounded,
                size: 64,
                color: Colors.orange,
              ),
              const SizedBox(height: 24),
              const Text(
                'Email Not Verified',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Please verify your email address to continue.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                emailController.text.trim(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _resendVerificationEmail(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Resend Verification Email'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _resendVerificationEmail(BuildContext context) async {
    LoadingIndicator.setLoading(context);

    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: emailController.text.trim(),
      );

      if (!context.mounted) return;
      LoadingIndicator.setLoading(context, false);

      CustomSuccessWidget.showSuccess(
        context,
        'Verification email sent! Please check your inbox.',
      );
    } on AuthException catch (e) {
      if (!context.mounted) return;
      LoadingIndicator.setLoading(context, false);
      _handleAuthException(context, e);
    } catch (e) {
      if (!context.mounted) return;
      LoadingIndicator.setLoading(context, false);
      CustomErrorWidgetNew.showError(
        context,
        'Failed to resend verification email. Please try again.',
      );
    }
  }

  void _handleAuthException(BuildContext context, AuthException e) {
    String errorMessage;

    // Handle specific auth error codes
    switch (e.statusCode) {
      case '400':
        if (e.message.toLowerCase().contains('invalid login credentials') ||
            e.message.toLowerCase().contains('invalid email or password')) {
          errorMessage = 'Invalid email or password';
        } else if (e.message.toLowerCase().contains('email')) {
          errorMessage = 'Invalid email address';
        } else if (e.message.toLowerCase().contains('password')) {
          errorMessage = 'Invalid password';
        } else {
          errorMessage = 'Invalid credentials. Please try again.';
        }
        break;
      case '401':
        errorMessage = 'Invalid email or password';
        break;
      case '422':
        if (e.message.toLowerCase().contains('email')) {
          errorMessage = 'Invalid email format';
        } else {
          errorMessage = e.message;
        }
        break;
      case '429':
        errorMessage = 'Too many login attempts. Please try again later.';
        break;
      case '500':
        errorMessage = 'Server error. Please try again later.';
        break;
      case '503':
        errorMessage =
            'Service temporarily unavailable. Please try again later.';
        break;
      default:
        // Check for common error messages
        if (e.message.toLowerCase().contains('invalid login credentials')) {
          errorMessage = 'Invalid email or password';
        } else if (e.message.toLowerCase().contains('email not confirmed')) {
          errorMessage = 'Please verify your email first';
        } else if (e.message.toLowerCase().contains('user not found')) {
          errorMessage = 'No account found with this email';
        } else if (e.message.toLowerCase().contains('network')) {
          errorMessage = 'Network error. Please check your connection.';
        } else {
          errorMessage = e.message;
        }
    }

    CustomErrorWidgetNew.showError(context, errorMessage);
  }

  void navigateToSignUp(BuildContext context) {
    context.go('/SignUpScreen');
  }

  // Clear all controllers
  void clearControllers() {
    emailController.clear();
    passwordController.clear();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
