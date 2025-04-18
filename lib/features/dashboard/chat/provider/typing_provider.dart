import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final typingUsersProvider = StateNotifierProvider.family<TypingUsersNotifier, Map<String, bool>, String>((ref, roomId) {
  return TypingUsersNotifier();
});

class TypingUsersNotifier extends StateNotifier<Map<String, bool>> {
  TypingUsersNotifier() : super({});
  final Map<String, Timer> _timers = {};

  void setTyping(String userId, String roomId, bool isTyping) {
    // Cancel any existing timer for this user
    _timers[userId]?.cancel();
    
    if (isTyping) {
      state = {...state, userId: true};
      
      // Set a timer to clear the typing status after 2 seconds of inactivity
      _timers[userId] = Timer(const Duration(seconds: 2), () {
        final newState = Map<String, bool>.from(state);
        newState.remove(userId);
        state = newState;
      });
    } else {
      final newState = Map<String, bool>.from(state);
      newState.remove(userId);
      state = newState;
    }
  }
  
  @override
  void dispose() {
    // Cancel all timers when the notifier is disposed
    for (final timer in _timers.values) {
      timer.cancel();
    }
    super.dispose();
  }
}