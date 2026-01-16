import 'package:get/get.dart';
import '../controllers/album_detail_controller.dart';

class AlbumDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AlbumDetailController>(
      () => AlbumDetailController(),
    );
  }
}
