// ignore_for_file: implementation_imports

import 'package:dio/src/dio_exception.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ApiFailure {
  final String error;
  final String? code;

  ApiFailure(this.error, {this.code});

  factory ApiFailure.custom(String message) {
    return ApiFailure(message);
  }

  factory ApiFailure.fromDioException(DioException e) {
    // Extract error message from response if available
    String errorMessage = e.message ?? 'Unknown error occurred';
    if (e.response?.data is Map && e.response?.data.containsKey('error')) {
      errorMessage = e.response?.data['error'];
    }
    return ApiFailure(errorMessage);
  }
}

class AuthFailure {
  final String error;
  final String? code;

  AuthFailure(this.error, {this.code});

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
