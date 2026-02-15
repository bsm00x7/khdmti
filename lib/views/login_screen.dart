import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:khdmti_project/comme_widget/custom_form_filde.dart';
import 'package:khdmti_project/controller/login_controller.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginController(),
      child: const _LoginScreenContent(),
    );
  }
}

class _LoginScreenContent extends StatelessWidget {
  const _LoginScreenContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final controller = context.watch<LoginController>();

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Center(
                child: SvgPicture.asset("assets/Background.svg"),
              ),
              Text(
                "خدمتي",
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              Text(
                "منصتك للعمل الحر والفرص",
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 40),
              Align(
                alignment: Alignment.topRight,
                child: Text(
                  "البريد الإلكتروني",
                  style: theme.textTheme.titleMedium,
                ),
              ),
              Form(
                key: controller.formKeyLogin,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    CustomTextFormField(
                      controller: controller.emailController,
                      theme: theme,
                      hintText: "أدخل البريد الإلكتروني",
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
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
                      prefixIcon: Icon(Icons.email),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.topRight,
                      child: Text(
                        "كلمة المرور",
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(height: 10),
                    CustomTextFormField(
                      prefixIcon: Icon(Icons.password),
                      controller: controller.passwordController,
                      obscureText: controller.obscurePassword,
                      theme: theme,
                      hintText: "أدخل كلمة المرور",
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) {
                        controller.onLoginPressed(context: context);
                      },
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: controller.togglePasswordVisibility,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "الرجاء إدخال كلمة المرور";
                        }
                        if (value.length < 6) {
                          return "كلمة المرور يجب أن تكون 6 أحرف على الأقل";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    GestureDetector(
                      onTap: () {
                        controller.onForgotPasswordPressed(context: context);
                      },
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "نسيت كلمة المرور؟",
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        fixedSize: Size(size.width * 0.9, 62),
                      ),
                      onPressed: controller.isLoading
                          ? null
                          : () => controller.onLoginPressed(context: context),
                      child: controller.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text("تسجيل الدخول"),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
              Row(
                children: [
                  SizedBox(
                    height: 20,
                    width: size.width * 0.35,
                    child: const Divider(
                      color: Colors.grey,
                      thickness: 0.7,
                    ),
                  ),
                  Text(
                    " أو سجل عبر",
                    style: theme.textTheme.headlineSmall,
                  ),
                  SizedBox(
                    height: 20,
                    width: size.width * 0.35,
                    child: const Divider(
                      color: Colors.grey,
                      thickness: 0.7,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Facebook Login Button
                  _SocialLoginButton(
                    width: size.width * .45,
                    height: size.height * .07,
                    label: "فيسبوك",
                    icon: const Icon(
                      Icons.facebook,
                      color: Colors.blue,
                    ),
                    onTap: () {
                      // TODO: Implement Facebook login
                    },
                    theme: theme,
                  ),
                  // Google Login Button
                  _SocialLoginButton(
                    width: size.width * .40,
                    height: size.height * .07,
                    label: "جوجل",
                    icon: SvgPicture.asset(
                      "assets/google.svg",
                      height: 20,
                    ),
                    onTap: () {
                      // TODO: Implement Google login
                    },
                    theme: theme,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () {
                  controller.navigateToSignUp(context);
                },
                child: Text.rich(
                  TextSpan(
                    text: "ليس لديك حساب؟ ",
                    children: [
                      TextSpan(
                        text: "أنشئ حساباً جديداً",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Social Login Button Widget
class _SocialLoginButton extends StatelessWidget {
  final double width;
  final double height;
  final String label;
  final Widget icon;
  final VoidCallback onTap;
  final ThemeData theme;

  const _SocialLoginButton({
    required this.width,
    required this.height,
    required this.label,
    required this.icon,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: width * .06),
        width: width,
        height: height,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              label,
              style: theme.textTheme.titleMedium!.copyWith(fontSize: 20),
            ),
            icon,
          ],
        ),
      ),
    );
  }
}
