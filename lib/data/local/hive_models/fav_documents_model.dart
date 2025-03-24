import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:zenzen/data/local/hive_models/local_user_model.dart';

part 'fav_documents_model.g.dart';

@HiveType(typeId: 1)
class FavDocument{
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

  FavDocument({
    required this.title,
    required this.projectId,
    required this.id,
    this.description,
    required this.createdAt,
    this.admin,
  });
}