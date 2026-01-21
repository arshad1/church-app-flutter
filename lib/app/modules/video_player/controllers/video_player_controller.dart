import 'package:get/get.dart';

class VideoPlayerController extends GetxController {
  final isPlaying = false.obs;
  final isFullScreen = false.obs;

  void togglePlayPause() {
    isPlaying.value = !isPlaying.value;
  }

  void toggleFullScreen() {
    isFullScreen.value = !isFullScreen.value;
  }
}
