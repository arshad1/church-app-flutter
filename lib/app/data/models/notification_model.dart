enum NotificationType { notification, announcement }

class NotificationModel {
  String? id;
  NotificationType? type;
  String? title;
  String? body;
  String? date;
  bool? isRead;
  Map<String, dynamic>? meta;

  NotificationModel({
    this.id,
    this.type,
    this.title,
    this.body,
    this.date,
    this.isRead,
    this.meta,
  });

  NotificationModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'] == 'ANNOUNCEMENT'
        ? NotificationType.announcement
        : NotificationType.notification;
    title = json['title'];
    body = json['body'];
    date = json['date'];
    isRead = json['isRead'];
    meta = json['meta'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['type'] = type == NotificationType.announcement
        ? 'ANNOUNCEMENT'
        : 'NOTIFICATION';
    data['title'] = title;
    data['body'] = body;
    data['date'] = date;
    data['isRead'] = isRead;
    data['meta'] = meta;
    return data;
  }
}
