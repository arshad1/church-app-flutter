import 'package:church_app/app/core/theme/app_theme.dart';
import 'package:church_app/app/core/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:church_app/app/routes/app_pages.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../controllers/home_controller.dart';
import '../../notifications/views/notification_view.dart';

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
                    _buildNoticeBanner(),
                    SizedBox(height: 32.h),
                    _buildSectionHeader(
                      'Upcoming Events',
                      onSeeAll: () => Get.toNamed(Routes.events),
                    ),
                    SizedBox(height: 16.h),
                    _buildEventsList(),
                    SizedBox(height: 32.h),
                    _buildSectionHeader(
                      'Gallery',
                      onSeeAll: () => Get.toNamed(Routes.media),
                    ),
                    SizedBox(height: 16.h),
                    _buildGalleryPreview(),
                    SizedBox(height: 32.h),
                    _buildFeaturedEvent(),
                  ],
                ),
              ),
            ),
            const AppBottomNavBar(currentRoute: Routes.home),
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
              child: Obx(
                () => CircleAvatar(
                  radius: 20.r,
                  backgroundImage: controller.userImage.value != null
                      ? NetworkImage(controller.userImage.value!)
                            as ImageProvider
                      : const AssetImage('assets/images/avatar.png'),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${controller.userName}',
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
        GestureDetector(
          onTap: () => Get.to(() => const NotificationView()),
          child: Stack(
            children: [
              Icon(Icons.notifications, color: Colors.white, size: 24.sp),
              // TODO: Only show red dot if unread notifications exist
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
                  GestureDetector(
                    onTap: () {
                      // ignore: deprecated_member_use
                      Share.share(
                        '"${verse.content}" - ${verse.title ?? verse.date}',
                        subject: 'Verse of the Day',
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.share,
                        color: Colors.white,
                        size: 16.sp,
                      ),
                    ),
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
      {
        'icon': Icons.calendar_month,
        'label': 'Events',
        'onTap': () => Get.toNamed(Routes.events),
      },
      {
        'icon': Icons.people,
        'label': 'Directory',
        'onTap': () => Get.toNamed(Routes.directory),
      },
      {
        'icon': Icons.photo_library,
        'label': 'Gallery',
        'onTap': () => Get.toNamed(Routes.media),
      },
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.map((action) {
        return GestureDetector(
          onTap: action['onTap'] as VoidCallback?,
          child: Column(
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
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGalleryPreview() {
    return Obx(() {
      if (controller.galleryAlbums.isEmpty) {
        return Center(
          child: Text(
            'No photos available',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        );
      }

      return Row(
        children: controller.galleryAlbums.map((album) {
          return Expanded(
            child: GestureDetector(
              onTap: () => Get.toNamed(
                Routes.albumDetail,
                arguments: {'id': album.id, 'title': album.title},
              ),
              child: Container(
                height: 120.h,
                margin: EdgeInsets.only(right: 12.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  image: DecorationImage(
                    image: NetworkImage(
                      album.coverImage ?? 'https://via.placeholder.com/300',
                    ),
                    fit: BoxFit.cover,
                    onError: (e, s) =>
                        const AssetImage('assets/images/placeholder.png'),
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  padding: EdgeInsets.all(8.w),
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    album.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  Future<void> _launchURL(String url, {String? title}) async {
    // Check if it's a video URL (YouTube or other video links)
    if (url.contains('youtube.com') ||
        url.contains('youtu.be') ||
        url.contains('.mp4') ||
        url.contains('.m3u8') ||
        url.toLowerCase().contains('stream')) {
      // Navigate to in-app video player
      Get.toNamed(
        Routes.videoPlayer,
        arguments: {'url': url, 'title': title ?? 'Live Stream'},
      );
    } else {
      // For non-video URLs, use external launcher
      try {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          Get.snackbar('Error', 'Could not launch $url');
        }
      } catch (e) {
        Get.snackbar('Error', 'Failed to launch URL: $e');
      }
    }
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

  Widget _buildFeaturedEvent() {
    return Obx(() {
      final event = controller.featuredEvent;
      if (event == null) return const SizedBox.shrink();

      final canLaunchStream =
          event.isLive && event.liveUrl != null && event.liveUrl!.isNotEmpty;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Featured Event'),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: canLaunchStream
                ? () => _launchURL(event.liveUrl!, title: event.title)
                : () => Get.toNamed(Routes.events),
            child: Container(
              width: double.infinity,
              height: 200.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.r),
                color: AppTheme.surface,
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
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: event.isLive ? Colors.red : AppTheme.primary,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (event.isLive) ...[
                                Icon(
                                  Icons.circle,
                                  color: Colors.white,
                                  size: 8.sp,
                                ),
                                SizedBox(width: 4.w),
                              ],
                              Text(
                                event.isLive ? 'LIVE NOW' : 'UPCOMING',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (canLaunchStream) ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.play_circle_outline,
                                  color: Colors.white,
                                  size: 12.sp,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  'Watch',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const Spacer(),
                    Text(
                      event.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),
                    if (event.description != null &&
                        event.description!.isNotEmpty)
                      Text(
                        event.description!,
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
            ),
          ),
        ],
      );
    });
  }

  Widget _buildNoticeBanner() {
    return Obx(() {
      if (controller.announcements.isEmpty) {
        return const SizedBox.shrink(); // Hide if no announcements
      }
      // ... content
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
            // ...
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
          final dateTime = DateTime.parse(event.startDate);
          final month = _getMonthAbbreviation(dateTime.month);
          final day = dateTime.day.toString();
          final canLaunchStream =
              event.isLive &&
              event.liveUrl != null &&
              event.liveUrl!.isNotEmpty;

          return GestureDetector(
            onTap: canLaunchStream
                ? () => _launchURL(event.liveUrl!, title: event.title)
                : null,
            child: Container(
              margin: EdgeInsets.only(bottom: 16.h),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16.r),
                border: event.isLive
                    ? Border.all(
                        color: Colors.red.withValues(alpha: 0.5),
                        width: 2,
                      )
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 50.w,
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    decoration: BoxDecoration(
                      color: event.isLive
                          ? Colors.red.withValues(alpha: 0.2)
                          : AppTheme.background,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      children: [
                        Text(
                          month,
                          style: TextStyle(
                            color: event.isLive ? Colors.red : AppTheme.primary,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2.h),
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
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                event.title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (event.isLive) ...[
                              SizedBox(width: 8.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      color: Colors.white,
                                      size: 6.sp,
                                    ),
                                    SizedBox(width: 3.w),
                                    Text(
                                      'LIVE',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 9.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
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
                              _formatTime(dateTime),
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12.sp,
                              ),
                            ),
                            if (event.location != null) ...[
                              SizedBox(width: 12.w),
                              Icon(
                                Icons.place,
                                color: AppTheme.textSecondary,
                                size: 14.sp,
                              ),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: Text(
                                  event.location!,
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12.sp,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    canLaunchStream
                        ? Icons.play_circle_fill
                        : Icons.chevron_right,
                    color: canLaunchStream
                        ? Colors.red
                        : AppTheme.textSecondary,
                    size: 24.sp,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  String _getMonthAbbreviation(int month) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return months[month - 1];
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
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
