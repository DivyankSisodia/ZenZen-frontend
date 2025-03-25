import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenzen/features/auth/login/model/user_model.dart';

import '../../../../data/local/hive_models/fav_documents_model.dart';
import '../../../../data/local/provider/hive_provider.dart';
import '../../../../data/local/service/user_service.dart';
import '../model/document_model.dart';

class FavDocumentViewModel
    extends StateNotifier<AsyncValue<List<FavDocument>>> {
  final HiveService hiveService;

  FavDocumentViewModel(this.hiveService) : super(const AsyncValue.loading()) {
    getAllFavorites();
  }

  void getAllFavorites() async {
    print('Getting all favorites');
    try {
      state = const AsyncValue.loading();
      await Future.delayed(const Duration(milliseconds: 800));
      final favBox = hiveService.favDocumentBox;
      final favorites = favBox.values.toList();
      // Call this wherever you need to print documents
      hiveService.printDocuments();
      try {
        print('Favorites: ${favorites.length}');
        state = AsyncValue.data(favorites);
      } catch (error) {
        state = AsyncValue.error(error, StackTrace.current);
      }
    } catch (e, stackTrace) {
      print('Error: $e');
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void addToFavorites(DocumentModel document) async {
    try {
      final favDocument = FavDocument(
        title: document.title,
        projectId: document.projectId!,
        id: document.id!,
        createdAt: document.createdAt,
        admin:
            document.admin?.toLocalUser(), // Convert UserModel? to LocalUser?
      );

      await hiveService.favDocumentBox.put(document.id!, favDocument);
      getAllFavorites(); // Refresh the list
    } catch (e, stackTrace) {
      print('Error: $e');
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void removeFromFavorites(String documentId) async {
    try {
      await hiveService.favDocumentBox.delete(documentId);
      print(hiveService.favDocumentBox.get(documentId));
      getAllFavorites(); // Refresh the list
    } catch (e, stackTrace) {
      print('Error: $e');
      state = AsyncValue.error(e, stackTrace);
    }
  }

  bool isFavorite(String documentId) {
    return hiveService.favDocumentBox.containsKey(documentId);
  }
}

// Provider definition
final favDocumentViewModelProvider =
    StateNotifierProvider<FavDocumentViewModel, AsyncValue<List<FavDocument>>>(
        (ref) {
  final hiveService = ref.watch(userDataProvider);
  return FavDocumentViewModel(hiveService);
});
