import 'package:fpdart/fpdart.dart';

import '../../../../data/api/doc_api.dart';
import '../../../../data/failure.dart';
import '../model/document_model.dart';

class DocRepository{
  final DocApiService remoteDataSource;

  DocRepository(this.remoteDataSource);

  Future<Either<List<DocumentModel>, ApiFailure>> getDocuments() {
    return remoteDataSource.getDocuments();
  }

  Future<Either<DocumentModel, ApiFailure>> getDocInfo(String id) {
    return remoteDataSource.getDocInfo(id);
  }

  Future<Either<DocumentModel, ApiFailure>> createDocument(String title, String projectId) {
    return remoteDataSource.createDocument(title, projectId);
  }

  Future<Either<DocumentModel, ApiFailure>> addUserToDoc(String docId, List<String> sharedUsers, String projectId) {
    return remoteDataSource.shareDocument(docId, sharedUsers, projectId);
  }

  Future<Either<bool, ApiFailure>> deleteDocument(String docId) {
    return remoteDataSource.deleteDocument(docId);
  }
}