import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../data/models/gallery_models.dart';

class ImageViewerView extends StatefulWidget {
  final List<GalleryItem> images;
  final int initialIndex;

  const ImageViewerView({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<ImageViewerView> createState() => _ImageViewerViewState();
}

class _ImageViewerViewState extends State<ImageViewerView> {
  late PageController _pageController;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070A1C),
      body: Stack(
        children: [
          // Full screen image viewer with pinch-to-zoom
          PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final image = widget.images[index];
              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: Hero(
                    tag: 'image_${image.id}',
                    child: Image.network(
                      image.url,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primary,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.white54,
                            size: 64.sp,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),

          // Top bar with close button and counter
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF070A1C).withValues(alpha: 0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GlassIconButton(
                      icon: Icons.close_rounded,
                      size: 42,
                      onTap: () => Get.back(),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: AppTheme.glow(),
                      ),
                      child: Text(
                        '${currentIndex + 1} / ${widget.images.length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom navigation indicators (optional)
          if (widget.images.length > 1)
            Positioned(
              bottom: 40.h,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.images.length > 10 ? 10 : widget.images.length,
                  (index) {
                    if (widget.images.length > 10 && index == 9) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Text(
                          '...',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      width: currentIndex == index ? 24.w : 8.w,
                      height: 8.h,
                      decoration: BoxDecoration(
                        gradient: currentIndex == index
                            ? AppTheme.primaryGradient
                            : null,
                        color: currentIndex == index
                            ? null
                            : Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
