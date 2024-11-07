import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mounarch/Constant/const_colors.dart';
import 'package:mounarch/Constant/const_textTheme.dart';
import 'package:mounarch/Screen/Home_Screen/Controller/home_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> containerLabels = [
      "Users Data Api",
      "Books APi",
      "Todo Data APi\n 200 Data",
    ];
    final List<Color> containerColors = [
      Colors.red,
      Colors.blue,
      Colors.green,
    ];
    return GetBuilder(
      init: HomeController(),
      id: 'home',
      builder: (controller) {
        return Scaffold(
            appBar: AppBar(
              title: Text('Home Screen'),
              actions: [
                IconButton(
                  onPressed: () async {
                    await GetStorage().erase();
                    Get.offAllNamed('/login_screen');
                    controller.signOut();
                  },
                  icon: Icon(
                    Icons.logout_outlined,
                    color: ConstColors.black,
                    size: 25.sp,
                  ),
                ),
              ],
            ),
            body: GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1, // Number of items per row
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0.sp,
              ),
              itemCount: 3, // Number of containers
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    if (index == 0) {
                      Get.toNamed('/user_screen');
                    } else if (index == 1) {
                      Get.toNamed('/news_screen');
                    } else if (index == 2) {
                      Get.toNamed('/todo_screen');
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: containerColors[index],
                        borderRadius: BorderRadius.circular(8.sp)),
                    alignment: Alignment.center,
                    child: Text(
                      containerLabels[index],
                      style: getTextTheme().displayLarge,
                    ),
                  ),
                );
              },
            ));
      },
    );
  }
}
