import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mounarch/Constant/const_colors.dart';
import 'package:mounarch/Constant/const_textTheme.dart';
import 'package:mounarch/Constant/toast.dart';

class LoginController extends GetxController {
  final GetStorage box = GetStorage();
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final passController1 = TextEditingController();
  final numberController = TextEditingController();
  final userNameController = TextEditingController();
  RxBool loading = false.obs;
  RxBool isVisible1 = false.obs;
  RxBool isVisible2 = false.obs;
  RxBool isVisible = false.obs;
  RxBool signupLoading = false.obs;
  final Rx<File?> profileImage = Rx<File?>(null);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final users = FirebaseFirestore.instance.collection('userData').obs;

  Future<void> takeProfilePicture() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (photo != null) {
        profileImage.value = File(photo.path);
        update(['profileImage', 'signUp']);
        Get.snackbar(
          'Success',
          'Photo captured successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar('User Alert', 'Error taking photo',
          backgroundColor: ConstColors.red,
          colorText: ConstColors.white,
          snackPosition: SnackPosition.TOP);
    }
  }

  Future<String> uploadImageToFirebase(File imageFile) async {
    String fileName =
        'profile_images/${DateTime.now().millisecondsSinceEpoch}.jpg';
    Reference storageRef = FirebaseStorage.instance.ref().child(fileName);

    UploadTask uploadTask = storageRef.putFile(imageFile);

    TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
    var url = await snapshot.ref.getDownloadURL();
    log('url is $url');
    return url;
  }

  void signUp(
    BuildContext context,
    String email,
    String password,
  ) async {
    if (profileImage.value == null) {
      Get.snackbar('User Alert', 'Please select a profile picture',
          backgroundColor: ConstColors.red,
          colorText: ConstColors.white,
          snackPosition: SnackPosition.TOP);
      return;
    }

    signupLoading.value = true;
    update(['signUp']);

    // Check if user already exists
    final existingUser =
        await users.value.where("email", isEqualTo: email).get();
    if (existingUser.docs.isNotEmpty) {
      signupLoading.value = false;
      update(['signUp']);
      Get.snackbar('User Alert', 'User already exists',
          backgroundColor: ConstColors.red,
          colorText: ConstColors.white,
          snackPosition: SnackPosition.TOP);

      return;
    }

    // Create user in Firebase Auth
    _auth
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((value) async {
      log('emal and passwrd is $email , $password');
      String uid = await _getNextUserId();

      // Upload profile image to Firebase Storage and get the URL
      String imageUrl = await uploadImageToFirebase(profileImage.value!);

      // Insert user data into Firestore with image URL
      await users.value.doc(value.user!.uid).set({
        "userName": userNameController.text.trim(),
        "userId": uid,
        "email": email,
        "number": numberController.text.trim(),
        "profilePicUrl": imageUrl, // Use the Firebase Storage URL
        "signUpTime": DateFormat('hh:mm:ss a').format(DateTime.now()),
        "signUpDate": DateFormat('dd-MMM-yyyy').format(DateTime.now()),
      }).then(
        (value) {
          signupLoading.value = false;
          update(['signUp']);
        },
      ).onError(
        (error, stackTrace) {
          signupLoading.value = false;
          update(['signUp']);
        },
      );
      Get.snackbar('Signup Successful', 'Please login',
          backgroundColor: ConstColors.green,
          colorText: ConstColors.white,
          snackPosition: SnackPosition.TOP);

      clearForm();

      Get.toNamed('/login_screen');
      signupLoading.value = false;
      update(['signUp']);
    }).onError((error, stackTrace) {
      clearForm();

      String errorMessage = parseFirebaseAuthError(error);
      log("signup erre i $errorMessage");
      signupLoading.value = false;
      update(['signUp']);
      Get.snackbar('Error', errorMessage,
          backgroundColor: ConstColors.red,
          colorText: ConstColors.white,
          snackPosition: SnackPosition.TOP);
    }).whenComplete(() {
      clearForm();
      signupLoading.value = false;
      update(['signUp']);
    });
  }

  void clearForm() {
    userNameController.clear();
    numberController.clear();
    passController.clear();
    passController1.clear();
    numberController.clear();
    profileImage.value = null;
  }

  // Method to sign up the user
  // void signUp(BuildContext context, String email, String password,
  //     String userName) async {
  //   signupLoading.value = true;
  //   update(['signUp']);
  //   // Check if user already exists
  //   final existingUser =
  //       await users.value.where("email", isEqualTo: email).get();
  //   if (existingUser.docs.isNotEmpty) {
  //     signupLoading.value = false;
  //     update(['signUp']);
  //     Get.snackbar('Error', 'User already exists',
  //         snackPosition: SnackPosition.TOP);
  //     return;
  //   }
  //   _auth
  //       .createUserWithEmailAndPassword(email: email, password: password)
  //       .then((value) async {
  //     String uid = await _getNextUserId();
  //     await users.value.doc(value.user!.uid).set({
  //       "userName": userNameController.text,
  //       "userId": uid,
  //       "email": email,
  //       "number": numberController.text,
  //       "signUpTime": DateFormat('hh:mm:ss a').format(DateTime.now()),
  //       "signUpDate": DateFormat('dd-MMM-yyyy').format(DateTime.now()),
  //     });
  //     Toast().toastMessage(
  //       message: "Signup Successful",
  //       bgColor: ConstColors.green,
  //       textColor: ConstColors.white,
  //       textsize: 12.sp,
  //     );
  //     userNameController.clear();
  //     passController.clear();
  //     passController1.clear();
  //     numberController.clear();
  //     Get.toNamed('/login_screen');
  //     signupLoading.value = false;
  //     update(['signUp']);
  //   }).onError((error, stackTrace) {
  //     String errorMessage = parseFirebaseAuthError(error);
  //     Toast().toastMessage(
  //       message: errorMessage,
  //       bgColor: ConstColors.red,
  //       textColor: ConstColors.white,
  //       textsize: 12.sp,
  //     );
  //     signupLoading.value = false;
  //     update(['signUp']);
  //   });
  // }
  void resetPassword() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Reset Password'),
        content: const Text('Enter your email id to get reset link'),
        actions: [
          TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email id';
              }
              return null;
            },
            controller: emailController,
            decoration: const InputDecoration(hintText: 'Enter email'),
          ),
          const SizedBox(
            height: 8,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (emailController.text != '') {
                    forgotloign(emailController.text);

                    Get.back();
                  } else {
                    Get.snackbar('User Alert', 'Please enter email',
                        backgroundColor: ConstColors.red,
                        colorText: ConstColors.white,
                        snackPosition: SnackPosition.TOP);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: Text(
                  'Send',
                  style: getTextTheme().bodyMedium,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  void forgotloign(String email) {
    _auth.sendPasswordResetEmail(email: email).then((value) {
      emailController.clear();
      Get.back();
      Get.snackbar('User Alert', 'Sent email to reset password',
          backgroundColor: ConstColors.green,
          colorText: ConstColors.white,
          snackPosition: SnackPosition.TOP);
      //Get.toNamed('/login_screen');
    }).onError((error, stackTrace) {
      Get.snackbar('Error', error.toString(), snackPosition: SnackPosition.TOP);
    });
  }

  // Method to get the next available user ID
  Future<String> _getNextUserId() async {
    final querySnapshot =
        await users.value.orderBy("userId", descending: true).limit(1).get();

    if (querySnapshot.docs.isNotEmpty) {
      // Convert userId to int, increment, then convert back to String
      int nextUserId = int.parse(querySnapshot.docs.first["userId"]) + 1;
      return nextUserId.toString();
    } else {
      return '1'; // Start user ID from 1 if there are no users
    }
  }

  // Method to log in the user
  void emailLogin(BuildContext context, String email, String password) async {
    loading.value = true;
    update(['login']);

    try {
      // Attempt to sign in with email and password
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if the user is not null
      if (userCredential.user != null) {
        final userDoc = await users.value.doc(userCredential.user!.uid).get();

        if (userDoc.exists) {
          // Fetch and store user data
          await box.write('login', 'login');
          await box.write('userName', userDoc["userName"]);
          await box.write('userId', userDoc["userId"]);

          log("Username is : ${box.read('userName')}, UserId is : ${box.read('userId')}");
          Get.snackbar('Login Successful', 'Welcome to my app',
              backgroundColor: ConstColors.green,
              colorText: ConstColors.white,
              snackPosition: SnackPosition.TOP);

          clearForm();
          Get.offAllNamed('/dash_screen');
        } else {
          Get.snackbar('Error', 'User data not found',
              backgroundColor: ConstColors.red,
              colorText: ConstColors.white,
              snackPosition: SnackPosition.TOP);
        }
      } else {
        Get.snackbar('Error', 'User not found',
            backgroundColor: ConstColors.red,
            colorText: ConstColors.white,
            snackPosition: SnackPosition.TOP);
      }
    } on FirebaseAuthException catch (e) {
      String errror = '';
      // Handle specific Firebase authentication errors
      String errorMessage = parseFirebaseAuthError(e.code);
      if (errorMessage == "invalid-credential") {
        errror = 'Invalid email or password';
      }
      Get.snackbar('User Alert', errorMessage,
          backgroundColor: ConstColors.red,
          colorText: ConstColors.white,
          snackPosition: SnackPosition.TOP);

      log('Email login error: $errorMessage');
    } catch (e) {
      String errror = '';
      if (e == "invalid-credential") {
        errror = 'Invalid email or password';
      }
      // Handle any other errors
      Get.snackbar('Error', errror,
          backgroundColor: ConstColors.red,
          colorText: ConstColors.white,
          snackPosition: SnackPosition.TOP);

      log('Email login error: $e');
    } finally {
      loading.value = false; // Ensure loading is false at the end
    }
  }

  // Method to parse Firebase Auth errors
  String parseFirebaseAuthError(error) {
    String errorMessage = error.toString();
    if (errorMessage.contains('] ')) {
      return errorMessage.split('] ')[1];
    } else {
      return errorMessage;
    }
  }

  // Other existing methods remain the same...
}
