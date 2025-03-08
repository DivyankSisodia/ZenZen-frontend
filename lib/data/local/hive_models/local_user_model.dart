
import 'package:hive_ce_flutter/hive_flutter.dart';

part 'local_user_model.g.dart';

@HiveType(typeId: 0)
class User {
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

  User({
    required this.userName,
    required this.avatar,
    required this.email,
    required this.mobile,
    required this.isVerified,
  });
}