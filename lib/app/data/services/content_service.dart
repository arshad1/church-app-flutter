import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../models/announcement.dart';
import '../models/event.dart';
import '../models/bible_verse.dart';

class ContentService extends GetxService {
  final ApiClient _client = ApiClient();

  Future<List<Announcement>> getAnnouncements() async {
    try {
      final response = await _client.get('/content/announcements');
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
        '/events',
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
      final response = await _client.get('/content/BIBLE_VERSE');
      final List<dynamic> data = response.data;
      print("Bible Verse Data: $data"); // Debug print
      return data.map((json) => BibleVerse.fromJson(json)).toList();
    } catch (e) {
      print("Error fetching bible verses: $e");
      return [];
    }
  }
}
