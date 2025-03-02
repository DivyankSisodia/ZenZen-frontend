import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenzen/config/constants.dart';
import 'package:zenzen/data/api/auth_api.dart';
import 'package:zenzen/features/auth/login/model/user_model.dart';

import '../repo/auth_repository.dart';
import '../viewmodel/auth_viewmodel.dart';

// Dio Provider
final dioProvider = Provider<Dio>(
  (ref) => Dio(
    BaseOptions(
      baseUrl: ApiRoutes.baseUrl,
    ),
  ),
);

// Data Source Provider
final authRemoteDataSourceProvider = Provider<AuthApiService>(
  (ref) => AuthApiService(
    ApiRoutes.baseUrl, 
    ref.read(dioProvider),
  ),
);



// Repository Provider
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.read(authRemoteDataSourceProvider)),
);

// ViewModel Provider
final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AsyncValue<UserModel?>>(
  (ref) => AuthViewModel(ref.read(authRepositoryProvider)),
);
