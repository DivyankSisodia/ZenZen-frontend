import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:zenzen/data/failure.dart';
import 'package:zenzen/features/auth/login/model/user_model.dart';

import '../../config/router/constants.dart';
import '../cache/api_cache.dart';
import '../local_data.dart';

class MiscApi {
  final String baseUrl;
  final Dio dio;
  final TokenManager tokenManager;

  MiscApi(this.baseUrl, this.dio, this.tokenManager);

  final ApiCache _cache = ApiCache();

  Future<void> logout() async {
    try {
      final accessToken = await tokenManager.getAccessToken();

      final Map<String, dynamic> headers = {};
      if (accessToken != null && accessToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $accessToken';
      }
      await dio.post(
        '$baseUrl${ApiRoutes.logout}',
        options: Options(headers: headers),
      );
    } on DioException catch (e) {
      print('Error: $e');
    }
  }

  Future<void> deleteAccount() async {
    try {
      final accessToken = await tokenManager.getAccessToken();

      final Map<String, dynamic> headers = {};
      if (accessToken != null && accessToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $accessToken';
      }
      await dio.delete(
        '$baseUrl${ApiRoutes.deleteAccount}',
        options: Options(headers: headers),
      );
    } on DioException catch (e) {
      print('Error: $e');
    }
  }

  Future<Either<List<UserModel>, ApiFailure>> getAllUsers() async {
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
        if (response.data is Map<String, dynamic> && response.data.containsKey('data')) {
          final List<dynamic> documentsData = response.data['data'] as List<dynamic>;

          final users = documentsData.map((doc) => UserModel.fromJson(doc as Map<String, dynamic>)).toList();

          return Left(users);
        } else {
          return Right(ApiFailure('Response missing "data" field or has incorrect format'));
        }
      } else {
        final errorMsg = response.data is Map<String, dynamic> && response.data.containsKey('message') ? response.data['message'] : 'Unknown error';

        return Right(ApiFailure(errorMsg));
      }
    } on DioError catch (e) {
      return Right(ApiFailure.fromDioException(e));
    }
  }

  Future<Either<UserModel, ApiFailure>> getUserById(String userId) async {
    final cachedData = _cache.get('user_$userId');
    if (cachedData != null) {
      return Left(cachedData as UserModel);
    }
    try {
      final response = await dio.post(
        '$baseUrl${ApiRoutes.getUserById}',
        data: {
          'id': userId,
        },
      );

      if (response.statusCode == 200) {
        final user = UserModel.fromJson(response.data['data'] as Map<String, dynamic>);

        // Cache the user data
        _cache.set('user_$userId', user, duration: const Duration(minutes: 10));
        // Return the user data
        return Left(user);
      } else {
        return Right(ApiFailure.custom(response.data['message'] ?? 'Unknown error'));
      }
    } on DioException catch (e) {
      return Right(ApiFailure.fromDioException(e));
    }
  }

  Future<Either<List<UserModel>, ApiFailure>> getMultipleUsers(List<String> ids) async {
    try {
      final response = await dio.post(
        '$baseUrl${ApiRoutes.getMultipleUsers}',
        data: {
          'userIds': ids,
        },
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
