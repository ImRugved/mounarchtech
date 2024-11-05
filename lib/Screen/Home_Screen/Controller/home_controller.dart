import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mounarch/Constant/global.dart';

import 'package:mounarch/Screen/Home_Screen/Model/user_data.dart';

import 'package:mounarch/Utils/api.dart';

class HomeController extends GetxController {
  final db = FirebaseFirestore.instance.collection('userData');

  List<UserData> userList = [];
  RxBool isLoading = false.obs;
  RxBool loading = false.obs;
  RxString userId = ''.obs;
  final GetStorage box = GetStorage();

  API api = API();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  void onInit() {
    super.onInit();
    getAll();
    getUserData();
    fetchUserData();
  }

  void getAll() async {
    userId.value = await box.read('userId');
    log('user id is ${userId.value}');
  }

  // Method to fetch user data by UID
  Future<Map<String, dynamic>?> fetchUserData() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        final DocumentSnapshot doc = await db.doc(currentUser.uid).get();

        if (doc.exists) {
          return doc.data() as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      Get.toNamed('/login_screen');
      log("User successfully signed out.");
    } catch (e) {
      log("Error signing out: $e");
    }
  }

  Future<void> getUserData() async {
    loading.value = true;
    update(['home']);
    try {
      final response = await Dio().get(
        Global.hostUrl, // Replace with Global.hostUrl if needed
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
      log('API response: ${response.data}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parse the JSON data into UserResponse model
        final userResponse = UserResponse.fromJson(response.data);
        // Store the user data in the userList
        userList = userResponse.data;
        update(['home']); // Update UI with the new data
      } else {
        loading.value = false;
        update(['home']);
        Get.snackbar("Invalid Data", "Failed to fetch the user data");
      }
      update(['home']);
    } on DioException catch (error) {
      String errorMessage = error.type == DioExceptionType.connectionError
          ? "Network Error"
          : error.type == DioExceptionType.connectionTimeout
              ? "Time Out"
              : "Something went wrong: $error";
      Get.snackbar("Error", errorMessage);
    } catch (error) {
      log('Vehicle rate ERROR: $error');
      Get.snackbar("Error", "$error");
    } finally {
      loading.value = false;
      update(['home']);
    }
  }
}
