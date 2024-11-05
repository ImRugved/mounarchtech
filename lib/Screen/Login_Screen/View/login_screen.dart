import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mounarch/Constant/const_colors.dart';
import 'package:mounarch/Constant/const_textTheme.dart';
import 'package:mounarch/Constant/loading.dart';
import 'package:mounarch/Constant/rounded_button.dart';
import 'package:mounarch/Screen/Login_Screen/Controller/login_controller.dart';
import 'package:mounarch/Screen/Login_Screen/View/signup_screen.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    return Scaffold(
        backgroundColor: ConstColors.white,
        body: Center(
          child: GetBuilder(
              init: LoginController(),
              id: 'login',
              builder: (controller) {
                return SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Welcome',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: ConstColors.orange,
                              fontSize: 24.sp,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Image.asset(
                            'assets/images/logo.png',
                            height: 150.h,
                          ),
                          SizedBox(height: 24.h),
                          TextFormField(
                            controller: controller.emailController,
                            decoration: InputDecoration(
                              fillColor:
                                  const Color.fromARGB(255, 210, 230, 249),
                              prefixIcon: Icon(Icons.person_outline,
                                  color: Colors.grey[600]),
                              hintText: 'Email',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: controller.passController,
                            obscureText: !controller.isVisible.value,
                            decoration: InputDecoration(
                              fillColor:
                                  const Color.fromARGB(255, 210, 230, 249),
                              prefixIcon: Icon(Icons.lock_outline,
                                  color: Colors.grey[600]),
                              hintText: 'Password',
                              suffixIcon: GestureDetector(
                                  onTap: () {
                                    controller.isVisible.value =
                                        !controller.isVisible.value;
                                    controller.update(["login"]);
                                  },
                                  onDoubleTap: () {},
                                  child: !controller.isVisible.value
                                      ? Icon(Icons.visibility_off_sharp,
                                          color: ConstColors.darkGrey,
                                          size: 25.sp)
                                      : Icon(Icons.visibility_outlined,
                                          color: ConstColors.darkGrey,
                                          size: 25.sp)),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              } else if (value.length < 8) {
                                return 'Password must be at least 8 characters long';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          RoundedButton(
                            press: () {
                              // Validate the form fields
                              if (formKey.currentState != null &&
                                  formKey.currentState!.validate()) {
                                controller.emailLogin(
                                  context,
                                  controller.emailController.text.trim(),
                                  controller.passController.text.trim(),
                                );
                              } else {
                                Get.snackbar(
                                  'User Alert',
                                  'Please enter valid credentials',
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              }
                            },
                            text: 'Login',
                            color: ConstColors.primary,
                            bordercolor: ConstColors.primary,
                            radius: 8.sp,
                            style: getTextTheme().bodyLarge,
                          ).toProgress(controller.loading),
                          const SizedBox(height: 16),
                          Center(
                            child: TextButton(
                              onPressed: () {},
                              child: Text('Forgot Password?',
                                  style: getTextTheme().titleSmall),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account?",
                                style: getTextTheme().headlineSmall,
                              ),
                              TextButton(
                                onPressed: () {
                                  Get.toNamed('/signup_screen');
                                },
                                child: Text('Sign Up',
                                    style: getTextTheme().titleMedium),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
        ));
  }
}
