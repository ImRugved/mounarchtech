import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mounarch/Constant/const_colors.dart';
import 'package:mounarch/Constant/const_textTheme.dart';
import 'package:mounarch/Screen/Home_Screen/Controller/home_controller.dart';

class SecondScreen extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());

  SecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Book Management',
          style: getTextTheme().bodyLarge,
        ),
        backgroundColor: Colors.blue,
      ),
      body: Obx(() => controller.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    _buildAddBookForm(),
                    const SizedBox(height: 20),
                    controller.books.isEmpty ? SizedBox() : _buildSearchBar(),
                    _buildBooksList(),
                  ],
                ),
              ),
            )),
    );
  }

  Widget _buildSearchBar() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: controller.booksearchController,
          decoration: InputDecoration(
            hintText: 'Search by book name or author...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: Obx(() => controller.isSearching.value
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      controller.booksearchController.clear();
                      controller.searchBooks('');
                    },
                  )
                : const SizedBox.shrink()),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onChanged: (value) => controller.searchBooks(value),
        ),
      ),
    );
  }

  Widget _buildAddBookForm() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Add/Update Book', style: getTextTheme().headlineLarge),
            const SizedBox(height: 16),
            _buildImagePicker(),
            const SizedBox(height: 16),
            TextField(
              controller: controller.bookNameController,
              decoration: const InputDecoration(
                labelText: 'Book Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.book),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.authorNameController,
              decoration: const InputDecoration(
                labelText: 'Author Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.bookPriceController,
              decoration: const InputDecoration(
                labelText: 'Price',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                if (controller.selectedImage.value != null) {
                  controller.addBook();
                } else {
                  Get.snackbar(
                    'Error',
                    'Please select an image for the book',
                    backgroundColor: ConstColors.red,
                    colorText: ConstColors.white,
                  );
                }
              },
              icon: const Icon(Icons.add),
              label: Text(
                'Add Book',
                style: getTextTheme().displayMedium,
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Obx(() {
      return Column(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: controller.selectedImage.value != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      controller.selectedImage.value!,
                      fit: BoxFit.cover,
                    ),
                  )
                : controller.currentImageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: controller.currentImageUrl.value,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) => const Center(
                            child: Icon(Icons.error, size: 50),
                          ),
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.add_photo_alternate, size: 50),
                      ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: controller.pickImage,
            icon: const Icon(Icons.camera_alt),
            label: Text(
              controller.selectedImage.value == null &&
                      controller.currentImageUrl.isEmpty
                  ? 'Select Image'
                  : 'Change Image',
              style: getTextTheme().displayMedium,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildBooksList() {
    return Obx(() {
      final displayedBooks = controller.isSearching.value
          ? controller.filteredBooks
          : controller.books;

      if (controller.isSearching.value && displayedBooks.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'No books found matching your search',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }

      if (displayedBooks.isEmpty) {
        return Center(
          child: Column(
            children: [
              const Icon(Icons.library_books, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'No books added yet',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: displayedBooks.length,
        itemBuilder: (context, index) {
          final book = displayedBooks[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(8),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: book['imageUrl'] != null
                    ? CachedNetworkImage(
                        imageUrl: book['imageUrl'],
                        width: 60,
                        height: 80,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 60,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 60,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(Icons.error),
                        ),
                      )
                    : Container(
                        width: 60,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.book),
                      ),
              ),
              title: Text(
                "Book Name: ${book['bookname'] ?? ""}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    'Author: ${book['author'] ?? ''}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  Text(
                    'Price: \$${book['bookprice'] ?? ''}',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showEditDialog(book),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteDialog(book['bookId']),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  void _showEditDialog(Map<String, dynamic> book) {
    controller.editBookData(book);
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              TextField(
                controller: controller.bookNameController,
                decoration: const InputDecoration(labelText: 'Book Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller.authorNameController,
                decoration: const InputDecoration(labelText: 'Author'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller.bookPriceController,
                decoration: const InputDecoration(labelText: 'Price'),
              ),
              const SizedBox(height: 16),
              _buildImagePicker(),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (controller.selectedImage.value != null) {
                    controller.updateBook(book['bookId']);
                  } else {
                    Get.snackbar(
                      'Error',
                      'Please select an image for the book',
                      backgroundColor: ConstColors.red,
                      colorText: ConstColors.white,
                    );
                  }
                  Get.back();
                },
                child: const Text('Update Book'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(String bookId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this book?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.deleteBook(bookId);
              Get.back();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
