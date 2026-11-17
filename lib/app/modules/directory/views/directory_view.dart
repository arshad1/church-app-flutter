import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/bottom_nav_bar.dart';
import '../../../core/widgets/ui_kit.dart';
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
      body: AppBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              FadeSlideIn(child: _buildHeader()),
              SizedBox(height: 16.h),
              FadeSlideIn(index: 1, child: _buildSearchBar()),
              SizedBox(height: 12.h),
              Expanded(child: _buildContent()),
              const AppBottomNavBar(currentRoute: Routes.directory),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Directory', style: AppTheme.heading(fontSize: 30.sp)),
                SizedBox(height: 4.h),
                Text(
                  'Our parish families, one tap away',
                  style: AppTheme.body(
                    fontSize: 13.sp,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          GlassIconButton(
            icon: Icons.refresh_rounded,
            onTap: () => controller.refresh(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: TextField(
        style: AppTheme.body(fontSize: 14.sp),
        cursorColor: AppTheme.primary,
        textInputAction: TextInputAction.search,
        decoration: AppTheme.inputDecoration(
          hint: 'Search names, houses, families…',
          icon: Icons.search_rounded,
        ),
        onChanged: (value) => controller.searchDirectory(value),
      ),
    );
  }

  Widget _buildContent() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const AppLoader();
      }

      if (controller.families.isEmpty) {
        return EmptyState(
          icon: controller.searchQuery.value.isEmpty
              ? Icons.groups_outlined
              : Icons.search_off_rounded,
          message: controller.searchQuery.value.isEmpty
              ? 'No families found'
              : 'No results for "${controller.searchQuery.value}"',
        );
      }

      return RefreshIndicator(
        color: AppTheme.primary,
        backgroundColor: AppTheme.surface,
        onRefresh: () => controller.fetchDirectory(isRefresh: true),
        child: ListView.builder(
          controller: controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
          itemCount:
              controller.families.length +
              (controller.isLoadMore.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == controller.families.length) {
              return const AppLoader();
            }

            final family = controller.families[index];
            return FadeSlideIn(
              index: index % 8,
              child: _buildFamilyCard(family),
            );
          },
        ),
      );
    });
  }

  Widget _buildFamilyCard(FamilyModel family) {
    final query = controller.searchQuery.value.trim();

    if (family.houses != null && family.houses!.isNotEmpty) {
      var houses = family.houses!;
      // While searching, show only the houses that matched — unless the
      // family name itself matched, then show the whole family.
      if (query.isNotEmpty &&
          !DirectoryController.familyNameMatches(family, query)) {
        final matched = houses
            .where((h) => DirectoryController.houseMatches(h, query))
            .toList();
        if (matched.isNotEmpty) houses = matched;
      }
      return Column(
        children: houses.map((house) {
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

    // Open the household automatically when the search matched one of its
    // other members, so the match is visible straight away.
    final query = controller.searchQuery.value.trim().toLowerCase();
    final expandForSearch =
        query.isNotEmpty &&
        otherMembers.any((m) => DirectoryController.memberMatches(m, query));

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
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppTheme.glass,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Theme(
        data: Theme.of(Get.context!).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          key: ValueKey('${head.id}-$houseName-$query'),
          initiallyExpanded: expandForSearch,
          tilePadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
          childrenPadding: EdgeInsets.only(bottom: 6.h),
          shape: const Border(),
          collapsedShape: const Border(),
          iconColor: AppTheme.accent,
          collapsedIconColor: AppTheme.accent,
          trailing: otherMembers.isEmpty ? const SizedBox.shrink() : null,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.home_rounded,
                          size: 12.sp,
                          color: AppTheme.accent,
                        ),
                        SizedBox(width: 5.w),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 190.w),
                          child: Text(
                            headerText,
                            style: AppTheme.body(
                              color: AppTheme.accent,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (otherMembers.isNotEmpty) ...[
                    SizedBox(width: 8.w),
                    Text(
                      '+${otherMembers.length}',
                      style: AppTheme.body(
                        fontSize: 11.sp,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 12.h),
              _buildHeadDetails(head),
            ],
          ),
          children: otherMembers.map((m) => _buildMemberTile(m)).toList(),
        ),
      ),
    );
  }

  String _initial(String? name) {
    final n = name?.trim() ?? '';
    return n.isEmpty ? '?' : n.substring(0, 1).toUpperCase();
  }

  Widget _avatar(MemberModel member, double size) {
    final hasImage =
        member.profileImage != null && member.profileImage!.isNotEmpty;
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(size * 0.28),
          image: hasImage
              ? DecorationImage(
                  image: NetworkImage(member.profileImage!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        alignment: Alignment.center,
        child: hasImage
            ? null
            : GradientMask(
                child: Text(
                  _initial(member.name),
                  style: AppTheme.heading(fontSize: size * 0.4),
                ),
              ),
      ),
    );
  }

  Widget _buildHeadDetails(MemberModel head) {
    return Row(
      children: [
        _avatar(head, 52.r),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                head.name ?? 'Unknown',
                style: AppTheme.body(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 3.h),
              Row(
                children: [
                  Icon(
                    Icons.star_rounded,
                    size: 12.sp,
                    color: AppTheme.accent,
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'Head of family',
                    style: AppTheme.body(
                      color: AppTheme.textSecondary,
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
              if (head.phone != null) ...[
                SizedBox(height: 2.h),
                Text(
                  head.phone!,
                  style: AppTheme.body(
                    color: AppTheme.textMuted,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (head.phone != null && head.phone!.isNotEmpty)
          _buildActionButton(Icons.call_rounded, () => _call(head.phone!)),
      ],
    );
  }

  Widget _buildMemberTile(MemberModel member) {
    return Padding(
      padding: EdgeInsets.fromLTRB(14.w, 4.h, 14.w, 8.h),
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            _avatar(member, 40.r),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name ?? 'Unknown',
                    style: AppTheme.body(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    member.familyRole ?? 'Member',
                    style: AppTheme.body(
                      color: AppTheme.textSecondary,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            if (member.phone != null && member.phone!.isNotEmpty)
              _buildActionButton(
                Icons.call_rounded,
                () => _call(member.phone!),
                isGhost: true,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _call(String phone) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Widget _buildActionButton(
    IconData icon,
    VoidCallback onTap, {
    bool isGhost = false,
  }) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        width: isGhost ? 36.r : 42.r,
        height: isGhost ? 36.r : 42.r,
        decoration: BoxDecoration(
          gradient: isGhost ? null : AppTheme.primaryGradient,
          color: isGhost ? AppTheme.accent.withValues(alpha: 0.12) : null,
          shape: BoxShape.circle,
          boxShadow: isGhost ? null : AppTheme.glow(AppTheme.secondary, 0.3),
        ),
        child: Icon(
          icon,
          color: isGhost ? AppTheme.accent : Colors.white,
          size: isGhost ? 17.sp : 20.sp,
        ),
      ),
    );
  }
}
