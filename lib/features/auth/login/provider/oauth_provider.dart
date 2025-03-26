// Providers
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:zenzen/features/auth/login/viewmodel/auth_viewmodel.dart';

import '../../../../config/router/constants.dart';
import '../../../../data/api/auth_api.dart';
import '../repo/oauth_repository.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn();
});

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();

  // Add interceptors for auth token, logging, etc.
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        // You can add auth token from secure storage here
        // options.headers['Authorization'] = 'Bearer $token';
        return handler.next(options);
      },
      onError: (error, handler) {
        // Handle token expiration, etc.
        if (error.response?.statusCode == 401) {
          // Handle token refresh or logout
        }
        return handler.next(error);
      },
    ),
  );

  return dio;
});

final authApiServiceProvider = Provider<AuthApiService>((ref) {
  final tokens = ref.watch(tokenManagerProvider);
  final dio = ref.watch(dioProvider);
  print(ApiRoutes.baseUrl);
  return AuthApiService(ApiRoutes.baseUrl, dio, tokens);
});

final authRepositoryProvider = Provider<OAuthRepository>((ref) {
  return OAuthRepository(
    auth: ref.watch(firebaseAuthProvider),
    googleSignIn: ref.watch(googleSignInProvider),
    apiService: ref.watch(authApiServiceProvider),
  );
});
