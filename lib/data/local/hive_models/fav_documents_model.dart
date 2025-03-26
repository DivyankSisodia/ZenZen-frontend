import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:zenzen/data/local/hive_models/local_user_model.dart';

import '../../../features/auth/login/model/user_model.dart';
import '../../../features/dashboard/docs/model/document_model.dart';

part 'fav_documents_model.g.dart';

@HiveType(typeId: 1)
class FavDocument {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String projectId;

  @HiveField(2)
  final String id;

  @HiveField(3)
  final String? description;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final LocalUser? admin;

  @HiveField(7)
  final LocalUser? users;

  @HiveField(8)
  final bool? isPrivate;

  FavDocument({
    required this.title,
    required this.projectId,
    required this.id,
    this.description,
    required this.createdAt,
    this.admin,
    this.users,
    this.isPrivate,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'projectId': projectId,
        'id': id,
        'description': description,
        'createdAt': createdAt.toIso8601String(),
        'admin': admin?.toJson(),
      };
}

extension FavDocumentExtension on FavDocument {
  DocumentModel toDocumentModel() {
    return DocumentModel(
      id: id,
      title: title,
      document: [], // Adjust if FavDocument has a document field
      users: [], // Adjust if FavDocument has a users field
      isPrivate: false, // Default or map from FavDocument if applicable
      createdBy: '', // Default or map from FavDocument if applicable
      createdAt: createdAt,
      updatedAt: createdAt, // Assuming no updatedAt in FavDocument
      isDeleted: false, // Default or map from FavDocument if applicable
      sharedUsers: [], // Adjust if FavDocument has sharedUsers
      sharedUserCount: 0, // Default or map from FavDocument if applicable
      admin: admin != null
          ? UserModel(id: admin!.id) // Convert LocalUser to UserModel
          : null,
      projectId: projectId,
    );
  }
}
