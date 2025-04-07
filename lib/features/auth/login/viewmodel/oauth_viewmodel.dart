import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zenzen/config/router/constants.dart';
import 'package:zenzen/data/local_data.dart';

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
  final OAuthRepository _repository;

  AuthNotifier(this._repository) : super(AuthState());

  Future<void> signInWithGoogle(bool isLogin, BuildContext context) async {
    state = state.copyWith(isLoading: true, failure: null);

    final result = isLogin == true ? await _repository.signInWithGoogle(true) : await _repository.signInWithGoogle(false);

    print('result: $result');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.getBool('isVerified');

    final bool x = prefs.getBool('isVerified') ?? false;
    print('isVerified oAuth login: $x');

    result.fold(
      (failure) => state = state.copyWith(isLoading: false, failure: failure),
      (userCredential) {

        TokenManager tokenManager = TokenManager();

        print('Access Token: ${userCredential.credential!.accessToken}');
        print('Refresh Token: ${userCredential.user!.refreshToken}');

        if (userCredential.credential!.accessToken != null && userCredential.user!.refreshToken != null) {
          tokenManager.saveTokens(
            accessToken: userCredential.credential!.accessToken!,
            refreshToken: userCredential.user!.refreshToken!,
          );
        }

        final userModel = UserModel.fromUserCredential(userCredential);

        state = state.copyWith(isLoading: false, user: userModel, failure: null);
        x ? context.goNamed(RoutesName.home) : context.goNamed(RoutesName.registerInfo);
      },
    );
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);

    await _repository.signOut();

    state = AuthState();
  }

  // // OAuth login
  // Future<void> loginWithOAuth(String email, String password, BuildContext context) async {
  //   state = state.copyWith(isLoading: true, failure: null);

  //   final result = await _repository.loginWithOAuth(email, password);

  //   result.fold(
  //     (userModel) {
  //       TokenManager tokenManager = TokenManager();

  //       print('Access Token: ${userCredential.credential!.accessToken}');
  //       print('Refresh Token: ${userCredential!.user!.refreshToken}');

  //       if (userCredential.credential!.accessToken != null && userCredential!.user!.refreshToken != null) {
  //         tokenManager.saveTokens(
  //           accessToken: userCredential.credential!.accessToken!,
  //           refreshToken: userCredential!.user!.refreshToken!,
  //         );
  //       }

  //       final userModel = UserModel.fromUserCredential(userCredential);

  //       state = state.copyWith(isLoading: false, user: userModel, failure: null);
  //       context.goNamed(RoutesName.home);
  //     },
  //     (failure) => state = state.copyWith(isLoading: false, failure: failure),
  //   );
  // }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});
