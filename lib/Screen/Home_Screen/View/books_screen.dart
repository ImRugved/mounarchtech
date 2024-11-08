import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mounarch/Constant/const_colors.dart';
import 'package:mounarch/Screen/Home_Screen/Controller/home_controller.dart';
import 'package:mounarch/Screen/Home_Screen/Model/books_model.dart';
import 'package:shimmer/shimmer.dart';

class BooksScreen extends StatelessWidget {
  const BooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
      id: 'home',
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: _buildAppBar(controller),
          body: _buildBody(controller),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(HomeController controller) {
    return AppBar(
      title: const Text(
        'Bookstore',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(60.sp),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
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
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(HomeController controller) {
    return Obx(() {
      if (controller.loading.value && controller.booksModel.value == null) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.booksModel.value == null) {
        return _buildErrorState();
      }

      final filteredBooks = _getFilteredBooks(controller);

      if (filteredBooks.isEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        backgroundColor: ConstColors.primary,
        color: ConstColors.white,
        onRefresh: controller.handlerefresh,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
          itemCount: filteredBooks.length,
          itemBuilder: (context, index) {
            final item = filteredBooks[index];
            return Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: BookItem(item: item),
            );
          },
        ),
      );
    });
  }

  List<Item> _getFilteredBooks(HomeController controller) {
    return controller.booksModel.value!.items!.where((item) {
      final title = item.volumeInfo?.title?.toLowerCase() ?? '';
      final authors = item.volumeInfo?.authors?.join(', ').toLowerCase() ?? '';
      final searchTerm = controller.searchTerm.value;

      return title.contains(searchTerm) || authors.contains(searchTerm);
    }).toList();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 50.sp, color: Colors.grey),
          SizedBox(height: 10.h),
          const Text(
            'No matching books found',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 50.sp, color: Colors.red),
          SizedBox(height: 10.h),
          const Text(
            'Failed to load books',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          SizedBox(height: 20.h),
          ElevatedButton(
            onPressed: () => Get.find<HomeController>().getBookData(),
            child: const Text('Retry'),
          ),
        ],
      ),
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
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBookImage(),
                SizedBox(width: 12.w),
                Expanded(child: _buildBookInfo()),
              ],
            ),
            if (widget.item.volumeInfo?.description != null) ...[
              SizedBox(height: 8.h),
              _buildDescription(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBookImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: widget.item.volumeInfo?.imageLinks?.thumbnail != null
          ? CachedNetworkImage(
              imageUrl: widget.item.volumeInfo!.imageLinks!.thumbnail!,
              placeholder: (context, url) => _buildImageShimmer(),
              errorWidget: (context, url, error) => _buildImageError(),
              height: 120.sp,
              width: 80.sp,
              fit: BoxFit.cover,
            )
          : _buildImageError(),
    );
  }

  Widget _buildImageShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 120.sp,
        width: 80.sp,
        color: Colors.white,
      ),
    );
  }

  Widget _buildImageError() {
    return Container(
      height: 120.sp,
      width: 80.sp,
      color: Colors.grey[200],
      child: Icon(Icons.image_not_supported, color: Colors.grey[400]),
    );
  }

  Widget _buildBookInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.item.volumeInfo?.title ?? 'Unknown Title',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 4.h),
        if (widget.item.volumeInfo?.authors?.isNotEmpty ?? false) ...[
          Text(
            'By ${widget.item.volumeInfo!.authors!.join(", ")}',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
        ],
        if (widget.item.volumeInfo?.categories?.isNotEmpty ?? false)
          Text(
            widget.item.volumeInfo!.categories!.first,
            style: TextStyle(
              fontSize: 12.sp,
              color: ConstColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        SizedBox(height: 4.h),
        if (widget.item.volumeInfo?.publishedDate != null)
          Text(
            'Published: ${DateFormat.yMMMd().format(widget.item.volumeInfo!.publishedDate!)}',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
            ),
          ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Row(
          children: [
            Expanded(
              child: Text(
                widget.item.volumeInfo!.description!,
                maxLines: _isDescriptionExpanded ? null : 3,
                overflow: _isDescriptionExpanded
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey[800],
                  height: 1.4,
                ),
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
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                size: 20.sp,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ],
    );
  }
}
