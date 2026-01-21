import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../routes/app_pages.dart';
import '../theme/app_theme.dart';

class AppBottomNavBar extends StatelessWidget {
  final String currentRoute;

  const AppBottomNavBar({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: Color(0xFF1F2937))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: Icons.home_outlined,
            label: 'Home',
            route: Routes.home,
            isActive: currentRoute == Routes.home,
          ),
          _buildNavItem(
            icon: Icons.calendar_today_outlined,
            label: 'Events',
            route: Routes.events,
            isActive: currentRoute == Routes.events,
          ),
          _buildNavItem(
            icon: Icons.play_circle_outline,
            label: 'Media',
            route: Routes.media,
            isActive: currentRoute == Routes.media,
          ),
          _buildNavItem(
            icon: Icons.info_outline,
            label: 'Contact',
            route: Routes.aboutUs,
            isActive: currentRoute == Routes.aboutUs,
          ),
          _buildNavItem(
            icon: Icons.person_outline,
            label: 'Profile',
            route: Routes.profile,
            isActive: currentRoute == Routes.profile,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required String route,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () {
        if (!isActive) {
          Get.offNamed(route);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? AppTheme.primary : AppTheme.textSecondary,
            size: 24.sp,
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppTheme.primary : AppTheme.textSecondary,
              fontSize: 10.sp,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
