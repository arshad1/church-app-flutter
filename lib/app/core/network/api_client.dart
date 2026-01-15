import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get_utils/src/platform/platform.dart';

class ApiClient {
  final Dio _dio = Dio();
  final GetStorage _storage = GetStorage();

  ApiClient() {
    // START: Base URL configuration
    // Use 10.0.2.2 for Android Emulator, localhost for iOS Simulator or Web
    // Updated to localhost as requested, but keeping 10.0.2.2 logic for Android stability
    String baseUrl = 'http://localhost:3000/api';
    
    if (GetPlatform.isAndroid) {
      baseUrl = 'http://10.0.2.2:3000/api';
    }

    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = _storage.read('token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // Handle common errors here (e.g., logging, global snackbar)
        print("API Error: ${e.response?.statusCode} - ${e.message}");
        return handler.next(e);
      },
    ));
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return _dio.put(path, data: data);
  }

  Future<Response> delete(String path) async {
    return _dio.delete(path);
  }
}
