import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import '../../core/network/api_client.dart';
import '../models/notification_model.dart';

class NotificationService extends GetxService {
  FirebaseMessaging? _fcm;
  final ApiClient _client = ApiClient();

  // Observable list of notifications if we want global access,
  // but typically Controller manages the list. Service just fetches.

  Future<NotificationService> init() async {
    debugPrint("[NotificationService] Initializing...");
    try {
      _fcm = FirebaseMessaging.instance;
      debugPrint("[NotificationService] FirebaseMessaging instance created");
      await requestPermission();

      // Subscribe to 'all' topic for public announcements
      await _fcm!.subscribeToTopic('all');
      debugPrint("[NotificationService] Subscribed to 'all' topic");

      // Register token on init if available
      String? token = await getFcmToken();
      if (token != null) {
        debugPrint("[NotificationService] Found token on init, registering...");
        await _registerTokenInBackend(token);
      } else {
        debugPrint("[NotificationService] No token found on init");
      }

      // Listen for token refreshes
      onTokenRefresh.listen((token) {
        debugPrint("[NotificationService] Token refreshed: $token");
        _registerTokenInBackend(token);
      });
    } catch (e) {
      debugPrint(
        "[NotificationService] Firebase Messaging initialization failed: $e",
      );
      // Continue without FCM, API notifications will still work
    }
    return this;
  }

  Future<void> requestPermission() async {
    if (_fcm == null) return;

    try {
      debugPrint("[NotificationService] Requesting permission...");
      NotificationSettings settings = await _fcm!.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint(
        "[NotificationService] Permission status: ${settings.authorizationStatus}",
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('User granted permission');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        debugPrint('User granted provisional permission');
      } else {
        debugPrint('User declined or has not accepted permission');
      }
    } catch (e) {
      debugPrint("[NotificationService] Error requesting permission: $e");
    }
  }

  Future<String?> getFcmToken() async {
    if (_fcm == null) return null;
    try {
      String? token = await _fcm!.getToken();
      debugPrint("[NotificationService] FCM Token: $token");
      return token;
    } catch (e) {
      debugPrint("[NotificationService] Error getting FCM token: $e");
      return null;
    }
  }

  Stream<String> get onTokenRefresh {
    if (_fcm == null) return const Stream.empty();
    return _fcm!.onTokenRefresh;
  }

  Future<void> _registerTokenInBackend(String token) async {
    debugPrint(
      "[NotificationService] Attempting to register token in backend...",
    );
    try {
      String platform = Platform.isAndroid
          ? 'android'
          : (Platform.isIOS ? 'ios' : 'unknown');
      debugPrint("[NotificationService] Platform: $platform");

      // Ensure the endpoint matches backend route definition
      // notification.routes.ts: router.post('/register-token', ...)
      final response = await _client.post(
        '/notifications/register-token',
        data: {'token': token, 'platform': platform},
      );

      debugPrint(
        "[NotificationService] Backend Response: ${response.statusCode} - ${response.statusMessage}",
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint(
          "[NotificationService] FCM Token successfully registered in backend DB",
        );
      }
    } catch (e) {
      debugPrint("[NotificationService] Failed to register FCM token: $e");
      if (e is DioException) {
        debugPrint("[NotificationService] DioError Data: ${e.response?.data}");
        debugPrint(
          "[NotificationService] DioError Status: ${e.response?.statusCode}",
        );
      }
    }
  }

  // --- API Methods ---

  Future<Map<String, dynamic>> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _client.get(
        '/mobile/notifications',
        queryParameters: {'page': page, 'limit': limit},
      );

      if (response.statusCode == 200) {
        // Expected format: { data: [...], meta: { ... } }
        final Map<String, dynamic> body = response.data;
        final List<dynamic> listData = body['data'] ?? [];
        final List<NotificationModel> notifications = listData
            .map((json) => NotificationModel.fromJson(json))
            .toList();

        return {'data': notifications, 'meta': body['meta']};
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      if (e is DioException) {
        debugPrint("API Error getNotifications: ${e.message}");
        throw Exception(e.message);
      }
      throw Exception(e.toString());
    }
  }

  Future<void> markAsRead(String id) async {
    // Only call API if it's a real notification (numeric ID typically, but strict check here)
    if (!id.startsWith('ann_')) {
      try {
        await _client.put('/notifications/$id/read');
      } catch (e) {
        debugPrint('Error marking notification as read: $e');
      }
    }
  }
}
