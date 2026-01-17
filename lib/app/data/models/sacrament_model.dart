class SacramentModel {
  int? id;
  String? type;
  DateTime? date;
  String? details;
  int? memberId;

  SacramentModel({this.id, this.type, this.date, this.details, this.memberId});

  SacramentModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    date = json['date'] != null ? DateTime.tryParse(json['date']) : null;
    details = json['details'];
    memberId = json['memberId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['type'] = type;
    data['date'] = date?.toIso8601String();
    data['details'] = details;
    data['memberId'] = memberId;
    return data;
  }
}
