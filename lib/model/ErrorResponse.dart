class ErrorResponse {
  Error? error;

  ErrorResponse({this.error});

  ErrorResponse.fromJson(Map<String, dynamic> json) {
    error = json['error'] != null ? new Error.fromJson(json['error']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.error != null) {
      data['error'] = this.error!.toJson();
    }
    return data;
  }
}

class Error {
  String? code;
  String? description;
  String? source;
  String? step;
  String? reason;
  String? field;

  Error(
      {this.code,
      this.description,
      this.source,
      this.step,
      this.reason,
      this.field});

  Error.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    description = json['description'];
    source = json['source'];
    step = json['step'];
    reason = json['reason'];
    field = json['field'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['description'] = this.description;
    data['source'] = this.source;
    data['step'] = this.step;
    data['reason'] = this.reason;
    data['field'] = this.field;
    return data;
  }
}
