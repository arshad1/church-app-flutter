import 'package:get/get.dart';
import '../../../data/models/gallery_models.dart';
import '../../../data/services/content_service.dart';
import '../views/image_viewer_view.dart';

class AlbumDetailController extends GetxController {
  final ContentService _contentService = Get.find<ContentService>();

  final images = <GalleryItem>[].obs;
  final isLoading = true.obs;
  final albumTitle = ''.obs;
  final albumId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Get parameters from route
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      albumId.value = args['id'].toString();
      albumTitle.value = args['title'] ?? 'Album';
      fetchAlbumImages();
    }
  }

  Future<void> fetchAlbumImages() async {
    isLoading.value = true;
    try {
      final fetchedImages = await _contentService.getAlbumDetails(
        albumId.value,
      );
      images.assignAll(fetchedImages);
    } catch (e) {
      // Handle error
    } finally {
      isLoading.value = false;
    }
  }

  void openImageViewer(int index) {
    Get.to(
      () => ImageViewerView(images: images, initialIndex: index),
      transition: Transition.fade,
    );
  }
}
