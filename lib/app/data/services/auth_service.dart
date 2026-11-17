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

  /// Returns [value] if it is a non-empty string, otherwise null.
  static String? _text(dynamic value) =>
      value is String && value.trim().isNotEmpty ? value.trim() : null;

  /// The logged-in member's name.
  ///
  /// Priority: member.name (from /mobile/profile, the member's real name),
  /// then fullName / name from the login response.
  String get userName {
    final u = user;
    if (u is! Map) return 'Guest';
    final member = u['member'];
    return _text(member is Map ? member['name'] : null) ??
        _text(u['fullName']) ??
        _text(u['name']) ??
        _text(member is Map ? member['fullName'] : null) ??
        'Member';
  }

  String? get userImage {
    final u = user;
    if (u is! Map) return null;
    final member = u['member'];
    // Priority: member.profileImage (from Profile), then profilePic (Login)
    return _text(member is Map ? member['profileImage'] : null) ??
        _text(u['profilePic']);
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
