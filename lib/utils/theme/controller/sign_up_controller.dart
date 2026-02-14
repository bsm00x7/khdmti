import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:khdmti_project/db/auth/auth.dart';
import 'package:khdmti_project/model/user_model.dart';
import 'package:khdmti_project/utils/widgets/custom_error_widget.dart';
import 'package:khdmti_project/utils/widgets/looding_indicator.dart';
import 'package:khdmti_project/utils/widgets/success.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpController extends ChangeNotifier {
  final formKeySignUp = GlobalKey<FormState>();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> onPressed({required BuildContext context}) async {
    // Prevent multiple submissions
    if (_isLoading) return;

    if (formKeySignUp.currentState?.validate() ?? false) {
      _setLoading(true);
      LoadingIndicator.setLoading(context);

      try {
        final AuthResponse user = await Auth.createNewUser(
          user: UserModel(
            fullname: nameController.text.trim(),
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          ),
        ).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw TimeoutException('Request timed out');
          },
        );

        if (!context.mounted) return;
        LoadingIndicator.setLoading(context, false);
        _setLoading(false);

        // Check if email verification is required
        if (user.session?.user.emailConfirmedAt == null) {
          _showEmailVerificationSheet(context);
        } else {
          // Email already confirmed (rare case)
          CustomSuccessWidget.showSuccess(
            context,
            'Account created successfully!',
          );
          clearControllers();
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

  void _showEmailVerificationSheet(BuildContext context) {
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
                Icons.mark_email_read_outlined,
                size: 64,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              const Text(
                'Verify Your Email',
                style: TextStyle(
                  fontSize: 22,
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
              Text(
                emailController.text.trim(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
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
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    clearControllers();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Got it'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () async {
                  // Resend verification email logic here
                  try {
                    await Supabase.instance.client.auth.resend(
                      type: OtpType.signup,
                      email: emailController.text.trim(),
                    );
                    if (context.mounted) {
                      CustomSuccessWidget.showSuccess(
                        context,
                        'Verification email resent!',
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      CustomErrorWidgetNew.showError(
                        context,
                        'Failed to resend email. Please try again.',
                      );
                    }
                  }
                },
                child: const Text('Resend verification email'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleAuthException(BuildContext context, AuthException e) {
    String errorMessage;

    // Handle specific auth error codes
    switch (e.statusCode) {
      case '400':
        if (e.message.toLowerCase().contains('email')) {
          errorMessage = 'Invalid email address';
        } else if (e.message.toLowerCase().contains('password')) {
          errorMessage = 'Password does not meet requirements';
        } else {
          errorMessage = 'Invalid input. Please check your details.';
        }
        break;
      case '409':
        errorMessage =
            'This email is already registered. Please sign in instead.';
        break;
      case '422':
        if (e.message.toLowerCase().contains('email')) {
          errorMessage = 'Invalid email format';
        } else if (e.message.toLowerCase().contains('password')) {
          errorMessage = 'Password must be at least 6 characters';
        } else {
          errorMessage = e.message;
        }
        break;
      case '429':
        errorMessage = 'Too many attempts. Please try again later.';
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
        if (e.message.toLowerCase().contains('user already registered')) {
          errorMessage =
              'This email is already registered. Please sign in instead.';
        } else if (e.message.toLowerCase().contains('invalid email')) {
          errorMessage = 'Please enter a valid email address';
        } else if (e.message.toLowerCase().contains('weak password')) {
          errorMessage =
              'Password is too weak. Please use a stronger password.';
        } else if (e.message.toLowerCase().contains('network')) {
          errorMessage = 'Network error. Please check your connection.';
        } else {
          errorMessage = e.message;
        }
    }

    CustomErrorWidgetNew.showError(context, errorMessage);
  }

  // Clear all controllers
  void clearControllers() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
  }

  @override
  void dispose() {
    passwordController.dispose();
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }
}
