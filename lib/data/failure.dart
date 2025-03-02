import 'package:dio/src/dio_exception.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ApiFailure {
  final String message;
  final String? code;

  ApiFailure(this.message, {this.code});

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
  final String message;
  final String? code;

  AuthFailure(this.message, {this.code});

  factory AuthFailure.fromDioException(DioException e) {
    return AuthFailure(
      e.response?.statusMessage ?? 'Network error occurred',
      code: e.response?.statusCode.toString(),
    );
  }

  factory AuthFailure.fromFirebaseException(FirebaseAuthException e) {
    return AuthFailure(e.message ?? 'Authentication failed', code: e.code);
  }

  factory AuthFailure.custom(String message) {
    return AuthFailure(message);
  }

  @override
  String toString() => 'AuthFailure: $message (code: $code)';
}
