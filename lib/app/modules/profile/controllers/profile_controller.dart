import 'package:flutter/material.dart';
import 'package:dio/dio.dart' show DioException;
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

  /// True while a new profile photo is uploading (shown on the avatar).
  final RxBool isUploadingPhoto = false.obs;

  /// Closes the current screen. Uses the navigator directly because
  /// Get.back() only dismisses a snackbar when one is showing.
  void _closeScreen() => Get.key.currentState?.maybePop();

  void _success(String message) => Get.snackbar(
    'Success',
    message,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: const Color(0xFF16A34A),
    colorText: Colors.white,
    margin: const EdgeInsets.all(12),
  );

  void _failure(String message, Object error) => Get.snackbar(
    'Error',
    '$message: ${_readable(error)}',
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: const Color(0xFFDC2626),
    colorText: Colors.white,
    margin: const EdgeInsets.all(12),
  );

  /// Shows the server's message for API errors instead of a raw exception.
  static String _readable(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['message'] is String) return data['message'];
      return e.message ?? 'Network error';
    }
    return e.toString().replaceFirst('Exception: ', '');
  }

  Rx<SettingsModel?> get churchSettings => _settingsService.settings;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
    _settingsService.fetchSettings();
  }

  /// Loads the profile. With [silent], the page keeps showing the current
  /// data while refreshing instead of switching to a spinner.
  Future<void> fetchProfile({bool silent = false}) async {
    if (!silent) isLoading.value = true;
    try {
      user.value = await _userService.getUserProfile();
    } catch (e) {
      _failure('Failed to load profile', e);
    } finally {
      if (!silent) isLoading.value = false;
    }
  }

  /// Uploads [file] as the logged-in member's photo and saves it.
  Future<void> updateProfilePhoto(File file) async {
    final member = user.value?.member;
    if (member?.id == null) {
      _failure('Could not update photo', 'Member ID not found');
      return;
    }

    isUploadingPhoto.value = true;
    try {
      final imageUrl = await _uploadService.uploadImage(file);
      await _familyService.updateFamilyMember(member!.id!, {
        if (member.name != null) 'name': member.name,
        if (member.phone != null) 'phone': member.phone,
        'profileImage': imageUrl,
      });

      // Show the new photo straight away, then sync with the server.
      member.profileImage = imageUrl;
      user.refresh();
      await _authService.refreshUser(); // updates the Home header too
      await fetchProfile(silent: true);
      _success('Profile photo updated');
    } catch (e) {
      _failure('Failed to update photo', e);
    } finally {
      isUploadingPhoto.value = false;
    }
  }

  Future<void> addFamilyMember(
    Map<String, dynamic> data,
    File? imageFile,
  ) async {
    isLoading.value = true;
    try {
      await _familyService.addFamilyMember(data, imageFile);
      _closeScreen(); // Close the add member screen
      _success('Family member added successfully');
      fetchProfile(silent: true); // Refresh profile to show new member
    } catch (e) {
      _failure('Failed to add family member', e);
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
      _failure('Could not update profile', 'Member ID not found');
      return;
    }

    isLoading.value = true;
    try {
      // 1. Update User Profile (Email) if changed
      email = email?.trim();
      address = address?.trim();
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
        'name': name.trim(),
        'phone': phone.trim(),
        if (imageUrl != null) 'profileImage': imageUrl,
      });

      _closeScreen(); // Close edit screen
      _success('Profile updated successfully');
      await _authService
          .refreshUser(); // Refresh local user data for Home screen
      fetchProfile(silent: true); // Refresh profile
    } catch (e) {
      _failure('Failed to update profile', e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteFamilyMember(int memberId) async {
    isLoading.value = true;
    try {
      await _familyService.deleteFamilyMember(memberId);
      _success('Family member removed');
      fetchProfile(silent: true);
    } catch (e) {
      _failure('Failed to remove member', e);
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
      _closeScreen(); // Close edit screen
      _success('Member updated successfully');
      // specific member update might check if it's the logged-in user
      if (memberId == user.value?.member?.id) {
        await _authService.refreshUser();
      }
      fetchProfile(silent: true);
    } catch (e) {
      _failure('Failed to update member', e);
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
      _closeScreen(); // Close edit screen
      _success('Family details updated');
      fetchProfile(silent: true);
    } catch (e) {
      _failure('Failed to update family', e);
    } finally {
      isLoading.value = false;
    }
  }

  void logout() {
    _authService.logout();
  }
}
