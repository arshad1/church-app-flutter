import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/bottom_nav_bar.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../routes/app_pages.dart';
import '../controllers/media_controller.dart';

class MediaView extends GetView<MediaController> {
  const MediaView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: AppBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  color: AppTheme.primary,
                  backgroundColor: AppTheme.surface,
                  onRefresh: controller.fetchGalleryContent,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeSlideIn(child: _buildHeader()),
                        SizedBox(height: 18.h),
                        FadeSlideIn(index: 1, child: _buildFilterTabs()),
                        SizedBox(height: 20.h),
                        _buildRecentGrid(),
                      ],
                    ),
                  ),
                ),
              ),
              const AppBottomNavBar(currentRoute: Routes.media),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Media Gallery', style: AppTheme.heading(fontSize: 30.sp)),
              SizedBox(height: 4.h),
              Text(
                'Moments from our church family',
                style: AppTheme.body(
                  fontSize: 13.sp,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Obx(() {
          final total = controller.getCategoryPhotoCount('All');
          if (total == 0) return const SizedBox.shrink();
          return PillLabel(
            text: '$total PHOTOS',
            icon: Icons.photo_camera_outlined,
          );
        }),
      ],
    );
  }

  Widget _buildFilterTabs() {
    return Obx(() {
      final filters = ['All'];
      if (controller.categories.isNotEmpty) {
        filters.addAll(controller.categories.map((c) => c.title));
      }

      return SizedBox(
        height: 42.h,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: filters.length,
          separatorBuilder: (context, index) => SizedBox(width: 10.w),
          itemBuilder: (context, index) {
            final filter = filters[index];
            return Obx(() {
              final isSelected = controller.selectedFilter.value == filter;
              final photoCount = controller.getCategoryPhotoCount(filter);
              final label = filter == 'All' ? 'All Albums' : filter;

              return PressableScale(
                onTap: () => controller.selectedFilter.value = filter,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppTheme.primaryGradient : null,
                    color: isSelected ? null : AppTheme.glass,
                    borderRadius: BorderRadius.circular(30.r),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : AppTheme.glassBorder,
                    ),
                    boxShadow: isSelected ? AppTheme.glow() : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: AppTheme.body(
                          fontSize: 13.sp,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : AppTheme.textSecondary,
                        ),
                      ),
                      if (photoCount > 0 && filter != 'All') ...[
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 7.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.25)
                                : AppTheme.accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            '$photoCount',
                            style: AppTheme.body(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.accent,
                            ),
                          ),
                        ),
                      ],
                    ],
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
        return const AppLoader();
      }

      final albums = controller.filteredAlbums;

      if (albums.isEmpty) {
        return const EmptyState(
          icon: Icons.photo_album_outlined,
          message: 'No albums found',
        );
      }

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14.w,
          mainAxisSpacing: 14.h,
          childAspectRatio: 0.72,
        ),
        itemCount: albums.length,
        itemBuilder: (context, index) {
          final item = albums[index];
          return FadeSlideIn(
            key: ValueKey('${controller.selectedFilter.value}-${item.id}'),
            index: index,
            child: PressableScale(
              onTap: () {
                Get.toNamed(
                  Routes.albumDetail,
                  arguments: {'id': item.id, 'title': item.title},
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(22.r),
                  border: Border.all(color: AppTheme.glassBorder),
                  image: item.coverImage != null
                      ? DecorationImage(
                          image: NetworkImage(item.coverImage!),
                          fit: BoxFit.cover,
                          onError: (e, s) {},
                        )
                      : null,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22.r),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppTheme.background.withValues(alpha: 0.95),
                      ],
                      stops: const [0.4, 1],
                    ),
                  ),
                  padding: EdgeInsets.all(12.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item.coverImage == null)
                        Expanded(
                          child: Center(
                            child: GradientMask(
                              child: Icon(
                                Icons.photo_library_outlined,
                                size: 40.sp,
                              ),
                            ),
                          ),
                        )
                      else
                        const Spacer(),
                      if (item.itemCount != null)
                        Container(
                          margin: EdgeInsets.only(bottom: 8.h),
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            '${item.itemCount} Photos',
                            style: AppTheme.body(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      Text(
                        item.title,
                        style: AppTheme.heading(fontSize: 15.sp),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        item.date,
                        style: AppTheme.body(
                          color: AppTheme.textSecondary,
                          fontSize: 11.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }
}
