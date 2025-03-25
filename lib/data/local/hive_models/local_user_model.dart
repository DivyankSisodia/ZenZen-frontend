import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../../features/auth/login/model/user_model.dart';

part 'local_user_model.g.dart';

@HiveType(typeId: 0)
class LocalUser {
  @HiveField(0)
  final String userName;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String avatar;

  @HiveField(3)
  final String mobile;

  @HiveField(4)
  final bool isVerified;

  @HiveField(5)
  final String? id;

  LocalUser({
    required this.userName,
    required this.avatar,
    required this.email,
    required this.mobile,
    required this.isVerified,
    this.id,
  });

  UserModel toUserModel() => UserModel(
    id: id,
    userName: userName,
    email: email,
    avatar: avatar,
    mobile: mobile,
    isVerified: isVerified,
  );

  Map<String, dynamic> toJson() => {
  'id': id,
  'userName': userName,
  'email': email,
  'avatar': avatar,
  'mobile': mobile,
  'isVerified': isVerified,
};
}
