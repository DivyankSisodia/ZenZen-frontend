import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/router/constants.dart';
import '../../../../data/api/chat_api.dart';
import '../../../../utils/providers/dio_provider.dart';
import '../../../auth/login/viewmodel/auth_viewmodel.dart';
import '../repo/dashboard_repo.dart';

final chatMessageRemoteProvider = Provider<ChatService>(
  (ref)=> ChatService(
    ApiRoutes.baseUrl,
    ref.read(dioProvider),
    ref.read(tokenManagerProvider),
  ),
);

// Repository Provider
final chatMessageRepositoryProvider = Provider<ChatDashboardRepository>(
  (ref) => ChatDashboardRepository(ref.read(chatMessageRemoteProvider)),
);
