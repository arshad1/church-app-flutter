import 'package:get/get.dart';
import '../../../data/models/announcement.dart';
import '../../../data/models/event.dart';
import '../../../data/models/bible_verse.dart';
import '../../../data/services/content_service.dart';

import '../../../data/services/auth_service.dart';

class HomeController extends GetxController {
  final ContentService _contentService = Get.find<ContentService>();
  final AuthService _authService = Get.find<AuthService>();

  String get userName => _authService.userName;

  final announcements = <Announcement>[].obs;
  final upcomingEvents = <Event>[].obs;
  final bibleVerse = Rxn<BibleVerse>();
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchContent();
  }

  Future<void> fetchContent() async {
    isLoading.value = true;
    try {
      final fetchedAnnouncements = await _contentService.getAnnouncements();
      announcements.assignAll(fetchedAnnouncements);

      final fetchedEvents = await _contentService.getEvents();
      upcomingEvents.assignAll(fetchedEvents);

      final fetchedVerses = await _contentService.getBibleVerses();
      if (fetchedVerses.isNotEmpty) {
        bibleVerse.value = fetchedVerses.first;
      }
    } catch (e) {
      // print("Error in HomeController: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
