class SettingsModel {
  int? id;
  String? churchName;
  String? address;
  String? phone;
  String? email;
  String? website;
  String? logoUrl;
  String? description;

  SettingsModel({
    this.id,
    this.churchName,
    this.address,
    this.phone,
    this.email,
    this.website,
    this.logoUrl,
    this.description,
  });

  SettingsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    churchName = json['churchName'];
    address = json['address'];
    phone = json['phone'];
    email = json['email'];
    website = json['website'];
    logoUrl = json['logoUrl'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['churchName'] = churchName;
    data['address'] = address;
    data['phone'] = phone;
    data['email'] = email;
    data['website'] = website;
    data['logoUrl'] = logoUrl;
    data['description'] = description;
    return data;
  }
}
