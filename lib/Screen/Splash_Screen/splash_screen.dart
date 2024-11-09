import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mounarch/Constant/const_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  GetStorage box = GetStorage();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(seconds: 3), () async {
      await box.read('introDone') == null
          ? Get.offAllNamed('/intro_screen')
          : box.read("login") == 'login'
              ? Get.offAllNamed("/dash_screen")
              : Get.offAllNamed("/login_screen");
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: ConstColors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: 250.h,
              ),
              // Text(
              //   'Splash Screen',
              //   style: GoogleFonts.poppins(
              //     fontWeight: FontWeight.w600,
              //     color: ConstColors.black,
              //     fontSize: kIsWeb ? 8.sp : 12.sp,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
