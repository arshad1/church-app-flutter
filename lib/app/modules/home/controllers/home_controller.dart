import 'package:get/get.dart';
import '../../../data/models/announcement.dart';
import '../../../data/models/event.dart';
import '../../../data/models/bible_verse.dart';
import '../../../data/models/gallery_models.dart';
import '../../../data/services/content_service.dart';

import '../../../data/services/auth_service.dart';

class HomeController extends GetxController {
  final ContentService _contentService = Get.find<ContentService>();
  final AuthService _authService = Get.find<AuthService>();

  String get userName => _authService.userName;

  final announcements = <Announcement>[].obs;
  final upcomingEvents = <Event>[].obs;
  final galleryAlbums = <GalleryAlbum>[].obs; // Added for Home Screen Gallery

  // Getter for featured event (Live or first upcoming)
  Event? get featuredEvent {
    return upcomingEvents.firstWhereOrNull((e) => e.isLive) ??
        (upcomingEvents.isNotEmpty ? upcomingEvents.first : null);
  }

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

      final fetchedAlbums = await _contentService.getGalleryAlbums();
      galleryAlbums.assignAll(
        fetchedAlbums.take(2).toList(),
      ); // Take top 2 for preview
    } catch (e) {
      // print("Error in HomeController: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
