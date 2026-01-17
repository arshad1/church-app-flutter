import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/user_service.dart';
import 'dart:io';
import '../../../data/services/family_service.dart';
import '../../../data/services/upload_service.dart';

class ProfileController extends GetxController {
  final UserService _userService = Get.put(UserService());
  final FamilyService _familyService = Get.put(FamilyService());
  final UploadService _uploadService = Get.put(UploadService());

  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    isLoading.value = true;
    try {
      user.value = await _userService.getUserProfile();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addFamilyMember(Map<String, dynamic> data) async {
    isLoading.value = true;
    try {
      await _familyService.addFamilyMember(data);
      Get.back(); // Close the add member screen
      Get.snackbar('Success', 'Family member added successfully');
      fetchProfile(); // Refresh profile to show new member
    } catch (e) {
      Get.snackbar('Error', 'Failed to add family member: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile({
    required String name,
    required String phone,
    File? imageFile,
  }) async {
    final memberId = user.value?.member?.id;
    if (memberId == null) {
      Get.snackbar('Error', 'Member ID not found');
      return;
    }

    isLoading.value = true;
    try {
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _uploadService.uploadImage(imageFile);
      }

      await _familyService.updateFamilyMember(memberId, {
        'name': name,
        'phone': phone,
        if (imageUrl != null) 'profileImage': imageUrl,
      });
      Get.back(); // Close edit screen
      Get.snackbar('Success', 'Profile updated successfully');
      fetchProfile(); // Refresh profile
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteFamilyMember(int memberId) async {
    isLoading.value = true;
    try {
      await _familyService.deleteFamilyMember(memberId);
      Get.snackbar('Success', 'Family member removed');
      fetchProfile();
    } catch (e) {
      Get.snackbar('Error', 'Failed to remove member: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateFamilyMemberProfile({
    required int memberId,
    required String name,
    required String phone,
    File? imageFile,
  }) async {
    isLoading.value = true;
    try {
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _uploadService.uploadImage(imageFile);
      }

      await _familyService.updateFamilyMember(memberId, {
        'name': name,
        'phone': phone,
        if (imageUrl != null) 'profileImage': imageUrl,
      });
      Get.back(); // Close edit screen
      Get.snackbar('Success', 'Member updated successfully');
      fetchProfile();
    } catch (e) {
      Get.snackbar('Error', 'Failed to update member: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
