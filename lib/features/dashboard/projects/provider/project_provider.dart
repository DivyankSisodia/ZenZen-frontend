import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenzen/data/api/project_api.dart';

import '../../../../config/constants.dart';
import '../../../../utils/providers/dio_provider.dart';
import '../../../auth/login/viewmodel/auth_viewmodel.dart';
import '../repo/project_repo.dart';

final projectRemoteDataSourceProvider = Provider<ProjectApi>(
  (ref) => ProjectApi(
    ApiRoutes.baseUrl,
    ref.read(dioProvider),
    ref.read(tokenManagerProvider),
  ),
);

// Repository Provider
final projectRepositoryProvider = Provider<ProjectRepository>(
  (ref) => ProjectRepository(ref.read(projectRemoteDataSourceProvider)),
);