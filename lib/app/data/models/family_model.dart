import 'member_model.dart';

class FamilyModel {
  int? id;
  String? name;
  String? address;
  String? phone;
  List<MemberModel>? members;

  FamilyModel({this.id, this.name, this.address, this.phone, this.members});

  FamilyModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    address = json['address'];
    phone = json['phone'];
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
    data['address'] = address;
    data['phone'] = phone;
    if (members != null) {
      data['members'] = members!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
