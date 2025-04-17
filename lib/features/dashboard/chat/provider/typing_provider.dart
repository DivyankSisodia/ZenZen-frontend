import 'package:flutter_riverpod/flutter_riverpod.dart';

final typingUsersProvider = StateNotifierProvider.family<TypingUsersNotifier, Map<String, bool>, String>((ref, roomId) {
  return TypingUsersNotifier();
});

class TypingUsersNotifier extends StateNotifier<Map<String, bool>> {
  TypingUsersNotifier() : super({});

  void setTyping(String userId, bool isTyping) {
    if (isTyping) {
      state = {...state, userId: true};
    } else {
      final newState = Map<String, bool>.from(state);
      newState.remove(userId);
      state = newState;
    }
  }
}