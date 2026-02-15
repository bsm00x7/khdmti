import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:khdmti_project/comme_widget/custom_form_filde.dart';
import 'package:khdmti_project/views/authpage/controller/forget_controller.dart';
import 'package:provider/provider.dart';

class ForgetScreen extends StatefulWidget {
  const ForgetScreen({super.key});

  @override
  State<ForgetScreen> createState() => _ForgetScreenState();
}

class _ForgetScreenState extends State<ForgetScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ChangeNotifierProvider<ForgetController>(
      create: (context) => ForgetController(),
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  // Back button
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.pop(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Logo
                  Center(
                    child: SvgPicture.asset(
                      "assets/Background.svg",
                      height: 120,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // App name
                  Center(
                    child: Text(
                      "خدمتي",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Subtitle
                  Center(
                    child: Text(
                      "منصتك للعمل الحر والفرص",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 50),
                  // Reset password title
                  Center(
                    child: Text(
                      "نسيت كلمة المرور؟",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Instructions
                  Center(
                    child: Text(
                      "أدخل بريدك الإلكتروني وسنرسل لك رابط لإعادة تعيين كلمة المرور",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Form
                  Consumer<ForgetController>(
                    builder: (context, controller, child) {
                      return Form(
                        key: controller.formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Email label
                            Align(
                              alignment: Alignment.topRight,
                              child: Text(
                                "البريد الإلكتروني",
                                style: theme.textTheme.titleMedium,
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Email field
                            CustomTextFormField(
                              controller: controller.emailController,
                              theme: theme,
                              hintText: "أدخل البريد الإلكتروني",
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => controller
                                  .onForgotPasswordPressed(context: context),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "الرجاء إدخال البريد الإلكتروني";
                                }
                                // Email validation regex
                                final emailRegex = RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                );
                                if (!emailRegex.hasMatch(value)) {
                                  return "الرجاء إدخال بريد إلكتروني صحيح";
                                }
                                return null;
                              },
                              prefixIcon: const Icon(Icons.email),
                            ),
                            const SizedBox(height: 30),
                            // Reset button
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                minimumSize: const Size(double.infinity, 62),
                              ),
                              onPressed: controller.isLoading
                                  ? null
                                  : () => controller.onForgotPasswordPressed(
                                      context: context),
                              child: controller.isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : const Text(
                                      "إرسال رابط إعادة التعيين",
                                      style: TextStyle(fontSize: 16),
                                    ),
                            ),
                            const SizedBox(height: 30),
                            // Back to login
                            Center(
                              child: InkWell(
                                onTap: () => context.pop(),
                                child: Text(
                                  "العودة إلى تسجيل الدخول",
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
