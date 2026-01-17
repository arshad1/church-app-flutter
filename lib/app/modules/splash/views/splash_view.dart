import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/settings_service.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsService = Get.find<SettingsService>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Obx(() {
          final settings = settingsService.settings.value;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Using a Placeholder for Logo - You can replace this with your actual asset
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.2),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: settings?.logoUrl != null
                    ? ClipOval(
                        child: Image.network(
                          settings!.logoUrl!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset(
                                'assets/splash/splash_logo.png',
                                width: 80,
                                height: 80,
                                color: AppTheme.primary,
                              ),
                        ),
                      )
                    : Image.asset(
                        'assets/splash/splash_logo.png',
                        width: 80,
                        height: 80,
                        color: AppTheme.primary,
                      ),
              ),
              const SizedBox(height: 24),
              Text(
                settings?.churchName ?? "Church App",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
              ),
            ],
          );
        }),
      ),
    );
  }
}
