import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
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
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: const Text('My Profile', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppTheme.primary),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final user = controller.user.value;
                if (user == null || user.member == null) {
                  return const Center(
                    child: Text(
                      'No profile data',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                final member = user.member!;

                return DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // Profile Header
                      _buildProfileHeader(member),
                      const SizedBox(height: 20),
                      // Tabs
                      const TabBar(
                        labelColor: AppTheme.primary,
                        unselectedLabelColor: AppTheme.textSecondary,
                        indicatorColor: AppTheme.primary,
                        tabs: [
                          Tab(text: "Personal"),
                          Tab(text: "Family"),
                          Tab(text: "History"),
                        ],
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
    );
  }

  Widget _buildProfileHeader(MemberModel member) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.surface, width: 4),
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: AppTheme.surface,
                backgroundImage: member.profileImage != null
                    ? NetworkImage(member.profileImage!)
                    : null, // Add a placeholder image asset if needed
                child: member.profileImage == null
                    ? const Icon(Icons.person, size: 50, color: Colors.grey)
                    : null,
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: () => Get.to(() => const EditProfileView()),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 16),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              member.name ?? 'Guest',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.verified, color: AppTheme.primary, size: 20),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                (member.status ?? 'MEMBER').toUpperCase(),
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Since 2015', // This could be dynamic based on createdAt
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPersonalTab(MemberModel member, String? email) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("Contact Information", onEdit: () {}),
          const SizedBox(height: 16),
          _buildInfoCard(
            icon: Icons.email,
            label: "EMAIL",
            value: email ?? "No email",
            isLocked: true,
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            icon: Icons.phone,
            label: "PHONE",
            value: member.phone ?? "No phone",
          ),
          const SizedBox(height: 12),
          // Assuming address might come from Family model later, or added to Member
          _buildInfoCard(
            icon: Icons.location_on,
            label: "HOME ADDRESS",
            value: member.family?.address ?? "No address linked",
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyTab(MemberModel member) {
    final familyMembers = member.family?.members ?? [];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "My Family",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => Get.to(() => const EditFamilyView()),
                child: const Text(
                  "Edit Family",
                  style: TextStyle(color: AppTheme.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (familyMembers.isEmpty)
            const Text(
              "No family members found.",
              style: TextStyle(color: AppTheme.textSecondary),
            )
          else
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: familyMembers.length + 1, // +1 for Add button
                separatorBuilder: (c, i) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  if (index == familyMembers.length) {
                    return _buildAddFamilyButton();
                  }
                  final fMember = familyMembers[index];
                  // Just show first name
                  final firstName = (fMember.name ?? '?').split(' ')[0];
                  return GestureDetector(
                    onTap: () =>
                        Get.to(() => EditFamilyMemberView(member: fMember)),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: AppTheme.surface,
                          backgroundImage: fMember.profileImage != null
                              ? NetworkImage(fMember.profileImage!)
                              : null,
                          child: fMember.profileImage == null
                              ? Text(
                                  firstName[0],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          firstName,
                          style: const TextStyle(color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddFamilyButton() {
    return GestureDetector(
      onTap: () => Get.to(() => const AddFamilyMemberView()),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.background,
              border: Border.all(color: AppTheme.surface, width: 2),
            ),
            child: const Icon(Icons.add, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          const Text("Add", style: TextStyle(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(MemberModel member) {
    // Mock data for Spiritual Journey based on the design
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Spiritual Journey",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Example items - in real app, these would come from member.sacraments or similar
          _buildJourneyCard(
            icon: Icons.water_drop,
            title: "Baptism",
            date: "Oct 12, 1988",
            location: "St. Peter's Cathedral",
            color: const Color(0xFF3B46F6),
          ),
          const SizedBox(height: 12),
          _buildJourneyCard(
            icon: Icons.church,
            title: "Confirmation",
            date: "May 20, 2002",
            location: "St. Mary's Church",
            color: const Color(0xFFF97316),
          ),
          const SizedBox(height: 12),
          _buildJourneyCard(
            icon: Icons.favorite,
            title: "Holy Matrimony",
            date: "Jun 15, 2015",
            location: "Sacred Heart Chapel",
            color: const Color(0xFFEC4899),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$date • $location",
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onEdit}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (onEdit != null)
          TextButton(
            onPressed: onEdit,
            child: const Text(
              "Edit",
              style: TextStyle(color: AppTheme.primary),
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
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
              ],
            ),
          ),
          if (isLocked)
            const Icon(Icons.lock, color: AppTheme.textSecondary, size: 16),
        ],
      ),
    );
  }
}
