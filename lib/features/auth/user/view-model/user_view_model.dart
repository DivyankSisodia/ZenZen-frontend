import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenzen/features/auth/login/model/user_model.dart';
import 'package:zenzen/features/auth/user/provider/user_provider.dart';
import 'package:zenzen/features/auth/user/repo/user_repo.dart';

import '../../../../utils/common/custom_toast.dart';

class UserViewModel extends StateNotifier<AsyncValue<List<UserModel>>> {
  final UserRepo repository;
  final Ref ref;

  UserViewModel(this.repository, this.ref) : super(const AsyncValue.loading());

  bool _isLoading = false;

  CustomToast customToast = CustomToast();

  Future<void> getAllUsers() async {
    // Skip if already loading
    if (_isLoading) return;

    _isLoading = true;
    state = const AsyncValue.loading();

    try {
      final result = await repository.getAllUsers();
      if (mounted) {
        result.fold(
          (user) => state = AsyncValue.data(user),
          (error) => state = AsyncValue.error(error, StackTrace.current),
        );
      }
    } catch (e, stackTrace) {
      if (mounted) {
        state = AsyncValue.error(e, stackTrace);
      }
    } finally {
      _isLoading = false;
    }
  }
}

final userViewmodelProvider = StateNotifierProvider<UserViewModel, AsyncValue<List<UserModel>>>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return UserViewModel(repository, ref);
});