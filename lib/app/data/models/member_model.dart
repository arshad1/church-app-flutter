import 'family_model.dart';
import 'sacrament_model.dart';

class MemberModel {
  int? id;
  String? name;
  String? email;
  String? phone;
  String? profileImage;
  String? familyRole;
  String? status;
  DateTime? dob;
  String? gender;
  int? familyId;
  int? spouseId;
  int? houseId;
  DateTime? createdAt;
  FamilyModel? family;
  List<SacramentModel>? sacraments;

  MemberModel({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.profileImage,
    this.familyRole,
    this.status,
    this.dob,
    this.gender,
    this.familyId,
    this.spouseId,
    this.createdAt,
    this.family,
    this.sacraments,
  });

  MemberModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    profileImage = json['profileImage'];
    familyRole = json['familyRole'];
    status = json['status'];
    dob = json['dob'] != null ? DateTime.tryParse(json['dob']) : null;
    gender = json['gender'];
    familyId = json['familyId'];
    spouseId = json['spouseId'];
    houseId = json['houseId'];
    createdAt = json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt'])
        : null;
    family = json['family'] != null
        ? FamilyModel.fromJson(json['family'])
        : null;
    if (json['sacraments'] != null) {
      sacraments = <SacramentModel>[];
      json['sacraments'].forEach((v) {
        sacraments!.add(SacramentModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['phone'] = phone;
    data['profileImage'] = profileImage;
    data['familyRole'] = familyRole;
    data['status'] = status;
    data['dob'] = dob?.toIso8601String();
    data['gender'] = gender;
    data['familyId'] = familyId;
    data['spouseId'] = spouseId;
    data['houseId'] = houseId;
    data['createdAt'] = createdAt?.toIso8601String();
    if (family != null) {
      data['family'] = family!.toJson();
    }
    if (sacraments != null) {
      data['sacraments'] = sacraments!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
