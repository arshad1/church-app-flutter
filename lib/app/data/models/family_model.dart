import 'member_model.dart';
import 'house_model.dart';

class FamilyModel {
  int? id;
  String? name;
  String? address;
  String? phone;
  String? houseName;
  List<MemberModel>? members;
  List<HouseModel>? houses;

  FamilyModel({
    this.id,
    this.name,
    this.address,
    this.phone,
    this.houseName,
    this.members,
    this.houses,
  });

  FamilyModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    address = json['address'];
    phone = json['phone'];
    houseName = json['houseName'];
    if (json['members'] != null) {
      members = <MemberModel>[];
      json['members'].forEach((v) {
        members!.add(MemberModel.fromJson(v));
      });
    }
    if (json['houses'] != null) {
      houses = <HouseModel>[];
      json['houses'].forEach((v) {
        houses!.add(HouseModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['address'] = address;
    data['phone'] = phone;
    data['houseName'] = houseName;
    if (members != null) {
      data['members'] = members!.map((v) => v.toJson()).toList();
    }
    if (houses != null) {
      data['houses'] = houses!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
