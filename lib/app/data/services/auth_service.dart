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
    if (u == null) return "Guest";

    // Priority: fullName (from Login), then member.name (from Profile)
    return u['fullName'] ?? u['member']?['name'] ?? "Member";
  }

  String? get userImage {
    final u = user;
    if (u == null) return null;

    // Priority: profilePic (from Login), then member.profileImage (from Profile)
    return u['profilePic'] ?? u['member']?['profileImage'];
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

  Future<void> refreshUser() async {
    try {
      final response = await _client.get('/mobile/profile');
      // Update stored user data
      if (response.data != null) {
        _storage.write('user', response.data);
      }
    } catch (e) {
      // print("Failed to refresh user: $e");
    }
  }
}
