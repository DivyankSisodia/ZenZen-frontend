import 'package:fpdart/fpdart.dart';
import 'package:zenzen/data/api/project_api.dart';

import '../../../data/failure.dart';
import '../model/project_model.dart';

class ProjectRepository{
  final ProjectApi remoteDataSource;

  ProjectRepository(this.remoteDataSource);

  Future<Either<ProjectModel, ApiFailure>> createProject(String title, String? description) {
    return remoteDataSource.createProject(title, description!);
  }

  Future<Either<List<ProjectModel>, ApiFailure>> getProjects() {
    return remoteDataSource.getProjects();
  }

  Future<Either<ProjectModel, ApiFailure>> getProjectInfo(String projectId, List<String> users) {
    return remoteDataSource.addUserToProject(projectId, users);
  }
}