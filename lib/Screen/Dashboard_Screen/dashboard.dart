import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/route_manager.dart';
import 'package:mounarch/Constant/const_colors.dart';
import 'package:mounarch/Constant/custom_dialog.dart';

import 'package:mounarch/Screen/Home_Screen/View/home_screen.dart';
import 'package:mounarch/Screen/Profile_Screen/View/profile.dart';
import 'package:mounarch/Screen/Second_Scren/View/second_screen.dart';

class BottomNavigationPage extends StatefulWidget {
  const BottomNavigationPage({super.key});

  @override
  State<BottomNavigationPage> createState() => _BottomNavigationPageState();
}

class _BottomNavigationPageState extends State<BottomNavigationPage> {
  int selectedIndex = 0;
  late PageController _pageController;

  final List<Widget> widgetOptions = [
    HomeScreen(),
    SecondScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();

    _pageController = PageController(initialPage: selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: PageView(
          onPageChanged: onPageChanged,
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: widgetOptions,
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: ConstColors.primary,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          unselectedItemColor: ConstColors.darkGrey,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.article, size: 30),
              label: "",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home, size: 30),
              label: "",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, size: 30),
              label: "",
            ),
          ],
          currentIndex: selectedIndex,
          selectedItemColor: ConstColors.white,
          onTap: onTabTapped,
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    // Show exit confirmation dialog
    exitDialog();
    return false; // Prevent the default back action
  }

  void onPageChanged(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  void onTabTapped(int index) {
    setState(() {
      selectedIndex = index; // Update the selected index
    });
    _pageController.animateToPage(index,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  exitDialog() {
    showDialog(
      barrierDismissible: true,
      barrierColor: ConstColors.primary.withOpacity(0.1),
      context: context,
      builder: (context) => customDialogueWithCancel(
        backgroundColor: ConstColors.primary,
        content: "Are you sure you want to exit the app?",
        dismissBtnTitle: "Yes",
        onClick: () {
          exit(0);
        },
        cancelBtn: 'Cancel',
        onCancelClick: () => Navigator.pop(context),
        title: "Hold on!",
      ),
    );
  }
}
