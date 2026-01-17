import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/services/notification_service.dart';

class NotificationController extends GetxController {
  final NotificationService _service = Get.find<NotificationService>();

  final ScrollController scrollController = ScrollController();
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;

  // Pagination State
  final RxBool isLoading = true.obs;
  final RxBool isLoadingMore = false.obs;
  int _currentPage = 1;
  static const int _limit = 20;
  bool _hasMore = true;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();

    // Infinite Scroll Listener
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 200 &&
          !isLoading.value &&
          !isLoadingMore.value &&
          _hasMore) {
        _loadMore();
      }
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  Future<void> fetchNotifications({bool isRefresh = true}) async {
    try {
      if (isRefresh) {
        isLoading.value = true;
        _currentPage = 1;
        _hasMore = true;
      } else {
        isLoadingMore.value = true;
      }

      final result = await _service.getNotifications(
        page: _currentPage,
        limit: _limit,
      );
      final List<NotificationModel> newItems = result['data'];
      // final meta = result['meta'];

      if (isRefresh) {
        notifications.assignAll(newItems);
      } else {
        notifications.addAll(newItems);
      }

      // Update pagination cursor
      if (newItems.length < _limit) {
        _hasMore = false;
      } else {
        _currentPage++;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load notifications');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> onRefresh() async {
    await fetchNotifications(isRefresh: true);
  }

  Future<void> _loadMore() async {
    await fetchNotifications(isRefresh: false);
  }

  Future<void> markAsRead(NotificationModel notification) async {
    if (notification.isRead == true ||
        notification.type == NotificationType.announcement) {
      return; // Already read or is announcement
    }

    // Optimistic update
    notification.isRead = true;
    notifications.refresh();

    if (notification.id != null) {
      await _service.markAsRead(notification.id!);
    }
  }
}
