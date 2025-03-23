import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/project_model.dart';
import '../provider/project_provider.dart';
import '../repo/project_repo.dart';

class ProjectViewmodel extends StateNotifier<AsyncValue<List<ProjectModel>>> {
  final ProjectRepository repository;
  final Ref ref;

  ProjectViewmodel(this.repository, this.ref) : super(const AsyncValue.loading());

  Future<void> createProject(String title, String? description, BuildContext context) async {
    try {
      if (!state.isLoading) {
        state = const AsyncValue.loading();
      }

      final result = await repository.createProject(title, description!);

      result.fold(
        (project) => state = AsyncValue.data([project]),
        (error) => state = AsyncValue.error(error, StackTrace.current),
      );

      // if success, naviagte to the project screen
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> getProjects() async {
    try {
      if (!state.isLoading) {
        state = const AsyncValue.loading();
      }

      final result = await repository.getProjects();

      result.fold(
        (listOfProjects) => state = AsyncValue.data(listOfProjects),
        (error) => state = AsyncValue.error(error, StackTrace.current),
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> getProjectInfo(String projectId, List<String> users) async {
    try {
      if (!state.isLoading) {
        state = const AsyncValue.loading();
      }

      final result = await repository.getProjectInfo(projectId, users);

      result.fold(
        (project) => state = AsyncValue.data([project]),
        (error) => state = AsyncValue.error(error, StackTrace.current),
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

final projectViewModelProvider = StateNotifierProvider<ProjectViewmodel, AsyncValue<List<ProjectModel>>>((ref) {
  final repository = ref.watch(projectRepositoryProvider);
  return ProjectViewmodel(repository, ref); 
});