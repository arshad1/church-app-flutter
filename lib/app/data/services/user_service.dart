import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../models/user_model.dart';

class UserService extends GetxService {
  final ApiClient _client = ApiClient();

  Future<UserModel> getUserProfile() async {
    try {
      final response = await _client.get('/mobile/profile');
      return UserModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
