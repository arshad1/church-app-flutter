import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_pages.dart';

class LoginController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final GetStorage _storage = GetStorage();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isPasswordVisible = false.obs;
  final isLoading = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        "Required",
        "Please enter both email and password",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
      return;
    }

    if (!GetUtils.isEmail(email)) {
      Get.snackbar(
        "Invalid Email",
        "Please enter a valid email address",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      final response = await _authService.login(email, password);

      // Save session
      final token = response['token'];
      final user = response['user'];

      await _storage.write('token', token);
      await _storage.write('user', user);

      // Register Token (Fire & Forget)
      // TODO: Replace with real FCM token when firebase_messaging is added
      _authService.registerToken(
        "dummy_fcm_token_${DateTime.now().millisecondsSinceEpoch}",
        GetPlatform.isAndroid ? "android" : "ios",
      );

      // Navigate to Landing Page instead of Home
      Get.offAllNamed(Routes.landing);
    } catch (e) {
      String message = "Login failed";
      if (e is DioException) {
        message =
            e.response?.data['message'] ?? e.message ?? "Connection error";
      } else {
        message = e.toString();
      }

      Get.snackbar(
        "Error",
        message,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
