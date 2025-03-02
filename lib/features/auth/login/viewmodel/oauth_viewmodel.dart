import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/failure.dart';
import '../model/user_model.dart';
import '../provider/oauth_provider.dart';
import '../repo/oauth_repository.dart';

class AuthState {
  final bool isLoading;
  final UserModel? user;
  final AuthFailure? failure;

  AuthState({
    this.isLoading = false,
    this.user,
    this.failure,
  });

  bool get isLoggedIn => user != null;

  AuthState copyWith({
    bool? isLoading,
    UserModel? user,
    AuthFailure? failure,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      failure: failure,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(AuthState()) {
    // Check if user is already logged in
    _checkCurrentUser();
  }

  Future<void> _checkCurrentUser() async {
    state = state.copyWith(isLoading: true);

    final result = await _repository.getCurrentUser();

    result.fold(
      (user) =>
          state = state.copyWith(isLoading: false, user: user, failure: null),
      (failure) => state = state.copyWith(
          isLoading: false,
          failure: null), // Just set loading to false, no error
    );
  }

  Future<void> signInWithGoogle(bool isLogin) async {
    state = state.copyWith(isLoading: true, failure: null);

    final result = isLogin == true
        ? await _repository.signInWithGoogle(true)
        : await _repository.signInWithGoogle(false);

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, failure: failure),
      (userCredential) {
        final userModel = UserModel.fromUserCredential(userCredential);
        state =
            state.copyWith(isLoading: false, user: userModel, failure: null);
      },
    );
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);

    await _repository.signOut();

    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});
