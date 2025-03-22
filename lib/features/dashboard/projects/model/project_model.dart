import '../../../auth/login/model/user_model.dart';
import '../../docs/model/document_model.dart';
// Import DocumentModel if needed.

class ProjectModel {
  final String? id;
  final String? title;
  final String? description;
  final List<UserModel>? addedUser;
  final List<UserModel>? admin;
  final bool? isDeleted;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  // documents can be List<String> or List<DocumentModel>
  final List<dynamic>? documents;

  ProjectModel({
    this.id,
    this.title,
    this.description,
    this.addedUser,
    this.admin,
    this.isDeleted,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.documents,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'addedUser': addedUser,
      'admin': admin,
      'isDeleted': isDeleted,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'documents': documents?.map((doc) {
        return doc is String ? doc : (doc as DocumentModel).toJson();
      }).toList(),
    };
  }

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      addedUser: json['addedUser'] != null
          ? List<UserModel>.from(
              (json['addedUser'] as List)
                  .map((user) => UserModel.fromJson(user)))
          : null,
      admin: json['admin'] != null
          ? List<UserModel>.from(
              (json['admin'] as List).map((user) => UserModel.fromJson(user)))
          : null,
      isDeleted: json['isDeleted'],
      createdBy: json['createdBy'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      documents: json['documents'] != null
          ? (json['documents'] as List).map((doc) {
              if (doc is String) {
                return doc;
              } else {
                return DocumentModel.fromJson(doc as Map<String, dynamic>);
              }
            }).toList()
          : null,
    );
  }

  // copyWith method
  ProjectModel copyWith({
    String? id,
    String? title,
    String? description,
    List<UserModel>? addedUser,
    List<UserModel>? admin,
    bool? isDeleted,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<dynamic>? documents,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      addedUser: addedUser ?? this.addedUser,
      admin: admin ?? this.admin,
      isDeleted: isDeleted ?? this.isDeleted,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      documents: documents ?? this.documents,
    );
  }
}
