import 'package:church_app/app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:church_app/app/routes/app_pages.dart';
import 'package:intl/intl.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

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
                    _buildVerseCard(),
                    SizedBox(height: 24.h),
                    _buildQuickActions(),
                    SizedBox(height: 32.h),
                    _buildSectionHeader('Daily Devotions', onSeeAll: () {}),
                    SizedBox(height: 16.h),
                    _buildDevotionsList(),
                    SizedBox(height: 32.h),
                    _buildNoticeBanner(),
                    SizedBox(height: 32.h),
                    _buildSectionHeader('Upcoming Events'),
                    SizedBox(height: 16.h),
                    _buildEventsList(),
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
        Row(
          children: [
            GestureDetector(
              onTap: () => Get.toNamed(Routes.profile),
              child: CircleAvatar(
                radius: 20.r,
                backgroundImage: const AssetImage('assets/images/avatar.png'),
              ),
            ),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good Morning, ${controller.userName}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Welcome back',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ],
        ),
        Stack(
          children: [
            Icon(Icons.notifications, color: Colors.white, size: 24.sp),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 8.r,
                height: 8.r,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVerseCard() {
    return Obx(() {
      final verse = controller.bibleVerse.value;
      if (verse == null) {
        return const SizedBox.shrink(); // Hide if no verse available
      }

      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          image: const DecorationImage(
            image: AssetImage('assets/images/verse_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.r),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.1),
                Colors.black.withValues(alpha: 0.7),
              ],
            ),
          ),
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.wb_sunny_outlined,
                      color: Colors.white,
                      size: 14.sp,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'VERSE OF THE DAY',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                '"${verse.content}"', // Dynamic content
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              SizedBox(height: 8.h),
              if (verse.title != null) // Dynamic title/reference part 2
                Text(
                  verse.title!,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12.sp,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(verse.date), // Formatted date
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.share, color: Colors.white, size: 16.sp),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildQuickActions() {
    final actions = [
      {'icon': Icons.volunteer_activism, 'label': 'Giving'},
      {'icon': Icons.spa, 'label': 'Prayer'},
      {'icon': Icons.ondemand_video, 'label': 'Live'},
      {'icon': Icons.place, 'label': 'Check-in'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.map((action) {
        return Column(
          children: [
            Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                action['icon'] as IconData,
                color: Colors.white.withValues(alpha: 0.9),
                size: 28.sp,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              action['label'] as String,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      }).toList(),
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
          GestureDetector(
            onTap: onSeeAll,
            child: Text(
              'See All',
              style: TextStyle(
                color: AppTheme.primary,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDevotionsList() {
    return SizedBox(
      height: 160.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildDevotionCard(
            'Finding Peace in Chaos',
            '5 min read',
            'assets/images/devotion1.png',
            isToday: true,
          ),
          SizedBox(width: 16.w),
          _buildDevotionCard(
            'Walking in Faith',
            'Yesterday',
            'assets/images/devotion2.png',
          ),
        ],
      ),
    );
  }

  Widget _buildDevotionCard(
    String title,
    String subtitle,
    String imagePath, {
    bool isToday = false,
  }) {
    return Container(
      width: 240.w,
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(
          alpha: 0.5,
        ), // Transparent to show background if needed
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16.r),
                    ),
                    image: DecorationImage(
                      image: AssetImage(imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (isToday)
                  Positioned(
                    top: 12.h,
                    left: 12.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        'TODAY',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: AppTheme.textSecondary,
                      size: 14.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12.sp,
                      ),
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

  Widget _buildNoticeBanner() {
    return Obx(() {
      if (controller.announcements.isEmpty) {
        return const SizedBox.shrink(); // Hide if no announcements
      }

      // Show the latest announcement
      final announcement = controller.announcements.first;

      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF97316), Color(0xFFEF4444)], // Orange to Red
          ),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.campaign, color: Colors.white, size: 24.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    announcement.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    announcement.content,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12.sp,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            ElevatedButton(
              onPressed: () {
                // TODO: Show full announcement details
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFEF4444),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                minimumSize: Size.zero,
              ),
              child: Text(
                'View',
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildEventsList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.upcomingEvents.isEmpty) {
        return Center(
          child: Text(
            "No upcoming events",
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        );
      }

      return Column(
        children: controller.upcomingEvents.map((event) {
          // Parse date
          DateTime? date;
          try {
            date = DateTime.parse(event.startDate);
          } catch (_) {}

          final month = date != null
              ? [
                  "JAN",
                  "FEB",
                  "MAR",
                  "APR",
                  "MAY",
                  "JUN",
                  "JUL",
                  "AUG",
                  "SEP",
                  "OCT",
                  "NOV",
                  "DEC",
                ][date.month - 1]
              : "";
          final day = date != null ? date.day.toString() : "";
          final time = date != null
              ? "${date.hour}:${date.minute.toString().padLeft(2, '0')}"
              : ""; // Simple formatting

          return Container(
            margin: EdgeInsets.only(bottom: 16.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    children: [
                      Text(
                        month,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        day,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '$time • ${event.location ?? "TBA"}',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppTheme.textSecondary,
                  size: 20.sp,
                ),
              ],
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildBottomNavBar() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: const BoxDecoration(
        color: Colors.black, // Or AppTheme.background which is almost black
        border: Border(top: BorderSide(color: Color(0xFF1F2937))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Home', isActive: true),
          _buildNavItem(
            Icons.play_circle_fill,
            'Media',
            onTap: () => Get.toNamed(Routes.media),
          ),
          _buildNavItem(
            Icons.calendar_today,
            'Events',
            onTap: () => Get.toNamed(Routes.events),
          ),
          _buildNavItem(Icons.menu, 'More'),
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

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMMM d, yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }
}
