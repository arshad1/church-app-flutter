import 'package:church_app/app/core/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../data/models/event.dart';
import '../../../routes/app_pages.dart';
import '../controllers/events_controller.dart';

class EventsView extends GetView<EventsController> {
  const EventsView({super.key});

  static const _filters = <(String, IconData)>[
    ('All Events', Icons.apps_rounded),
    ('Live & Streamed', Icons.live_tv_rounded),
    ('Featured', Icons.star_rounded),
  ];

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
                  onRefresh: controller.fetchEvents,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeSlideIn(child: _buildHeader()),
                        SizedBox(height: 18.h),
                        FadeSlideIn(index: 1, child: _buildSearchBar()),
                        SizedBox(height: 14.h),
                        FadeSlideIn(index: 2, child: _buildFilterChips()),
                        SizedBox(height: 22.h),
                        FadeSlideIn(index: 3, child: _buildFeaturedCard()),
                        Obx(
                          () => SectionHeader(
                            title: controller.isSearching
                                ? 'Results'
                                : 'Upcoming',
                          ),
                        ),
                        SizedBox(height: 14.h),
                        _buildUpcomingEventsList(),
                      ],
                    ),
                  ),
                ),
              ),
              const AppBottomNavBar(currentRoute: Routes.events),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Events', style: AppTheme.heading(fontSize: 30.sp)),
        SizedBox(height: 4.h),
        Text(
          'Gather, worship and serve together',
          style: AppTheme.body(
            fontSize: 13.sp,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Obx(
      () => TextField(
        onChanged: (value) => controller.searchQuery.value = value,
        style: AppTheme.body(fontSize: 14.sp),
        cursorColor: AppTheme.primary,
        textInputAction: TextInputAction.search,
        decoration: AppTheme.inputDecoration(
          hint: 'Search events, places…',
          icon: Icons.search_rounded,
          suffix: controller.isSearching
              ? IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppTheme.textSecondary,
                  ),
                  onPressed: () {
                    controller.clearSearch();
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                )
              : null,
        ),
        controller: controller.searchController,
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _filters.map((f) {
          final (filter, icon) = f;
          return Obx(() {
            final isSelected = controller.selectedFilter.value == filter;
            return Padding(
              padding: EdgeInsets.only(right: 10.w),
              child: PressableScale(
                onTap: () => controller.selectedFilter.value = filter,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
                  ),
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
                      Icon(
                        icon,
                        size: 15.sp,
                        color: isSelected
                            ? Colors.white
                            : AppTheme.textSecondary,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        filter,
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
                    ],
                  ),
                ),
              ),
            );
          });
        }).toList(),
      ),
    );
  }

  Widget _buildFeaturedCard() {
    return Obx(() {
      final featuredEvent = controller.featuredEvent;

      if (featuredEvent == null ||
          controller.isSearching ||
          controller.selectedFilter.value != 'All Events') {
        return const SizedBox.shrink();
      }

      final canLaunchStream =
          featuredEvent.isLive &&
          featuredEvent.liveUrl != null &&
          featuredEvent.liveUrl!.isNotEmpty;

      return Padding(
        padding: EdgeInsets.only(bottom: 24.h),
        child: PressableScale(
          onTap: () => _showEventDetails(featuredEvent),
          child: Container(
            width: double.infinity,
            height: 210.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26.r),
              border: Border.all(color: AppTheme.glassBorder),
              image: const DecorationImage(
                image: AssetImage('assets/images/media_worship_night.png'),
                fit: BoxFit.cover,
              ),
              boxShadow: AppTheme.glow(
                featuredEvent.isLive ? AppTheme.live : AppTheme.secondary,
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
                  Row(
                    children: [
                      featuredEvent.isLive
                          ? const LiveBadge()
                          : const PillLabel(
                              text: 'FEATURED',
                              icon: Icons.star_rounded,
                            ),
                      const Spacer(),
                      if (canLaunchStream)
                        const PillLabel(
                          text: 'WATCH',
                          icon: Icons.play_arrow_rounded,
                          filled: true,
                        ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    featuredEvent.title,
                    style: AppTheme.heading(fontSize: 22.sp),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  _metaRow(featuredEvent, light: true),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _metaRow(Event event, {bool light = false}) {
    final dateTime = DateTime.tryParse(event.startDate);
    final color = light ? Colors.white.withValues(alpha: 0.85) : null;
    Widget item(IconData icon, String text, {bool expand = false}) {
      final label = Text(
        text,
        style: AppTheme.body(
          fontSize: 12.sp,
          color: color ?? AppTheme.textSecondary,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: AppTheme.accent),
          SizedBox(width: 4.w),
          expand ? Flexible(child: label) : label,
        ],
      );
    }

    return Row(
      children: [
        if (dateTime != null) ...[
          item(Icons.calendar_today_rounded, DateFormat('MMM d').format(dateTime)),
          SizedBox(width: 12.w),
          item(Icons.schedule_rounded, _formatTime(dateTime)),
        ],
        if (event.location != null) ...[
          SizedBox(width: 12.w),
          Expanded(child: item(Icons.place_outlined, event.location!, expand: true)),
        ],
      ],
    );
  }

  Widget _buildUpcomingEventsList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const AppLoader();
      }

      final events = controller.upcomingEvents;

      if (events.isEmpty) {
        return EmptyState(
          icon: controller.isSearching
              ? Icons.search_off_rounded
              : Icons.event_busy_rounded,
          message: controller.isSearching
              ? 'No events match your search'
              : 'No upcoming events',
        );
      }

      return Column(
        children: [
          for (var i = 0; i < events.length; i++)
            FadeSlideIn(
              key: ValueKey('${controller.selectedFilter.value}-${events[i].id}'),
              index: i,
              child: _eventTile(events[i]),
            ),
        ],
      );
    });
  }

  Widget _eventTile(Event event) {
    final dateTime = DateTime.parse(event.startDate);
    final month = _getMonthAbbreviation(dateTime.month);
    final day = dateTime.day.toString();
    final canLaunchStream =
        event.isLive && event.liveUrl != null && event.liveUrl!.isNotEmpty;

    return GlassCard(
      onTap: () => _showEventDetails(event),
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      borderColor: event.isLive ? AppTheme.live.withValues(alpha: 0.6) : null,
      child: Row(
        children: [
          Container(
            width: 56.w,
            padding: EdgeInsets.symmetric(vertical: 9.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: event.isLive
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
                    color: event.isLive ? AppTheme.live : AppTheme.accent,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(day, style: AppTheme.heading(fontSize: 21.sp)),
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
                    if (event.isLive) ...[
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
          canLaunchStream
              ? Container(
                  width: 34.w,
                  height: 34.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.primaryGradient,
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                )
              : Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.accent,
                  size: 22.sp,
                ),
        ],
      ),
    );
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

  /// Opens video links in the in-app player (same as Home), others externally.
  Future<void> _launchStream(String url, {String? title}) async {
    if (url.contains('youtube.com') ||
        url.contains('youtu.be') ||
        url.contains('.mp4') ||
        url.contains('.m3u8') ||
        url.toLowerCase().contains('stream')) {
      Get.toNamed(
        Routes.videoPlayer,
        arguments: {'url': url, 'title': title ?? 'Live Stream'},
      );
      return;
    }
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Error',
          'Could not open stream',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.live,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to launch stream: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.live,
        colorText: Colors.white,
      );
    }
  }

  void _showEventDetails(Event event) {
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
              ] else if (event.isFeatured) ...[
                const PillLabel(text: 'FEATURED', icon: Icons.star_rounded),
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
                    _launchStream(event.liveUrl!, title: event.title);
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
}
