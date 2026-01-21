import 'package:get/get.dart';
import '../../../data/models/family_model.dart';
import '../../../data/models/member_model.dart';
import '../../../data/services/user_service.dart';

class DirectoryController extends GetxController {
  final UserService _userService = Get.find<UserService>();

  final family = Rxn<FamilyModel>();
  final members = <MemberModel>[].obs;
  final filteredMembers = <MemberModel>[].obs;
  final isLoading = true.obs;
  final searchQuery = ''.obs;
  final viewMode = 'table'.obs; // 'table' or 'tree'

  String? familyName;
  String? houseName;

  @override
  void onInit() {
    super.onInit();
    fetchUserFamily();
  }

  Future<void> fetchUserFamily() async {
    isLoading.value = true;
    try {
      // Fetch user profile which includes family data
      final user = await _userService.getMyProfile();

      if (user.member?.family != null) {
        family.value = user.member!.family;
        familyName = user.member!.family!.name;

        // Get house name if user belongs to a house
        if (user.member!.houseId != null &&
            user.member!.family!.houses != null) {
          final userHouse = user.member!.family!.houses!.firstWhere(
            (h) => h.id == user.member!.houseId,
            orElse: () => user.member!.family!.houses!.first,
          );
          houseName = userHouse.name;
        }

        // Get all family members
        final allMembers = user.member!.family!.members ?? [];
        members.assignAll(allMembers);
        filteredMembers.assignAll(allMembers);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load family data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void searchMembers(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredMembers.assignAll(members);
    } else {
      filteredMembers.assignAll(
        members.where((member) {
          final name = member.name?.toLowerCase() ?? '';
          final searchLower = query.toLowerCase();
          return name.contains(searchLower);
        }).toList(),
      );
    }
  }

  void toggleViewMode() {
    viewMode.value = viewMode.value == 'table' ? 'tree' : 'table';
  }

  void refresh() {
    fetchUserFamily();
  }
}
