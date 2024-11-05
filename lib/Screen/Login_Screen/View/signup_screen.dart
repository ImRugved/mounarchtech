import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mounarch/Constant/const_colors.dart';
import 'package:mounarch/Constant/const_textTheme.dart';
import 'package:mounarch/Constant/loading.dart';
import 'package:mounarch/Constant/rounded_button.dart';
import 'package:mounarch/Screen/Login_Screen/Controller/login_controller.dart';
import 'package:mounarch/Screen/Login_Screen/View/login_screen.dart';

class SignUpForm extends StatelessWidget {
  const SignUpForm({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    return Scaffold(
      body: Center(
        child: GetBuilder(
          init: LoginController(),
          id: 'signUp',
          builder: (ctrl) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Sign up',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: ConstColors.orange,
                          fontSize: 24.sp,
                        ),
                      ),
                      SizedBox(
                        height: 8.h,
                      ),
                      // Text('Create your account',
                      //     style: getTextTheme().headlineSmall),
                      // In your signup screen
                      GetBuilder<LoginController>(
                        id: 'profileImage',
                        builder: (controller) => GestureDetector(
                          onTap: controller.takeProfilePicture,
                          child: Container(
                            width: 120,
                            height: 120,
                            margin: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[200],
                            ),
                            child: controller.profileImage.value != null
                                ? ClipOval(
                                    child: Image.file(
                                      controller.profileImage.value!,
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.camera_alt,
                                          size: 40, color: Colors.grey),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Take Photo',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
// ... rest of your signup form
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: ctrl.userNameController,
                        decoration: InputDecoration(
                          fillColor: const Color.fromARGB(255, 210, 230, 249),
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: Colors.grey[600],
                          ),
                          hintText: 'Username',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a username';
                          } else if (value.length < 3) {
                            return 'Username must be at least 3 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: ctrl.numberController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(10),
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          fillColor: const Color.fromARGB(255, 210, 230, 249),
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: Colors.grey[600],
                          ),
                          hintText: 'Mobile Number',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a username';
                          } else if (value.length < 10) {
                            return 'Please enter valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: ctrl.emailController,
                        decoration: InputDecoration(
                          fillColor: const Color.fromARGB(255, 210, 230, 249),
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: Colors.grey[600],
                          ),
                          hintText: 'Email',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$')
                              .hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: ctrl.passController,
                        obscureText: !ctrl.isVisible1.value,
                        decoration: InputDecoration(
                          fillColor: const Color.fromARGB(255, 210, 230, 249),
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: Colors.grey[600],
                            size: 25.sp,
                          ),
                          hintText: 'Password',
                          suffixIcon: GestureDetector(
                              onTap: () {
                                ctrl.isVisible1.value = !ctrl.isVisible1.value;
                                ctrl.update(["signUp"]);
                              },
                              onDoubleTap: () {},
                              child: !ctrl.isVisible1.value
                                  ? Icon(Icons.visibility_off_sharp,
                                      color: ConstColors.darkGrey, size: 25.sp)
                                  : Icon(Icons.visibility_outlined,
                                      color: ConstColors.darkGrey,
                                      size: 25.sp)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          } else if (value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: ctrl.passController1,
                        obscureText: !ctrl.isVisible2.value,
                        decoration: InputDecoration(
                          fillColor: const Color.fromARGB(255, 210, 230, 249),
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: Colors.grey[600],
                            size: 25.sp,
                          ),
                          hintText: 'Confirm Password',
                          suffixIcon: GestureDetector(
                              onTap: () {
                                ctrl.isVisible2.value = !ctrl.isVisible2.value;
                                ctrl.update(["signUp"]);
                              },
                              onDoubleTap: () {},
                              child: !ctrl.isVisible2.value
                                  ? Icon(Icons.visibility_off_sharp,
                                      color: ConstColors.darkGrey, size: 25.sp)
                                  : Icon(Icons.visibility_outlined,
                                      color: ConstColors.darkGrey,
                                      size: 25.sp)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          } else if (value != ctrl.passController.text) {
                            return 'Passwords does not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      RoundedButton(
                        press: () {
                          if (formKey.currentState!.validate()) {
                            if (ctrl.passController.text.trim() ==
                                ctrl.passController1.text.trim()) {
                              ctrl.signUp(
                                context,
                                ctrl.emailController.text.trim(),
                                ctrl.passController.text.trim(),
                                ctrl.userNameController.text.trim(),
                              );
                            } else {
                              Get.snackbar(
                                  'User Alert', 'Passwords does not match',
                                  snackPosition: SnackPosition.TOP);
                            }
                          }
                        },
                        text: 'Sign Up',
                        color: ConstColors.primary,
                        bordercolor: ConstColors.primary,
                        radius: 8.sp,
                        style: getTextTheme().bodyLarge,
                      ).toProgress(
                        ctrl.signupLoading,
                      ),
                      const SizedBox(height: 16),
                      const Center(
                        child: Text('Or'),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account?',
                            style: getTextTheme().headlineMedium,
                          ),
                          TextButton(
                            onPressed: () {
                              Get.toNamed('/login_screen');
                            },
                            child: Text(
                              'Login',
                              style: getTextTheme().titleMedium,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
