import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData, MultipartFile, Response;
import '../../core/network/api_client.dart';
import '../models/member_model.dart';
import '../models/family_model.dart';

class FamilyService extends GetxService {
  final ApiClient _client = ApiClient();

  Future<MemberModel> addFamilyMember(
    Map<String, dynamic> data,
    File? imageFile,
  ) async {
    try {
      final formData = FormData.fromMap(data);

      if (imageFile != null) {
        String fileName = imageFile.path.split('/').last;
        formData.files.add(
          MapEntry(
            'profileImage',
            await MultipartFile.fromFile(imageFile.path, filename: fileName),
          ),
        );
      }

      final response = await _client.post(
        '/mobile/family/members',
        data: formData,
      );
      return MemberModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<MemberModel> updateFamilyMember(
    int memberId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client.put(
        '/mobile/family/members/$memberId',
        data: data,
      );
      // The backend returns { success: true, message: ..., member: ... } or just member?
      // Based on controller: res.json({ success: true, message: 'Family member updated successfully', member: updatedMember });
      if (response.data['member'] != null) {
        return MemberModel.fromJson(response.data['member']);
      }
      return MemberModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteFamilyMember(int memberId) async {
    try {
      await _client.delete('/mobile/family/members/$memberId');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getDirectory({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
      };

      final response = await _client.get(
        '/mobile/directory',
        queryParameters: queryParams,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data; // Expected { data: [], meta: {} }
      }
      return {'data': [], 'meta': {}};
    } catch (e) {
      return {'data': [], 'meta': {}};
    }
  }

  Future<List<FamilyModel>> getAllFamilies() async {
    try {
      final response = await _client.get('/mobile/families');
      final List<dynamic> data = response.data;
      return data.map((json) => FamilyModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> updateFamily(Map<String, dynamic> data) async {
    try {
      await _client.put('/mobile/family', data: data);
    } catch (e) {
      rethrow;
    }
  }
}
