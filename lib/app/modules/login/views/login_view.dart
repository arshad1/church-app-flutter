import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../data/services/settings_service.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: AppBackground(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(bottom: 24 + bottomInset),
          child: Column(
            children: [
              _buildHero(context),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    FadeSlideIn(
                      index: 3,
                      child: TextField(
                        controller: controller.emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        style: AppTheme.body(fontSize: 15),
                        cursorColor: AppTheme.primary,
                        decoration: AppTheme.inputDecoration(
                          label: 'Email or Username',
                          hint: 'Enter your email or username',
                          icon: Icons.person_outline_rounded,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeSlideIn(
                      index: 4,
                      child: Obx(
                        () => TextField(
                          controller: controller.passwordController,
                          obscureText: !controller.isPasswordVisible.value,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) {
                            if (!controller.isLoading.value) controller.login();
                          },
                          style: AppTheme.body(fontSize: 15),
                          cursorColor: AppTheme.primary,
                          decoration: AppTheme.inputDecoration(
                            label: 'Password',
                            hint: 'Enter your password',
                            icon: Icons.lock_outline_rounded,
                            suffix: IconButton(
                              icon: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                transitionBuilder: (child, anim) =>
                                    ScaleTransition(scale: anim, child: child),
                                child: Icon(
                                  controller.isPasswordVisible.value
                                      ? Icons.visibility_rounded
                                      : Icons.visibility_off_rounded,
                                  key: ValueKey(
                                    controller.isPasswordVisible.value,
                                  ),
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              onPressed: controller.togglePasswordVisibility,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    FadeSlideIn(
                      index: 5,
                      child: Obx(
                        () => GradientButton(
                          label: 'Sign In',
                          icon: Icons.login_rounded,
                          isLoading: controller.isLoading.value,
                          onPressed: controller.login,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    FadeSlideIn(index: 6, child: _ornament()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return SizedBox(
      height: 360 + topPad,
      child: Stack(
        fit: StackFit.expand,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 1.12, end: 1.0),
            duration: const Duration(seconds: 4),
            curve: Curves.easeOut,
            builder: (context, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: Image.asset('assets/images/login.png', fit: BoxFit.cover),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.secondary.withValues(alpha: 0.15),
                  AppTheme.background.withValues(alpha: 0.6),
                  AppTheme.background,
                ],
                stops: const [0, 0.55, 1],
              ),
            ),
          ),
          // Back button (only when there is a page to go back to).
          if (Navigator.of(context).canPop())
            Positioned(
              top: topPad + 8,
              left: 16,
              child: GlassIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                size: 40,
                onTap: () => Get.back(),
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: Column(
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.5, end: 1),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.elasticOut,
                  builder: (context, s, child) =>
                      Transform.scale(scale: s, child: child),
                  child: _logo(),
                ),
                const SizedBox(height: 22),
                FadeSlideIn(
                  index: 1,
                  child: Text(
                    'Welcome Home',
                    style: AppTheme.heading(fontSize: 34),
                  ),
                ),
                const SizedBox(height: 8),
                FadeSlideIn(
                  index: 2,
                  child: Text(
                    'Sign in to connect with your community',
                    style: AppTheme.body(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _logo() {
    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: AppTheme.primaryGradient,
        boxShadow: AppTheme.glow(AppTheme.secondary, 0.5),
      ),
      padding: const EdgeInsets.all(2),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: AppTheme.background.withValues(alpha: 0.85),
        ),
        alignment: Alignment.center,
        child: Obx(() {
          final settings = Get.find<SettingsService>().settings.value;
          const fallback = GradientMask(
            child: Icon(Icons.church_rounded, size: 42),
          );
          return settings?.logoUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Image.network(
                    settings!.logoUrl!,
                    width: 78,
                    height: 78,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => fallback,
                  ),
                )
              : fallback;
        }),
      ),
    );
  }

  Widget _ornament() {
    final line = Expanded(
      child: Container(height: 1, color: AppTheme.glassBorder),
    );
    return Row(
      children: [
        line,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: GradientMask(
            child: Text(
              '✦  PEACE BE WITH YOU  ✦',
              style: AppTheme.body(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
        line,
      ],
    );
  }
}
