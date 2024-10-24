class RazorAddBankModal {
  String? id;
  String? type;
  String? status;
  String? email;
  Profile? profile;
  List<Null>? notes;
  int? createdAt;
  String? phone;
  String? contactName;
  String? referenceId;
  String? businessType;
  String? legalBusinessName;
  String? customerFacingBusinessName;
  LegalInfo? legalInfo;

  RazorAddBankModal(
      {this.id,
      this.type,
      this.status,
      this.email,
      this.profile,
      this.notes,
      this.createdAt,
      this.phone,
      this.contactName,
      this.referenceId,
      this.businessType,
      this.legalBusinessName,
      this.customerFacingBusinessName,
      this.legalInfo});

  RazorAddBankModal.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    status = json['status'];
    email = json['email'];
    profile =
        json['profile'] != null ? new Profile.fromJson(json['profile']) : null;

    createdAt = json['created_at'];
    phone = json['phone'];
    contactName = json['contact_name'];
    referenceId = json['reference_id'];
    businessType = json['business_type'];
    legalBusinessName = json['legal_business_name'];
    customerFacingBusinessName = json['customer_facing_business_name'];
    legalInfo = json['legal_info'] != null
        ? new LegalInfo.fromJson(json['legal_info'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['type'] = this.type;
    data['status'] = this.status;
    data['email'] = this.email;
    if (this.profile != null) {
      data['profile'] = this.profile!.toJson();
    }

    data['created_at'] = this.createdAt;
    data['phone'] = this.phone;
    data['contact_name'] = this.contactName;
    data['reference_id'] = this.referenceId;
    data['business_type'] = this.businessType;
    data['legal_business_name'] = this.legalBusinessName;
    data['customer_facing_business_name'] = this.customerFacingBusinessName;
    if (this.legalInfo != null) {
      data['legal_info'] = this.legalInfo!.toJson();
    }
    return data;
  }
}

class Profile {
  String? category;
  String? subcategory;
  Addresses? addresses;

  Profile({this.category, this.subcategory, this.addresses});

  Profile.fromJson(Map<String, dynamic> json) {
    category = json['category'];
    subcategory = json['subcategory'];
    addresses = json['addresses'] != null
        ? new Addresses.fromJson(json['addresses'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['category'] = this.category;
    data['subcategory'] = this.subcategory;
    if (this.addresses != null) {
      data['addresses'] = this.addresses!.toJson();
    }
    return data;
  }
}

class Addresses {
  Registered? registered;

  Addresses({this.registered});

  Addresses.fromJson(Map<String, dynamic> json) {
    registered = json['registered'] != null
        ? new Registered.fromJson(json['registered'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.registered != null) {
      data['registered'] = this.registered!.toJson();
    }
    return data;
  }
}

class Registered {
  String? street1;
  String? street2;
  String? city;
  String? state;
  String? postalCode;
  String? country;

  Registered(
      {this.street1,
      this.street2,
      this.city,
      this.state,
      this.postalCode,
      this.country});

  Registered.fromJson(Map<String, dynamic> json) {
    street1 = json['street1'];
    street2 = json['street2'];
    city = json['city'];
    state = json['state'];
    postalCode = json['postal_code'];
    country = json['country'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['street1'] = this.street1;
    data['street2'] = this.street2;
    data['city'] = this.city;
    data['state'] = this.state;
    data['postal_code'] = this.postalCode;
    data['country'] = this.country;
    return data;
  }
}

class LegalInfo {
  String? pan;
  String? gst;

  LegalInfo({this.pan, this.gst});

  LegalInfo.fromJson(Map<String, dynamic> json) {
    pan = json['pan'];
    gst = json['gst'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['pan'] = this.pan;
    data['gst'] = this.gst;
    return data;
  }
}
