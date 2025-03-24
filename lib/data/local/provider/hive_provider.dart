import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../service/user_service.dart';

final userDataProvider = Provider<HiveService>((ref) {
  return HiveService();
});