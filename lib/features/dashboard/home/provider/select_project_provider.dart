import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/login/model/user_model.dart';

final selectedProjectIdProvider = StateProvider.autoDispose<String>((ref) {
  return '';
});

final userListProvider = StateProvider.autoDispose<List<UserModel>>((ref) {
  return [];
});