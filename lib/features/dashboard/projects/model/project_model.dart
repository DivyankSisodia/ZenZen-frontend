import '../../../auth/login/model/user_model.dart';
import '../../docs/model/document_model.dart';

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

  // Convert List<UserModel> to List<String> (just IDs)
  List<String>? get addedUserIds => addedUser?.map((user) => user.id!).toList();
  
  // Convert List<UserModel> to List<String> (just IDs) for admin
  List<String>? get adminIds => admin?.map((user) => user.id!).toList();

  // Standard toJson that uses UserModel objects
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'addedUser': addedUser?.map((user) => user.toJson()).toList(),
      'admin': admin?.map((user) => user.toJson()).toList(),
      'isDeleted': isDeleted,
      'createdBy': createdBy,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'documents': documents?.map((doc) {
        return doc is String ? doc : (doc as DocumentModel).toJson();
      }).toList(),
    };
  }

  // Alternative toJson that uses just the user IDs
  Map<String, dynamic> toJsonWithUserIds() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'addedUser': addedUserIds,
      'admin': adminIds,
      'isDeleted': isDeleted,
      'createdBy': createdBy,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'documents': documents?.map((doc) {
        return doc is String ? doc : (doc as DocumentModel).id;
      }).toList(),
    };
  }

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['_id'] ?? json['id'],
      title: json['title'],
      description: json['description'],
      addedUser: json['addedUser'] != null
          ? _parseUserList(json['addedUser'])
          : null,
      admin: json['admin'] != null
          ? _parseUserList(json['admin'])
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

  // Helper method to parse user list which could be List<Map> or List<String>
  static List<UserModel> _parseUserList(List<dynamic> userList) {
    return userList.map((user) {
      if (user is String) {
        // If it's just a string ID, create a minimal UserModel
        return UserModel(id: user);
      } else if (user is Map<String, dynamic>) {
        // If it's a full user object
        return UserModel.fromJson(user);
      } else {
        // Fallback
        return UserModel();
      }
    }).toList();
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