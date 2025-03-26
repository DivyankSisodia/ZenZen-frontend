import 'dart:convert';

import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:zenzen/data/local/hive_models/local_user_model.dart';

import '../hive_models/fav_documents_model.dart';

class HiveService {
  static const String _userBox = 'userBox';
  static const String _favDocumentBox = 'favDocumentBox';

  static final HiveService _instance = HiveService._internal();

  factory HiveService() {
    return _instance;
  }

  HiveService._internal();

  Future<void> init() async {
    await Hive.initFlutter();

    // Register Hive Adapters
    Hive.registerAdapter(LocalUserAdapter());
    Hive.registerAdapter(FavDocumentAdapter());

    // Open Hive Boxes
    await Hive.openBox<LocalUser>(_userBox);
    await Hive.openBox<FavDocument>(_favDocumentBox);
  }

  Box<LocalUser> get userBox => Hive.box<LocalUser>(_userBox);

  Box<FavDocument> get favDocumentBox => Hive.box<FavDocument>(_favDocumentBox);

  void printAllData() {
    final box = userBox;
    for (var key in box.keys) {
      final user = box.get(key);
      print('Key: $key, Value: $user');
    }
  }

  void printDocuments() {
    final box = favDocumentBox;
    final encoder = JsonEncoder.withIndent('  ');

    for (var key in box.keys) {
      final document = box.get(key);
      print('Key: $key');
      print(encoder.convert(document?.toJson()));
      print('----------------------');
    }
  }
}
