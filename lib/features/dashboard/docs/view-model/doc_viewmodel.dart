// ignore_for_file: unnecessary_cast, unused_catch_stack, unnecessary_type_check
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zenzen/features/dashboard/docs/model/document_model.dart';
import 'package:zenzen/features/dashboard/docs/repo/document_repo.dart';
import 'package:zenzen/utils/common/custom_toast.dart';

import '../../../../config/router/constants.dart';
import '../../../../data/failure.dart';
import '../provider/doc_provider.dart';

class DocViewmodel extends StateNotifier<AsyncValue<List<DocumentModel>>> {
  final DocRepository repository;
  final Ref ref;

  DocViewmodel(this.repository, this.ref) : super(const AsyncValue.loading());

  bool _isLoading = false;

  CustomToast customToast = CustomToast();

  Future<void> getAllDocuments() async {
    if (_isLoading) return;

    _isLoading = true;
    state = const AsyncValue.loading();
    try {
      final result = await repository.getDocuments();
      if (mounted) {
        result.fold(
          (documents) {
            state = const AsyncValue.loading();
            state = AsyncValue.data(documents);
          },
          (error) => state = AsyncValue.error(error, StackTrace.current),
        );
      }
    } catch (e, stackTrace) {
      if (mounted) {
        state = AsyncValue.error(e, stackTrace);
      }
    } finally {
      _isLoading = false;
    }
  }

  Future<void> getDocumentInfo(String id) async {
    if (_isLoading) return;

    _isLoading = true;
    state = const AsyncValue.loading();
    try {
      final result = await repository.getDocInfo(id);

      if (mounted) {
        result.fold(
          (docModel) {
            if (docModel.id != id) {
              state = AsyncValue.error('Document ID mismatch', StackTrace.current);
              return;
            }
            state = const AsyncValue.loading();
            state = AsyncValue.data([docModel]);
          },
          (error) => state = AsyncValue.error(error, StackTrace.current),
        );
      }
    } catch (e, stackTrace) {
      if (mounted) {
        state = AsyncValue.error(e, stackTrace);
      }
    } finally {
      _isLoading = false;
    }
  }

  Future<void> createDocument(
      String title, String projectId, BuildContext context) async {
    try {
      // Set loading state
      state = const AsyncValue.loading();

      // Call repository to create a new document
      final result = await repository.createDocument(title, projectId);

      result.fold(
        (docModel) async {
          // Debug log to see what's in the document model
          print('Document created: id=${docModel.id}, title=${docModel.title}');

          // Update state with the newly created document
          state = AsyncValue.data([docModel]);

          // Check if id is null before navigation
          if (docModel.id == null) {
            print('Warning: Document ID is null after creation');
            return; // Don't navigate if ID is null
          }

          getAllDocuments();

          // Navigate to the document screen with the newly created document's ID and title
          print('Document ID: ${docModel.id}');
          context.goNamed(
            RoutesName.doc,
            pathParameters: {'id': docModel.id!},
            extra: docModel.title, // title is non-nullable in your model
          );
        },
        (error) {
          print('Error creating document: $error');
          state = AsyncValue.error(error, StackTrace.current);
        },
      );
    } catch (e, stackTrace) {
      print('Unexpected error in createDocument: $e');
      print('Stack trace: $stackTrace');
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Add a user to a document
  Future<void> shareDocToUsers(
      String docId, List<String> users, String projectId) async {
    try {
      if (!state.isLoading) {
        state = const AsyncValue.loading();
      }

      final result = await repository.addUserToDoc(docId, users, projectId);

      result.fold(
        (docModel) {
          state = AsyncValue.data([docModel]);
          getAllDocuments();
        },
        (error) => state = AsyncValue.error(error, StackTrace.current),
      );
    } catch (e, stackTrace) {
      print('Unexpected error in createDocument: $e');
      print('Stack trace: $stackTrace');
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deleteDocument(String documentId, BuildContext context) async {
    try {
      // Call repository to delete the document
      final result = await repository.deleteDocument(documentId);

      result.fold(
        (success) {
          // Success case - Show success toast
          customToast.showToast('Document deleted successfully ☑️', context);

          getAllDocuments();
        },
        (error) {
          // Error case - Show error toast
          customToast.showToast(
            error is ApiFailure ? error.error : error.toString(),
            context,
          );
        },
        // (error)=> state = AsyncValue.error(error, StackTrace.current),
      );
    } catch (e) {
      // Catch unexpected errors and show a toast
      if (e is ApiFailure) {
        print('Error deleting document: ${e.error}');
      }
      customToast.showToast(
        e is ApiFailure ? e.error : e.toString(),
        context,
      );
    }
  }

  Future<void> getProjectDocs(String projectId) async {
    _isLoading = true;
    state = const AsyncValue.loading();
    try {
      final result = await repository.getProjectDocs(projectId);

      result.fold(
        (listOfDocs) => state = AsyncValue.data(listOfDocs),
        (error) => state = AsyncValue.error(error, StackTrace.current),
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    } finally {
      _isLoading = false;
    }
  }

  Future<void> getSharedDocs() async {
    _isLoading = true;
    state = const AsyncValue.loading();
    try {
      final result = await repository.getSharedWithMeDocs();

      result.fold(
        (listOfDocs) => state = AsyncValue.data(listOfDocs),
        (error) => state = AsyncValue.error(error, StackTrace.current),
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    } finally {
      _isLoading = false;
    }
  }
}

final docViewmodelProvider =
    StateNotifierProvider<DocViewmodel, AsyncValue<List<DocumentModel>>>((ref) {
  final repository = ref.watch(docRepositoryProvider);
  return DocViewmodel(repository, ref);
});
