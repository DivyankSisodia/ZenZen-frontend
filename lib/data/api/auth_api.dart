import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zenzen/config/router/constants.dart';
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
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
        enabled: kDebugMode,
        request: true,
        filter: (options, args) {
          // don't print requests with uris containing '/posts'
          if (options.path.contains('/auth/')) {
            return false;
          }
          // don't print responses with unit8 list data
          return !args.isResponse || !args.hasUint8ListData;
        },
      ),
    );

    // Add token refresh interceptor
    dio.interceptors.add(QueuedInterceptorsWrapper(
      onError: (DioException error, ErrorInterceptorHandler handler) async {
        print('Error: $error');
        if (error.response?.statusCode == 401) {
          // Check if the error message contains JWT expired or token related terms
          final errorMsg = error.response?.data?['error'] ?? '';
          final isTokenExpired = errorMsg.toLowerCase().contains('expired') || errorMsg.toLowerCase().contains('jwt') || errorMsg.toLowerCase().contains('token');

          if (!isTokenExpired) {
            handler.next(error);
            return;
          }

          final refreshToken = await tokenManager.getRefreshToken();
          debugPrint('Refresh token: $refreshToken');
          if (refreshToken == null || refreshToken.isEmpty) {
            _logoutUser();
            handler.reject(error);
            return;
          }

          try {
            debugPrint('Refreshing token...');
            // Call refresh token endpoint
            final response = await dio.post(
              '$baseUrl${ApiRoutes.getAccessToken}',
              data: {'refreshToken': refreshToken},
              options: Options(headers: {'Content-Type': 'application/json'}),
            );

            if (response.statusCode == 200 && response.data != null) {
              // Check if the data has the expected structure
              final responseData = response.data['data'];
              print('Response data: $responseData');
              if (responseData is Map && responseData.containsKey('accessToken') && responseData.containsKey('refreshToken')) {
                final newAccessToken = responseData['accessToken'];
                final newRefreshToken = responseData['refreshToken'];

                // Save new tokens
                await tokenManager.saveTokens(
                  accessToken: newAccessToken,
                  refreshToken: newRefreshToken,
                );

                print('Token refreshed successfully');
                print('New access token: $newAccessToken');
                print('New refresh token: $newRefreshToken');

                // Create a new request with the updated token
                final opts = Options(
                  method: error.requestOptions.method,
                  headers: {
                    ...error.requestOptions.headers,
                    'Authorization': 'Bearer $newAccessToken',
                  },
                );

                print("headers daal rha ${opts.headers}");

                final clonedRequest = await dio.request(
                  error.requestOptions.path,
                  options: opts,
                  data: error.requestOptions.data,
                  queryParameters: error.requestOptions.queryParameters,
                );

                print('Request after token refresh: $clonedRequest');

                // Retry the request

                handler.resolve(clonedRequest);
                return;
              }
            }

            print('Failed to refresh token');

            // If we get here, token refresh failed
            _logoutUser();
            handler.reject(error);
          } catch (e) {
            debugPrint('Error refreshing token: $e');
            _logoutUser();
            handler.reject(error);
          }
        } else {
          handler.next(error);
        }
      },
    ));
  }

  void _logoutUser() {
    // Clear tokens
    tokenManager.clearTokens();
  }

  Future<Either<UserModel, ApiFailure>> login(String email, String password) async {
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
        debugPrint('User data: ${response.data['data']['tokens']['accessToken']}');
        final user = UserModel.fromJson({...response.data['data']['user'], 'tokens': response.data['data']['tokens']});

        return Left(user);
      } else {
        return Right(ApiFailure.custom(response.data['message'] ?? 'Unknown error'));
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

  Future<Either<OtpModel, ApiFailure>> verifyUser(String email, String otp) async {
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

  Future<Either<List<UserModel>, ApiFailure>> getUsers() async {
    try {
      final accessToken = await tokenManager.getAccessToken();

      final Map<String, dynamic> headers = {};
      if (accessToken != null && accessToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $accessToken';
      }
      final response = await dio.get(
        '$baseUrl${ApiRoutes.getUsers}',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        // Access the 'data' array from the response
        if (response.data is Map<String, dynamic> && response.data.containsKey('data')) {
          final List<dynamic> documentsData = response.data['data'] as List<dynamic>;

          final documents = documentsData.map((doc) => UserModel.fromJson(doc as Map<String, dynamic>)).toList();

          return Left(documents);
        } else {
          return Right(ApiFailure('Response missing "data" field or has incorrect format'));
        }
      }
      return Right(ApiFailure('Unexpected response status code'));
    } on DioException catch (e) {
      return Right(ApiFailure.fromDioException(e));
    }
  }
}
