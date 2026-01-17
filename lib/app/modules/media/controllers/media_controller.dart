import 'package:get/get.dart';
import '../../../data/models/gallery_models.dart';
import '../../../data/services/content_service.dart';

class MediaController extends GetxController {
  final ContentService _contentService = Get.find<ContentService>();

  final selectedFilter = 'All'.obs; // Maps to Category title
  final categories = <GalleryCategory>[].obs;
  final albums = <GalleryAlbum>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchGalleryContent();
  }

  Future<void> fetchGalleryContent() async {
    isLoading.value = true;
    try {
      // Fetch categories
      final fetchedCategories = await _contentService.getGalleryCategories();
      categories.assignAll(fetchedCategories);

      // Fetch albums
      final fetchedAlbums = await _contentService.getGalleryAlbums();
      albums.assignAll(fetchedAlbums);
    } catch (e) {
      // Handle error cleanly
    } finally {
      isLoading.value = false;
    }
  }

  List<GalleryAlbum> get filteredAlbums {
    if (selectedFilter.value == 'All') {
      return albums;
    }

    // Find the category by title
    final category = categories.firstWhereOrNull(
      (c) => c.title == selectedFilter.value,
    );

    if (category != null) {
      // Filter albums by category ID
      return albums.where((a) => a.categoryId == category.id).toList();
    }

    return albums;
  }

  int getCategoryPhotoCount(String categoryTitle) {
    if (categoryTitle == 'All') {
      return albums.fold(0, (sum, album) => sum + (album.itemCount ?? 0));
    }

    final category = categories.firstWhereOrNull(
      (c) => c.title == categoryTitle,
    );

    if (category != null) {
      return albums
          .where((a) => a.categoryId == category.id)
          .fold(0, (sum, album) => sum + (album.itemCount ?? 0));
    }

    return 0;
  }
}
