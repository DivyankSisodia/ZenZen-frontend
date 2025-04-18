// ignore_for_file: implementation_imports

import 'package:dio/src/dio_exception.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ApiFailure {
  final String error;
  final String? code;

  ApiFailure(this.error, {this.code});

  bool get isConnectionError {
    return error.toLowerCase().contains('socket') || 
           error.toLowerCase().contains('connection') ||
           error.toLowerCase().contains('network') ||
           error.toLowerCase().contains('internet') ||
           error.toLowerCase().contains('timeout');
  }

  factory ApiFailure.custom(String message) {
    return ApiFailure(message);
  }

  // factory ApiFailure.fromDioException(DioException e) {
  //   // Extract error message from response if available
  //   String errorMessage = e.message ?? 'Unknown error occurred';
  //   if (e.response?.data is Map && e.response?.data.containsKey('error')) {
  //     errorMessage = e.response?.data['error'];
  //   }
  //   return ApiFailure(errorMessage);
  // }
  factory ApiFailure.fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiFailure('Connection timed out. Please check your internet connection.');
      case DioExceptionType.connectionError:
        return ApiFailure('No internet connection. Please check your network settings.');
      // Other cases...
      default:
        if (e.message?.contains('SocketException') ?? false) {
          return ApiFailure('Network error: Cannot connect to the server');
        }
        return ApiFailure(e.message ?? 'Unknown error occurred');
    }
  }
}

class AuthFailure {
  final String error;
  final String? code;

  AuthFailure(this.error, {this.code});

  factory AuthFailure.fromApiFailure(ApiFailure e) {
    return AuthFailure(e.error, code: e.code);
  }

  factory AuthFailure.fromDioException(DioException e) {
    return AuthFailure(
      e.response?.statusMessage ?? 'Network error occurred',
      code: e.response?.statusCode.toString(),
    );
  }

  factory AuthFailure.fromFirebaseException(FirebaseAuthException e) {
    return AuthFailure(e.message ?? 'Authentication failed', code: e.code);
  }

  factory AuthFailure.custom(String error) {
    return AuthFailure(error);
  }

  @override
  String toString() => 'AuthFailure: $error (code: $code)';
}
