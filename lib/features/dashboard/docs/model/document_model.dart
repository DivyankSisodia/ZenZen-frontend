import 'package:zenzen/features/auth/login/model/user_model.dart';

class DocumentModel {
  final String? id;
  final String title;
  final List document;
  final List<UserModel> users;
  final bool isPrivate;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final List<UserModel> invitedUsers;
  final List<UserModel> sharedUsers;
  final int sharedUserCount;
  final UserModel? admin; // Add this field

  DocumentModel({
    this.id,
    required this.title,
    required this.document,
    required this.users,
    required this.isPrivate,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.invitedUsers,
    required this.sharedUsers,
    required this.sharedUserCount,
    this.admin,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
  // Check for different ID field names
  String? docId;
  if (json.containsKey('_id')) {
    docId = json['_id'];
  } else if (json.containsKey('id')) {
    docId = json['id'];
  } else if (json.containsKey('documentId')) {
    docId = json['documentId'];
  }

  // Properly map user objects
  List<UserModel> mapUsers(List<dynamic>? usersList) {
    if (usersList == null) return [];
    return usersList.map((userJson) => 
      UserModel.fromJson(userJson as Map<String, dynamic>)
    ).toList();
  }

  // Parse admin object if present
  UserModel? admin;
  if (json['admin'] != null) {
    if (json['admin'] is Map<String, dynamic>) {
      // If admin is an object, parse it as UserModel
      admin = UserModel.fromJson(json['admin'] as Map<String, dynamic>);
    } else {
      // If admin is a string (ID), leave it as null
      // You may want to fetch the admin user separately using this ID
      // For now, we'll just not populate the admin field
    }
  }

  return DocumentModel(
    id: docId,
    title: json['title'] ?? 'Untitled Document',
    document: json['document'] ?? [],
    users: mapUsers(json['users']),
    isPrivate: json['isPrivate'] ?? false,
    createdBy: json['createdBy'] ?? '',
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : DateTime.now(),
    updatedAt: json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt'])
        : DateTime.now(),
    isDeleted: json['isDeleted'] ?? false,
    invitedUsers: mapUsers(json['invitedUsers']),
    sharedUsers: mapUsers(json['sharedUsers']),
    sharedUserCount: json['sharedUserCount'] ?? 0,
    admin: admin ,
  );
}

  DocumentModel copyWith({
    String? id,
    String? title,
    List? document,
    List<UserModel>? users,
    bool? isPrivate,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    List<UserModel>? invitedUsers,
    List<UserModel>? sharedUsers,
    int? sharedUserCount,
    UserModel? admin,
  }) {
    return DocumentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      document: document ?? this.document,
      users: users ?? this.users,
      isPrivate: isPrivate ?? this.isPrivate,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      invitedUsers: invitedUsers ?? this.invitedUsers,
      sharedUsers: sharedUsers ?? this.sharedUsers,
      sharedUserCount: sharedUserCount ?? this.sharedUserCount,
      admin: admin ?? this.admin,
    );
  }
  
  // Update toJson to include admin
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'document': document,
      'users': users.map((user) => user.toJson()).toList(),
      'isPrivate': isPrivate,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
      'invitedUsers': invitedUsers.map((user) => user.toJson()).toList(),
      'sharedUsers': sharedUsers.map((user) => user.toJson()).toList(),
      'sharedUserCount': sharedUserCount,
      'admin': admin?.toJson(),
    };
  }
}