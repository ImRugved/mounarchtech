import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mounarch/Screen/Home_Screen/Controller/home_controller.dart';
import 'package:mounarch/Screen/Home_Screen/Model/books_model.dart';

class BooksScreen extends StatelessWidget {
  const BooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
      id: 'home',
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Bookstore'),
            actions: [
              IconButton(
                onPressed: () {
                  controller.signOut();
                },
                icon: const Icon(Icons.logout),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: controller.searchController,
                  onChanged: (value) => controller.updateSearchTerm(value),
                  decoration: InputDecoration(
                    hintText: 'Search by title or author...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          body: Obx(
            () {
              if (controller.loading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.booksModel.value == null) {
                return const Center(child: Text('No books found'));
              }

              // Filter books based on search term
              final filteredBooks =
                  controller.booksModel.value!.items!.where((item) {
                final title = item.volumeInfo?.title?.toLowerCase() ?? '';
                final authors =
                    item.volumeInfo?.authors?.join(', ').toLowerCase() ?? '';
                final searchTerm = controller.searchTerm.value;

                return title.contains(searchTerm) ||
                    authors.contains(searchTerm);
              }).toList();

              return filteredBooks.isEmpty
                  ? const Center(child: Text('No matching books found'))
                  : ListView.builder(
                      itemCount: filteredBooks.length,
                      itemBuilder: (context, index) {
                        final item = filteredBooks[index];
                        return BookItem(item: item);
                      },
                    );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: controller.getBookData,
            child: const Icon(Icons.refresh),
          ),
        );
      },
    );
  }
}

class BookItem extends StatefulWidget {
  final Item item;

  const BookItem({super.key, required this.item});

  @override
  State<BookItem> createState() => _BookItemState();
}

class _BookItemState extends State<BookItem> {
  bool _isDescriptionExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.item.volumeInfo?.imageLinks?.thumbnail != null)
                  CachedNetworkImage(
                    imageUrl: widget.item.volumeInfo!.imageLinks!.thumbnail!,
                    placeholder: (context, url) => SizedBox(
                        height: 20.h,
                        width: 21.w,
                        child: const CircularProgressIndicator()),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                    height: 80.sp,
                    width: 50.sp,
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.volumeInfo?.title ?? '',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        softWrap:
                            true, // Allows the text to wrap if it's too long
                        overflow: TextOverflow
                            .ellipsis, // Optionally, show ellipsis if the text is too long to fit
                      ),
                      const SizedBox(height: 4),
                      if (widget.item.volumeInfo?.subtitle != null)
                        Text(
                          'Subtitle: ${widget.item.volumeInfo!.subtitle!}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      const SizedBox(height: 5),
                      if (widget.item.volumeInfo?.authors?.isNotEmpty ?? false)
                        Text(
                          'Authors: ${widget.item.volumeInfo!.authors!.join(', ')}',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      if (widget.item.volumeInfo?.publishedDate != null)
                        Text(
                          'Published: ${DateFormat.yMMMd().format(widget.item.volumeInfo!.publishedDate!)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.item.volumeInfo?.description ?? '',
                    maxLines: _isDescriptionExpanded ? null : 3,
                    overflow: _isDescriptionExpanded
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isDescriptionExpanded = !_isDescriptionExpanded;
                    });
                  },
                  icon: Icon(
                    _isDescriptionExpanded
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    size: 18,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
