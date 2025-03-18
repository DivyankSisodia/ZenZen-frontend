import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zenzen/config/constants.dart';
import 'package:zenzen/data/local/hive_models/local_user_model.dart';
import 'package:zenzen/features/auth/login/model/user_model.dart';

import '../../../../data/local/service/user_service.dart';
import '../../../../data/local_data.dart';
import '../provider/auth_provider.dart';
import '../repo/auth_repository.dart';

final tokenManagerProvider = Provider((ref) => TokenManager());

class AuthViewModel extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthRepository repository;
  final TokenManager tokenManager;
  final Ref ref;

  AuthViewModel(this.repository, this.tokenManager, this.ref)
      : super(const AsyncValue.data(null));

  Future<void> login(String email, String password, BuildContext context) async {
    try {
      state = const AsyncValue.loading();
      final result = await repository.login(email, password);

      result.fold(
        (userModel) async {
          state = AsyncValue.data(userModel);

          if (userModel.refreshToken != null && userModel.accessToken != null) {
            await tokenManager.saveTokens(
              accessToken: userModel.accessToken!,
              refreshToken: userModel.refreshToken!,
            );
          }

          // Convert UserModel to User (Hive model)
          print('UserModel in viewmodel: ${userModel.toJson()}');
          final localUser = User(
            id: userModel.id ?? '',
            userName: userModel.userName ?? '',
            avatar: userModel.avatar ?? '',
            email: email,
            mobile: userModel.mobile ?? '',
            isVerified: userModel.isVerified ?? false,
          );

          print('LocalUser in vm: ${localUser.id}');

          // Save the converted user data to Hive
          final hiveService = ref.read(userDataProvider);
          await hiveService.userBox.put('currentUser', localUser);

          bool isVerifiedUser = userModel.isVerified ?? false;

          if (isVerifiedUser) {
            context.goNamed(RoutesName.home);
          } else {
            context.goNamed(RoutesName.verifyUser, extra: email);
          }
        },
        (error) {
          print('Login error: $error');
          state = AsyncValue.error(error, StackTrace.current);
        },
      );
    } catch (e, stackTrace) {
      print('Unexpected error in login: $e');
      print('Stack trace: $stackTrace');
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> signup(
      String email, String password, BuildContext context) async {
    state = const AsyncValue.loading();
    final result = await repository.signup(email, password);

    result.fold(
      (userModel) async {
        // Save tokens
        if (userModel.refreshToken != null && userModel.accessToken != null) {
          await tokenManager.saveTokens(
            accessToken: userModel.accessToken!,
            refreshToken: userModel.refreshToken!,
          );
        }
        state = AsyncValue.data(userModel);

        // Navigate to login or home
        context.goNamed(RoutesName.registerInfo);
      },
      (error) {
        state = AsyncValue.error(error, StackTrace.current);
      },
    );
  }

  Future<void> logout(BuildContext context) async {
    await tokenManager.clearTokens();
    state = const AsyncValue.data(null);
    context.goNamed(RoutesName.login);
  }

  Future<void> register(String email, String userName, String mobile,
      String avatar, BuildContext context) async {
    state = const AsyncValue.loading();
    final result =
        await repository.registerInfo(email, userName, mobile, avatar);

    state = result.fold(
      (authmodel) => AsyncValue.data(authmodel),
      (error) => AsyncValue.error(error, StackTrace.current),
    );

    if (result.isLeft()) {
      // Go to home screen
      context.goNamed(RoutesName.verifyUser, extra: email);
    }
  }
}

final authStateProvider =
    StateNotifierProvider<AuthViewModel, AsyncValue<UserModel?>>((ref) {
  return AuthViewModel(
    ref.read(authRepositoryProvider),
    ref.read(tokenManagerProvider),
    ref,
  );
});

final userDataProvider = Provider<HiveService>((ref) {
  return HiveService();
});
