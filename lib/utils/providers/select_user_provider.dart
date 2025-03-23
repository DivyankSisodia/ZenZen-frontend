import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenzen/features/auth/login/model/user_model.dart';

class SelectedUsersNotifier extends StateNotifier<List<UserModel>> {
  SelectedUsersNotifier() : super([]);

  void addUser(UserModel user) {
    if (!state.contains(user)) {
      state = [...state, user];
    }
  }

  void removeUser(UserModel user) {
    state = state.where((u) => u.id != user.id).toList();
  }

  void clearSelection() {
    state = [];
  }
  
  bool isSelected(UserModel user) {
    return state.any((u) => u.id == user.id);
  }
}

// Create the provider
final selectedUsersProvider = StateNotifierProvider.autoDispose<SelectedUsersNotifier, List<UserModel>>((ref) {
  return SelectedUsersNotifier();
});