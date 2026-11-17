import 'package:get/get.dart';
import '../../../data/models/family_model.dart';
import '../../../data/models/house_model.dart';
import '../../../data/models/member_model.dart';
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

  /// When searching, every page is loaded (up to this many) so the search
  /// covers the whole directory, not just the first page.
  static const int _maxSearchPages = 50;

  /// Incremented on every fetch so responses from older, slower requests
  /// (e.g. for a previous search term) are ignored.
  int _requestId = 0;

  bool get isSearching => searchQuery.value.trim().isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    fetchDirectory();

    // Setup scroll listener for pagination (not needed while searching:
    // search results are loaded in full).
    scrollController.addListener(() {
      if (!scrollController.hasClients) return;
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        if (!isSearching &&
            !isLoading.value &&
            !isLoadMore.value &&
            currentPage < totalPages) {
          loadMore();
        }
      }
    });

    // Debounce typing; always run the latest query (stale results are
    // discarded via _requestId).
    debounce(
      searchQuery,
      (_) => fetchDirectory(isRefresh: true),
      time: const Duration(milliseconds: 400),
    );
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  Future<void> fetchDirectory({bool isRefresh = false}) async {
    final requestId = ++_requestId;
    final query = searchQuery.value.trim();

    if (isRefresh) {
      isLoading.value = true;
      currentPage = 1;
      families.clear();
    }

    try {
      if (query.isEmpty) {
        // Normal browsing: first page, more pages load on scroll.
        final response = await _familyService.getDirectory(
          page: 1,
          limit: limit,
        );
        if (requestId != _requestId) return; // a newer request took over

        final meta = response['meta'] is Map ? response['meta'] as Map : {};
        totalPages = _toInt(meta['pages']) ?? 1;
        currentPage = 1;
        families.assignAll(_parse(response['data']));
      } else {
        // Searching: load all pages (server-side search narrows them when
        // supported), then filter locally by family, house and member names
        // so the result is correct whatever the server does.
        final all = <FamilyModel>[];
        var page = 1;
        var pages = 1;
        do {
          final response = await _familyService.getDirectory(
            page: page,
            limit: limit,
            search: query,
          );
          if (requestId != _requestId) return; // user typed something else
          final meta = response['meta'] is Map
              ? response['meta'] as Map
              : {};
          pages = _toInt(meta['pages']) ?? 1;
          final batch = _parse(response['data']);
          all.addAll(batch);
          if (batch.isEmpty) break;
          page++;
        } while (page <= pages && page <= _maxSearchPages);

        totalPages = 1;
        currentPage = 1;
        families.assignAll(all.where((f) => familyMatches(f, query)));
      }
    } catch (e) {
      if (requestId == _requestId) {
        Get.snackbar('Error', 'Failed to load directory: $e');
      }
    } finally {
      if (requestId == _requestId) isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    final requestId = _requestId;
    isLoadMore.value = true;
    currentPage++;
    try {
      final response = await _familyService.getDirectory(
        page: currentPage,
        limit: limit,
      );
      if (requestId != _requestId) return; // list was refreshed meanwhile
      families.addAll(_parse(response['data']));
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

  // ---------------------------------------------------------------------------
  // Search matching
  // ---------------------------------------------------------------------------

  static bool _has(String? value, String q) =>
      value != null && value.toLowerCase().contains(q);

  static bool memberMatches(MemberModel m, String q) =>
      _has(m.name, q) || _has(m.phone, q);

  /// Whether a house matches by its own name or any member in it.
  static bool houseMatches(HouseModel h, String query) {
    final q = query.trim().toLowerCase();
    return _has(h.name, q) || (h.members ?? []).any((m) => memberMatches(m, q));
  }

  /// Whether the family's own name matches (then all its houses are shown).
  static bool familyNameMatches(FamilyModel f, String query) {
    final q = query.trim().toLowerCase();
    return _has(f.name, q) || _has(f.houseName, q);
  }

  /// Whether a family matches by family name, house name or member name.
  static bool familyMatches(FamilyModel f, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    if (familyNameMatches(f, q)) return true;
    if ((f.members ?? []).any((m) => memberMatches(m, q))) return true;
    return (f.houses ?? []).any((h) => houseMatches(h, q));
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static List<FamilyModel> _parse(dynamic data) {
    if (data is! List) return [];
    return data
        .whereType<Map>()
        .map((json) => FamilyModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  static int? _toInt(dynamic v) =>
      v is int ? v : (v is num ? v.toInt() : int.tryParse('$v'));
}
