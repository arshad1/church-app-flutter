import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:get_storage/get_storage.dart';
import '../../routes/app_pages.dart';

class ApiClient {
  final Dio _dio = Dio();
  final GetStorage _storage = GetStorage();

  Dio get dio => _dio;

  ApiClient() {
    // Updated base URL to use the specified local IP address
    String baseUrl = 'http://192.168.0.187:3000/api';

    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _storage.read('token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          if (e.response?.statusCode == 401) {
            // Only redirect if we are NOT already on the login page
            if (Get.currentRoute != Routes.login) {
              _handleUnauthorized();
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  void _handleUnauthorized() {
    // Clear local storage
    _storage.remove('token');
    _storage.remove('user');

    // Redirect to login page instead of welcome
    Get.offAllNamed(Routes.login);

    Get.snackbar(
      "Session Expired",
      "Please login again to continue",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withValues(alpha: 0.8),
      colorText: Colors.white,
    );
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
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
