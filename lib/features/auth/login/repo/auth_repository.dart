import 'package:fpdart/fpdart.dart';
import 'package:zenzen/data/api/auth_api.dart';
import 'package:zenzen/data/failure.dart';
import 'package:zenzen/features/auth/login/model/user_model.dart';

class AuthRepository {
  final AuthApiService remoteDataSource;

  AuthRepository(this.remoteDataSource);

  Future<Either<UserModel, ApiFailure>> login(String email, String password) {
    return remoteDataSource.login(email, password);
  }

  Future<Either<UserModel, ApiFailure>> signup(String email, String password) {
    return remoteDataSource.signUp(email, password);
  }
}
