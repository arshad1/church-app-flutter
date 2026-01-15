import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
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
                    SizedBox(height: 32.h),
                    _buildSectionHeader('Featured Highlights', onSeeAll: () {}),
                    SizedBox(height: 16.h),
                    _buildFeaturedSlider(),
                    SizedBox(height: 32.h),
                    _buildSectionHeader('Recent Uploads'),
                    SizedBox(height: 16.h),
                    _buildRecentGrid(),
                  ],
                ),
              ),
            ),
            _buildBottomNavBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Media Gallery',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            Icon(Icons.search, color: Colors.white, size: 24.sp),
            SizedBox(width: 16.w),
            Icon(Icons.filter_list, color: Colors.white, size: 24.sp),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterTabs() {
    final filters = ['All', 'Photos', 'Videos', 'Albums'];
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: filters.map((filter) {
          return Obx(() {
            final isSelected = controller.selectedFilter.value == filter;
            return Expanded(
              child: GestureDetector(
                onTap: () => controller.selectedFilter.value = filter,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Center(
                    child: Text(
                      filter,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppTheme.textSecondary,
                        fontSize: 14.sp,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            );
          });
        }).toList(),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: Text(
              'View all',
              style: TextStyle(color: AppTheme.primary, fontSize: 14.sp),
            ),
          ),
      ],
    );
  }

  Widget _buildFeaturedSlider() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFeaturedCard(
            'assets/images/media_choir.png',
            'HIGHLIGHT',
            'Christmas Choir Special',
            'DEC 25 • 45 PHOTOS',
          ),
          _buildFeaturedCard(
            'assets/images/media_worship_night.png',
            'VIDEO',
            'Sunday Worship',
            'NOV 12 • 45 MIN',
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard(
    String image,
    String tag,
    String title,
    String meta,
  ) {
    return Container(
      margin: EdgeInsets.only(right: 16.w),
      width: 320.w, // Fixed width for horizontal scrolling list item
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.8),
                ],
              ),
            ),
          ),
          Positioned(
            left: 20.w,
            bottom: 20.h,
            right: 20.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        meta,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward,
                      color: AppTheme.textSecondary,
                      size: 20.sp,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentGrid() {
    final items = [
      {
        'image': 'assets/images/media_youth_camp.png',
        'title': 'Youth Camp 2023',
        'date': 'Oct 14',
        'type': 'photo',
      },
      {
        'image': 'assets/images/media_leadership.png',
        'title': 'Leadership Conference 2023',
        'date': 'Aug 15',
        'type': 'photo',
      },
      {
        'image': 'assets/images/media_food_drive.png',
        'title': 'Community Food Drive',
        'date': 'Sep 28 • 124 Photos',
        'type': 'gallery',
      },
      {
        'image': 'assets/images/media_summer_picnic.png',
        'title': 'Summer Picnic',
        'date': 'Jul 04',
        'type': 'photo',
      },
      {
        'image': 'assets/images/media_worship_night.png',
        'title': 'Worship Night',
        'date': 'Video',
        'type': 'video',
      },
      {
        'image': 'assets/images/media_baptism.png',
        'title': 'Baptism Highlights',
        'date': 'Video',
        'type': 'video',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 0.8, // Taller cards
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            image: DecorationImage(
              image: AssetImage(item['image']!),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
              if (item['type'] == 'video' || item['type'] == 'gallery')
                Positioned(
                  top: 12.h,
                  right: 12.w,
                  child: item['type'] == 'video'
                      ? Center(
                          child: Icon(
                            Icons.play_circle_fill,
                            color: Colors.white,
                            size: 32.sp,
                          ),
                        ) // Needs better centering if main icon
                      : Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Icon(
                            Icons.collections,
                            color: Colors.white,
                            size: 16.sp,
                          ),
                        ),
                ),

              if (item['type'] == 'video')
                Center(
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 32.sp,
                    ),
                  ),
                ),

              Positioned(
                left: 12.w,
                bottom: 12.h,
                right: 12.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title']!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      item['date']!,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: Color(0xFF1F2937))),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                Icons.home,
                'Home',
                onTap: () => Get.offNamed(Routes.home),
              ),
              _buildNavItem(
                Icons.calendar_today,
                'Events',
                onTap: () => Get.offNamed(Routes.events),
              ), // Swapped order to match mockup? No, mockup has Media 3rd actually.
              // Wait, mockup standard nav is Home / Events / Media / Profile usually. The mockup image "Media Gallery" shows:
              // Home / Events / Media / Profile.
              // Media is selected.
              _buildNavItem(Icons.play_circle_fill, 'Media', isActive: true),
              _buildNavItem(
                Icons.person,
                'Profile',
                onTap: () => Get.offNamed(Routes.profile),
              ),
            ],
          ),
          Positioned(
            right: 20.w,
            top: -40.h,
            child: FloatingActionButton(
              onPressed: () {},
              backgroundColor: AppTheme.primary,
              child: Icon(Icons.camera_alt, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label, {
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? AppTheme.primary : AppTheme.textSecondary,
            size: 24.sp,
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppTheme.primary : AppTheme.textSecondary,
              fontSize: 10.sp,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
