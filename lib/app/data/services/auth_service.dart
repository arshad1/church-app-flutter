import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/network/api_client.dart';
import '../../routes/app_pages.dart';

class AuthService extends GetxService {
  final ApiClient _client = ApiClient();
  final _storage = GetStorage();

  bool get isAuthenticated => _storage.hasData('token');
  String? get token => _storage.read('token');
  dynamic get user => _storage.read('user');

  String get userName {
    final u = user;
    if (u == null) return "User";

    // Try different common name fields
    if (u['firstName'] != null) {
      if (u['lastName'] != null) {
        return "${u['firstName']} ${u['lastName']}";
      }
      return u['firstName'];
    }

    if (u['name'] != null) return u['name'];

    // Fallback to email username if nothing else
    if (u['email'] != null) {
      return u['email'].split('@')[0];
    }

    return "Member";
  }

  Future<dynamic> login(String email, String password) async {
    try {
      final response = await _client.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  void logout() {
    _storage.remove('token');
    _storage.remove('user');
    Get.offAllNamed(Routes.welcome);
  }

  Future<void> registerToken(String token, String platform) async {
    try {
      await _client.post(
        '/notifications/register-token',
        data: {'token': token, 'platform': platform},
      );
    } catch (e) {
      // print("Token registration failed: $e");
    }
  }
}
