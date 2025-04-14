// providers/socket_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenzen/data/sockets/socket_repo.dart';

import '../model/chat_model.dart';

final dashboardDataProvider = StreamProvider.autoDispose<List<ChatRoom>>((ref) {
  final socketRepo = ref.watch(socketRepoProvider);
  return socketRepo.dashboardDataStream.map((dynamicList) {
    // Filter out any null values and convert each item to a ChatRoom
    return dynamicList
        .where((item) => item != null) // Filter out null values
        .map((item) => ChatRoom.fromJson(item as Map<String, dynamic>))
        .toList();
  });
});