import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/chat_model.dart';
import '../provider/dashboard_provider.dart';
import '../repo/dashboard_repo.dart';

class ChatDashboardViewModel extends StateNotifier<AsyncValue<List<ChatRoom>>> {
  final ChatDashboardRepository repository;
  final Ref ref;
  ChatDashboardViewModel(this.ref, this.repository) : super(const AsyncValue.loading());

  bool _isLoading = false;

  Future<void> getChats() async {
    if (_isLoading) return;

    _isLoading = true;
    state = const AsyncValue.loading();

    try {
      final res = await repository.getChatDashboard();
      if (mounted) {
        res.fold(
          (chats) {
            state = AsyncValue.data(chats);
          },
          (failure) {
            // Handle your specific ApiFailure type
            String errorMessage = failure.error;
            state = AsyncValue.error(errorMessage, StackTrace.current);
          },
        );
      }
    } catch (e, stackTrace) {
      if (mounted) {
        // Handle general exceptions
        String errorMessage = e.toString();
        state = AsyncValue.error(errorMessage, stackTrace);
      }
    } finally {
      _isLoading = false;
    }
  }
}
final chatDashboardProvider = StateNotifierProvider<ChatDashboardViewModel, AsyncValue<List<ChatRoom>>>((ref) {
  final repository = ref.watch(chatDashboardRepositoryProvider);
  return ChatDashboardViewModel(ref, repository);
});