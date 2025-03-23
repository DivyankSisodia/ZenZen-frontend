import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenzen/data/api/misc_api.dart';

import '../../../../config/router/constants.dart';
import '../../../../utils/providers/dio_provider.dart';
import '../../login/viewmodel/auth_viewmodel.dart';
import '../repo/user_repo.dart';

final userRemoteDataSourceProvider = Provider<MiscApi>(
  (ref)=> MiscApi(
    ApiRoutes.baseUrl,
    ref.read(dioProvider),
    ref.read(tokenManagerProvider),
  ),
);

// Repository Provider
final userRepositoryProvider = Provider<UserRepo>(
  (ref) => UserRepo(ref.read(userRemoteDataSourceProvider)),
);
