import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenzen/features/dashboard/chat/model/message_model.dart';

class ChatMessagesNotifier extends StateNotifier<List<MessageModel>> {
  ChatMessagesNotifier() : super([]);

  void addMessage(MessageModel message) {
    state = [...state, message];
  }

  void clearMessages() {
    state = [];
  }
}

// Provider for the state notifier
final chatMessagesProvider = StateNotifierProvider.family<ChatMessagesNotifier, List<MessageModel>, String>((ref, roomId) {
  return ChatMessagesNotifier();
});