import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

class LandingController extends GetxController {
  void goToHome() {
    Get.offAllNamed(Routes.home);
  }
}
