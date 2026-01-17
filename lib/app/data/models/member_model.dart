import 'family_model.dart';

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
  FamilyModel? family;

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
    this.family,
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
    family = json['family'] != null
        ? FamilyModel.fromJson(json['family'])
        : null;
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
    if (family != null) {
      data['family'] = family!.toJson();
    }
    return data;
  }
}
