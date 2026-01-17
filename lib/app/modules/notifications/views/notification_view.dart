import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
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
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          );
        }

        if (controller.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_off_outlined,
                  size: 64,
                  color: AppTheme.textSecondary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No notifications yet',
                  style: TextStyle(
                    color: AppTheme.textSecondary.withValues(alpha: 0.7),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.onRefresh,
          color: AppTheme.primary,
          backgroundColor: AppTheme.surface,
          child: ListView.separated(
            controller: controller.scrollController,
            padding: const EdgeInsets.all(16),
            itemCount:
                controller.notifications.length +
                (controller.isLoadingMore.value ? 1 : 0),
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == controller.notifications.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(
                      color: AppTheme.primary,
                      strokeWidth: 2,
                    ),
                  ),
                );
              }
              final notification = controller.notifications[index];
              return _buildNotificationItem(notification);
            },
          ),
        );
      }),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    final isAnnouncement = notification.type == NotificationType.announcement;
    final isRead =
        notification.isRead ==
        true; // Announcements are always "read" visually or handled differently

    return GestureDetector(
      onTap: () => controller.markAsRead(notification),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRead
              ? AppTheme.surface
              : AppTheme.surface.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(12),
          border: isRead
              ? null
              : Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
          // Highlight unread with a subtle border or background tint
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isAnnouncement
                    ? Colors.orange.withValues(alpha: 0.1)
                    : AppTheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isAnnouncement ? Icons.campaign : Icons.notifications,
                color: isAnnouncement ? Colors.orange : AppTheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title ?? 'No Title',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: isRead
                                ? FontWeight.w500
                                : FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (!isRead && !isAnnouncement)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body ?? '',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDate(notification.date),
                    style: TextStyle(
                      color: AppTheme.textSecondary.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
