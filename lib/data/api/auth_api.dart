import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:zenzen/config/constants.dart';
import 'package:zenzen/data/failure.dart';
import 'package:zenzen/features/auth/login/model/user_model.dart';

class AuthApiService {
  final String baseUrl;
  final Dio dio;

  AuthApiService(this.baseUrl, this.dio);

  Future<Either<UserModel, ApiFailure>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await dio.post(
        '$baseUrl${ApiRoutes.login}',
        data: {
          'email': email,
          'password': password,
        },
      );

      print('response: ${response.data}');

      if (response.statusCode == 200) {
        final user = UserModel.fromJson(response.data);
        return Left(user);
      } else {
        return Right(ApiFailure.custom(response.data['message']));
      }
    } on DioException catch (e) {
      return Right(ApiFailure.fromDioException(e));
    }
  }

  Future<Either<UserModel, ApiFailure>> register(
    String email,
    String password,
  ) async {
    try {
      final response = await dio.post(
        '$baseUrl${ApiRoutes.registerUserInfo}',
        data: {
          'email': email,
          'password': password,
        },
      );

      final user = UserModel.fromJson(response.data);
      return Left(user);
    } on DioException catch (e) {
      return Right(ApiFailure.fromDioException(e));
    }
  }

  Future<Either<UserModel, AuthFailure>> getUser() async {
    try {
      final response = await dio.get('$baseUrl/auth/user');

      final user = UserModel.fromJson(response.data);
      return Left(user);
    } on DioException catch (e) {
      return Right(AuthFailure.custom(e.message!));
    }
  }

  Future<Either<UserModel, ApiFailure>> signUp(
    String email,
    String password,
  ) async {
    try {
      print('$baseUrl${ApiRoutes.signup}');
      final response = await dio.post(
        '$baseUrl${ApiRoutes.signup}',
        data: {
          'email': email,
          'password': password,
        },
      );

      print('response: ${response.data}');

      final user = UserModel.fromJson(response.data);
      return Left(user);
    } on DioException catch (e) {
      return Right(ApiFailure.fromDioException(e));
    }
  }
}
