import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:zenzen/data/failure.dart';
import 'package:zenzen/data/local_data.dart';
// Add this import

import '../../config/constants/constants.dart';
import '../../features/dashboard/docs/model/document_model.dart';

class DocApiService {
  final String baseUrl;
  final Dio dio;
  final TokenManager tokenManager;

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
        // request: true,
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
  }

  // create a document
  Future<Either<DocumentModel, ApiFailure>> createDocument(
      String title, String projectId) async {
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
        final responseData = response.data is Map && response.data.containsKey('data') 
            ? response.data['data'] 
            : response.data;
            
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
  // get all documents
  Future<Either<List<DocumentModel>, ApiFailure>> getDocuments() async {
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
        if (response.data is Map<String, dynamic> &&
            response.data.containsKey('data')) {
          final List<dynamic> documentsData =
              response.data['data'] as List<dynamic>;

          final documents = documentsData
              .map((doc) => DocumentModel.fromJson(doc as Map<String, dynamic>))
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

  // get a document by id
  // get a document by id
  Future<Either<DocumentModel, ApiFailure>> getDocInfo(String id) async {
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
        // If the response is wrapped in a data field, extract it
        Map<String, dynamic> documentData;
        if (response.data is Map<String, dynamic> &&
            response.data.containsKey('data')) {
          documentData = response.data['data'];
        } else {
          documentData = response.data;
        }

        final document = DocumentModel.fromJson(documentData);

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
          'email': sharedUsers,
          'projectId': projectId,
        },
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        // If the response is wrapped in a data field, extract it
        Map<String, dynamic> documentData;
        if (response.data is Map<String, dynamic> &&
            response.data.containsKey('data')) {
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

}
