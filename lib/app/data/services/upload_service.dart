import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import '../../core/network/api_client.dart';

class UploadService extends GetxService {
  final ApiClient _client = ApiClient();

  /// Uploads an image file and returns the full URL.
  Future<String?> uploadImage(File file) async {
    try {
      String fileName = file.path.split('/').last;

      dio.FormData formData = dio.FormData.fromMap({
        "image": await dio.MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
      });

      final response = await _client.dio.post('/common/upload', data: formData);

      // Assuming backend returns { "url": "http://..." }
      if (response.statusCode == 200 && response.data['url'] != null) {
        return response.data['url'];
      }
      return null;
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }
}
