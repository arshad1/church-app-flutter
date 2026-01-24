import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/bottom_nav_bar.dart';
import '../../../routes/app_pages.dart';
import '../controllers/directory_controller.dart';
import '../../profile/views/add_family_member_view.dart';
import '../../profile/views/edit_family_member_view.dart';
import '../../profile/bindings/profile_binding.dart';

class DirectoryView extends GetView<DirectoryController> {
  const DirectoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  _buildHeader(),
                  SizedBox(height: 16.h),
                  _buildFamilyInfo(),
                  SizedBox(height: 16.h),
                  _buildSearchBar(),
                  SizedBox(height: 16.h),
                  Expanded(child: _buildContent()),
                ],
              ),
            ),

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
            'Family Directory',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.person_add,
                  color: AppTheme.primary,
                  size: 24.sp,
                ),
                onPressed: () => Get.to(
                  () => const AddFamilyMemberView(),
                  binding: ProfileBinding(),
                )?.then((_) => controller.refresh()),
                tooltip: 'Add Member',
              ),
              Obx(
                () => IconButton(
                  icon: Icon(
                    controller.viewMode.value == 'table'
                        ? Icons.account_tree
                        : Icons.table_chart,
                    color: AppTheme.primary,
                    size: 24.sp,
                  ),
                  onPressed: () => controller.toggleViewMode(),
                  tooltip: controller.viewMode.value == 'table'
                      ? 'Tree View'
                      : 'Table View',
                ),
              ),
              IconButton(
                icon: Icon(Icons.refresh, color: AppTheme.primary, size: 24.sp),
                onPressed: () => controller.refresh(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyInfo() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (controller.familyName != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.family_restroom,
                    color: AppTheme.primary,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    controller.familyName!,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
            if (controller.houseName != null) ...[
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(Icons.home, color: AppTheme.textSecondary, size: 18.sp),
                  SizedBox(width: 8.w),
                  Text(
                    controller.houseName!,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: AppTheme.textSecondary, size: 20.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: TextField(
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
                decoration: InputDecoration(
                  hintText: 'Search family members...',
                  hintStyle: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14.sp,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (value) => controller.searchMembers(value),
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

      if (controller.filteredMembers.isEmpty) {
        return Center(
          child: Text(
            controller.searchQuery.value.isEmpty
                ? 'No family members found'
                : 'No results for "${controller.searchQuery.value}"',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14.sp),
          ),
        );
      }

      return controller.viewMode.value == 'table'
          ? _buildTableView()
          : _buildTreeView();
    });
  }

  Widget _buildTableView() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Name',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Relationship',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Contact',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Table Rows
          ...controller.filteredMembers.asMap().entries.map((entry) {
            final index = entry.key;
            final member = entry.value;
            final isLast = index == controller.filteredMembers.length - 1;

            return Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: AppTheme.surface.withValues(alpha: 0.5),
                border: Border(
                  bottom: BorderSide(color: AppTheme.background, width: 1),
                ),
                borderRadius: isLast
                    ? BorderRadius.vertical(bottom: Radius.circular(12.r))
                    : null,
              ),
              child: InkWell(
                onTap: () => Get.to(
                  () => EditFamilyMemberView(member: member),
                  binding: ProfileBinding(),
                )?.then((_) => controller.refresh()),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16.r,
                            backgroundColor: AppTheme.primary.withValues(
                              alpha: 0.2,
                            ),
                            child: Text(
                              member.name?.substring(0, 1).toUpperCase() ?? '?',
                              style: TextStyle(
                                color: AppTheme.primary,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              member.name ?? 'Unknown',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        member.familyRole ?? 'N/A',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        member.phone ?? 'N/A',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTreeView() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: controller.filteredMembers.map((member) {
          final isHead =
              member.familyRole == 'Self' ||
              member.familyRole == 'HEAD' ||
              member.familyRole == 'Head of Family';
          final indentLevel = isHead ? 0 : 1;

          return Container(
            margin: EdgeInsets.only(left: (indentLevel * 24).w, bottom: 12.h),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: isHead
                  ? Border.all(color: AppTheme.primary, width: 2)
                  : null,
            ),
            child: InkWell(
              onTap: () => Get.to(
                () => EditFamilyMemberView(member: member),
                binding: ProfileBinding(),
              )?.then((_) => controller.refresh()),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    if (!isHead)
                      Container(
                        width: 2,
                        height: 40.h,
                        color: AppTheme.primary.withValues(alpha: 0.3),
                        margin: EdgeInsets.only(right: 12.w),
                      ),
                    CircleAvatar(
                      radius: 24.r,
                      backgroundColor: isHead
                          ? AppTheme.primary
                          : AppTheme.primary.withValues(alpha: 0.2),
                      child: Text(
                        member.name?.substring(0, 1).toUpperCase() ?? '?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  member.name ?? 'Unknown',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (isHead)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary,
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: Text(
                                    'HEAD',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            member.familyRole ?? 'N/A',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12.sp,
                            ),
                          ),
                          if (member.phone != null) ...[
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.phone,
                                  color: AppTheme.textSecondary,
                                  size: 12.sp,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  member.phone!,
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
