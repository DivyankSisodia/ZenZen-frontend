import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:zenzen/data/local_data.dart';

import '../config/router/constants.dart';

class TokenRefreshManager {
  final Dio dio;
  final TokenManager tokenManager;
  final String baseUrl;

  TokenRefreshManager({
    required this.dio,
    required this.tokenManager,
    required this.baseUrl,
  });

  // Check if an error is related to token expiration
  bool isTokenExpiredError(String errorMsg) {
    final lowercaseMsg = errorMsg.toLowerCase();
    return lowercaseMsg.contains('expired') || 
           lowercaseMsg.contains('jwt') || 
           lowercaseMsg.contains('token');
  }

  // Refresh the access token using refresh token
  Future<TokenPair?> refreshAccessToken(String refreshToken) async {
    debugPrint('Refreshing token...');
    
    try {
      final response = await dio.post(
        '$baseUrl${ApiRoutes.getAccessToken}',
        data: {'refreshToken': refreshToken},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      
      if (response.statusCode != 200 || response.data == null) {
        return null;
      }
      
      final responseData = response.data;
      if (responseData is! Map || 
          !responseData['data'].containsKey('accessToken') || 
          !responseData['data'].containsKey('refreshToken')) {
        return null;
      }
      
      final newAccessToken = responseData['data']['accessToken'];
      final newRefreshToken = responseData['data']['refreshToken'];
      
      // Save new tokens
      await tokenManager.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );
      
      return TokenPair(newAccessToken, newRefreshToken);
    } catch (e) {
      debugPrint('Error refreshing token: $e');
      return null;
    }
  }

  // Retry a request with a new token
  Future<Response> retryRequestWithNewToken(
    RequestOptions requestOptions,
    String newAccessToken,
  ) async {
    final opts = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        'Authorization': 'Bearer $newAccessToken',
      },
    );
    
    return dio.request(
      requestOptions.path,
      options: opts,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
    );
  }
}

// Simple class to hold token pair
class TokenPair {
  final String accessToken;
  final String refreshToken;
  
  TokenPair(this.accessToken, this.refreshToken);
}

