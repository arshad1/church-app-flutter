import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../data/services/settings_service.dart';
import '../controllers/landing_controller.dart';

class LandingView extends GetView<LandingController> {
  const LandingView({super.key});

  @override
  Widget build(BuildContext context) {
    final churchName =
        Get.find<SettingsService>().settings.value?.churchName ??
        'GraceCommunity';

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const Spacer(),
                // Success badge pops in, then the check draws itself.
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.elasticOut,
                  builder: (context, s, child) =>
                      Transform.scale(scale: s, child: child),
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.primaryGradient,
                      boxShadow: AppTheme.glow(AppTheme.secondary, 0.5),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 72,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                FadeSlideIn(
                  index: 3,
                  child: Text(
                    'Login Successful!',
                    style: AppTheme.heading(fontSize: 32),
                  ),
                ),
                const SizedBox(height: 14),
                FadeSlideIn(
                  index: 4,
                  child: Text(
                    'Welcome back to $churchName. '
                    'We are glad to have you here.',
                    textAlign: TextAlign.center,
                    style: AppTheme.body(
                      color: AppTheme.textSecondary,
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),
                ),
                const Spacer(),
                FadeSlideIn(
                  index: 6,
                  child: GradientButton(
                    label: 'Continue to Home',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: controller.goToHome,
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
