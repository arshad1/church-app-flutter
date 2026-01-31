import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/bottom_nav_bar.dart';
import '../../../routes/app_pages.dart';
import '../controllers/directory_controller.dart';
import '../../../data/models/family_model.dart';
import '../../../data/models/member_model.dart';

class DirectoryView extends GetView<DirectoryController> {
  const DirectoryView({super.key});

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

  Widget _buildFamilyCard(FamilyModel family) {
    if (family.houses != null && family.houses!.isNotEmpty) {
      return Column(
        children: family.houses!.map((house) {
          return _buildHouseholdItem(
            members: house.members ?? [],
            houseName: house.name,
            familyName: family.name,
          );
        }).toList(),
      );
    }

    return _buildHouseholdItem(
      members: family.members ?? [],
      houseName: family.houseName,
      familyName: family.name,
    );
  }

  Widget _buildHouseholdItem({
    required List<MemberModel> members,
    String? houseName,
    String? familyName,
  }) {
    if (members.isEmpty) return const SizedBox.shrink();

    MemberModel? head;
    try {
      head = members.firstWhere((m) => m.headOfFamily == true);
    } catch (_) {
      if (members.isNotEmpty) head = members.first;
    }

    if (head == null) return const SizedBox.shrink();

    final otherMembers = members.where((m) => m.id != head!.id).toList();

    // Header Text Logic
    final houseStr = houseName?.trim() ?? '';
    final familyStr = familyName?.trim() ?? '';
    String headerText = houseStr;
    if (familyStr.isNotEmpty && familyStr != houseStr) {
      if (headerText.isNotEmpty) headerText += ' • ';
      headerText += familyStr;
    }
    if (headerText.isEmpty) headerText = 'Family';

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.surface, width: 1),
      ),
      child: Theme(
        data: Theme.of(Get.context!).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          childrenPadding: EdgeInsets.zero,
          trailing: otherMembers.isEmpty
              ? const SizedBox.shrink()
              : Icon(Icons.keyboard_arrow_down, color: AppTheme.primary),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Label
              Row(
                children: [
                  Icon(Icons.home, size: 12.sp, color: AppTheme.primary),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      headerText,
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              // Head Details
              _buildHeadDetails(head),
            ],
          ),
          children: otherMembers.map((m) => _buildMemberTile(m)).toList(),
        ),
      ),
    );
  }

  Widget _buildHeadDetails(MemberModel head) {
    return Row(
      children: [
        Container(
          width: 50.r,
          height: 50.r,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            image: head.profileImage != null
                ? DecorationImage(
                    image: NetworkImage(head.profileImage!),
                    fit: BoxFit.cover,
                  )
                : null,
            color: head.profileImage == null
                ? AppTheme.primary.withValues(alpha: 0.2)
                : null,
          ),
          child: head.profileImage == null
              ? Center(
                  child: Text(
                    head.name?.substring(0, 1).toUpperCase() ?? '?',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                head.name ?? 'Unknown',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (head.phone != null) ...[
                SizedBox(height: 4.h),
                Text(
                  head.phone!,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (head.phone != null && head.phone!.isNotEmpty)
          _buildActionButton(Icons.phone, () async {
            final Uri launchUri = Uri(
              scheme: 'tel',
              path: head.phone!,
            );
            if (await canLaunchUrl(launchUri)) {
              await launchUrl(launchUri);
            }
          }),
      ],
    );
  }

  Widget _buildMemberTile(MemberModel member) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 16.h),
      child: Row(
        children: [
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
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
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : null,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name ?? 'Unknown',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  member.familyRole ?? 'Member',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          if (member.phone != null && member.phone!.isNotEmpty)
            _buildActionButton(Icons.phone, () async {
              final Uri launchUri = Uri(
                scheme: 'tel',
                path: member.phone!,
              );
              if (await canLaunchUrl(launchUri)) {
                await launchUrl(launchUri);
              }
            }, isGhost: true),
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
