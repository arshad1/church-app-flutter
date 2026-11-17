import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../routes/app_pages.dart';
import '../theme/app_theme.dart';

/// Floating glass navigation bar. The active tab expands into a gradient pill
/// with its label; inactive tabs show icon + small label.
class AppBottomNavBar extends StatelessWidget {
  final String currentRoute;

  const AppBottomNavBar({super.key, required this.currentRoute});

  static const _items = [
    _NavItem(Icons.home_outlined, Icons.home_rounded, 'Home', Routes.home),
    _NavItem(
      Icons.calendar_today_outlined,
      Icons.calendar_month_rounded,
      'Events',
      Routes.events,
    ),
    _NavItem(
      Icons.play_circle_outline,
      Icons.play_circle_fill_rounded,
      'Media',
      Routes.media,
    ),
    _NavItem(
      Icons.people_outline,
      Icons.people_alt_rounded,
      'Directory',
      Routes.directory,
    ),
    _NavItem(
      Icons.person_outline,
      Icons.person_rounded,
      'Profile',
      Routes.profile,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(14.w, 6.h, 14.w, 10.h),
      child: Container(
        height: 66,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: const Color(0xE6161A44),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: AppTheme.glassBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _items
              .map(
                (item) => _NavButton(
                  item: item,
                  isActive: currentRoute == item.route,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  const _NavItem(this.icon, this.activeIcon, this.label, this.route);
}

class _NavButton extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  const _NavButton({required this.item, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (!isActive) Get.offNamed(item.route);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutBack,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 12 : 8,
          vertical: isActive ? 10 : 6,
        ),
        decoration: BoxDecoration(
          gradient: isActive ? AppTheme.primaryGradient : null,
          borderRadius: BorderRadius.circular(18),
          boxShadow: isActive ? AppTheme.glow(AppTheme.secondary, 0.4) : null,
        ),
        child: isActive
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(item.activeIcon, color: Colors.white, size: 18),
                  const SizedBox(width: 5),
                  Text(
                    item.label,
                    style: AppTheme.body(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(item.icon, color: AppTheme.textSecondary, size: 22),
                  const SizedBox(height: 3),
                  Text(
                    item.label,
                    style: AppTheme.body(
                      fontSize: 10,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
