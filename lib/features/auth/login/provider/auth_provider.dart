import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenzen/config/constants.dart';
import 'package:zenzen/data/api/auth_api.dart';

import '../../../../utils/providers/dio_provider.dart';
import '../repo/auth_repository.dart';
import '../viewmodel/auth_viewmodel.dart';

// Data Source Provider
final authRemoteDataSourceProvider = Provider<AuthApiService>(
  (ref) => AuthApiService(
    ApiRoutes.baseUrl, 
    ref.read(dioProvider),
    ref.read(tokenManagerProvider),
  ),
);

// Repository Provider
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.read(authRemoteDataSourceProvider)),
);

// ViewModel Provider

