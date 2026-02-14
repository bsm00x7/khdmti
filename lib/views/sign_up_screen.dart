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
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: ChangeNotifierProvider(
        create: (context) => SignUpController(),
        child: SingleChildScrollView(
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
                  " منصتك الأولى للعمل الحر والفرص في تونس",
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(
                  height: 40,
                ),
                Consumer<SignUpController>(
                  builder: (context, value, child) {
                    return Form(
                        key: value.formKeySignUp,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Align(
                              alignment: Alignment.topRight,
                              child: Text(
                                "  الاسم",
                                style: theme.textTheme.titleMedium,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomTextFormField(
                              controller: value.nameController,
                              theme: theme,
                              hintText: " ادخل اسمك",
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "الرجاء ادخال اسمك صحيحة";
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
                                " رقم الهاتف أو البريد الإلكتروني",
                                style: theme.textTheme.titleMedium,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            CustomTextFormField(
                              controller: value.emailController,
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
                            const SizedBox(
                              height: 10,
                            ),
                            CustomTextFormField(
                              controller: value.passwordController,
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
                            const SizedBox(
                              height: 30,
                            ),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    fixedSize: Size(size.width * 0.9, 62)),
                                onPressed: () =>
                                    value.onPressed(context: context),
                                child: Text("إنشاء حساب"))
                          ],
                        ));
                  },
                ),
                SizedBox(
                  height: 60,
                ),
                Row(
                  children: [
                    SizedBox(
                      height: 20,
                      width: size.width * 0.32,
                      child: Divider(
                        color: Colors.grey,
                        thickness: 0.7,
                      ),
                    ),
                    Text(
                      " أو تابع باستخدام",
                      style: theme.textTheme.headlineSmall,
                    ),
                    SizedBox(
                      height: 20,
                      width: size.width * 0.32,
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
                      padding:
                          EdgeInsets.symmetric(horizontal: size.width * .06),
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
                      padding:
                          EdgeInsets.symmetric(horizontal: size.width * .06),
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
                        return LoginScreen();
                      },
                    ));
                  },
                  child: Text.rich(
                    TextSpan(text: "لديك حساب؟ ", children: [
                      TextSpan(
                          text: "سجل الدخول",
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
      ),
    );
  }
}
