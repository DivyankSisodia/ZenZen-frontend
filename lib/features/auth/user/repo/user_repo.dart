import 'package:fpdart/fpdart.dart';
import 'package:zenzen/data/api/misc_api.dart';

import '../../../../data/failure.dart';
import '../../login/model/user_model.dart';

class UserRepo {
  final MiscApi miscApi;

  UserRepo(this.miscApi);

  Future<void> logout() async {
    return miscApi.logout();
  }

  Future<void> deleteAccount() async {
    return miscApi.deleteAccount();
  }

  Future<Either<List<UserModel>, ApiFailure>> getAllUsers() async {
    return miscApi.getAllUsers();
  }

  Future<Either<UserModel, ApiFailure>> getUser(String id) async {
    return miscApi.getUserById(id);
  }
}