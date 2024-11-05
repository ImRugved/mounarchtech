import 'package:get/get.dart';
import 'package:mounarch/Screen/Dashboard_Screen/dashboard.dart';
import 'package:mounarch/Screen/Home_Screen/View/home_screen.dart';
import 'package:mounarch/Screen/Home_Screen/View/news_screen.dart';
import 'package:mounarch/Screen/Home_Screen/View/todo_screen.dart';
import 'package:mounarch/Screen/Home_Screen/View/user_screen.dart';
import 'package:mounarch/Screen/Login_Screen/Bindings/loging_binding.dart';
import 'package:mounarch/Screen/Login_Screen/View/login_screen.dart';
import 'package:mounarch/Screen/Login_Screen/View/signup_screen.dart';
import 'package:mounarch/Screen/Profile_Screen/View/profile.dart';
import 'package:mounarch/Screen/Splash_Screen/splash_screen.dart';

class Routes {
  static final pages = [
    //Splash screen
    GetPage(name: '/splash_screen', page: () => const SplashScreen()),
//Home_Screen

    GetPage(
      name: '/dash_screen',
      page: () => const BottomNavigationPage(),
    ),
    GetPage(
      name: '/user_screen',
      page: () => const UserScreen(),
    ),
    GetPage(
      name: '/news_screen',
      page: () => const NewsScreen(),
    ),
    GetPage(
      name: '/todo_screen',
      page: () => const TodoScreen(),
    ),
    GetPage(
      name: '/home_screen',
      page: () => const HomeScreen(),
    ),

    //Login page Screen
    GetPage(
        name: '/login_screen',
        page: () => const LoginForm(),
        binding: LoginBinding()),

    // //Exit page screen
    GetPage(
        name: '/signup_screen',
        page: () => const SignUpForm(),
        binding: LoginBinding()),
    GetPage(
      name: '/profile_screen',
      page: () => const ProfileScreen(),
      //binding: LoginBinding(),
    ),
  ];
}
