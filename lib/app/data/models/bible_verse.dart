class BibleVerse {
  final int id;
  final String content;
  final String date;
  final String?
  title; // Assuming it might have a reference like "John 3:16" as title or content

  BibleVerse({
    required this.id,
    required this.content,
    required this.date,
    this.title,
  });

  factory BibleVerse.fromJson(Map<String, dynamic> json) {
    return BibleVerse(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      content:
          json['content'] ??
          json['text'] ??
          json['description'] ??
          json['body'] ??
          json['verse'] ??
          '',
      date: json['date'] ?? '',
      title: json['title'],
    );
  }
}
