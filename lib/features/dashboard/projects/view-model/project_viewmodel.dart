import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenzen/data/failure.dart';

import '../../../../utils/common/custom_toast.dart';
import '../model/project_model.dart';
import '../provider/project_provider.dart';
import '../repo/project_repo.dart';

class ProjectViewmodel extends StateNotifier<AsyncValue<List<ProjectModel>>> {
  final ProjectRepository repository;
  final Ref ref;
  Timer? _debounceTimer;

  ProjectViewmodel(this.repository, this.ref)
      : super(const AsyncValue.loading());

  CustomToast customToast = CustomToast();

    bool _isLoading = false;

  Future<void> createProject(
      String title, String? description, BuildContext context) async {
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
    
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
       if (_isLoading || state is AsyncData<List<ProjectModel>>) return;

      _isLoading = true;
      state = const AsyncValue.loading();
      try {
        state = const AsyncValue.loading();

        final result = await repository.getProjects();

        result.fold(
          (listOfProjects) => state = AsyncValue.data(listOfProjects),
          (error) => state = AsyncValue.error(error, StackTrace.current),
        );
      } catch (e, stackTrace) {
        state = AsyncValue.error(e, stackTrace);
      }
    });
  }

  Future<void> addUserToProject(String projectId, List<String> userId) async {
    try {
      if (!state.isLoading) {
        state = const AsyncValue.loading();
      }

      final result = await repository.addUsers(projectId, userId);

      result.fold(
        (project) {
          state = AsyncValue.data([project]);

          getProjects();
        },
        (error) => state = AsyncValue.error(error, StackTrace.current),
      );
    } catch (e, stackTrace) {
      if (e is ApiFailure) {
        print(e.error);
      }
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // delete project
  Future<void> deleteProject(String projectId, BuildContext context) async {
    try {
      // Call repository to delete the document
      final result = await repository.deleteProject(projectId);

      result.fold(
        (success) {
          // Success case - Show success toast
          customToast.showToast('Project deleted successfully ☑️', context);

          getProjects();
        },
        (error) {
          // Error case - Show error toast
          customToast.showToast(
            // ignore: unnecessary_type_check
            error is ApiFailure ? error.error : error.toString(),
            context,
          );
        },
        // (error)=> state = AsyncValue.error(error, StackTrace.current),
      );
    } catch (e) {
      // Catch unexpected errors and show a toast
      if (e is ApiFailure) {
        print('Error deleting project: ${e.error}');
      }
      customToast.showToast(
        e is ApiFailure ? e.error : e.toString(),
        context,
      );
    }
  }
}

final projectViewModelProvider =
    StateNotifierProvider<ProjectViewmodel, AsyncValue<List<ProjectModel>>>(
        (ref) {
  final repository = ref.watch(projectRepositoryProvider);
  return ProjectViewmodel(repository, ref);
});
