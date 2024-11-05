import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mounarch/Constant/const_colors.dart';
import 'package:mounarch/Screen/Home_Screen/Controller/home_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          body: Padding(
            padding: EdgeInsets.all(16.0.r),
            child: controller.loading.value
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: controller.userList.length,
                    itemBuilder: (context, index) {
                      final user = controller.userList[index];
                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.symmetric(vertical: 8.h),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(user.avatar),
                          ),
                          title: Text(
                            '${user.firstName} ${user.lastName}',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(user.email),
                        ),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}
