import 'member_model.dart';

class UserModel {
  int? id;
  String? email;
  String? role;
  MemberModel? member;

  UserModel({this.id, this.email, this.role, this.member});

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email'];
    role = json['role'];
    member = json['member'] != null
        ? MemberModel.fromJson(json['member'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['email'] = email;
    data['role'] = role;
    if (member != null) {
      data['member'] = member!.toJson();
    }
    return data;
  }
}
