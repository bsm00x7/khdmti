import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:khdmti_project/comme_widget/custom_form_filde.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

final FormKey = GlobalKey<FormState>();

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            children: [
              SizedBox(
                height: 40,
              ),
              Center(
                child: SvgPicture.asset("assets/Background.svg"),
              ),
              Text(
                "خدمتي",
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "منصتك للعمل الحر والفرص",
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(
                height: 40,
              ),
              Align(
                alignment: Alignment.topRight,
                child: Text(
                  " رقم الهاتف أو البريد الإلكتروني",
                  style: theme.textTheme.titleMedium,
                ),
              ),
              Form(
                  key: FormKey,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      CustomTextFormField(
                        theme: theme,
                        hintText: "أدخل رقم الهاتف أو البريد",
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "dd";
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Text(
                          " كلمة المرور",
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      CustomTextFormField(
                        obscureText: true,
                        theme: theme,
                        hintText: "أدخل كلمة المرور",
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "dd";
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      GestureDetector(
                        onTap: () {
                          // TODO : Create Screen Forget Password
                        },
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            " نسيت كلمة المرور؟",
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadiusGeometry.circular(12)),
                              fixedSize: Size(size.width * 0.9, 62)),
                          onPressed: () {},
                          child: Text("تسجيل الدخول"))
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
