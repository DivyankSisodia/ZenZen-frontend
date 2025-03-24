import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:zenzen/data/failure.dart';
import 'package:zenzen/data/local_data.dart';
import 'package:zenzen/features/dashboard/projects/model/project_model.dart';

import '../../config/router/constants.dart';

class ProjectApi {
  final String baseUrl;
  final Dio dio;
  final TokenManager tokenManager;

  ProjectApi(this.baseUrl, this.dio, this.tokenManager) {
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
          // if (options.path.contains('/')) {
          //   return false;
          // }
          // don't print responses with unit8 list data
          return !args.isResponse || !args.hasUint8ListData;
        },
      ),
    );

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

  Future<Either<ProjectModel, ApiFailure>> createProject(String title, String? description) async {
    try {
      final accessToken = await tokenManager.getAccessToken();
      final Map<String, dynamic> headers = {};
      if (accessToken != null && accessToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $accessToken';
      }

      final res = await dio.post(
        '$baseUrl${ApiRoutes.createProject}',
        data: {
          'title': title,
          'description': description,
        },
        options: Options(headers: headers),
      );

      if (res.statusCode == 200) {
        final project = ProjectModel.fromJson(res.data);
        return Left(project);
      } else {
        return Right(ApiFailure('Failed to create project'));
      }
    } on DioError catch (e) {
      return Right(ApiFailure.fromDioException(e));
    }
  }

  // get all projects
  Future<Either<List<ProjectModel>, ApiFailure>> getProjects() async {
    try {
      final accessToken = await tokenManager.getAccessToken();
      final Map<String, dynamic> headers = {};
      if (accessToken != null && accessToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $accessToken';
      }

      final response = await dio.post(
        '$baseUrl${ApiRoutes.getAllProjects}',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        // Access the 'data' array from the response
        if (response.data is Map<String, dynamic> &&
            response.data.containsKey('data')) {
          final List<dynamic> documentsData =
              response.data['data'] as List<dynamic>;

          final documents = documentsData
              .map((doc) => ProjectModel.fromJson(doc as Map<String, dynamic>))
              .toList();

          return Left(documents);
        } else {
          return Right(ApiFailure(
              'Response missing "data" field or has incorrect format'));
        }
      } else {
        final errorMsg = response.data is Map<String, dynamic> &&
                response.data.containsKey('message')
            ? response.data['message']
            : 'Unknown error';

        return Right(ApiFailure(errorMsg));
      }
    } on DioException catch (e) {
      return Right(ApiFailure.fromDioException(e));
    } catch (e) {
      // Add a general catch to handle JSON parsing errors

      return Right(ApiFailure('Failed to parse response: $e'));
    }
  }

  // add user to project
  Future<Either<ProjectModel, ApiFailure>> addUserToProject(
      String projectId, List<String> users) async {
    try {
      final accessToken = await tokenManager.getAccessToken();
      final Map<String, dynamic> headers = {};
      if (accessToken != null && accessToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $accessToken';
      }

      final response = await dio.post(
        '$baseUrl${ApiRoutes.addUserToProject}',
        data: {
          'projectId': projectId,
          'users': users,
        },
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        // If the response is wrapped in a data field, extract it
        Map<String, dynamic> projectData;
        if (response.data is Map<String, dynamic> &&
            response.data.containsKey('data')) {
          projectData = response.data['data'];
        } else {
          projectData = response.data;
        }

        final project = ProjectModel.fromJson(projectData);
        return Left(project);
      } else {
        return Right(ApiFailure('Failed to add user to project'));
      }
    } on DioError catch (e) {
      return Right(ApiFailure.fromDioException(e));
    }
  }

  // delete project
  Future<Either<bool, ApiFailure>> deleteProject(String projectId) async {
    try {
      final accessToken = await tokenManager.getAccessToken();
      final Map<String, dynamic> headers = {};
      if (accessToken != null && accessToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $accessToken';
      }

      final response = await dio.post(
        '$baseUrl${ApiRoutes.deleteProject}',
        data: {
          'projectId': projectId,
        },
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        return Left(true);
      } else {
        return Right(ApiFailure('Failed to delete project'));
      }
    } on DioError catch (e) {
      return Right(ApiFailure.fromDioException(e));
    }
  }
}
