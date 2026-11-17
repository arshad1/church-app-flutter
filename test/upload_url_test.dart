import 'package:church_app/app/data/services/upload_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UploadService.extractUrl', () {
    const url = 'https://example.com/uploads/photo.jpg';

    test('reads the common response shapes', () {
      expect(UploadService.extractUrl({'url': url}), url);
      expect(UploadService.extractUrl({'fileUrl': url}), url);
      expect(UploadService.extractUrl({'location': url}), url);
      expect(UploadService.extractUrl({'path': url}), url);
      expect(UploadService.extractUrl({'data': {'url': url}}), url);
      expect(UploadService.extractUrl({'data': url}), url);
      expect(UploadService.extractUrl(url), url);
    });

    test('returns null when there is no URL', () {
      expect(UploadService.extractUrl({'success': true}), isNull);
      expect(UploadService.extractUrl({'url': ''}), isNull);
      expect(UploadService.extractUrl(null), isNull);
    });
  });
}
