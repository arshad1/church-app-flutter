import 'package:get/get.dart';
import '../../../data/models/event.dart';
import '../../../data/services/content_service.dart';

class EventsController extends GetxController {
  final ContentService _contentService = Get.find<ContentService>();

  final selectedFilter = 'All Events'.obs;
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
      print("Error fetching events: $e");
    } finally {
      isLoading.value = false;
    }
  }

  List<Event> get filteredEvents {
    switch (selectedFilter.value) {
      case 'Live & Streamed':
        return events.where((event) => event.isLive || event.isStreamed).toList();
      case 'Featured':
        return events.where((event) => event.isFeatured).toList();
      case 'All Events':
      default:
        return events;
    }
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
    if (featuredEvent != null && selectedFilter.value == 'All Events') {
      return filtered.where((event) => event.id != featuredEvent!.id).toList();
    }
    return filtered;
  }
}
