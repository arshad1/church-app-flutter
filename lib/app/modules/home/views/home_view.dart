import 'package:church_app/app/core/theme/app_theme.dart';
import 'package:church_app/app/core/widgets/bottom_nav_bar.dart';
import 'package:church_app/app/core/widgets/ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:church_app/app/routes/app_pages.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../controllers/home_controller.dart';
import '../../../data/models/event.dart';
import '../../notifications/views/notification_view.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

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
                  onRefresh: controller.fetchContent,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeSlideIn(index: 0, child: _buildHeader()),
                        SizedBox(height: 22.h),
                        FadeSlideIn(index: 1, child: _buildVerseCard()),
                        SizedBox(height: 22.h),
                        FadeSlideIn(index: 2, child: _buildQuickActions()),
                        SizedBox(height: 22.h),
                        FadeSlideIn(index: 3, child: _buildNoticeBanner()),
                        FadeSlideIn(index: 4, child: _buildFeaturedEvent()),
                        SizedBox(height: 26.h),
                        FadeSlideIn(
                          index: 5,
                          child: SectionHeader(
                            title: 'Upcoming Events',
                            onSeeAll: () => Get.toNamed(Routes.events),
                          ),
                        ),
                        SizedBox(height: 14.h),
                        _buildEventsList(),
                        SizedBox(height: 18.h),
                        FadeSlideIn(
                          index: 7,
                          child: SectionHeader(
                            title: 'Gallery',
                            onSeeAll: () => Get.toNamed(Routes.media),
                          ),
                        ),
                        SizedBox(height: 14.h),
                        FadeSlideIn(index: 8, child: _buildGalleryPreview()),
                      ],
                    ),
                  ),
                ),
              ),
              const AppBottomNavBar(currentRoute: Routes.home),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Header
  // ---------------------------------------------------------------------------

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Widget _buildHeader() {
    return Row(
      children: [
        PressableScale(
          onTap: () => Get.toNamed(Routes.profile),
          child: Container(
            padding: EdgeInsets.all(2.5.r),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.primaryGradient,
            ),
            child: Container(
              padding: EdgeInsets.all(2.r),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.background,
              ),
              child: Obx(
                () => CircleAvatar(
                  radius: 21.r,
                  backgroundColor: AppTheme.surface,
                  backgroundImage: controller.userImage.value != null
                      ? NetworkImage(controller.userImage.value!)
                            as ImageProvider
                      : const AssetImage('assets/images/avatar.png'),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$_greeting 👋',
                style: AppTheme.body(
                  fontSize: 12.sp,
                  color: AppTheme.textSecondary,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                controller.userName,
                style: AppTheme.heading(fontSize: 20.sp),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        GlassIconButton(
          icon: Icons.notifications_none_rounded,
          showDot: true, // TODO: only show when unread notifications exist
          onTap: () => Get.to(() => const NotificationView()),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Verse of the day
  // ---------------------------------------------------------------------------

  Widget _buildVerseCard() {
    return Obx(() {
      final verse = controller.bibleVerse.value;
      if (verse == null) {
        return const SizedBox.shrink(); // Hide if no verse available
      }

      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26.r),
          border: Border.all(color: AppTheme.glassBorder),
          boxShadow: AppTheme.glow(AppTheme.secondary, 0.18),
        ),
        child: ShimmerSweep(
          borderRadius: BorderRadius.circular(26.r),
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/verse_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.background.withValues(alpha: 0.25),
                    AppTheme.backgroundAlt.withValues(alpha: 0.9),
                  ],
                ),
              ),
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const PillLabel(
                    text: 'VERSE OF THE DAY',
                    icon: Icons.wb_sunny_outlined,
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    '“${verse.content}”',
                    style: AppTheme.heading(
                      fontSize: 19.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                  if (verse.title != null) ...[
                    SizedBox(height: 8.h),
                    Text(
                      '— ${verse.title!}',
                      style: AppTheme.body(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.accent,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  SizedBox(height: 14.h),
                  Row(
                    children: [
                      Icon(
                        Icons.event_note_rounded,
                        size: 14.sp,
                        color: AppTheme.textSecondary,
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          _formatDate(verse.date),
                          style: AppTheme.body(
                            fontSize: 12.sp,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                      GlassIconButton(
                        icon: Icons.ios_share_rounded,
                        size: 38,
                        onTap: () {
                          // ignore: deprecated_member_use
                          Share.share(
                            '"${verse.content}" - ${verse.title ?? verse.date}',
                            subject: 'Verse of the Day',
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  // ---------------------------------------------------------------------------
  // Quick actions
  // ---------------------------------------------------------------------------

  Widget _buildQuickActions() {
    final actions = <(IconData, String, VoidCallback)>[
      (Icons.calendar_month_rounded, 'Events', () => Get.toNamed(Routes.events)),
      (Icons.groups_rounded, 'Directory', () => Get.toNamed(Routes.directory)),
      (Icons.photo_library_rounded, 'Gallery', () => Get.toNamed(Routes.media)),
      (Icons.person_rounded, 'Profile', () => Get.toNamed(Routes.profile)),
    ];

    return Row(
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0) SizedBox(width: 10.w),
          Expanded(
            child: PressableScale(
              onTap: actions[i].$3,
              child: Column(
                children: [
                  Container(
                    height: 62.w,
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppTheme.glass,
                      borderRadius: BorderRadius.circular(18.r),
                      border: Border.all(color: AppTheme.glassBorder),
                    ),
                    child: GradientMask(
                      child: Icon(actions[i].$1, size: 27.sp),
                    ),
                  ),
                  SizedBox(height: 7.h),
                  Text(
                    actions[i].$2,
                    style: AppTheme.body(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Notice banner
  // ---------------------------------------------------------------------------

  Widget _buildNoticeBanner() {
    return Obx(() {
      if (controller.announcements.isEmpty) {
        return const SizedBox.shrink(); // Hide if no announcements
      }
      final announcement = controller.announcements.first;

      return Padding(
        padding: EdgeInsets.only(bottom: 22.h),
        child: GlassCard(
          padding: EdgeInsets.all(14.w),
          radius: 20.r,
          borderColor: AppTheme.accent.withValues(alpha: 0.45),
          gradient: LinearGradient(
            colors: [
              AppTheme.accent.withValues(alpha: 0.22),
              AppTheme.secondary.withValues(alpha: 0.12),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(
                  Icons.campaign_rounded,
                  color: Colors.white,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      announcement.title,
                      style: AppTheme.body(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      announcement.content,
                      style: AppTheme.body(
                        fontSize: 12.sp,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ---------------------------------------------------------------------------
  // Featured / live event
  // ---------------------------------------------------------------------------

  Widget _buildFeaturedEvent() {
    return Obx(() {
      final event = controller.featuredEvent;
      if (event == null) return const SizedBox.shrink();

      final canLaunchStream =
          event.isLive && event.liveUrl != null && event.liveUrl!.isNotEmpty;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: event.isLive ? 'Happening Now' : 'Featured Event',
          ),
          SizedBox(height: 14.h),
          PressableScale(
            onTap: canLaunchStream
                ? () => _launchURL(event.liveUrl!, title: event.title)
                : () => _showEventDetails(event),
            child: Container(
              width: double.infinity,
              height: 190.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26.r),
                border: Border.all(color: AppTheme.glassBorder),
                image: const DecorationImage(
                  image: AssetImage('assets/images/event_easter.png'),
                  fit: BoxFit.cover,
                ),
                boxShadow: AppTheme.glow(
                  event.isLive ? AppTheme.live : AppTheme.secondary,
                  0.25,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26.r),
                  gradient: AppTheme.imageOverlay,
                ),
                padding: EdgeInsets.all(18.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    event.isLive
                        ? const LiveBadge()
                        : const PillLabel(
                            text: 'UPCOMING',
                            icon: Icons.star_rounded,
                          ),
                    const Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.title,
                                style: AppTheme.heading(fontSize: 21.sp),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                [
                                  _formatDateTimeShort(event.startDate),
                                  if (event.location != null) event.location!,
                                ].join(' · '),
                                style: AppTheme.body(
                                  fontSize: 12.sp,
                                  color: AppTheme.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Container(
                          width: 48.w,
                          height: 48.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppTheme.primaryGradient,
                            boxShadow: AppTheme.glow(),
                          ),
                          child: Icon(
                            canLaunchStream
                                ? Icons.play_arrow_rounded
                                : Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 26.sp,
                          ),
                        ),
                      ],
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

  // ---------------------------------------------------------------------------
  // Upcoming events
  // ---------------------------------------------------------------------------

  Widget _buildEventsList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const AppLoader();
      }

      if (controller.upcomingEvents.isEmpty) {
        return const EmptyState(
          icon: Icons.event_busy_rounded,
          message: 'No upcoming events',
        );
      }

      final events = controller.upcomingEvents.toList();
      return Column(
        children: [
          for (var i = 0; i < events.length; i++)
            FadeSlideIn(index: 6 + i, child: _eventTile(events[i])),
        ],
      );
    });
  }

  Widget _eventTile(Event event) {
    final dateTime = DateTime.parse(event.startDate);
    final month = _getMonthAbbreviation(dateTime.month);
    final day = dateTime.day.toString();
    final isLive = event.isLive;

    return GlassCard(
      onTap: () => _showEventDetails(event),
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      borderColor: isLive ? AppTheme.live.withValues(alpha: 0.6) : null,
      child: Row(
        children: [
          Container(
            width: 54.w,
            padding: EdgeInsets.symmetric(vertical: 8.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isLive
                    ? [
                        AppTheme.live.withValues(alpha: 0.35),
                        AppTheme.live.withValues(alpha: 0.10),
                      ]
                    : [
                        AppTheme.accent.withValues(alpha: 0.28),
                        AppTheme.secondary.withValues(alpha: 0.10),
                      ],
              ),
              border: Border.all(color: AppTheme.glassBorder),
            ),
            child: Column(
              children: [
                Text(
                  month,
                  style: AppTheme.body(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: isLive ? AppTheme.live : AppTheme.accent,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(day, style: AppTheme.heading(fontSize: 20.sp)),
              ],
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: AppTheme.body(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isLive) ...[
                      SizedBox(width: 8.w),
                      const LiveBadge(text: 'LIVE', compact: true),
                    ],
                  ],
                ),
                SizedBox(height: 5.h),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      color: AppTheme.accent,
                      size: 14.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      _formatTime(dateTime),
                      style: AppTheme.body(
                        color: AppTheme.textSecondary,
                        fontSize: 12.sp,
                      ),
                    ),
                    if (event.location != null) ...[
                      SizedBox(width: 10.w),
                      Icon(
                        Icons.place_outlined,
                        color: AppTheme.accent,
                        size: 14.sp,
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          event.location!,
                          style: AppTheme.body(
                            color: AppTheme.textSecondary,
                            fontSize: 12.sp,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
                if (event.description != null &&
                    event.description!.isNotEmpty) ...[
                  SizedBox(height: 6.h),
                  Text(
                    event.description!,
                    style: AppTheme.body(
                      color: AppTheme.textMuted,
                      fontSize: 12.sp,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 6.w),
          Icon(
            Icons.chevron_right_rounded,
            color: AppTheme.accent,
            size: 22.sp,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Gallery preview
  // ---------------------------------------------------------------------------

  Widget _buildGalleryPreview() {
    return Obx(() {
      if (controller.galleryAlbums.isEmpty) {
        return const EmptyState(
          icon: Icons.photo_library_outlined,
          message: 'No photos available',
        );
      }

      final albums = controller.galleryAlbums.toList();
      return Row(
        children: [
          for (var i = 0; i < albums.length; i++) ...[
            if (i > 0) SizedBox(width: 12.w),
            Expanded(
              child: PressableScale(
                onTap: () => Get.toNamed(
                  Routes.albumDetail,
                  arguments: {'id': albums[i].id, 'title': albums[i].title},
                ),
                child: Container(
                  height: 130.h,
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: AppTheme.glassBorder),
                    image: albums[i].coverImage != null
                        ? DecorationImage(
                            image: NetworkImage(albums[i].coverImage!),
                            fit: BoxFit.cover,
                            onError: (e, s) {},
                          )
                        : null,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.r),
                      gradient: AppTheme.imageOverlay,
                    ),
                    padding: EdgeInsets.all(10.w),
                    alignment: Alignment.bottomLeft,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            albums[i].title,
                            style: AppTheme.body(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Icons.photo_library_outlined,
                          size: 14.sp,
                          color: AppTheme.accent,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
          // Keep a single album at half width, like before.
          if (albums.length == 1) ...[
            SizedBox(width: 12.w),
            const Expanded(child: SizedBox()),
          ],
        ],
      );
    });
  }

  // ---------------------------------------------------------------------------
  // Event details sheet
  // ---------------------------------------------------------------------------

  void _showEventDetails(event) {
    final dateTime = DateTime.parse(event.startDate);
    final canLaunchStream =
        event.isLive && event.liveUrl != null && event.liveUrl!.isNotEmpty;

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.fromLTRB(24.w, 14.h, 24.w, 28.h),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
          border: Border(top: BorderSide(color: AppTheme.glassBorder)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44.w,
                  height: 5.h,
                  margin: EdgeInsets.only(bottom: 20.h),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                ),
              ),
              if (event.isLive) ...[
                const LiveBadge(),
                SizedBox(height: 12.h),
              ],
              Text(event.title, style: AppTheme.heading(fontSize: 25.sp)),
              SizedBox(height: 18.h),
              _buildDetailRow(
                Icons.calendar_today_rounded,
                DateFormat('EEEE, MMMM d, yyyy').format(dateTime),
              ),
              SizedBox(height: 12.h),
              _buildDetailRow(
                Icons.schedule_rounded,
                DateFormat('h:mm a').format(dateTime),
              ),
              if (event.location != null) ...[
                SizedBox(height: 12.h),
                _buildDetailRow(Icons.place_rounded, event.location!),
              ],
              SizedBox(height: 22.h),
              Text('About this event', style: AppTheme.heading(fontSize: 18.sp)),
              SizedBox(height: 8.h),
              Text(
                event.description ?? 'No description available.',
                style: AppTheme.body(
                  color: AppTheme.textSecondary,
                  fontSize: 14.sp,
                  height: 1.6,
                ),
              ),
              SizedBox(height: 28.h),
              if (canLaunchStream)
                GradientButton(
                  label: 'Watch Live Stream',
                  icon: Icons.play_circle_fill_rounded,
                  onPressed: () {
                    Get.back();
                    _launchURL(event.liveUrl!, title: event.title);
                  },
                ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: AppTheme.accent.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppTheme.glassBorder),
          ),
          child: Icon(icon, color: AppTheme.accent, size: 20.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: AppTheme.body(fontSize: 15.sp, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers (unchanged behaviour)
  // ---------------------------------------------------------------------------

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

  String _formatDateTimeShort(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM d · h:mm a').format(date);
    } catch (_) {
      return dateStr;
    }
  }
}
