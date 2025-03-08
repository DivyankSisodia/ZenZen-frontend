import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenzen/data/local/service/user_service.dart';

final userDataProvider = StateProvider<HiveService>((ref) {
  return HiveService();
});