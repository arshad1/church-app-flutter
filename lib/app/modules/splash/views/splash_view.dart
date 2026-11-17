import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../data/models/settings_model.dart';
import '../../../data/services/settings_service.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsService = Get.find<SettingsService>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: AppBackground(
        child: Center(
          child: Obx(() {
            final settings = settingsService.settings.value;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo pops in with a gentle bounce and a breathing glow.
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.6, end: 1),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.elasticOut,
                  builder: (context, scale, child) =>
                      Transform.scale(scale: scale, child: child),
                  child: const _BreathingGlow(child: _SplashLogo()),
                ),
                const SizedBox(height: 32),
                FadeSlideIn(
                  index: 3,
                  child: Text(
                    settings?.churchName ?? 'Church App',
                    textAlign: TextAlign.center,
                    style: AppTheme.heading(fontSize: 30),
                  ),
                ),
                const SizedBox(height: 8),
                FadeSlideIn(
                  index: 5,
                  child: Text(
                    'Faith · Family · Fellowship',
                    style: AppTheme.body(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 56),
                const FadeSlideIn(index: 7, child: _GradientProgressBar()),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _SplashLogo extends StatelessWidget {
  const _SplashLogo();

  @override
  Widget build(BuildContext context) {
    return Obx(() => _build(Get.find<SettingsService>().settings.value));
  }

  Widget _build(SettingsModel? settings) {
    final fallback = Image.asset(
      'assets/splash/splash_logo.png',
      width: 72,
      height: 72,
      color: Colors.white,
    );

    return Container(
      width: 120,
      height: 120,
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppTheme.primaryGradient,
      ),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.background,
        ),
        alignment: Alignment.center,
        child: settings?.logoUrl != null
            ? ClipOval(
                child: Image.network(
                  settings!.logoUrl!,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => fallback,
                ),
              )
            : fallback,
      ),
    );
  }
}

class _BreathingGlow extends StatefulWidget {
  final Widget child;
  const _BreathingGlow({required this.child});

  @override
  State<_BreathingGlow> createState() => _BreathingGlowState();
}

class _BreathingGlowState extends State<_BreathingGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) => Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.secondary.withValues(alpha: 0.25 + _c.value * 0.3),
              blurRadius: 30 + _c.value * 30,
              spreadRadius: 2 + _c.value * 6,
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class _GradientProgressBar extends StatefulWidget {
  const _GradientProgressBar();

  @override
  State<_GradientProgressBar> createState() => _GradientProgressBarState();
}

class _GradientProgressBarState extends State<_GradientProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) => FractionalTranslation(
            translation: Offset(-1 + _c.value * 2, 0),
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
