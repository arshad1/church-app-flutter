import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/ui_kit.dart';
import '../controllers/album_detail_controller.dart';

class AlbumDetailView extends GetView<AlbumDetailController> {
  const AlbumDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: AppBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              FadeSlideIn(child: _buildHeader()),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const AppLoader();
                  }

                  if (controller.images.isEmpty) {
                    return const EmptyState(
                      icon: Icons.image_not_supported_outlined,
                      message: 'No images found',
                    );
                  }

                  return _buildImageGrid();
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 20.w, 8.h),
      child: Row(
        children: [
          GlassIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            size: 40,
            onTap: () => Get.back(),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Text(
                    controller.albumTitle.value,
                    style: AppTheme.heading(fontSize: 22.sp),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: 2.h),
                Obx(
                  () => Text(
                    '${controller.images.length} Photos',
                    style: AppTheme.body(
                      color: AppTheme.accent,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGrid() {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.h,
        childAspectRatio: 1,
      ),
      itemCount: controller.images.length,
      itemBuilder: (context, index) {
        final image = controller.images[index];
        return FadeSlideIn(
          index: index % 15,
          staggerMs: 40,
          offsetY: 16,
          child: PressableScale(
            onTap: () => controller.openImageViewer(index),
            child: Hero(
              tag: 'image_${image.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14.r),
                child: Container(
                  color: AppTheme.surface,
                  child: Image.network(
                    image.url,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(color: AppTheme.surfaceLight);
                    },
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
