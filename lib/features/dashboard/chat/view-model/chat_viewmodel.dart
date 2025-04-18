// ignore_for_file: prefer_final_fields

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/message_model.dart';
import '../provider/chatMessage_provider.dart';
import '../repo/dashboard_repo.dart';

class ChatViewmodel extends StateNotifier<AsyncValue<List<MessageModel>>> {
  final ChatDashboardRepository chatDashboardRepository;
  final Ref ref;

  ChatViewmodel(this.chatDashboardRepository, this.ref) : super(const AsyncLoading());

  bool _isLoading = false;

  Future<void> getChatMessages(String roomId) async {
    if (_isLoading) return;

    _isLoading = true;
    state = const AsyncLoading();

    try {
      final res = await chatDashboardRepository.getChatMessages(roomId);

      if (mounted) {
        res.fold(
          (messages) {
            state = AsyncValue.data(messages);
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

  void addMessage(MessageModel message) {
  if (state is AsyncData) {
    final currentMessages = (state as AsyncData<List<MessageModel>>).value;

    // Check if we already have a message for this room
    final existingMessageIndex = currentMessages.indexWhere((m) => m.roomId == message.roomId);

    if (existingMessageIndex >= 0) {
      // Update existing message by adding to its chats list
      final existingMessage = currentMessages[existingMessageIndex];

      // Create a new list with proper typing
      final updatedChats = [...?existingMessage.chats, ...?message.chats];

      final updatedMessage = existingMessage.copyWith(
        chats: updatedChats,
        updatedAt: message.updatedAt ?? existingMessage.updatedAt,
      );

      final updatedMessages = [...currentMessages];
      updatedMessages[existingMessageIndex] = updatedMessage;

      state = AsyncValue.data(updatedMessages);
    } else {
      // Add new message
      state = AsyncValue.data([...currentMessages, message]);
    }
  }
}
}

final chatViewModelProvider = StateNotifierProvider<ChatViewmodel, AsyncValue<List<MessageModel>>>((ref) {
  final repository = ref.watch(chatMessageRepositoryProvider);
  return ChatViewmodel(repository, ref);
});
