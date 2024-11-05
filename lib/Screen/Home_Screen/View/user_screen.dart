import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mounarch/Screen/Home_Screen/Controller/home_controller.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User APi'),
      ),
      body: GetBuilder(
          init: HomeController(),
          id: 'user',
          builder: (controller) {
            return Padding(
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
            );
          }),
    );
  }
}
