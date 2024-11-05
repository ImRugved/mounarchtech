import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mounarch/Constant/const_colors.dart';
import 'package:mounarch/Constant/const_textTheme.dart';
import 'package:mounarch/Screen/Home_Screen/Controller/home_controller.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News APi'),
      ),
      body: GetBuilder(
          init: HomeController(),
          id: 'news',
          builder: (ctrl) {
            return ctrl.loading.value
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: ctrl.newsList.length,
                    itemBuilder: (context, index) {
                      final article = ctrl.newsList[index];
                      return Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 15.w, vertical: 15.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (article.urlToImage != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  article.urlToImage!,
                                  fit: BoxFit.cover,
                                  height: 200,
                                  width: double.infinity,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: SizedBox(
                                          height: 18.h,
                                          width: 20.w,
                                          child: CircularProgressIndicator()),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Icon(
                                        Icons.image_not_supported,
                                        size: 48.0,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            const SizedBox(height: 16.0),
                            Text(
                              article.title ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            if (article.author != null)
                              Text(
                                'By ${article.author!}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14.0,
                                ),
                              ),
                            const SizedBox(height: 8.0),
                            Text(
                              article.description ?? '',
                              style: const TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              'Published: ${DateFormat('yyyy-MM-dd HH:mm').format(article.publishedAt!)}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14.0,
                              ),
                            ),
                            Divider(
                              color: ConstColors.primary,
                            )
                          ],
                        ),
                      );
                    },
                  );
          }),
    );
  }
}
