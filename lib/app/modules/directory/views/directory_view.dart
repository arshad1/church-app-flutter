import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/bottom_nav_bar.dart';
import '../../../routes/app_pages.dart';
import '../controllers/directory_controller.dart';

class DirectoryView extends GetView<DirectoryController> {
  const DirectoryView({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            SizedBox(height: 16.h),
            _buildSearchBar(),
            SizedBox(height: 16.h),
            Expanded(child: _buildContent()),
            const AppBottomNavBar(currentRoute: Routes.directory),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Community Directory',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: AppTheme.primary, size: 24.sp),
            onPressed: () => controller.refresh(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppTheme.surface, width: 1),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: AppTheme.textSecondary, size: 20.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: TextField(
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
                decoration: InputDecoration(
                  hintText: 'Search community...',
                  hintStyle: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14.sp,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (value) => controller.searchDirectory(value),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.families.isEmpty) {
        return Center(
          child: Text(
            controller.searchQuery.value.isEmpty
                ? 'No families found'
                : 'No results for "${controller.searchQuery.value}"',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14.sp),
          ),
        );
      }

      return ListView.builder(
        controller: controller.scrollController,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        itemCount:
            controller.families.length + (controller.isLoadMore.value ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == controller.families.length) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(16.h),
                child: const CircularProgressIndicator(),
              ),
            );
          }

          final family = controller.families[index];
          return _buildFamilyCard(family);
        },
      );
    });
  }

  Widget _buildFamilyCard(family) {
    bool hasMultipleHouses = family.houses != null && family.houses!.length > 1;
    bool hasSingleHouse = family.houses != null && family.houses!.length == 1;

    // Common decoration for the card container
    BoxDecoration cardDecoration = BoxDecoration(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: AppTheme.surface, width: 1),
    );

    if (hasSingleHouse) {
      // Single House: Show House Name as Parent Node
      var house = family.houses![0];
      return Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: cardDecoration,
        child: Theme(
          data: Theme.of(
            Get.context!,
          ).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            title: Text(
              house.name ?? (family.name ?? 'Unknown Family'),
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              family.name ?? '', // Show family name as subtitle context
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.sp),
            ),
            iconColor: AppTheme.primary,
            collapsedIconColor: AppTheme.textSecondary,
            children: (house.members ?? []).map<Widget>((member) {
              return _buildMemberTile(member, family);
            }).toList(),
          ),
        ),
      );
    } else if (hasMultipleHouses) {
      // Multiple Houses: Family Name -> List of Houses -> Members
      return Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: cardDecoration,
        child: Theme(
          data: Theme.of(
            Get.context!,
          ).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            title: Text(
              family.name ?? 'Unknown Family',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            iconColor: AppTheme.primary,
            collapsedIconColor: AppTheme.textSecondary,
            children: family.houses!.map<Widget>((house) {
              return ExpansionTile(
                title: Text(
                  house.name ?? 'Unknown House',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 15.sp,
                  ),
                ),
                iconColor: AppTheme.primary,
                collapsedIconColor: AppTheme.textSecondary,
                children: (house.members ?? []).map<Widget>((member) {
                  return _buildMemberTile(member, family);
                }).toList(),
              );
            }).toList(),
          ),
        ),
      );
    } else {
      // Fallback: No Houses (Just Members)
      return Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: cardDecoration,
        child: Theme(
          data: Theme.of(
            Get.context!,
          ).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            title: Text(
              family.name ?? 'Unknown Family',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            iconColor: AppTheme.primary,
            collapsedIconColor: AppTheme.textSecondary,
            children: (family.members ?? []).map<Widget>((member) {
              return _buildMemberTile(member, family);
            }).toList(),
          ),
        ),
      );
    }
  }

  Widget _buildMemberTile(member, family) {
    bool isHead = member.headOfFamily ?? false;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.background.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 60.r,
            height: 60.r,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              image: member.profileImage != null
                  ? DecorationImage(
                      image: NetworkImage(member.profileImage!),
                      fit: BoxFit.cover,
                    )
                  : null,
              color: member.profileImage == null
                  ? AppTheme.primary.withValues(alpha: 0.2)
                  : null,
            ),
            child: member.profileImage == null
                ? Center(
                    child: Text(
                      member.name?.substring(0, 1).toUpperCase() ?? '?',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : null,
          ),
          SizedBox(width: 16.w),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name ?? 'Unknown',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  family.name ?? 'Family', // "${family.name} Family"
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14.sp,
                  ),
                ),
                if (member.phone != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    member.phone!,
                    style: TextStyle(
                      color: AppTheme.textSecondary.withValues(alpha: 0.7),
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Actions
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: isHead
                      ? AppTheme.primary.withValues(alpha: 0.2)
                      : AppTheme.surface,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: isHead
                        ? AppTheme.primary
                        : AppTheme.textSecondary.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  isHead ? 'HEAD' : (member.familyRole ?? 'MEMBER'),
                  style: TextStyle(
                    color: isHead ? AppTheme.primary : AppTheme.textSecondary,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (member.phone != null && member.phone!.isNotEmpty) ...[
                SizedBox(width: 8.w),
                _buildActionButton(Icons.phone, () async {
                  final Uri emailLaunchUri = Uri(
                    scheme: 'tel',
                    path: member.phone!,
                  );
                  if (await canLaunchUrl(emailLaunchUri)) {
                    await launchUrl(emailLaunchUri);
                  }
                }),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    VoidCallback onTap, {
    bool isGhost = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: isGhost
              ? Colors.transparent
              : AppTheme.textSecondary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isGhost ? AppTheme.textSecondary : AppTheme.primary,
          size: 18.sp,
        ),
      ),
    );
  }
}
