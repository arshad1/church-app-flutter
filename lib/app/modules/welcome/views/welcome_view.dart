import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../data/services/settings_service.dart';
import '../../../routes/app_pages.dart';
import '../controllers/welcome_controller.dart';

class WelcomeView extends GetView<WelcomeController> {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsService = Get.find<SettingsService>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image with a slow "Ken Burns" zoom.
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 1.15, end: 1.0),
            duration: const Duration(seconds: 6),
            curve: Curves.easeOut,
            builder: (context, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: Image.asset(
              'assets/images/welcome_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          // Indigo overlay with a warm sunrise tint.
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.secondary.withValues(alpha: 0.18),
                  AppTheme.background.withValues(alpha: 0.55),
                  AppTheme.background,
                ],
                stops: const [0, 0.45, 0.85],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  FadeSlideIn(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: AppTheme.glow(),
                          ),
                          child: const Icon(
                            Icons.church_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Obx(
                          () => Text(
                            settingsService.settings.value?.churchName ??
                                'GraceCommunity',
                            style: AppTheme.heading(fontSize: 19),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  const FadeSlideIn(
                    index: 2,
                    child: PillLabel(
                      text: 'NEW UPDATES',
                      icon: Icons.auto_awesome_rounded,
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeSlideIn(
                    index: 3,
                    child: Text(
                      'Welcome Home',
                      style: AppTheme.heading(fontSize: 38),
                    ),
                  ),
                  const SizedBox(height: 14),
                  FadeSlideIn(
                    index: 4,
                    child: Text(
                      'Join a vibrant community of believers, access spiritual '
                      'content, and stay updated with church events.',
                      textAlign: TextAlign.center,
                      style: AppTheme.body(
                        fontSize: 15,
                        color: AppTheme.textSecondary,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  FadeSlideIn(
                    index: 5,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 26,
                          height: 6,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        for (var i = 0; i < 2; i++) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),
                  FadeSlideIn(
                    index: 6,
                    child: GradientButton(
                      label: 'Create Account',
                      icon: Icons.arrow_forward_rounded,
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(height: 14),
                  FadeSlideIn(
                    index: 7,
                    child: GlassCard(
                      height: 56,
                      radius: 18,
                      onTap: () => Get.toNamed(Routes.login),
                      child: Center(
                        child: Text(
                          'Log In',
                          style: AppTheme.body(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  FadeSlideIn(
                    index: 8,
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        'Continue as Guest',
                        style: AppTheme.body(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
