class Event {
  final int id;
  final String title;
  final String startDate;
  final bool isLive;
  final String? location;
  final String? description;

  Event({
    required this.id,
    required this.title,
    required this.startDate,
    required this.isLive,
    this.location,
    this.description,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      startDate: json['startDate'],
      isLive: json['isLive'] ?? false,
      location: json['location'],
      description: json['description'],
    );
  }
}
