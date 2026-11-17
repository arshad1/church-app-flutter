import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../../data/models/event.dart';
import '../../../data/services/content_service.dart';

class EventsController extends GetxController {
  final ContentService _contentService = Get.find<ContentService>();

  final selectedFilter = 'All Events'.obs;
  final searchQuery = ''.obs;
  final searchController = TextEditingController();

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
  final events = <Event>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    isLoading.value = true;
    try {
      final fetchedEvents = await _contentService.getEvents(type: 'upcoming');
      events.assignAll(fetchedEvents);
    } catch (e) {
      // print("Error fetching events: $e");
    } finally {
      isLoading.value = false;
    }
  }

  bool get isSearching => searchQuery.value.trim().isNotEmpty;

  List<Event> get filteredEvents {
    List<Event> result;
    switch (selectedFilter.value) {
      case 'Live & Streamed':
        result = events
            .where((event) => event.isLive || event.isStreamed)
            .toList();
        break;
      case 'Featured':
        result = events.where((event) => event.isFeatured).toList();
        break;
      case 'All Events':
      default:
        result = events.toList();
    }

    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return result;
    return result
        .where(
          (event) =>
              event.title.toLowerCase().contains(query) ||
              (event.location?.toLowerCase().contains(query) ?? false) ||
              (event.description?.toLowerCase().contains(query) ?? false),
        )
        .toList();
  }

  Event? get featuredEvent {
    // Return the first featured event, or first live event, or first event
    return events.firstWhereOrNull((event) => event.isFeatured) ??
        events.firstWhereOrNull((event) => event.isLive) ??
        (events.isNotEmpty ? events.first : null);
  }

  List<Event> get upcomingEvents {
    // Return filtered events except the featured one shown at top
    final filtered = filteredEvents;
    if (featuredEvent != null &&
        selectedFilter.value == 'All Events' &&
        !isSearching) {
      return filtered.where((event) => event.id != featuredEvent!.id).toList();
    }
    return filtered;
  }
}
