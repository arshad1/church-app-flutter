import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../data/models/member_model.dart';
import '../../../core/widgets/bottom_nav_bar.dart';
import '../../../routes/app_pages.dart';
import '../controllers/profile_controller.dart';
import 'add_family_member_view.dart';
import 'edit_profile_view.dart';
import 'edit_family_member_view.dart';
import 'edit_family_view.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: AppBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    if (canPop)
                      GlassIconButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        size: 40,
                        onTap: () => Get.back(),
                      )
                    else
                      const SizedBox(width: 40),
                    Expanded(
                      child: Center(
                        child: Text(
                          'My Profile',
                          style: AppTheme.heading(fontSize: 20),
                        ),
                      ),
                    ),
                    GlassIconButton(
                      icon: Icons.logout_rounded,
                      size: 40,
                      iconColor: AppTheme.primary,
                      onTap: _confirmLogout,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const AppLoader();
                  }

                  final user = controller.user.value;
                  if (user == null || user.member == null) {
                    return const EmptyState(
                      icon: Icons.person_off_outlined,
                      message: 'No profile data',
                    );
                  }

                  final member = user.member!;

                  return DefaultTabController(
                    length: 3,
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        FadeSlideIn(child: _buildProfileHeader(member)),
                        const SizedBox(height: 20),
                        FadeSlideIn(
                          index: 2,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: AppTheme.glass,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppTheme.glassBorder),
                            ),
                            child: const TabBar(
                              labelColor: Colors.white,
                              tabs: [
                                Tab(height: 38, text: 'Personal'),
                                Tab(height: 38, text: 'Family'),
                                Tab(height: 38, text: 'Journey'),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _buildPersonalTab(member, user.email),
                              _buildFamilyTab(member),
                              _buildHistoryTab(member),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
              const AppBottomNavBar(currentRoute: Routes.profile),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmLogout() {
    Get.dialog(
      Dialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
          side: BorderSide(color: AppTheme.glassBorder),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.primaryGradient,
                  boxShadow: AppTheme.glow(),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(height: 18),
              Text('Logout', style: AppTheme.heading(fontSize: 22)),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to logout?',
                textAlign: TextAlign.center,
                style: AppTheme.body(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GlassCard(
                      height: 50,
                      radius: 16,
                      onTap: () => Get.back(),
                      child: Center(
                        child: Text(
                          'No',
                          style: AppTheme.body(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GradientButton(
                      label: 'Yes',
                      height: 50,
                      onPressed: () => controller.logout(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(MemberModel member) {
    final hasImage =
        member.profileImage != null && member.profileImage!.isNotEmpty;

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Gradient ring with soft glow
            Container(
              padding: const EdgeInsets.all(3.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const SweepGradient(
                  colors: [
                    AppTheme.accent,
                    AppTheme.secondary,
                    AppTheme.cyan,
                    AppTheme.accent,
                  ],
                ),
                boxShadow: AppTheme.glow(AppTheme.secondary, 0.4),
              ),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.background,
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: AppTheme.surface,
                  backgroundImage: hasImage
                      ? NetworkImage(member.profileImage!)
                      : null,
                  child: hasImage
                      ? null
                      : const GradientMask(
                          child: Icon(Icons.person_rounded, size: 54),
                        ),
                ),
              ),
            ),
            Positioned(
              right: 2,
              bottom: 2,
              child: PressableScale(
                onTap: () => Get.to(() => const EditProfileView()),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.background, width: 3),
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: Colors.white,
                    size: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                member.name ?? 'Guest',
                style: AppTheme.heading(fontSize: 25),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            const GradientMask(child: Icon(Icons.verified_rounded, size: 20)),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            PillLabel(
              text: (member.status ?? 'MEMBER').toUpperCase(),
              icon: Icons.workspace_premium_rounded,
            ),
            if (member.createdAt != null)
              Text(
                'Since ${member.createdAt!.year}',
                style: AppTheme.body(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
            if (member.family?.houses != null &&
                member.family!.houses!.isNotEmpty &&
                member.houseId != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.glass,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.glassBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.home_rounded,
                      color: AppTheme.accent,
                      size: 15,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      member.family!.houses!
                              .firstWhere(
                                (h) => h.id == member.houseId,
                                orElse: () => member.family!.houses!.first,
                              )
                              .name ??
                          'Unknown House',
                      style: AppTheme.body(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildPersonalTab(MemberModel member, String? email) {
    final hasEmail = email != null && email.isNotEmpty;
    final hasPhone = member.phone != null && member.phone!.isNotEmpty;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeSlideIn(
            child: _buildSectionHeader(
              'Contact Information',
              onEdit: () => Get.to(() => const EditProfileView()),
            ),
          ),
          const SizedBox(height: 14),
          FadeSlideIn(
            index: 1,
            child: _buildInfoCard(
              icon: Icons.email_rounded,
              label: 'EMAIL',
              value: email ?? 'No email',
              onTap: hasEmail
                  ? () => _launch(Uri(scheme: 'mailto', path: email))
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          FadeSlideIn(
            index: 2,
            child: _buildInfoCard(
              icon: Icons.phone_rounded,
              label: 'PHONE',
              value: member.phone ?? 'No phone',
              onTap: hasPhone
                  ? () => _launch(Uri(scheme: 'tel', path: member.phone!))
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          FadeSlideIn(
            index: 3,
            child: _buildInfoCard(
              icon: Icons.location_on_rounded,
              label: 'HOME ADDRESS',
              value: member.family?.address ?? 'No address linked',
            ),
          ),
          const SizedBox(height: 20),
          FadeSlideIn(
            index: 4,
            child: GlassCard(
              onTap: () => Get.toNamed(Routes.aboutUs),
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.church_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'About our church',
                      style: AppTheme.body(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppTheme.accent,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launch(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Widget _buildFamilyTab(MemberModel member) {
    final familyMembers = member.family?.members ?? [];
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeSlideIn(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'My Family',
                    style: AppTheme.heading(fontSize: 21),
                  ),
                ),
                PressableScale(
                  onTap: () => Get.to(() => const EditFamilyView()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.glass,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.glassBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.edit_rounded,
                          size: 14,
                          color: AppTheme.accent,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Edit Family',
                          style: AppTheme.body(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Family members as a grid of cards, with the "Add" card last.
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.78,
            ),
            itemCount: familyMembers.length + 1,
            itemBuilder: (context, index) {
              if (index == familyMembers.length) {
                return FadeSlideIn(
                  index: index,
                  child: _buildAddFamilyButton(),
                );
              }
              final fMember = familyMembers[index];
              final fullName = fMember.name ?? '?';
              final initial = fullName.trim().isNotEmpty
                  ? fullName.trim()[0].toUpperCase()
                  : '?';
              final hasImage =
                  fMember.profileImage != null &&
                  fMember.profileImage!.isNotEmpty;

              return FadeSlideIn(
                index: index,
                child: GlassCard(
                  onTap: () =>
                      Get.to(() => EditFamilyMemberView(member: fMember)),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppTheme.primaryGradient,
                        ),
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: AppTheme.surface,
                          backgroundImage: hasImage
                              ? NetworkImage(fMember.profileImage!)
                              : null,
                          child: hasImage
                              ? null
                              : Text(
                                  initial,
                                  style: AppTheme.heading(fontSize: 22),
                                ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        fullName,
                        textAlign: TextAlign.center,
                        style: AppTheme.body(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (fMember.familyRole != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          fMember.familyRole!,
                          style: AppTheme.body(
                            fontSize: 10,
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddFamilyButton() {
    return PressableScale(
      onTap: () => Get.to(() => const AddFamilyMemberView()),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.accent.withValues(alpha: 0.18),
              AppTheme.secondary.withValues(alpha: 0.10),
            ],
          ),
          border: Border.all(color: AppTheme.accent.withValues(alpha: 0.5)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.primaryGradient,
                boxShadow: AppTheme.glow(),
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              'Add Member',
              style: AppTheme.body(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab(MemberModel member) {
    final sacraments = member.sacraments ?? [];
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeSlideIn(
            child: Text(
              'Spiritual Journey',
              style: AppTheme.heading(fontSize: 21),
            ),
          ),
          const SizedBox(height: 16),
          if (sacraments.isEmpty)
            const EmptyState(
              icon: Icons.auto_awesome_outlined,
              message: 'No spiritual journey data available.',
            )
          else
            // Vertical timeline
            Stack(
              children: [
                Positioned(
                  left: 15,
                  top: 18,
                  bottom: 18,
                  child: Container(
                    width: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppTheme.accent,
                          AppTheme.secondary,
                          AppTheme.secondary.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
                Column(
                  children: [
                    for (var i = 0; i < sacraments.length; i++)
                      FadeSlideIn(
                        index: i + 1,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildJourneyCard(
                            icon: _getSacramentIcon(sacraments[i].type),
                            title: sacraments[i].type ?? 'Unknown',
                            date:
                                sacraments[i].date?.toString().split(' ')[0] ??
                                'Unknown Date',
                            location: sacraments[i].details ?? 'No details',
                            color: _getSacramentColor(sacraments[i].type),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildJourneyCard({
    required IconData icon,
    required String title,
    required String date,
    required String location,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Timeline node
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.background,
            border: Border.all(color: color, width: 2),
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 10),
            ],
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: AppTheme.body(
                    color: color,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  location,
                  style: AppTheme.body(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(
                      Icons.event_rounded,
                      size: 13,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      date,
                      style: AppTheme.body(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onEdit}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTheme.heading(fontSize: 21)),
        if (onEdit != null)
          PressableScale(
            onTap: onEdit,
            child: GradientMask(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.edit_rounded, size: 15),
                  const SizedBox(width: 4),
                  Text(
                    'Edit',
                    style: AppTheme.body(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    bool isLocked = false,
    VoidCallback? onTap,
  }) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.accent.withValues(alpha: 0.25),
                  AppTheme.secondary.withValues(alpha: 0.12),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppTheme.accent, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTheme.body(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(value, style: AppTheme.body(fontSize: 15)),
              ],
            ),
          ),
          if (isLocked)
            const Icon(
              Icons.lock_rounded,
              color: AppTheme.textSecondary,
              size: 16,
            )
          else if (onTap != null)
            const Icon(
              Icons.north_east_rounded,
              color: AppTheme.accent,
              size: 16,
            ),
        ],
      ),
    );
  }

  IconData _getSacramentIcon(String? type) {
    if (type == null) return Icons.star_rounded;
    switch (type.toUpperCase()) {
      case 'BAPTISM':
        return Icons.water_drop_rounded;
      case 'CONFIRMATION':
        return Icons.church_rounded;
      case 'MARRIAGE':
      case 'HOLY MATRIMONY':
        return Icons.favorite_rounded;
      case 'COMMUNION':
        return Icons.wine_bar_rounded;
      default:
        return Icons.stars_rounded;
    }
  }

  Color _getSacramentColor(String? type) {
    if (type == null) return AppTheme.accent;
    switch (type.toUpperCase()) {
      case 'BAPTISM':
        return AppTheme.cyan;
      case 'CONFIRMATION':
        return AppTheme.accent;
      case 'MARRIAGE':
      case 'HOLY MATRIMONY':
        return AppTheme.secondary;
      case 'COMMUNION':
        return const Color(0xFF34D399);
      default:
        return AppTheme.primary;
    }
  }
}
