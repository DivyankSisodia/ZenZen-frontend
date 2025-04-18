import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenzen/data/api/chat_api.dart';

import '../../../../config/router/constants.dart';
import '../../../../utils/providers/dio_provider.dart';
import '../../../auth/login/viewmodel/auth_viewmodel.dart';
import '../repo/dashboard_repo.dart';

final chatDashboardRemoteProvider = Provider<ChatService>(
  (ref)=> ChatService(
    ApiRoutes.baseUrl,
    ref.read(dioProvider),
    ref.read(tokenManagerProvider),
  ),
);

// Repository Provider
final chatDashboardRepositoryProvider = Provider<ChatDashboardRepository>(
  (ref) => ChatDashboardRepository(ref.read(chatDashboardRemoteProvider)),
);

// socket disconnect helper provider

final diconnectSocketHelperProvider = StateProvider.autoDispose<bool>((ref) {
  return false;
});