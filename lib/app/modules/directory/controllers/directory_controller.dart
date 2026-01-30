import 'package:get/get.dart';
import '../../../data/models/family_model.dart';
import 'package:flutter/material.dart';
import '../../../data/services/family_service.dart';

class DirectoryController extends GetxController {
  final FamilyService _familyService = Get.put(FamilyService());
  final ScrollController scrollController = ScrollController();

  final families = <FamilyModel>[].obs;
  final isLoading = true.obs;
  final isLoadMore = false.obs;
  final searchQuery = ''.obs;

  // Pagination
  int currentPage = 1;
  int totalPages = 1;
  final int limit = 20;

  @override
  void onInit() {
    super.onInit();
    fetchDirectory();

    // Setup scroll listener for pagination
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        if (!isLoadMore.value && currentPage < totalPages) {
          loadMore();
        }
      }
    });

    // Setup debounce for search
    debounce(searchQuery, (callback) {
      if (!isLoading.value) {
        // Prevent search if initial load is happening
        fetchDirectory(isRefresh: true);
      }
    }, time: const Duration(milliseconds: 500));
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  Future<void> fetchDirectory({bool isRefresh = false}) async {
    if (isRefresh) {
      isLoading.value = true;
      currentPage = 1;
      families.clear();
    }

    try {
      final response = await _familyService.getDirectory(
        page: currentPage,
        limit: limit,
        search: searchQuery.value,
      );

      final List<dynamic> data = response['data'] ?? [];
      final Map<String, dynamic> meta = response['meta'] ?? {};

      totalPages = meta['pages'] ?? 1;

      final newFamilies = data
          .map((json) => FamilyModel.fromJson(json))
          .toList();

      if (isRefresh) {
        families.assignAll(newFamilies);
      } else {
        families.addAll(newFamilies);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load directory: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    isLoadMore.value = true;
    currentPage++;
    try {
      final response = await _familyService.getDirectory(
        page: currentPage,
        limit: limit,
        search: searchQuery.value,
      );

      final List<dynamic> data = response['data'] ?? [];
      final newFamilies = data
          .map((json) => FamilyModel.fromJson(json))
          .toList();
      families.addAll(newFamilies);
    } catch (e) {
      currentPage--; // Revert page increment on failure
    } finally {
      isLoadMore.value = false;
    }
  }

  void searchDirectory(String query) {
    searchQuery.value = query;
    // Debounce listener will trigger fetchDirectory
  }

  @override
  void refresh() {
    fetchDirectory(isRefresh: true);
  }
}
