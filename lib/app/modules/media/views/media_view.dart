import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/bottom_nav_bar.dart';
import '../../../routes/app_pages.dart';
import '../controllers/media_controller.dart';

class MediaView extends GetView<MediaController> {
  const MediaView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    SizedBox(height: 24.h),
                    _buildFilterTabs(),
                    SizedBox(height: 24.h),
                    // _buildSectionHeader('Albums'), // Optional: Header for the grid
                    // SizedBox(height: 16.h),
                    _buildRecentGrid(),
                  ],
                ),
              ),
            ),
            const AppBottomNavBar(currentRoute: Routes.media),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          'Media Gallery',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTabs() {
    return Obx(() {
      final filters = ['All'];
      if (controller.categories.isNotEmpty) {
        filters.addAll(controller.categories.map((c) => c.title));
      }

      return Container(
        height: 40.h,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
        ),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          itemCount: filters.length,
          separatorBuilder: (context, index) => SizedBox(width: 24.w),
          itemBuilder: (context, index) {
            final filter = filters[index];
            return Obx(() {
              final isSelected = controller.selectedFilter.value == filter;
              final photoCount = controller.getCategoryPhotoCount(filter);

              // Build display text with count
              String displayText = filter;
              if (filter == 'All') {
                displayText = 'All Albums';
              }
              if (photoCount > 0 && filter != 'All') {
                displayText = '$filter $photoCount';
              }

              return GestureDetector(
                onTap: () => controller.selectedFilter.value = filter,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  decoration: BoxDecoration(
                    border: isSelected
                        ? Border(
                            bottom: BorderSide(
                              color: AppTheme.primary,
                              width: 2.h,
                            ),
                          )
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    displayText,
                    style: TextStyle(
                      color: isSelected
                          ? AppTheme.primary
                          : AppTheme.textSecondary,
                      fontSize: 16.sp,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            });
          },
        ),
      );
    });
  }

  Widget _buildRecentGrid() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final albums = controller.filteredAlbums;

      if (albums.isEmpty) {
        return const Center(
          child: Text("No albums found", style: TextStyle(color: Colors.white)),
        );
      }

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.w,
          mainAxisSpacing: 16.h,
          childAspectRatio: 0.75,
        ),
        itemCount: albums.length,
        itemBuilder: (context, index) {
          final item = albums[index];
          return GestureDetector(
            onTap: () {
              Get.toNamed(
                Routes.albumDetail,
                arguments: {'id': item.id, 'title': item.title},
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.r),
                          image: DecorationImage(
                            image: NetworkImage(
                              item.coverImage ??
                                  'https://via.placeholder.com/300',
                            ),
                            fit: BoxFit.cover,
                            onError: (e, s) => const AssetImage(
                              'assets/images/placeholder.png',
                            ),
                          ),
                        ),
                      ),
                      if (item.itemCount != null)
                        Positioned(
                          right: 8.w,
                          bottom: 8.h,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              '${item.itemCount} Photos',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  item.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  item.date,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }
}
