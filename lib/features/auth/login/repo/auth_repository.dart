import 'package:fpdart/fpdart.dart';
import 'package:zenzen/data/api/auth_api.dart';
import 'package:zenzen/data/failure.dart';
import 'package:zenzen/features/auth/login/model/otp_model.dart';
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

  Future<Either<UserModel, ApiFailure>> registerInfo(String email, String userName, String mobile, String avatar) {
    return remoteDataSource.register(email, userName, mobile, avatar);
  }

  Future<Either<UserModel, ApiFailure>> getCurrentUser(String token) {
    return remoteDataSource.getUser(token);
  }

  Future<Either<OtpModel, ApiFailure>> verifyUser(String email, String otp) {
    return remoteDataSource.verifyUser(email, otp);
  }

  Future<Either<OtpModel, ApiFailure>> sendOtp(String email) {
    return remoteDataSource.sendOTP(email);
  }
}
