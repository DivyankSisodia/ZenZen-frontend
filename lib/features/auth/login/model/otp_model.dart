class OtpModel {
  String? otp;
  String? email;

  OtpModel({this.otp, this.email});

  OtpModel.fromJson(Map<String, dynamic> json) {
    otp = json['otp'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['otp'] = otp;
    data['email'] = email;
    return data;
  }
}