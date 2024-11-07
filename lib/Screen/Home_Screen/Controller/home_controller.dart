import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mounarch/Constant/global.dart';
import 'package:mounarch/Screen/Home_Screen/Model/books_model.dart';
import 'package:mounarch/Screen/Home_Screen/Model/todo_model.dart';

import 'package:mounarch/Screen/Home_Screen/Model/user_data.dart';

import 'package:mounarch/Utils/api.dart';

class HomeController extends GetxController {
  final db = FirebaseFirestore.instance.collection('userData');
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final RxList<Map<String, dynamic>> data = <Map<String, dynamic>>[].obs;

  List<UserData> userList = [];

  List<TodoApiModel> todoApi = [];
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
    getBookData();
    getTodoData();
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
    update(['user']);
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
        update(['user']); // Update UI with the new data
      } else {
        loading.value = false;
        update(['user']);
        Get.snackbar("Invalid Data", "Failed to fetch the user data");
      }
      update(['user']);
    } on DioException catch (error) {
      String errorMessage = error.type == DioExceptionType.connectionError
          ? "Network Error"
          : error.type == DioExceptionType.connectionTimeout
              ? "Time Out"
              : "Something went wrong: $error";
      Get.snackbar("Error", errorMessage);
    } catch (error) {
      log('user ERROR: $error');
      Get.snackbar("Error", "$error");
    } finally {
      loading.value = false;
      update(['user']);
    }
  }

  Future<void> getTodoData() async {
    try {
      final response = await Dio().get(
        'https://jsonplaceholder.typicode.com/todos',
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parse the JSON data into a list of TodoApiModel
        final todoList = (response.data as List)
            .map((item) => TodoApiModel.fromJson(item))
            .toList();

        // Store the todo data in the todoApi list
        todoApi = todoList;
        update(['todo']); // Update UI with the new data
      } else {
        Get.snackbar("Invalid Data", "Failed to fetch the todo data");
      }
    } on DioException catch (error) {
      String errorMessage = error.type == DioExceptionType.connectionError
          ? "Network Error"
          : error.type == DioExceptionType.connectionTimeout
              ? "Time Out"
              : "Something went wrong: $error";
      Get.snackbar("Error", errorMessage);
    } catch (error) {
      Get.snackbar("Error", "$error");
    }
  }

  final Rx<String> name = ''.obs;
  final Rx<String> email = ''.obs;
  final Rx<String> number = ''.obs;
  final Rx<String> address = ''.obs;
  final Rx<String> image = ''.obs;
  final Rx<File?> selectedImage = Rx<File?>(null);
  Rx<BooksModel?> booksModel = Rx<BooksModel?>(null);

  // Fetch data from Firestore
  Future<void> fetchData() async {
    final QuerySnapshot snapshot = await firestore.collection('empData').get();
    data.value =
        snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  // Add data to Firestore
  Future<void> addData() async {
    String? imageUrl;
    if (selectedImage.value != null) {
      imageUrl = await _imageToBase64(selectedImage.value!);
    }

    await firestore.collection('empData').add({
      'name': name.value,
      'email': email.value,
      'number': number.value,
      'address': address.value,
      'image': imageUrl,
    });
    clearForm();
    fetchData();
    update(['data']);
  }

  // Update data in Firestore
  Future<void> updateData(Map<String, dynamic> data) async {
    String? imageUrl;
    if (selectedImage.value != null) {
      imageUrl = await _imageToBase64(selectedImage.value!);
    }

    await firestore.collection('empData').doc(data['id']).update({
      'name': name.value,
      'email': email.value,
      'number': number.value,
      'address': address.value,
      'image': imageUrl,
    });
    clearForm();
    fetchData();
    update(['data']);
  }

  // Delete data from Firestore
  Future<void> deleteData(Map<String, dynamic> data) async {
    await firestore.collection('users').doc(data['id']).delete();
    fetchData();
  }

  // Clear form fields
  void clearForm() {
    name.value = '';
    email.value = '';
    number.value = '';
    address.value = '';
    image.value = '';
    selectedImage.value = null;
  }

  // Select image from camera or gallery
  Future<void> selectImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      selectedImage.value = File(pickedFile.path);
    }
    update(['data']);
  }

  Future<String> _imageToBase64(File imageFile) async {
    List<int> imageBytes = await imageFile.readAsBytes();
    String base64Image = base64Encode(imageBytes);
    return base64Image;
  }

  TextEditingController searchController = TextEditingController();
  RxString searchTerm = ''.obs;
  void updateSearchTerm(String term) {
    searchTerm.value = term.toLowerCase();
    update(['book']);
    // Convert to lowercase for case-insensitive search
  }

  Future<void> getBookData() async {
    loading.value = true;
    try {
      final response = await Dio().get(
        "https://www.googleapis.com/books/v1/volumes?q=fiction&maxResults=40",
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        booksModel.value = booksModelFromJson(json.encode(response.data));
      } else {
        Get.snackbar("Invalid Data", "Failed to fetch the book data");
      }
    } on DioException catch (error) {
      String errorMessage = '';
      if (error.type == DioExceptionType.connectionError) {
        errorMessage = "Network Error";
      } else if (error.type == DioExceptionType.connectionTimeout) {
        errorMessage = "Time Out";
      } else {
        errorMessage = "Something went wrong: ${error.toString()}";
      }

      Get.snackbar("Error", errorMessage);
    } catch (error) {
      Get.snackbar("Error", error.toString());
    } finally {
      loading.value = false;
    }
  }
}
