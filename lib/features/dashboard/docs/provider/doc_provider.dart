import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenzen/data/api/doc_api.dart';

import '../../../../config/router/constants.dart';
import '../../../../utils/providers/dio_provider.dart';
import '../../../auth/login/viewmodel/auth_viewmodel.dart';
import '../repo/document_repo.dart';

final docRemoteDataSourceProvider = Provider<DocApiService>(
  (ref)=> DocApiService(
    ApiRoutes.baseUrl,
    ref.read(dioProvider),
    ref.read(tokenManagerProvider),
  ),
);

// Repository Provider
final docRepositoryProvider = Provider<DocRepository>(
  (ref) => DocRepository(ref.read(docRemoteDataSourceProvider)),
);
