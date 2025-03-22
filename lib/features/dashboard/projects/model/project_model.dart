import '../../../auth/login/model/user_model.dart';

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
  final List<String>? documents;

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
      'documents': documents,
    };
  }

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      addedUser: json['addedUser'] != null ? List<UserModel>.from(json['addedUser'].map((user) => UserModel.fromJson(user))) : null,
      admin: json['admin'] != null ? List<UserModel>.from(json['admin'].map((user) => UserModel.fromJson(user))) : null,
      isDeleted: json['isDeleted'],
      createdBy: json['createdBy'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      documents: json['documents'] != null ? List<String>.from(json['documents']) : null,
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
    List<String>? documents,
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
