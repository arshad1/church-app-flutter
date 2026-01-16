class Event {
  final int id;
  final String title;
  final String startDate;
  final bool isLive;
  final bool isFeatured;
  final String? liveUrl;
  final String? location;
  final String? description;
  final String? type;
  final String? status;

  Event({
    required this.id,
    required this.title,
    required this.startDate,
    required this.isLive,
    this.isFeatured = false,
    this.liveUrl,
    this.location,
    this.description,
    this.type,
    this.status,
  });

  // Helper getter to check if event is streamed (has a live URL)
  bool get isStreamed => liveUrl != null && liveUrl!.isNotEmpty;

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'] ?? '',
      startDate: json['date'] ?? json['startDate'] ?? '',
      isLive: json['isLive'] ?? false,
      isFeatured: json['isFeatured'] ?? false,
      liveUrl: json['liveUrl'],
      location: json['location'],
      description: json['description'],
      type: json['type'],
      status: json['status'],
    );
  }
}
