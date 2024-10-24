class RazorproductsModal {
  List<Null>? requestedConfiguration;
  ActiveConfiguration? activeConfiguration;
  List<Requirements>? requirements;
  Tnc? tnc;
  String? id;
  String? productName;
  String? activationStatus;
  String? accountId;
  int? requestedAt;

  RazorproductsModal(
      {this.requestedConfiguration,
      this.activeConfiguration,
      this.requirements,
      this.tnc,
      this.id,
      this.productName,
      this.activationStatus,
      this.accountId,
      this.requestedAt});

  RazorproductsModal.fromJson(Map<String, dynamic> json) {
    activeConfiguration = json['active_configuration'] != null
        ? new ActiveConfiguration.fromJson(json['active_configuration'])
        : null;
    if (json['requirements'] != null) {
      requirements = <Requirements>[];
      json['requirements'].forEach((v) {
        requirements!.add(new Requirements.fromJson(v));
      });
    }
    tnc = json['tnc'] != null ? new Tnc.fromJson(json['tnc']) : null;
    id = json['id'];
    productName = json['product_name'];
    activationStatus = json['activation_status'];
    accountId = json['account_id'];
    requestedAt = json['requested_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    if (this.activeConfiguration != null) {
      data['active_configuration'] = this.activeConfiguration!.toJson();
    }
    if (this.requirements != null) {
      data['requirements'] = this.requirements!.map((v) => v.toJson()).toList();
    }
    if (this.tnc != null) {
      data['tnc'] = this.tnc!.toJson();
    }
    data['id'] = this.id;
    data['product_name'] = this.productName;
    data['activation_status'] = this.activationStatus;
    data['account_id'] = this.accountId;
    data['requested_at'] = this.requestedAt;
    return data;
  }
}

class ActiveConfiguration {
  Settlements? settlements;

  ActiveConfiguration({this.settlements});

  ActiveConfiguration.fromJson(Map<String, dynamic> json) {
    settlements = json['settlements'] != null
        ? new Settlements.fromJson(json['settlements'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.settlements != null) {
      data['settlements'] = this.settlements!.toJson();
    }
    return data;
  }
}

class Settlements {
  Null? accountNumber;
  Null? ifscCode;
  Null? beneficiaryName;

  Settlements({this.accountNumber, this.ifscCode, this.beneficiaryName});

  Settlements.fromJson(Map<String, dynamic> json) {
    accountNumber = json['account_number'];
    ifscCode = json['ifsc_code'];
    beneficiaryName = json['beneficiary_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['account_number'] = this.accountNumber;
    data['ifsc_code'] = this.ifscCode;
    data['beneficiary_name'] = this.beneficiaryName;
    return data;
  }
}

class Requirements {
  String? fieldReference;
  String? resolutionUrl;
  String? reasonCode;
  String? status;

  Requirements(
      {this.fieldReference, this.resolutionUrl, this.reasonCode, this.status});

  Requirements.fromJson(Map<String, dynamic> json) {
    fieldReference = json['field_reference'];
    resolutionUrl = json['resolution_url'];
    reasonCode = json['reason_code'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['field_reference'] = this.fieldReference;
    data['resolution_url'] = this.resolutionUrl;
    data['reason_code'] = this.reasonCode;
    data['status'] = this.status;
    return data;
  }
}

class Tnc {
  String? id;
  bool? accepted;
  int? acceptedAt;

  Tnc({this.id, this.accepted, this.acceptedAt});

  Tnc.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    accepted = json['accepted'];
    acceptedAt = json['accepted_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['accepted'] = this.accepted;
    data['accepted_at'] = this.acceptedAt;
    return data;
  }
}
