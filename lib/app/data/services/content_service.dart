import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../models/announcement.dart';
import '../models/event.dart';
import '../models/bible_verse.dart';
import '../models/gallery_models.dart';

class ContentService extends GetxService {
  final ApiClient _client = ApiClient();

  Future<List<Announcement>> getAnnouncements() async {
    try {
      final response = await _client.get('/mobile/announcements');
      final List<dynamic> data = response.data;
      return data.map((json) => Announcement.fromJson(json)).toList();
    } catch (e) {
      // Return empty list on error to allow UI to show something or nothing cleanly
      // print("Error fetching announcements: $e");
      return [];
    }
  }

  Future<List<Event>> getEvents({String type = 'upcoming'}) async {
    try {
      final response = await _client.get(
        '/mobile/events',
        queryParameters: {'type': type},
      );
      final List<dynamic> data = response.data;
      return data.map((json) => Event.fromJson(json)).toList();
    } catch (e) {
      // print("Error fetching events: $e");
      return [];
    }
  }

  Future<List<BibleVerse>> getBibleVerses() async {
    try {
      final response = await _client.get('/mobile/content/BIBLE_VERSE');
      final List<dynamic> data = response.data;
      print("Bible Verse Data: $data"); // Debug print
      return data.map((json) => BibleVerse.fromJson(json)).toList();
    } catch (e) {
      print("Error fetching bible verses: $e");
      return [];
    }
  }

  Future<List<GalleryCategory>> getGalleryCategories() async {
    try {
      final response = await _client.get('/mobile/gallery/categories');
      print("Categories Response: ${response.data}"); // Debug print
      final dynamic data = response.data;
      if (data is Map<String, dynamic> && data.containsKey('data')) {
        return (data['data'] as List)
            .map((json) => GalleryCategory.fromJson(json))
            .toList();
      } else if (data is List) {
        return data.map((json) => GalleryCategory.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("Error fetching gallery categories: $e");
      return [];
    }
  }

  Future<List<GalleryAlbum>> getGalleryAlbums({int? categoryId}) async {
    try {
      final queryParams = categoryId != null
          ? {'categoryId': categoryId.toString()}
          : null;
      final response = await _client.get(
        '/mobile/gallery/albums',
        queryParameters: queryParams,
      );
      final dynamic data = response.data;

      if (data is Map<String, dynamic> && data.containsKey('data')) {
        return (data['data'] as List)
            .map((json) => GalleryAlbum.fromJson(json))
            .toList();
      } else if (data is List) {
        return data.map((json) => GalleryAlbum.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("Error fetching gallery albums: $e");
      return [];
    }
  }

  Future<List<GalleryItem>> getAlbumDetails(String id) async {
    try {
      final response = await _client.get('/mobile/gallery/albums/$id');
      final dynamic data = response.data;

      // API returns an object with an 'images' array
      if (data is Map<String, dynamic> && data.containsKey('images')) {
        return (data['images'] as List)
            .map((json) => GalleryItem.fromJson(json))
            .toList();
      } else if (data is Map<String, dynamic> && data.containsKey('items')) {
        return (data['items'] as List)
            .map((json) => GalleryItem.fromJson(json))
            .toList();
      } else if (data is List) {
        return data.map((json) => GalleryItem.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("Error fetching album details: $e");
      return [];
    }
  }
}
