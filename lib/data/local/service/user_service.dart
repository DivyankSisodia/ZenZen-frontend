import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:zenzen/data/local/hive_models/local_user_model.dart';

class HiveService {
  static const String _userBox = 'userBox';

  static final HiveService _instance = HiveService._internal();

  factory HiveService() {
    return _instance;
  }

  HiveService._internal();

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(UserAdapter());
    await Hive.openBox<User>(_userBox);
  }

  Box<User> get userBox => Hive.box<User>(_userBox);

  void printAllData() {
    final box = userBox;
    for (var key in box.keys) {
      final user = box.get(key);
      print('Key: $key, Value: $user');
    }
  }
}