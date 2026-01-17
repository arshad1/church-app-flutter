class HouseModel {
  int? id;
  String? name;
  int? familyId;

  HouseModel({this.id, this.name, this.familyId});

  HouseModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    familyId = json['familyId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['familyId'] = familyId;
    return data;
  }
}
