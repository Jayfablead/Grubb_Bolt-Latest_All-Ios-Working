class StakeholdersModal {
  String? id;
  String? entity;
  List<Null>? relationship;
  List<Null>? phone;
  Notes? notes;

  // Kyc? kyc;
  String? name;
  String? email;
  Addresses? addresses;

  StakeholdersModal(
      {this.id,
      this.entity,
      this.relationship,
      this.phone,
      this.notes,
      // this.kyc,
      this.name,
      this.email,
      this.addresses});

  StakeholdersModal.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    entity = json['entity'];

    notes = json['notes'] != null ? new Notes.fromJson(json['notes']) : null;
    // kyc = json['kyc'] != null ? new Kyc.fromJson(json['kyc']) : null;
    name = json['name'];
    email = json['email'];
    addresses = json['addresses'] != null
        ? new Addresses.fromJson(json['addresses'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['entity'] = this.entity;

    if (this.notes != null) {
      data['notes'] = this.notes!.toJson();
    }
    // if (this.kyc != null) {
    //   data['kyc'] = this.kyc!.toJson();
    // }
    data['name'] = this.name;
    data['email'] = this.email;
    if (this.addresses != null) {
      data['addresses'] = this.addresses!.toJson();
    }
    return data;
  }
}

class Notes {
  String? randomKey;

  Notes({this.randomKey});

  Notes.fromJson(Map<String, dynamic> json) {
    randomKey = json['random_key'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['random_key'] = this.randomKey;
    return data;
  }
}

class Kyc {
  String? pan;

  Kyc({this.pan});

  Kyc.fromJson(Map<String, dynamic> json) {
    pan = json['pan'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['pan'] = this.pan;
    return data;
  }
}

class Addresses {
  Residential? residential;

  Addresses({this.residential});

  Addresses.fromJson(Map<String, dynamic> json) {
    residential = json['residential'] != null
        ? new Residential.fromJson(json['residential'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.residential != null) {
      data['residential'] = this.residential!.toJson();
    }
    return data;
  }
}

class Residential {
  String? street;
  String? city;
  String? state;
  String? postalCode;
  String? country;

  Residential(
      {this.street, this.city, this.state, this.postalCode, this.country});

  Residential.fromJson(Map<String, dynamic> json) {
    street = json['street'];
    city = json['city'];
    state = json['state'];
    postalCode = json['postal_code'];
    country = json['country'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['street'] = this.street;
    data['city'] = this.city;
    data['state'] = this.state;
    data['postal_code'] = this.postalCode;
    data['country'] = this.country;
    return data;
  }
}
