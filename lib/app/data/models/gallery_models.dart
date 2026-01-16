class GalleryCategory {
  final int id;
  final String title;

  GalleryCategory({required this.id, required this.title});

  factory GalleryCategory.fromJson(Map<String, dynamic> json) {
    return GalleryCategory(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      title: json['name'] ?? json['title'] ?? '', // API returns 'name' field
    );
  }
}

class GalleryAlbum {
  final int id;
  final String title;
  final String date;
  final String? coverImage;
  final String type; // 'photo' or 'video' or 'gallery'
  final int? itemCount; // e.g. "45 Photos"
  final int? categoryId; // Link to category for filtering

  GalleryAlbum({
    required this.id,
    required this.title,
    required this.date,
    this.coverImage,
    required this.type,
    this.itemCount,
    this.categoryId,
  });

  factory GalleryAlbum.fromJson(Map<String, dynamic> json) {
    // Parse item count from _count.images if available
    int? itemCount;
    if (json['_count'] != null && json['_count']['images'] != null) {
      itemCount = json['_count']['images'] is int
          ? json['_count']['images']
          : int.tryParse(json['_count']['images'].toString());
    } else {
      itemCount = json['item_count'];
    }

    // Parse categoryId - try both camelCase and snake_case
    int? categoryId;
    if (json['categoryId'] != null) {
      categoryId = json['categoryId'] is int
          ? json['categoryId']
          : int.tryParse(json['categoryId'].toString());
    } else if (json['category_id'] != null) {
      categoryId = json['category_id'] is int
          ? json['category_id']
          : int.tryParse(json['category_id'].toString());
    }

    return GalleryAlbum(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] ?? '',
      date: json['date'] ?? '',
      coverImage: json['coverImage'] ?? json['cover_image'] ?? json['image'],
      type: json['type'] ?? 'gallery',
      itemCount: itemCount,
      categoryId: categoryId,
    );
  }
}

class GalleryItem {
  final int id;
  final String url;
  final String type; // 'image', 'video'
  final String? title;

  GalleryItem({
    required this.id,
    required this.url,
    required this.type,
    this.title,
  });

  factory GalleryItem.fromJson(Map<String, dynamic> json) {
    return GalleryItem(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      url: json['url'] ?? '',
      type: json['type'] ?? 'image',
      title: json['title'],
    );
  }
}
