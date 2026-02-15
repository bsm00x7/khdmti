import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:khdmti_project/db/auth/auth.dart';
import 'package:khdmti_project/utils/widgets/custom_error_widget.dart';
import 'package:khdmti_project/utils/widgets/looding_indicator.dart';
import 'package:khdmti_project/utils/widgets/success.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgetController with ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  bool isLoading = false;

  Future<void> onForgotPasswordPressed({required BuildContext context}) async {
    if (emailController.text.trim().isEmpty) {
      CustomErrorWidgetNew.showError(
        context,
        'الرجاء إدخال البريد الإلكتروني أولاً',
      );
      return;
    }

    // Validate email format
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(emailController.text.trim())) {
      CustomErrorWidgetNew.showError(
        context,
        'الرجاء إدخال بريد إلكتروني صحيح',
      );
      return;
    }

    LoadingIndicator.setLoading(context);

    try {
      // Log the email being sent (for debugging)
      debugPrint(
          '🔄 Attempting password reset for: ${emailController.text.trim()}');

      await Auth.resetPassword(email: emailController.text.trim());

      debugPrint('✅ Password reset email sent successfully');

      if (!context.mounted) return;
      LoadingIndicator.setLoading(context, false);

      CustomSuccessWidget.showSuccess(
        context,
        'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني',
      );
    } on AuthException catch (e) {
      // Log the actual error
      debugPrint('❌ AuthException: ${e.message}');
      debugPrint('❌ Status Code: ${e.statusCode}');

      if (!context.mounted) return;
      LoadingIndicator.setLoading(context, false);
      _handleAuthException(context, e);
    } on SocketException catch (e) {
      debugPrint('❌ SocketException: $e');

      if (!context.mounted) return;
      LoadingIndicator.setLoading(context, false);
      CustomErrorWidgetNew.showError(
        context,
        'لا يوجد اتصال بالإنترنت. يرجى التحقق من شبكتك والمحاولة مرة أخرى',
      );
    } on TimeoutException catch (e) {
      debugPrint('❌ TimeoutException: $e');

      if (!context.mounted) return;
      LoadingIndicator.setLoading(context, false);
      CustomErrorWidgetNew.showError(
        context,
        'انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى',
      );
    } catch (e, stackTrace) {
      // Log the full error and stack trace
      debugPrint('❌ Unknown Error: $e');
      debugPrint('❌ Stack Trace: $stackTrace');

      if (!context.mounted) return;
      LoadingIndicator.setLoading(context, false);
      CustomErrorWidgetNew.showError(
        context,
        'فشل إرسال رابط إعادة التعيين. يرجى المحاولة مرة أخرى\nخطأ: ${e.toString()}',
      );
    }
  }

  void _handleAuthException(BuildContext context, AuthException e) {
    String errorMessage;

    // Handle specific auth error codes for PASSWORD RESET
    switch (e.statusCode) {
      case '400':
        if (e.message.toLowerCase().contains('email')) {
          errorMessage = 'عنوان البريد الإلكتروني غير صالح';
        } else if (e.message.toLowerCase().contains('invalid api key')) {
          errorMessage =
              'مفتاح API غير صالح. يرجى التحقق من إعدادات Supabase في التطبيق.';
        } else {
          errorMessage = 'طلب غير صالح. يرجى المحاولة مرة أخرى';
        }
        break;

      case '401':
        if (e.message.toLowerCase().contains('invalid api key')) {
          errorMessage =
              'مفتاح API غير صالح. يرجى التحقق من إعدادات Supabase في التطبيق.';
        } else {
          errorMessage = 'فشل التحقق من الهوية. يرجى تسجيل الدخول مرة أخرى';
        }
        break;

      case '403':
        errorMessage =
            'غير مصرح لك بإجراء هذه العملية. يرجى التحقق من صلاحياتك';
        break;

      case '404':
        // User not found - for security, don't reveal if email exists
        errorMessage =
            'إذا كان البريد الإلكتروني مسجلاً، ستتلقى رابط إعادة التعيين';
        break;

      case '422':
        if (e.message.toLowerCase().contains('email')) {
          errorMessage = 'صيغة البريد الإلكتروني غير صالحة';
        } else {
          errorMessage = 'بيانات غير صالحة. يرجى التحقق من بريدك الإلكتروني';
        }
        break;

      case '429':
        errorMessage =
            'تم إرسال عدد كبير من الطلبات. يرجى الانتظار قليلاً والمحاولة مرة أخرى';
        break;

      case '500':
        errorMessage = 'خطأ في الخادم. يرجى المحاولة مرة أخرى لاحقاً';
        break;

      case '503':
        errorMessage = 'الخدمة غير متاحة مؤقتاً. يرجى المحاولة مرة أخرى لاحقاً';
        break;

      default:
        // Check for common error messages in password reset context
        final lowerMessage = e.message.toLowerCase();

        if (lowerMessage.contains('user not found') ||
            lowerMessage.contains('email not found')) {
          // For security, don't reveal if email exists
          errorMessage =
              'إذا كان البريد الإلكتروني مسجلاً، ستتلقى رابط إعادة التعيين';
        } else if (lowerMessage.contains('invalid email') ||
            lowerMessage.contains('email')) {
          errorMessage = 'عنوان البريد الإلكتروني غير صالح';
        } else if (lowerMessage.contains('network')) {
          errorMessage = 'خطأ في الشبكة. يرجى التحقق من اتصالك';
        } else if (lowerMessage.contains('rate limit') ||
            lowerMessage.contains('too many')) {
          errorMessage = 'تم إرسال عدد كبير من الطلبات. يرجى الانتظار قليلاً';
        } else if (lowerMessage.contains('invalid api key')) {
          errorMessage =
              'مفتاح API غير صالح. يرجى التحقق من إعدادات Supabase في التطبيق.';
        } else {
          // Show the actual error message for debugging
          errorMessage = 'خطأ: ${e.message}';
        }
    }

    CustomErrorWidgetNew.showError(context, errorMessage);
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}
