import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String? userName;
  final String email;
  final String? avatar;
  final String? token;
  final String? mobile;
  final bool? isVerified;
  final String? userStatus;

  UserModel({
    this.userName,
    required this.email,
    this.avatar,
    this.token,
    this.mobile,
    this.isVerified,
    this.userStatus,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    print('json: $json');
    return UserModel(
      userName: json['userName'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'] ?? '',
      token: json['token'],
      mobile: json['mobile'],
      isVerified: json['isVerified'] ?? false,
      userStatus: json['user_status'],
    );
  }

  Map<String, dynamic> toJson() {
    print('toJson: $email');
    return {
      'userName': userName,
      'email': email,
      'avatar': avatar,
      'token': token,
      'mobile': mobile,
      'isVerified': isVerified,
      'user_status': userStatus,
    };
  }

  UserModel copyWith({
    String? userName,
    String? email,
    String? avatar,
    String? token,
    String? mobile,
    bool? isVerified,
    String? userStatus,
  }) {
    return UserModel(
      userName: userName ?? this.userName,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      token: token ?? this.token,
      mobile: mobile ?? this.mobile,
      isVerified: isVerified ?? this.isVerified,
      userStatus: userStatus ?? this.userStatus,
    );
  }

  static UserModel fromUserCredential(UserCredential userCredential) {
    return UserModel(
      mobile: userCredential.user!.phoneNumber ?? '',
      userName: userCredential.user!.displayName ?? '',
      email: userCredential.user!.email ?? '',
      avatar: userCredential.user!.photoURL ?? '',
    );
  }
}
