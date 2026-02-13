import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:khdmti_project/comme_widget/custom_form_filde.dart';
import 'package:khdmti_project/views/sign_up_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();

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
                  key: formKey,
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
                            return "الرجاء ادخال الهاتف أو البريد صحيحة";
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
                            return "الرجاء ادخال كلمة مرور صحيحة";
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
                                  borderRadius: BorderRadius.circular(12)),
                              fixedSize: Size(size.width * 0.9, 62)),
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              // TODO: Handle login
                            }
                          },
                          child: Text("تسجيل الدخول"))
                    ],
                  )),
              SizedBox(
                height: 60,
              ),
              Row(
                children: [
                  SizedBox(
                    height: 20,
                    width: size.width * 0.35,
                    child: Divider(
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
                    child: Divider(
                      color: Colors.grey,
                      thickness: 0.7,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: size.width * .06),
                    width: size.width * .45,
                    height: size.height * .07,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          "فيسبوك",
                          style: theme.textTheme.titleMedium!
                              .copyWith(fontSize: 20),
                        ),
                        Icon(
                          Icons.facebook,
                          color: Colors.blue,
                        )
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: size.width * .06),
                    width: size.width * .40,
                    height: size.height * .07,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          "جوجل",
                          style: theme.textTheme.titleMedium!
                              .copyWith(fontSize: 20),
                        ),
                        SvgPicture.asset(
                          "assets/google.svg",
                          height: 20,
                        )
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 20,
              ),
              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return SignUpScreen();
                    },
                  ));
                },
                child: Text.rich(
                  TextSpan(text: "ليس لديك حساب؟ ", children: [
                    TextSpan(
                        text: "أنشئ حساباً جديداً",
                        style: TextStyle(
                            color: Colors.blue,
                            fontSize: 16,
                            fontWeight: FontWeight.bold))
                  ]),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
