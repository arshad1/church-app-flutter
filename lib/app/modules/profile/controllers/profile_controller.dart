import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/user_service.dart';
import '../../../data/services/auth_service.dart';
import 'dart:io';
import '../../../data/services/family_service.dart';
import '../../../data/services/upload_service.dart';
import '../../../data/services/settings_service.dart';
import '../../../data/models/settings_model.dart';

class ProfileController extends GetxController {
  final UserService _userService = Get.put(UserService());
  final FamilyService _familyService = Get.put(FamilyService());
  final UploadService _uploadService = Get.put(UploadService());
  final SettingsService _settingsService = Get.put(SettingsService());
  final AuthService _authService = Get.find<AuthService>();

  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;

  Rx<SettingsModel?> get churchSettings => _settingsService.settings;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
    _settingsService.fetchSettings();
  }

  Future<void> fetchProfile() async {
    isLoading.value = true;
    try {
      user.value = await _userService.getUserProfile();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load profile: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addFamilyMember(Map<String, dynamic> data) async {
    isLoading.value = true;
    try {
      await _familyService.addFamilyMember(data);
      Get.back(); // Close the add member screen
      Get.snackbar(
        'Success',
        'Family member added successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      fetchProfile(); // Refresh profile to show new member
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add family member: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile({
    required String name,
    required String phone,
    String? email,
    String? address,
    File? imageFile,
  }) async {
    final memberId = user.value?.member?.id;
    if (memberId == null) {
      Get.snackbar(
        'Error',
        'Member ID not found',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    try {
      // 1. Update User Profile (Email) if changed
      if (email != null && email.isNotEmpty && email != user.value?.email) {
        await _userService.updateUserProfile({'email': email});
      }

      // 2. Update Family Details (Address) if changed
      // Note: This updates the address for the whole family
      if (address != null &&
          address.isNotEmpty &&
          address != user.value?.member?.family?.address) {
        await _familyService.updateFamily({'address': address});
      }

      // 3. Update Member Details (Name, Phone, Image)
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
      Get.snackbar(
        'Success',
        'Profile updated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      fetchProfile(); // Refresh profile
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update profile: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteFamilyMember(int memberId) async {
    isLoading.value = true;
    try {
      await _familyService.deleteFamilyMember(memberId);
      Get.snackbar(
        'Success',
        'Family member removed',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      fetchProfile();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to remove member: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateFamilyMemberProfile({
    required int memberId,
    required String name,
    required String phone,
    int? spouseId,
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
        if (spouseId != null) 'spouseId': spouseId,
        if (imageUrl != null) 'profileImage': imageUrl,
      });
      Get.back(); // Close edit screen
      Get.snackbar(
        'Success',
        'Member updated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      fetchProfile();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update member: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateFamilyDetails({
    String? name,
    String? houseName,
    String? phone,
    String? address,
  }) async {
    isLoading.value = true;
    try {
      await _familyService.updateFamily({
        if (name != null) 'name': name,
        if (houseName != null) 'houseName': houseName,
        if (phone != null) 'phone': phone,
        if (address != null) 'address': address,
      });
      Get.back(); // Close edit screen
      Get.snackbar(
        'Success',
        'Family details updated',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      fetchProfile();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update family: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void logout() {
    _authService.logout();
  }
}
