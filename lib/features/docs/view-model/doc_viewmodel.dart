import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenzen/features/docs/model/document_model.dart';
import 'package:zenzen/features/docs/repo/document_repo.dart';

import '../provider/doc_provider.dart';

class DocViewmodel extends StateNotifier<AsyncValue<List<DocumentModel>>> {
  final DocRepository repository;
  final Ref ref;

  DocViewmodel(this.repository, this.ref) : super(const AsyncValue.loading());


  Future<void> getAllDocuments() async {
  try {
    if (!state.isLoading) {
      state = const AsyncValue.loading();
    }
    
    final result = await repository.getDocuments();
    
    result.fold(
      (listOfDocs) => state = AsyncValue.data(listOfDocs),
      (error) => state = AsyncValue.error(error, StackTrace.current),
    );
  } catch (e, stackTrace) {
    state = AsyncValue.error(e, stackTrace);
  }
}


  Future<void> getDocumentInfo(String id) async {
    try {
      // Only set loading if not already in progress
      if (!state.isLoading) {
        state = const AsyncValue.loading();
      }

      final result = await repository.getDocInfo(id);

      if (mounted) {
        result.fold(
          (docModel) => state = AsyncValue.data([docModel]),
          (error) => state = AsyncValue.error(error, StackTrace.current),
        );
      }
    } catch (e, stackTrace) {
      if (mounted) {
        state = AsyncValue.error(e, stackTrace);
      }
    }
  }

  Future<void> createDocument(String title, String projectId) async {
    try {
      state = const AsyncValue.loading();
      final result = await repository.createDocument(title, projectId);

      result.fold(
        (docModel) async {
          state = AsyncValue.data([docModel]);
        },
        (error) {
          print('Login error: $error');
          state = AsyncValue.error(error, StackTrace.current);
        },
      );
    } catch (e, stackTrace) {
      print('Unexpected error in login: $e');
      print('Stack trace: $stackTrace');
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

final docViewmodelProvider =
    StateNotifierProvider<DocViewmodel, AsyncValue<List<DocumentModel>>>((ref) {
  final repository = ref.watch(docRepositoryProvider);
  return DocViewmodel(repository, ref);
});
