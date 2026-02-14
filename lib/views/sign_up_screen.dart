import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:khdmti_project/comme_widget/custom_form_filde.dart';
import 'package:khdmti_project/utils/theme/controller/sign_up_controller.dart';
import 'package:khdmti_project/views/login_screen.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late SignUpController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SignUpController();

    // Listen to password changes for strength indicator
    _controller.passwordController.addListener(() {
      _controller.updatePasswordStrength(_controller.passwordController.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: ChangeNotifierProvider.value(
        value: _controller,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Directionality(
              textDirection: TextDirection.rtl, // RTL for Arabic
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Logo and Title
                    Center(
                      child: SvgPicture.asset(
                        "assets/Background.svg",
                        height: 100,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      "خدمتي",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Text(
                      "منصتك الأولى للعمل الحر والفرص في تونس",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // Form Section
                    Consumer<SignUpController>(
                      builder: (context, controller, child) {
                        return Form(
                          key: controller.formKeySignUp,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Name Field
                              _buildFieldLabel("الاسم", theme),
                              const SizedBox(height: 8),
                              CustomTextFormField(
                                controller: controller.nameController,
                                theme: theme,
                                hintText: "أدخل اسمك الكامل",
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.name,
                                prefixIcon: const Icon(Icons.person_outline),
                                validator: controller.validateName,
                              ),
                              const SizedBox(height: 20),

                              // Email Field
                              _buildFieldLabel("البريد الإلكتروني", theme),
                              const SizedBox(height: 8),
                              CustomTextFormField(
                                controller: controller.emailController,
                                theme: theme,
                                hintText: "أدخل بريدك الإلكتروني",
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.emailAddress,
                                prefixIcon: const Icon(Icons.email_outlined),
                                validator: controller.validateEmail,
                              ),
                              const SizedBox(height: 20),

                              // Password Field
                              _buildFieldLabel("كلمة المرور", theme),
                              const SizedBox(height: 8),
                              CustomTextFormField(
                                controller: controller.passwordController,
                                theme: theme,
                                hintText: "أدخل كلمة المرور",
                                obscureText: !controller.isPasswordVisible,
                                textInputAction: TextInputAction.done,
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    controller.isPasswordVisible
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: Colors.grey,
                                  ),
                                  onPressed:
                                      controller.togglePasswordVisibility,
                                ),
                                validator: controller.validatePassword,
                                onFieldSubmitted: (_) {
                                  controller.onPressed(context: context);
                                },
                              ),
                              const SizedBox(height: 12),

                              // Password Strength Indicator
                              _buildPasswordStrength(controller),

                              const SizedBox(height: 30),

                              // Sign Up Button
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    disabledBackgroundColor: Colors.grey[300],
                                  ),
                                  onPressed: controller.isLoading
                                      ? null
                                      : () => controller.onPressed(
                                          context: context),
                                  child: controller.isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          "إنشاء حساب",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 30),

                    // Terms and Privacy
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "بإنشاء حساب، فإنك توافق على شروط الخدمة وسياسة الخصوصية",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Divider with "or continue with"
                    _buildDividerWithText("أو تابع باستخدام", theme, size),

                    const SizedBox(height: 30),

                    // Social Login Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSocialButton(
                          context: context,
                          label: "فيسبوك",
                          icon: const Icon(
                            Icons.facebook,
                            color: Color(0xFF1877F2),
                            size: 24,
                          ),
                          onTap: () {
                            // TODO: Implement Facebook login
                            _showComingSoonSnackbar(context, "فيسبوك");
                          },
                          size: size,
                          width: 0.45,
                        ),
                        _buildSocialButton(
                          context: context,
                          label: "جوجل",
                          icon: SvgPicture.asset(
                            "assets/google.svg",
                            height: 24,
                            width: 24,
                          ),
                          onTap: () {
                            // TODO: Implement Google login
                            _showComingSoonSnackbar(context, "جوجل");
                          },
                          size: size,
                          width: 0.42,
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Already have account
                    InkWell(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Text.rich(
                          TextSpan(
                            text: "لديك حساب؟ ",
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 15,
                            ),
                            children: const [
                              TextSpan(
                                text: "سجل الدخول",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper: Build field label
  Widget _buildFieldLabel(String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Text(
        text,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    );
  }

  // Helper: Build password strength indicator
  Widget _buildPasswordStrength(SignUpController controller) {
    if (controller.passwordController.text.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(right: 4),
        child: Text(
          "يجب أن تكون كلمة المرور 6 أحرف على الأقل",
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: controller.passwordStrength.progress,
            backgroundColor: Colors.grey[200],
            color: controller.passwordStrength.color,
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 8),

        // Strength label
        Row(
          children: [
            Icon(
              _getStrengthIcon(controller.passwordStrength),
              size: 16,
              color: controller.passwordStrength.color,
            ),
            const SizedBox(width: 6),
            Text(
              _getStrengthLabel(controller.passwordStrength),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: controller.passwordStrength.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),

        // Strength tip
        Padding(
          padding: const EdgeInsets.only(right: 22),
          child: Text(
            _getStrengthTip(controller.passwordStrength),
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  // Helper: Get strength icon
  IconData _getStrengthIcon(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return Icons.warning_amber_rounded;
      case PasswordStrength.medium:
        return Icons.check_circle_outline;
      case PasswordStrength.strong:
        return Icons.verified;
    }
  }

  // Helper: Get strength label in Arabic
  String _getStrengthLabel(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return "ضعيفة";
      case PasswordStrength.medium:
        return "متوسطة";
      case PasswordStrength.strong:
        return "قوية";
    }
  }

  // Helper: Get strength tip in Arabic
  String _getStrengthTip(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return "أضف المزيد من الأحرف والأرقام أو الرموز";
      case PasswordStrength.medium:
        return "جيد! أضف رموز خاصة لمزيد من الأمان";
      case PasswordStrength.strong:
        return "ممتاز! كلمة المرور قوية وآمنة";
    }
  }

  // Helper: Build divider with text
  Widget _buildDividerWithText(String text, ThemeData theme, Size size) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.grey[400],
            thickness: 0.8,
            endIndent: 12,
          ),
        ),
        Text(
          text,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: Colors.grey[600],
            fontSize: 13,
          ),
        ),
        Expanded(
          child: Divider(
            color: Colors.grey[400],
            thickness: 0.8,
            indent: 12,
          ),
        ),
      ],
    );
  }

  // Helper: Build social login button
  Widget _buildSocialButton({
    required BuildContext context,
    required String label,
    required Widget icon,
    required VoidCallback onTap,
    required Size size,
    required double width,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: size.width * width,
        height: 56,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 12),
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper: Show coming soon snackbar
  void _showComingSoonSnackbar(BuildContext context, String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "تسجيل الدخول عبر $provider قريباً",
          textAlign: TextAlign.center,
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
