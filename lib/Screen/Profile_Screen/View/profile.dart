import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mounarch/Constant/const_colors.dart';
import 'package:mounarch/Screen/Home_Screen/Controller/home_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Widget _buildProfileImage(String? url) {
    if (url == null || url.isEmpty) {
      return const CircleAvatar(
        radius: 50,
        child: Icon(Icons.person, size: 50),
      );
    }

    return CircleAvatar(
      radius: 50,
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: url,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          placeholder: (context, url) => SizedBox(
              height: 20.h,
              width: 20.w,
              child: const CircularProgressIndicator()),
          errorWidget: (context, url, error) =>
              const Icon(Icons.person, size: 50),
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: GetBuilder<HomeController>(
        id: 'profile',
        builder: (controller) {
          final userData = controller.getStoredUserData();
          if (userData == null) {
            return const Center(
              child: Text('No user data found'),
            );
          }

          log('profile is ${userData['profilePicUrl']}');

          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildProfileImage(userData['profilePicUrl']),
                      const SizedBox(height: 16),
                      Text(
                        userData['userName'] ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        userData['email'] ?? 'N/A',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            controller.signOut();
                          },
                          icon: const Icon(Icons.logout, color: Colors.black),
                          label: const Text(
                            "Logout",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ConstColors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildInfoTile(
                            icon: Icons.phone,
                            title: 'Phone Number',
                            value: userData['number'] ?? 'N/A',
                          ),
                          const Divider(),
                          _buildInfoTile(
                            icon: Icons.access_time,
                            title: 'Sign Up Time',
                            value: userData['signUpTime'] ?? 'N/A',
                          ),
                          const Divider(),
                          _buildInfoTile(
                            icon: Icons.calendar_today,
                            title: 'Sign Up Date',
                            value: userData['signUpDate'] ?? 'N/A',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
