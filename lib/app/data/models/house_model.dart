import 'member_model.dart';

class HouseModel {
  int? id;
  String? name;
  int? familyId;
  List<MemberModel>? members;

  HouseModel({this.id, this.name, this.familyId, this.members});

  HouseModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    familyId = json['familyId'];
    if (json['members'] != null) {
      members = <MemberModel>[];
      json['members'].forEach((v) {
        members!.add(MemberModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['familyId'] = familyId;
    if (members != null) {
      data['members'] = members!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
