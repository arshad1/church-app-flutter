import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: _buildAppBar(),
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 20.h),
              _buildProfileHeader(),
              SizedBox(height: 24.h),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildPersonalTab(),
                    _buildPlaceholderTab('Family'),
                    _buildPlaceholderTab('History'),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: AppTheme.primary,
          child: Icon(Icons.edit, color: Colors.white, size: 24.sp),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.background,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white, size: 24.sp),
        onPressed: () => Get.back(),
      ),
      title: Text(
        'My Profile',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.settings, color: AppTheme.primary, size: 24.sp),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 50.r,
              backgroundImage: const AssetImage('assets/images/avatar.png'),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.background, width: 3.w),
                ),
                child: Icon(Icons.edit, color: Colors.white, size: 14.sp),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    alpha: 0.1,
                  ), // Translucent backdrop for styling logic
                  borderRadius: BorderRadius.circular(10.r),
                ),
                // Could be another badge logic
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Sarah Smith', // Matching avatar gender
              style: TextStyle(
                color: Colors.white,
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 6.w),
            Icon(Icons.verified, color: AppTheme.primary, size: 20.sp),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                'ACTIVE MEMBER',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              'Since 2018',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.sp),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF374151), width: 1)),
      ),
      child: TabBar(
        labelColor: AppTheme.primary,
        unselectedLabelColor: AppTheme.textSecondary,
        labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        indicatorColor: AppTheme.primary,
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: const [
          Tab(text: 'Personal'),
          Tab(text: 'Family'),
          Tab(text: 'History'),
        ],
      ),
    );
  }

  Widget _buildPersonalTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Contact Information',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Edit',
                  style: TextStyle(color: AppTheme.primary, fontSize: 14.sp),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          _buildInfoCard(
            Icons.email,
            'EMAIL',
            'sarah.smith@email.com',
            isLocked: true,
          ),
          SizedBox(height: 12.h),
          _buildInfoCard(Icons.phone, 'PHONE', '+1 (555) 987-6543'),
          SizedBox(height: 12.h),
          _buildInfoCard(
            Icons.location_on,
            'HOME ADDRESS',
            '452 Willow Creek Blvd, Springfield, IL 62704',
          ),
          SizedBox(height: 32.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Family',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Manage',
                  style: TextStyle(color: AppTheme.primary, fontSize: 14.sp),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildFamilyList(),
          SizedBox(height: 32.h),
          Text(
            'Spiritual Journey',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          _buildJourneyCard(
            Icons.water_drop,
            'Baptism',
            'Oct 12, 1995 • St. Peter\'s Cathedral',
            AppTheme.primary.withValues(alpha: 0.2),
            AppTheme.primary,
          ),
          _buildJourneyCard(
            Icons.volunteer_activism, // Dove icon replacement
            'Confirmation',
            'May 20, 2010 • St. Mary\'s Church',
            Color(0xFFF97316).withValues(alpha: 0.2),
            Color(0xFFF97316),
          ),
          _buildJourneyCard(
            Icons.favorite,
            'Holy Matrimony',
            'Jun 15, 2018 • Sacred Heart Chapel',
            Colors.pink.withValues(alpha: 0.2),
            Colors.pink,
            isLast: true,
          ),
          SizedBox(height: 24.h),
          Center(
            child: TextButton(
              onPressed: () {},
              child: Text(
                'View Full History',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(height: 40.h), // Bottom padding for FAB
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    IconData icon,
    String label,
    String value, {
    bool isLocked = false,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppTheme.background,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.primary, size: 20.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (isLocked)
            Icon(Icons.lock, color: AppTheme.textSecondary, size: 18.sp),
        ],
      ),
    );
  }

  Widget _buildFamilyList() {
    return Row(
      children: [
        _buildFamilyMember('Jane', 'images/family_jane.png'), // Generated
        SizedBox(width: 16.w),
        _buildFamilyMember('Timmy', 'images/family_timmy.png'), // Generated
        SizedBox(width: 16.w),
        Column(
          children: [
            Container(
              width: 60.r,
              height: 60.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.textSecondary,
                  style: BorderStyle.solid,
                ),
              ),
              child: Icon(
                Icons.add,
                color: AppTheme.textSecondary,
                size: 24.sp,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Add',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.sp),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFamilyMember(String name, String asset) {
    return Column(
      children: [
        CircleAvatar(radius: 30.r, backgroundImage: AssetImage(asset)),
        SizedBox(height: 8.h),
        Text(
          name,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildJourneyCard(
    IconData icon,
    String title,
    String date,
    Color bg,
    Color iconColor, {
    bool isLast = false,
  }) {
    return Container(
      margin: EdgeInsets.only(
        bottom: isLast ? 0 : 4.h,
      ), // Reduced margin for linked look? Design has them separated but contained
      // Actually design shows them as a list in a container... wait, the screenshot shows separate containers for each item
      // but they look visually grouped. I'll stick to separate containers for cleaner code.
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : BorderSide(color: Color(0xFF374151), width: 1), // Divider
        ),
        // Group rounded corners?
        // Let's just make them look like list tiles.
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: iconColor, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  date,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderTab(String title) {
    return Center(
      child: Text(
        '$title Content Coming Soon',
        style: TextStyle(color: AppTheme.textSecondary, fontSize: 16.sp),
      ),
    );
  }
}
