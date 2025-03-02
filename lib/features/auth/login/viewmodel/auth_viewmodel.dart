import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zenzen/config/app_router.dart';
import 'package:zenzen/config/constants.dart';
import 'package:zenzen/features/auth/login/model/user_model.dart';

import '../repo/auth_repository.dart';

class AuthViewModel extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthRepository repository;

  AuthViewModel(this.repository) : super(const AsyncValue.data(null));

  Future<void> login(
      String email, String password, BuildContext context) async {
    state = const AsyncValue.loading();
    final result = await repository.login(email, password);

    state = result.fold(
      (authmodel) => AsyncValue.data(authmodel),
      (error) => AsyncValue.error(error, StackTrace.current),
    );

    if (result.isLeft()) {
      // Go to home screen
      context.pushNamed(RoutesName.home);
    }
  }

  Future<void> signup(String email, String password) async {
    state = const AsyncValue.loading();
    final result = await repository.signup(email, password);

    state = result.fold(
      (authmodel) => AsyncValue.data(authmodel),
      (error) => AsyncValue.error(error, StackTrace.current),
    );
  }
}
