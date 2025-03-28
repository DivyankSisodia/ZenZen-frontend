import 'package:firebase_auth/firebase_auth.dart';
import 'package:zenzen/data/local/hive_models/local_user_model.dart';

class UserModel {
  final String? id;
  final String? userName;
  final String? email;
  final String? avatar;
  final String? token;
  final String? mobile;
  final bool? isVerified;
  final String? userStatus;
  final String? accessToken;
  final String? refreshToken;

  UserModel({
    this.id,
    this.userName,
    this.email,
    this.avatar,
    this.token,
    this.mobile,
    this.isVerified,
    this.userStatus,
    this.accessToken,
    this.refreshToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final userModel = UserModel(
      id: json['_id'],
      userName: json['userName'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'] ?? '',
      token: json['token'],
      mobile: json['mobile'],
      isVerified: json['isVerified'] ?? false,
      userStatus: json['user_status'],
      accessToken: json['tokens'] != null ? json['tokens']['accessToken'] : null,
      refreshToken: json['tokens'] != null ? json['tokens']['refreshToken'] : null,
    );
    return userModel;
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
      'tokens': {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
      },
    };
  }

  UserModel copyWith({
    String? id,
    String? userName,
    String? email,
    String? avatar,
    String? token,
    String? mobile,
    bool? isVerified,
    String? userStatus,
    String? accessToken,
    String? refreshToken,
  }) {
    return UserModel(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      token: token ?? this.token,
      mobile: mobile ?? this.mobile,
      isVerified: isVerified ?? this.isVerified,
      userStatus: userStatus ?? this.userStatus,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
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

extension UserModelExtension on UserModel {
  LocalUser toLocalUser() {
    return LocalUser(
      userName: userName ?? '',
      email: email ?? '',
      avatar: avatar ?? '',
      mobile: mobile ?? '',
      isVerified: isVerified ?? false,
      id: id,
    );
  }
}
