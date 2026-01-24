import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../models/settings_model.dart';

class SettingsService extends GetxService {
  final ApiClient _client = ApiClient();
  final Rx<SettingsModel?> settings = Rx<SettingsModel?>(null);

  Future<SettingsService> init() async {
    await fetchSettings();
    return this;
  }

  Future<void> fetchSettings() async {
    try {
      final response = await _client.get('/mobile/settings');
      if (response.data != null) {
        settings.value = SettingsModel.fromJson(response.data);
      }
    } catch (e) {
      // Non-critical, can continue with defaults
    }
  }
}
