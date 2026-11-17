import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../../app/data/models/notification_model.dart';
import '../controllers/notification_controller.dart';
import 'package:intl/intl.dart';

class NotificationView extends GetView<NotificationController> {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized
    Get.put(NotificationController());

    return Scaffold(
      backgroundColor: AppTheme.background,
      extendBodyBehindAppBar: true,
      appBar: glassAppBar('Notifications', onBack: () => Get.back()),
      body: AppBackground(
        child: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const AppLoader();
            }

            if (controller.notifications.isEmpty) {
              return const EmptyState(
                icon: Icons.notifications_off_outlined,
                message: 'No notifications yet\nWe\'ll let you know when '
                    'something new happens.',
              );
            }

            return RefreshIndicator(
              onRefresh: controller.onRefresh,
              color: AppTheme.primary,
              backgroundColor: AppTheme.surface,
              child: ListView.separated(
                controller: controller.scrollController,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount:
                    controller.notifications.length +
                    (controller.isLoadingMore.value ? 1 : 0),
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index == controller.notifications.length) {
                    return const AppLoader();
                  }
                  final notification = controller.notifications[index];
                  return FadeSlideIn(
                    index: index % 10,
                    child: _buildNotificationItem(notification),
                  );
                },
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    final isAnnouncement = notification.type == NotificationType.announcement;
    final isRead = notification.isRead == true;
    final highlight = !isRead && !isAnnouncement;

    return GlassCard(
      onTap: () => controller.markAsRead(notification),
      padding: const EdgeInsets.all(14),
      borderColor: highlight
          ? AppTheme.primary.withValues(alpha: 0.55)
          : null,
      gradient: highlight
          ? LinearGradient(
              colors: [
                AppTheme.secondary.withValues(alpha: 0.14),
                Colors.white.withValues(alpha: 0.05),
              ],
            )
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: isAnnouncement
                  ? const LinearGradient(
                      colors: [AppTheme.accent, Color(0xFFFF8E5B)],
                    )
                  : AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isAnnouncement
                  ? Icons.campaign_rounded
                  : Icons.notifications_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title ?? 'No Title',
                        style: AppTheme.body(
                          fontWeight: isRead
                              ? FontWeight.w500
                              : FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    if (highlight)
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: PulsingDot(size: 8, color: AppTheme.primary),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.body ?? '',
                  style: AppTheme.body(
                    color: AppTheme.textSecondary,
                    fontSize: 13.5,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (isAnnouncement) ...[
                      Text(
                        'ANNOUNCEMENT',
                        style: AppTheme.body(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.accent,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      _formatDate(notification.date),
                      style: AppTheme.body(
                        color: AppTheme.textMuted,
                        fontSize: 12,
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

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString).toLocal();
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return DateFormat.jm().format(date); // Today, show time (e.g. 5:30 PM)
      } else if (difference.inDays < 7) {
        return DateFormat.E().add_jm().format(date); // e.g. Mon 5:30 PM
      } else {
        return DateFormat.yMMMd().format(date); // e.g. Jan 17, 2026
      }
    } catch (e) {
      return '';
    }
  }
}
