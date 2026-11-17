import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import '../../core/network/api_client.dart';

class UploadService extends GetxService {
  final ApiClient _client = ApiClient();

  /// Uploads an image file and returns its URL.
  ///
  /// Throws if the upload fails or the server response has no URL, so the
  /// caller can tell the user instead of silently dropping the photo.
  Future<String> uploadImage(File file) async {
    final fileName = file.path.split(Platform.pathSeparator).last;

    final formData = dio.FormData.fromMap({
      'image': await dio.MultipartFile.fromFile(file.path, filename: fileName),
    });

    final response = await _client.dio.post('/common/upload', data: formData);

    final status = response.statusCode ?? 0;
    if (status < 200 || status >= 300) {
      throw Exception('Upload failed (HTTP $status)');
    }

    final url = extractUrl(response.data);
    if (url == null) {
      throw Exception('Upload succeeded but the server returned no image URL');
    }
    return url;
  }

  /// Finds the uploaded file's URL in the common response shapes:
  /// `{url}`, `{data: {url}}`, `{fileUrl}`, `{location}`, `{path}`,
  /// `{data: "<url>"}` or a plain string.
  static String? extractUrl(dynamic data) {
    String? text(dynamic v) =>
        v is String && v.trim().isNotEmpty ? v.trim() : null;

    if (data is String) return text(data);
    if (data is! Map) return null;

    for (final key in ['url', 'fileUrl', 'imageUrl', 'location', 'path']) {
      final v = text(data[key]);
      if (v != null) return v;
    }
    final inner = data['data'];
    if (inner is String) return text(inner);
    if (inner is Map) return extractUrl(inner);
    return null;
  }
}
