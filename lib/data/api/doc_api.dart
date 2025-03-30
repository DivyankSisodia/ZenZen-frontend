import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:zenzen/data/cache/api_cache.dart';
import 'package:zenzen/data/failure.dart';
import 'package:zenzen/data/local_data.dart';
// Add this import

import '../../config/router/constants.dart';
import '../../features/dashboard/docs/model/document_model.dart';

class DocApiService {
  final String baseUrl;
  final Dio dio;
  final TokenManager tokenManager;
  final ApiCache apiCache = ApiCache();

  DocApiService(this.baseUrl, this.dio, this.tokenManager) {
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
          if (options.path.contains('/posts')) {
            return false;
          }
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

  // create a document
  Future<Either<DocumentModel, ApiFailure>> createDocument(String title, String projectId) async {
    try {
      final accessToken = await tokenManager.getAccessToken();
      final Map<String, dynamic> headers = {};
      if (accessToken != null && accessToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $accessToken';
      }

      final response = await dio.post(
        cancelToken: CancelToken(),
        data: {
          'title': title,
          'projectId': projectId,
        },
        '$baseUrl${ApiRoutes.createDocument}',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        // Debug the response
        print('API Response: ${response.data}');

        // Check if response.data contains 'data' field (common API pattern)
        final responseData = response.data is Map && response.data.containsKey('data') ? response.data['data'] : response.data;

        final document = DocumentModel.fromJson(responseData);

        // Debug the parsed document
        print('Parsed document: id=${document.id}, title=${document.title}');

        if (document.id == null) {
          print('Warning: Document ID is null after parsing. Raw response: ${response.data}');
        }

        return Left(document);
      } else {
        return Right(ApiFailure(response.data['error']));
      }
    } on DioException catch (e) {
      return Right(ApiFailure.fromDioException(e));
    }
  }

  // get all documents
  Future<Either<List<DocumentModel>, ApiFailure>> getDocuments() async {
    // fist check if the data is in cache
    final cachedData = apiCache.get(CacheConstants.getDocs);
    if (cachedData != null) {
      return Left(cachedData as List<DocumentModel>);
    }
    try {
      final accessToken = await tokenManager.getAccessToken();
      final Map<String, dynamic> headers = {};
      if (accessToken != null && accessToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $accessToken';
      }

      final response = await dio.post(
        '$baseUrl${ApiRoutes.getAllDocuments}',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        // Access the 'data' array from the response
        if (response.data is Map<String, dynamic> && response.data.containsKey('data')) {
          final List<dynamic> documentsData = response.data['data'] as List<dynamic>;

          final documents = documentsData.map((doc) => DocumentModel.fromJson(doc as Map<String, dynamic>)).toList();

          // store the data in cache
          apiCache.set(CacheConstants.getDocs, documents);

          return Left(documents);
        } else {
          return Right(ApiFailure('Response missing "data" field or has incorrect format'));
        }
      } else {
        final errorMsg = response.data is Map<String, dynamic> && response.data.containsKey('message') ? response.data['message'] : 'Unknown error';

        return Right(ApiFailure(errorMsg));
      }
    } on DioException catch (e) {
      return Right(ApiFailure.fromDioException(e));
    } catch (e) {
      // Add a general catch to handle JSON parsing errors

      return Right(ApiFailure('Failed to parse response: $e'));
    }
  }

  // get a document by id
  // get a document by id
  Future<Either<DocumentModel, ApiFailure>> getDocInfo(String id) async {
    print('Getting document info for id: $id');
    try {
      final accessToken = await tokenManager.getAccessToken();
      final Map<String, dynamic> headers = {};
      if (accessToken != null && accessToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $accessToken';
      }

      final response = await dio.post(
        data: {'docId': id},
        '$baseUrl${ApiRoutes.getDocumentInfo}',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        // Debug the response
        print('API Response: ${response.data}');

        // Check if response.data contains 'data' field (common API pattern)
        final responseData = response.data is Map && response.data.containsKey('data') ? response.data['data'] : response.data;

        final document = DocumentModel.fromJson(responseData);

        // Debug the parsed document
        print(document);

        return Left(document);
      } else {
        return Right(ApiFailure(response.data['error']));
      }
    } on DioException catch (e) {
      return Right(ApiFailure.fromDioException(e));
    }
  }

  // add user to document
  Future<Either<DocumentModel, ApiFailure>> shareDocument(String docId, List<String> sharedUsers, String projectId) async {
    try {
      final accessToken = await tokenManager.getAccessToken();
      final Map<String, dynamic> headers = {};
      if (accessToken != null && accessToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $accessToken';
      }

      final response = await dio.post(
        '$baseUrl${ApiRoutes.addUserToDoc}',
        data: {
          'docId': docId,
          'users': sharedUsers,
          'projectId': projectId,
        },
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        // If the response is wrapped in a data field, extract it
        Map<String, dynamic> documentData;
        if (response.data is Map<String, dynamic> && response.data.containsKey('data')) {
          documentData = response.data['data'];
        } else {
          documentData = response.data;
        }

        final document = DocumentModel.fromJson(documentData);
        return Left(document);
      } else {
        return Right(ApiFailure('Failed to add user to document'));
      }
    } on DioError catch (e) {
      return Right(ApiFailure.fromDioException(e));
    }
  }

  // delete a document
  Future<Either<bool, ApiFailure>> deleteDocument(String docId) async {
    print('Deleting document with id: $docId');
    try {
      final accessToken = await tokenManager.getAccessToken();
      final Map<String, dynamic> headers = {};
      if (accessToken != null && accessToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $accessToken';
      }

      print('response se pehle');

      print('url: $baseUrl${ApiRoutes.deleteDocument}');
      print('headers: $headers');
      print('docId: $docId');

      final response = await dio.post(
        '$baseUrl${ApiRoutes.deleteDocument}',
        data: {'docId': docId},
        options: Options(headers: headers),
      );

      try {
        print('response: ${response.data}');
      } catch (e) {
        print('Error in deleteDocument: $e');
      }

      if (response.statusCode == 200) {
        // Check for success message in response
        if (response.data is Map<String, dynamic> && response.data.containsKey('message') && response.data['message'] != null) {
          print('Document deleted: ${response.data['message']}');
          return Left(true);
        }
        return Left(true); // For backward compatibility
      } else {
        final errorMsg = response.data is Map<String, dynamic> && response.data.containsKey('message') ? response.data['message'] : 'Failed to delete document';
        return Right(ApiFailure(errorMsg));
      }
    } on DioException catch (e) {
      return Right(ApiFailure.fromDioException(e));
    }
  }

  Future<Either<List<DocumentModel>, ApiFailure>> getDocsForProject(String projectId) async {
    // first check if the data is in cache
    final cachedData = apiCache.get("${CacheConstants.projectDocs}-$projectId");
    if (cachedData != null) {
      return Left(cachedData as List<DocumentModel>);
    }
    // if not in cache, make the API call

    try {
      final accessToken = await tokenManager.getAccessToken();
      final Map<String, dynamic> headers = {};
      if (accessToken != null && accessToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $accessToken';
      }

      print('response se pehle');

      print('url: $baseUrl${ApiRoutes.getDocsForProject}');
      print('headers: $headers');
      print('docId: $projectId');

      final response = await dio.post(
        '$baseUrl${ApiRoutes.getDocsForProject}',
        data: {'projectId': projectId},
        options: Options(headers: headers),
      );

      if(response.statusCode == 200){
        if(response.data is Map<String, dynamic> && response.data.containsKey('data')){
          final List<dynamic> documentsData = response.data['data']['documents'] as List<dynamic>;

          final documents = documentsData.map((doc) => DocumentModel.fromJson(doc as Map<String, dynamic>)).toList();

          apiCache.set("${CacheConstants.projectDocs}-$projectId", documents);

          return Left(documents);
        } else {
          return Right(ApiFailure('Response missing "data" field or has incorrect format'));
        }
      } else {
        final errorMsg = response.data is Map<String, dynamic> && response.data.containsKey('message') ? response.data['message'] : 'Unknown error';

        return Right(ApiFailure(errorMsg));
      }
    } on DioException catch (e) {
      return Right(ApiFailure.fromDioException(e));
    }
  }

  // get sharedDocs

  Future<Either<List<DocumentModel>, ApiFailure>> getSharedDocs() async {
    try {
      final accessToken = await tokenManager.getAccessToken();
      final Map<String, dynamic> headers = {};
      if (accessToken != null && accessToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $accessToken';
      }

      final response = await dio.post(
        '$baseUrl${ApiRoutes.sharedDocs}',
        options: Options(headers: headers),
      );

      if(response.statusCode == 200){
        if(response.data is Map<String, dynamic> && response.data.containsKey('data')){
          final List<dynamic> documentsData = response.data['data'] as List<dynamic>;

          final documents = documentsData.map((doc) => DocumentModel.fromJson(doc as Map<String, dynamic>)).toList();

          return Left(documents);
        } else {
          return Right(ApiFailure('Response missing "data" field or has incorrect format'));
        }
      } else {
        final errorMsg = response.data is Map<String, dynamic> && response.data.containsKey('message') ? response.data['message'] : 'Unknown error';

        return Right(ApiFailure(errorMsg));
      }
    } on DioException catch (e) {
      return Right(ApiFailure.fromDioException(e));
    }
  }
}
