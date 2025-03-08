import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zenzen/config/constants.dart';
import 'package:zenzen/data/failure.dart';
import 'package:zenzen/features/auth/login/model/otp_model.dart';
import 'package:zenzen/features/auth/login/model/user_model.dart';

import '../local_data.dart';

class AuthApiService {
  final String baseUrl;
  final Dio dio;
  final TokenManager tokenManager;

  AuthApiService(this.baseUrl, this.dio, this.tokenManager) {
    // Add interceptor for authentication
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await tokenManager.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // Handle 401 errors (token expired)
          if (error.response?.statusCode == 401) {
            try {
              final refreshToken = await tokenManager.getRefreshToken();
              if (refreshToken != null) {
                // Refresh token logic here
                final refreshResponse = await dio.post(
                  '$baseUrl${ApiRoutes.getAccessToken}',
                  data: {'refreshToken': refreshToken},
                );

                if (refreshResponse.statusCode == 200) {
                  final newAccessToken =
                      refreshResponse.data['tokens']['access'];
                  final newRefreshToken =
                      refreshResponse.data['tokens']['refresh'];

                  await tokenManager.saveTokens(
                    accessToken: newAccessToken,
                    refreshToken: newRefreshToken,
                  );

                  // Retry original request
                  final opts = error.requestOptions;
                  opts.headers['Authorization'] = 'Bearer $newAccessToken';

                  final retryResponse = await dio.fetch(opts);
                  return handler.resolve(retryResponse);
                }
              }
            } catch (e) {
              // Fallback to default error handling
              print('Error refreshing token: $e');
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<Either<UserModel, ApiFailure>> login(
      String email, String password) async {
    try {
      final response = await dio.post(
        '$baseUrl${ApiRoutes.login}',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();

        bool isVerified = response.data['data']['user']['isVerified'] ?? false;
        String currentUserId = response.data['data']['user']['_id'] ?? '';

        prefs.setBool('isVerified', isVerified);
        prefs.setString('currentUserId', currentUserId);

        // Create UserModel with both user and token data
        final user = UserModel.fromJson({
          ...response.data['data']['user'],
          'tokens': response.data['data']['tokens']
        });

        return Left(user);
      } else {
        return Right(
            ApiFailure.custom(response.data['message'] ?? 'Unknown error'));
      }
    } on DioException catch (e) {
      return Right(ApiFailure.fromDioException(e));
    }
  }

  Future<Either<UserModel, ApiFailure>> register(
    String email,
    String userName,
    String mobile,
    String avatar,
  ) async {
    final accessToken = await tokenManager.getAccessToken();

    // Prepare headers with token if available
    final Map<String, dynamic> headers = {};
    if (accessToken != null && accessToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $accessToken';
    }
    try {
      final response = await dio.post(
        '$baseUrl${ApiRoutes.registerUserInfo}',
        data: {
          'email': email,
          'userName': userName,
          'mobile': mobile,
          'avatar': avatar,
        },
        options: headers.isNotEmpty ? Options(headers: headers) : Options(),
      );

      print('API service response: ${response.data}');

      final user = UserModel.fromJson(response.data);
      return Left(user);
    } on DioException catch (e) {
      return Right(ApiFailure.fromDioException(e));
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

  Future<Either<UserModel, ApiFailure>> getUser(String token) async {
    try {
      final accessToken = await tokenManager.getAccessToken();

      final Map<String, dynamic> headers = {};
      if (accessToken != null && accessToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $accessToken';
      }
      final response = await dio.get(
        '$baseUrl${ApiRoutes.user}',
        options: Options(headers: headers),
      );

      print('response: ${response.data}');

      final user = UserModel.fromJson(response.data);
      return Left(user);
    } on DioException catch (e) {
      return Right(ApiFailure.fromDioException(e));
    }
  }

  Future<Either<OtpModel, ApiFailure>> verifyUser(
      String email, String otp) async {
    try {
      final response = await dio.post(
        '$baseUrl${ApiRoutes.verifyUser}',
        data: {
          'email': email,
          'otp': otp,
        },
      );

      print('response: ${response.data}');

      final user = OtpModel.fromJson(response.data);
      return Left(user);
    } on DioException catch (e) {
      return Right(ApiFailure.fromDioException(e));
    }
  }

  Future<Either<OtpModel, ApiFailure>> sendOTP(String email) async {
    try {
      final response = await dio.post(
        '$baseUrl${ApiRoutes.sendOTP}',
        data: {
          'email': email,
        },
      );

      print('response: ${response.data}');

      final user = OtpModel.fromJson(response.data);
      return Left(user);
    } on DioException catch (e) {
      return Right(ApiFailure.fromDioException(e));
    }
  }
}
