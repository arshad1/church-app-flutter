class SettingsModel {
  int? id;
  String? churchName;
  String? address;
  String? phone;
  String? email;
  String? website;
  String? logoUrl;
  String? description;
  String? vicar;
  String? trustee;
  String? secretary;
  String? locationMapUrl;
  double? latitude;
  double? longitude;

  SettingsModel({
    this.id,
    this.churchName,
    this.address,
    this.phone,
    this.email,
    this.website,
    this.logoUrl,
    this.description,
    this.vicar,
    this.trustee,
    this.secretary,
    this.locationMapUrl,
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
    vicar = json['vicar'];
    trustee = json['trustee'];
    secretary = json['secretary'];
    locationMapUrl = json['locationMapUrl'];
    latitude = json['latitude'] != null
        ? (json['latitude'] as num).toDouble()
        : null;
    longitude = json['longitude'] != null
        ? (json['longitude'] as num).toDouble()
        : null;
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
    data['vicar'] = vicar;
    data['trustee'] = trustee;
    data['secretary'] = secretary;
    data['locationMapUrl'] = locationMapUrl;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    return data;
  }
}
