class DocumentModel {
  final String? id;
  final String title;
  final List document;
  final List<String> users;
  final bool isPrivate;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final List<String> invitedUsers;
  final List<String> sharedUsers;
  final int sharedUserCount;

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
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    // Debug the incoming JSON
    print('Parsing JSON: $json');

    // Check for different ID field names
    String? docId;
    if (json.containsKey('_id')) {
      docId = json['_id'];
    } else if (json.containsKey('id')) {
      docId = json['id'];
    } else if (json.containsKey('documentId')) {
      docId = json['documentId'];
    }

    print('Found document ID: $docId');

    return DocumentModel(
      id: docId,
      title: json['title'] ?? 'Untitled Document',
      document: json['document'] ?? [],
      users: List<String>.from(json['users'] ?? []),
      isPrivate: json['isPrivate'] ?? false,
      createdBy: json['createdBy'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      isDeleted: json['isDeleted'] ?? false,
      invitedUsers: List<String>.from(json['invitedUsers'] ?? []),
      sharedUsers: List<String>.from(json['sharedUsers'] ?? []),
      sharedUserCount: json['sharedUserCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'document': document,
      'users': users,
      'isPrivate': isPrivate,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isDeleted': isDeleted,
      'invitedUsers': invitedUsers,
      'sharedUsers': sharedUsers,
      'sharedUserCount': sharedUserCount,
    };
  }

  DocumentModel copyWith({
    String? id,
    String? title,
    List? document,
    List<String>? users,
    bool? isPrivate,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    List<String>? invitedUsers,
    List<String>? sharedUsers,
    int? sharedUserCount,
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
    );
  }
}
