import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Shared, animated building blocks for the "Sunrise Coral & Indigo" design.
/// Pure Flutter only — no extra packages required.

// -----------------------------------------------------------------------------
// Background
// -----------------------------------------------------------------------------

/// Indigo gradient with soft coral and cyan glows. Wrap a screen's body in it.
class AppBackground extends StatelessWidget {
  final Widget child;
  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
      child: Stack(
        children: [
          Positioned(
            top: -140,
            right: -120,
            child: _Glow(color: AppTheme.secondary, size: 340),
          ),
          Positioned(
            top: 260,
            left: -160,
            child: _Glow(color: AppTheme.cyan, size: 300, alpha: 0.16),
          ),
          Positioned(
            bottom: -160,
            right: -100,
            child: _Glow(color: AppTheme.accent, size: 300, alpha: 0.14),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  final Color color;
  final double size;
  final double alpha;
  const _Glow({required this.color, required this.size, this.alpha = 0.28});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: alpha), color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Cards & buttons
// -----------------------------------------------------------------------------

/// Translucent card with a thin warm border. Tappable cards shrink slightly
/// when pressed.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final VoidCallback? onTap;
  final Color? borderColor;
  final Gradient? gradient;
  final double? width;
  final double? height;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.radius = 20,
    this.onTap,
    this.borderColor,
    this.gradient,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? AppTheme.glass : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor ?? AppTheme.glassBorder),
      ),
      child: child,
    );
    if (onTap == null) return card;
    return PressableScale(onTap: onTap, child: card);
  }
}

/// Shrinks its child a little while pressed — gives every tap a tactile feel.
class PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scale;

  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scale = 0.96,
  });

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _down = false;

  void _set(bool v) {
    if (mounted && _down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.onTap == null ? null : (_) => _set(true),
      onTapUp: widget.onTap == null ? null : (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Full-width orange→pink gradient button with optional icon and loader.
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final double height;
  final Gradient gradient;

  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.height = 56,
    this.gradient = AppTheme.primaryGradient,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    return PressableScale(
      onTap: enabled ? onPressed : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: enabled || isLoading ? 1 : 0.5,
        child: Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: AppTheme.glow(),
          ),
          alignment: Alignment.center,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: isLoading
                ? const SizedBox(
                    key: ValueKey('loading'),
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    key: const ValueKey('label'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        label,
                        style: AppTheme.body(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Round translucent icon button (back, bell, share, ...).
class GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final Color? iconColor;
  final bool showDot;

  const GlassIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 44,
    this.iconColor,
    this.showDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppTheme.glass,
          borderRadius: BorderRadius.circular(size * 0.32),
          border: Border.all(color: AppTheme.glassBorder),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: iconColor ?? Colors.white, size: size * 0.5),
            if (showDot)
              Positioned(
                top: size * 0.22,
                right: size * 0.24,
                child: const PulsingDot(size: 8, color: AppTheme.accent),
              ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Text helpers
// -----------------------------------------------------------------------------

/// Paints any child (text or icon) with the brand gradient.
class GradientMask extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  const GradientMask({
    super.key,
    required this.child,
    this.gradient = AppTheme.primaryGradient,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: child,
    );
  }
}

/// Serif section title with optional gradient "See all" link.
class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  final String actionLabel;

  const SectionHeader({
    super.key,
    required this.title,
    this.onSeeAll,
    this.actionLabel = 'See all',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(child: Text(title, style: AppTheme.heading(fontSize: 21))),
        if (onSeeAll != null)
          PressableScale(
            onTap: onSeeAll,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              child: GradientMask(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      actionLabel,
                      style: AppTheme.body(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.arrow_forward_rounded, size: 16),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Small pill label such as "VERSE OF THE DAY" or "FEATURED".
class PillLabel extends StatelessWidget {
  final String text;
  final IconData? icon;
  final bool filled;

  const PillLabel({
    super.key,
    required this.text,
    this.icon,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final fg = filled ? Colors.white : AppTheme.accent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: filled ? AppTheme.primaryGradient : null,
        color: filled ? null : AppTheme.accent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(30),
        border: filled ? null : Border.all(color: AppTheme.glassBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: fg),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: AppTheme.body(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: fg,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Animations
// -----------------------------------------------------------------------------

/// Fades and slides its child up into place. Pass [index] to stagger lists.
class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration duration;
  final double offsetY;
  final int staggerMs;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.index = 0,
    this.duration = const Duration(milliseconds: 550),
    this.offsetY = 28,
    this.staggerMs = 70,
  });

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final Animation<double> _t = CurvedAnimation(
    parent: _c,
    curve: Curves.easeOutCubic,
  );

  @override
  void initState() {
    super.initState();
    final delay = Duration(
      milliseconds: (widget.index.clamp(0, 12)) * widget.staggerMs,
    );
    Future.delayed(delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      child: widget.child,
      builder: (context, child) => Opacity(
        opacity: _t.value,
        child: Transform.translate(
          offset: Offset(0, (1 - _t.value) * widget.offsetY),
          child: child,
        ),
      ),
    );
  }
}

/// A dot that softly pulses — used for "live" and unread indicators.
class PulsingDot extends StatefulWidget {
  final double size;
  final Color color;
  const PulsingDot({super.key, this.size = 8, this.color = AppTheme.live});

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    return SizedBox(
      width: s,
      height: s,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Transform.scale(
              scale: 1 + _c.value * 1.6,
              child: Container(
                width: s,
                height: s,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withValues(alpha: (1 - _c.value) * 0.5),
                ),
              ),
            ),
            Container(
              width: s,
              height: s,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Red "LIVE" badge with a pulsing dot.
class LiveBadge extends StatelessWidget {
  final String text;
  final bool compact;
  const LiveBadge({super.key, this.text = 'LIVE NOW', this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 7 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: AppTheme.live,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.glow(AppTheme.live, 0.45),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PulsingDot(size: compact ? 5 : 6, color: Colors.white),
          SizedBox(width: compact ? 4 : 6),
          Text(
            text,
            style: AppTheme.body(
              fontSize: compact ? 9 : 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

/// Sweeps a soft light band across its child every few seconds.
class ShimmerSweep extends StatefulWidget {
  final Widget child;
  final BorderRadius borderRadius;
  const ShimmerSweep({
    super.key,
    required this.child,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  State<ShimmerSweep> createState() => _ShimmerSweepState();
}

class _ShimmerSweepState extends State<ShimmerSweep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3600),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: Stack(
        children: [
          widget.child,
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _c,
                builder: (context, _) {
                  // Sweep during the first 40% of the cycle, then rest.
                  final t = (_c.value / 0.4).clamp(0.0, 1.0);
                  return FractionalTranslation(
                    translation: Offset(-1.2 + t * 2.4, 0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.white.withValues(alpha: 0),
                            Colors.white.withValues(alpha: 0.16),
                            Colors.white.withValues(alpha: 0),
                          ],
                          stops: const [0.3, 0.5, 0.7],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Branded loading spinner.
class AppLoader extends StatelessWidget {
  const AppLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: AppTheme.primary,
          ),
        ),
      ),
    );
  }
}

/// Friendly empty state with an icon in a gradient circle.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const EmptyState({super.key, required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.glass,
                border: Border.all(color: AppTheme.glassBorder),
              ),
              child: GradientMask(child: Icon(icon, size: 34)),
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTheme.body(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Transparent app bar with a glass back button and serif title.
PreferredSizeWidget glassAppBar(
  String title, {
  List<Widget>? actions,
  bool showBack = true,
  VoidCallback? onBack,
}) {
  return AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    automaticallyImplyLeading: false,
    titleSpacing: showBack ? 0 : 20,
    leading: showBack
        ? Builder(
            builder: (context) => Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Center(
                child: GlassIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  size: 40,
                  onTap: onBack ?? () => Navigator.of(context).maybePop(),
                ),
              ),
            ),
          )
        : null,
    leadingWidth: showBack ? 64 : null,
    title: Text(title, style: AppTheme.heading(fontSize: 22)),
    actions: actions,
  );
}
