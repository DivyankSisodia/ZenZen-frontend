
class ProjectModel {
  final String? id;
  final String? title;
  final String? description;
  final List<String>? addedUser;
  final List<String>? admin;
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

  Map<String,dynamic> toJson(){
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

  factory ProjectModel.fromJson(Map<String, dynamic> json){
    return ProjectModel(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      addedUser: List<String>.from(json['addedUser']),
      admin: List<String>.from(json['admin']),
      isDeleted: json['isDeleted'],
      createdBy: json['createdBy'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      documents: List<String>.from(json['documents']),
    );
  }

  // copyWith method
  ProjectModel copyWith({
    String?id,
    String? title,
    String? description,
    List<String>? addedUser,
    List<String>? admin,
    bool? isDeleted,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? documents,
  }) {
    return ProjectModel(
      id:id ?? this.id,
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
