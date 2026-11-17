import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../data/models/announcement.dart';
import '../../../data/models/event.dart';
import '../../../data/models/bible_verse.dart';
import '../../../data/models/gallery_models.dart';
import '../../../data/services/content_service.dart';

import '../../../data/services/auth_service.dart';

class HomeController extends GetxController {
  final ContentService _contentService = Get.find<ContentService>();
  final AuthService _authService = Get.find<AuthService>();

  /// Logged-in member's name; updates whenever the stored user changes.
  final userName = ''.obs;
  VoidCallback? _removeUserListener;

  final RxnString userImage = RxnString(); // Reactive user image

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
    // Initialize user name & image
    _syncUser();

    // Listen for storage changes to update name & image dynamically
    final storage = GetStorage();
    _removeUserListener = storage.listenKey('user', (val) => _syncUser());

    // Refresh the profile so the member name is current (also covers users
    // who logged in before the profile was fetched at login).
    _authService.refreshUser();

    fetchContent();
  }

  void _syncUser() {
    userName.value = _authService.userName;
    userImage.value = _authService.userImage;
  }

  @override
  void onClose() {
    _removeUserListener?.call();
    super.onClose();
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
