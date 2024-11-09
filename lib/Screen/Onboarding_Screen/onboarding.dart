import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/route_manager.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:mounarch/Constant/const_colors.dart';
import 'package:mounarch/Constant/const_textTheme.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({super.key});

  @override
  OnBoardingPageState createState() => OnBoardingPageState();
}

class OnBoardingPageState extends State<OnBoardingPage> {
  final introKey = GlobalKey<IntroductionScreenState>();
  GetStorage box = GetStorage();

  void _onIntroEnd(context) async {
    // Get to login screen after onboarding
    await box.write('introDone', 'true');
    Get.offAllNamed('/login_screen');
  }

  Widget _buildImage(String assetName, String text) {
    return Column(
      children: [
        Image.asset(
          'assets/images/$assetName',
          width: 300.w,
          height: 300.h,
        ),
        Text(text,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w500,
              color: ConstColors.black,
              fontSize: 14.sp,
            )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.w500,
        color: ConstColors.black,
        fontSize: 20,
      ),
      bodyTextStyle: TextStyle(
        fontWeight: FontWeight.w500,
        color: ConstColors.black,
        fontSize: 14,
      ),
      titlePadding: EdgeInsets.fromLTRB(13.0, 90.0, 13.0, 11.0),
      bodyPadding: EdgeInsets.fromLTRB(13.0, 50.0, 13.0, 11.0),
      pageColor: ConstColors.white,
      imagePadding: EdgeInsets.only(top: 0.0),
    );

    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: ConstColors.white,
      allowImplicitScrolling: true,
      autoScrollDuration: 10000,
      infiniteAutoScroll: false,
      pages: [
        PageViewModel(
          titleWidget: Text("Manage Your Profile",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                color: ConstColors.black,
                fontSize: 24.sp,
              )),
          bodyWidget: _buildImage('userProfile.png',
              "With this app, you can easily manage your personal profile. Update your username, email, and phone number, and keep your profile data up to date. Your profile will be securely stored and accessible from anywhere."),
          decoration: pageDecoration,
        ),
        PageViewModel(
          titleWidget: Text("Organize Your Books",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                color: ConstColors.black,
                fontSize: 24.sp,
              )),
          bodyWidget: _buildImage('book.png',
              "Effortlessly organize your books by adding them to your collection. You can update book details, delete entries, and search through your collection. This feature ensures that your library is well-managed and accessible anytime."),
          decoration: pageDecoration,
        ),
        PageViewModel(
          titleWidget: Text("Track Your Tasks",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                color: ConstColors.black,
                fontSize: 24.sp,
              )),
          bodyWidget: _buildImage('home.png',
              "Stay on top of your responsibilities with the To-Do list feature. Fetch tasks from a public API, track their progress, mark them as complete, and set reminders. This feature helps you stay organized and accomplish tasks with ease, ensuring you're always in control."),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      onSkip: () => _onIntroEnd(context),
      showSkipButton: true,
      skipOrBackFlex: 0,
      nextFlex: 0,
      showBackButton: false,
      back: const Icon(
        Icons.arrow_back,
        color: ConstColors.black,
      ),
      skip: Text('Skip', style: getTextTheme().headlineLarge),
      next: Text(
        'Next',
        style: getTextTheme().headlineLarge,
      ),
      done: Text(
        'Get Started',
        style: getTextTheme().headlineLarge,
      ),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsPadding: const EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 4.0),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: ConstColors.primary,
        activeSize: Size(22.0, 10.0),
        activeColor: ConstColors.primary,
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
      dotsContainerDecorator: const ShapeDecoration(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
    );
  }
}
