import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mounarch/Constant/const_colors.dart';
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
  final GetStorage storage = GetStorage();
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
    fetchAndStoreUserData();
    getBookData();
    getTodoData();
  }

  Future<void> handlerefresh() async {
    log('in handle refresh');
    await Future.delayed(const Duration(milliseconds: 1000));
    getBookData();
  }

  void getAll() async {
    userId.value = await box.read('userId');
    log('user id is ${userId.value}');
  }

  // Method to fetch user data by UID
  Future<void> fetchAndStoreUserData() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        final DocumentSnapshot doc = await db.doc(currentUser.uid).get();

        if (doc.exists) {
          final userData = doc.data() as Map<String, dynamic>;
          storage.write('userData', userData);
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Map<String, dynamic>? getStoredUserData() {
    return storage.read('userData');
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

  Rx<BooksModel?> booksModel = Rx<BooksModel?>(null);

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

  final bookNameController = TextEditingController();
  final authorNameController = TextEditingController();
  final bookPriceController = TextEditingController();
  final _storage = FirebaseStorage.instance;
  final Rx<File?> selectedImage = Rx<File?>(null);
  final currentImageUrl = RxString('');
  final RxList<Map<String, dynamic>> filteredBooks =
      <Map<String, dynamic>>[].obs;
  final RxBool isSearching = false.obs;
  final RxList<Map<String, dynamic>> books = <Map<String, dynamic>>[].obs;
  String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final booksearchController = TextEditingController();
  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (photo != null) {
        selectedImage.value = File(photo.path);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<String?> uploadImageToStorage(File imageFile) async {
    try {
      String fileName = 'books/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef = _storage.ref().child(fileName);

      if (currentImageUrl.isNotEmpty) {
        try {
          await _storage.refFromURL(currentImageUrl.value).delete();
        } catch (e) {
          log('Error deleting old image: $e');
        }
      }

      // Upload new image
      UploadTask uploadTask = storageRef.putFile(imageFile);

      // Show upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress =
            (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        print('Upload progress: $progress%');
      });

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload image: $e');
      return null;
    }
  }

  void searchBooks(String query) {
    if (query.isEmpty) {
      filteredBooks.clear();
      isSearching.value = false;
      return;
    }

    isSearching.value = true;
    query = query.toLowerCase();

    filteredBooks.value = books.where((book) {
      final bookName = (book['bookname'] ?? '').toString().toLowerCase();
      final authorName = (book['author'] ?? '').toString().toLowerCase();
      return bookName.contains(query) || authorName.contains(query);
    }).toList();
  }

  Future<void> addBook() async {
    if (currentUserId == null) {
      Get.snackbar('Error', 'Please login first');
      return;
    }

    if (!validateInputs()) return;

    try {
      isLoading.value = true;
      String? imageUrl;

      // Upload image if selected
      if (selectedImage.value != null) {
        imageUrl = await uploadImageToStorage(selectedImage.value!);
        if (imageUrl == null) {
          Get.snackbar('Error', 'Failed to upload image');
          isLoading.value = false;
          return;
        }
      }

      String bookId = DateTime.now().millisecondsSinceEpoch.toString();

      await _database
          .ref()
          .child('books')
          .child(currentUserId!)
          .child(bookId)
          .set({
        'bookname': bookNameController.text.trim(),
        'author': authorNameController.text.trim(),
        'bookprice': bookPriceController.text.trim(),
        'imageUrl': imageUrl,
        'bookId': bookId,
        'createdAt': ServerValue.timestamp,
      });

      clearForm();
      fetchBooks();
      Get.snackbar('Success', 'Book added successfully',
          backgroundColor: ConstColors.green, colorText: ConstColors.white);
    } catch (e) {
      log('send error is $e');
      Get.snackbar('Error', 'Failed to add book: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateBook(String bookId) async {
    if (currentUserId == null) return;
    if (!validateInputs()) return;

    try {
      isLoading.value = true;
      String? newImageUrl;

      if (selectedImage.value != null) {
        newImageUrl = await uploadImageToStorage(selectedImage.value!);
        if (newImageUrl == null) {
          Get.snackbar('Error', 'Failed to upload new image');
          isLoading.value = false;
          return;
        }
      }

      Map<String, dynamic> updates = {
        'bookname': bookNameController.text.trim(),
        'author': authorNameController.text.trim(),
        'bookprice': bookPriceController.text.trim(),
        'updatedAt': ServerValue.timestamp,
      };

      if (newImageUrl != null) {
        updates['imageUrl'] = newImageUrl;
      }

      await _database
          .ref()
          .child('books')
          .child(currentUserId!)
          .child(bookId)
          .update(updates);

      Get.snackbar('Success', 'Book updated successfully',
          backgroundColor: ConstColors.green, colorText: ConstColors.white);
      clearForm();
    } catch (e) {
      Get.snackbar('Error', 'Failed to update book: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteBook(String bookId) async {
    if (currentUserId == null) return;

    try {
      isLoading.value = true;

      DatabaseEvent event = await _database
          .ref()
          .child('books')
          .child(currentUserId!)
          .child(bookId)
          .once();

      dynamic bookData = event.snapshot.value;
      if (bookData is Map<Object?, Object?>) {
        Map<String, dynamic> bookDataMap = Map<String, dynamic>.from(bookData);

        if (bookDataMap['imageUrl'] != null) {
          try {
            await _storage.refFromURL(bookDataMap['imageUrl']).delete();
          } catch (e) {
            print('Error deleting image: $e');
          }
        }

        // Delete the book data from realtime database
        await _database
            .ref()
            .child('books')
            .child(currentUserId!)
            .child(bookId)
            .remove();

        Get.snackbar('Success', 'Book deleted successfully',
            backgroundColor: ConstColors.green, colorText: ConstColors.white);
      } else {
        Get.snackbar('Error', 'Failed to get book data');
      }
    } catch (e) {
      log('deleteel erroe is $e');
      Get.snackbar('Error', 'Failed to delete book: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void fetchBooks() {
    if (currentUserId == null) return;

    _database.ref().child('books').child(currentUserId!).onValue.listen(
        (event) {
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        final booksList = <Map<String, dynamic>>[];

        data.forEach((key, value) {
          final book = Map<String, dynamic>.from(value);
          book['bookId'] = key;
          booksList.add(book);
        });

        booksList.sort(
            (a, b) => (b['createdAt'] ?? 0).compareTo(a['createdAt'] ?? 0));

        books.value = booksList;
      } else {
        books.clear();
      }
    }, onError: (error) {
      Get.snackbar('Error', 'Failed to fetch books: $error');
    });
    update(['book']);
  }

  void editBookData(Map<String, dynamic> book) {
    bookNameController.text = book['bookname'] ?? '';
    authorNameController.text = book['author'] ?? '';
    bookPriceController.text = book['bookprice'] ?? '';
    currentImageUrl.value = book['imageUrl'] ?? '';
    selectedImage.value = null; // Reset selected image
  }

  bool validateInputs() {
    if (bookNameController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter book name',
        backgroundColor: ConstColors.red,
        colorText: ConstColors.white,
      );
      return false;
    }
    if (authorNameController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter author name',
        backgroundColor: ConstColors.red,
        colorText: ConstColors.white,
      );
      return false;
    }
    if (bookPriceController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter book price',
        backgroundColor: ConstColors.red,
        colorText: ConstColors.white,
      );
      return false;
    }
    return true;
  }

  void clearForm() {
    bookNameController.clear();
    authorNameController.clear();
    bookPriceController.clear();
    selectedImage.value = null;
    currentImageUrl.value = '';
  }
}
