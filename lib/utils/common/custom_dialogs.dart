import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/constants/responsive.dart';
import '../../config/constants/size_config.dart';
import '../../features/dashboard/projects/model/project_model.dart';
import '../../features/dashboard/docs/view-model/doc_viewmodel.dart';
import '../../features/dashboard/projects/view-model/project_viewmodel.dart';
import '../../features/dashboard/home/provider/select_project_provider.dart';

class CustomDialogs {
  void createDocCustomDialog(
      BuildContext context, WidgetRef ref, String title) {
    // Use the outer context for navigation, not the dialog's context
    final outerContext = context;
    final projectViewmodel = ref.read(projectViewModelProvider.notifier);

    // Fetch projects data when dialog opens
    projectViewmodel.getProjects();

    showCupertinoDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // Use dialogContext inside the builder
        return CupertinoAlertDialog(
          title: Text(title),
          content: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: SizedBox(
              width: Responsive.isMobile(dialogContext)
                  ? SizeConfig.screenWidth / 2.5
                  : SizeConfig.screenWidth / 4.5,
              height: 100,
              // Watch for changes in the projects state
              child: Consumer(
                builder: (context, ref, child) {
                  final projectsState = ref.watch(projectViewModelProvider);

                  return projectsState.when(
                    loading: () =>
                        const Center(child: CupertinoActivityIndicator()),
                    error: (err, stack) =>
                        Text('Error loading projects: ${err.toString()}'),
                    data: (projects) => CustomDropdown<String>(
                      hintBuilder: (context, hint, enabled) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            hint,
                            style: TextStyle(
                                color: CupertinoColors.systemGrey,
                                fontSize: 16,
                                fontFamily: 'SpaceGrotesk'),
                          ),
                        );
                      },
                      hintText: 'Select Project',
                      items: projects
                          .map((project) => project.title)
                          .whereType<String>()
                          .toList(),
                      decoration: CustomDropdownDecoration(
                        hintStyle: TextStyle(color: CupertinoColors.systemGrey),
                        listItemStyle: TextStyle(color: CupertinoColors.black),
                      ),
                      onChanged: (value) {
                        // Find the selected project's ID
                        final selectedProject = projects.firstWhere(
                          (project) => project.title == value,
                          orElse: () =>
                              ProjectModel(id: '', title: '', description: ''),
                        );

                        ref.read(selectedProjectIdProvider.notifier).state =
                            selectedProject.id!;

                        print('Selected Project: $value');
                        print('Selected Project ID: ${selectedProject.id}');

                        // Close the dialog first
                        Navigator.pop(dialogContext);

                        // Then use the outer context for document creation and navigation
                        // Use a slight delay to ensure the dialog is fully closed
                        Future.microtask(() {
                          final docViewModel =
                              ref.read(docViewmodelProvider.notifier);
                          final projectId = ref.read(selectedProjectIdProvider);
                          docViewModel.createDocument(
                              'bhele', projectId, outerContext);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(dialogContext);
              },
            ),
          ],
        );
      },
    );
  }

  void createProjectCustomDialog(
    String title,
    BuildContext context,
    WidgetRef ref,
    TextEditingController controller,
    FocusNode focusNode,
    String hint,
    TextEditingController descriptionController,
    FocusNode descriptionFocusNode,
    String descriptionHint,
  ) {
    final outerContext = context;

    showCupertinoDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return CupertinoAlertDialog(
          title: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'SpaceGrotesk',
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Column(
              children: [
                CupertinoTextField(
                  controller: controller,
                  focusNode: focusNode,
                  placeholder: hint,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
                const SizedBox(height: 15),
                CupertinoTextField(
                  controller: descriptionController,
                  focusNode: descriptionFocusNode,
                  placeholder: descriptionHint,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
              ],
            ),
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(dialogContext);
              },
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('OK'),
              onPressed: () {
                if (controller.text.isEmpty || descriptionController.text.isEmpty) {
                  DelightToastBar(
                    builder: (context) => const ToastCard(
                      leading: Icon(
                        Icons.flutter_dash,
                        size: 28,
                      ),
                      title: Text(
                        "Please fill all the fields",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ).show(context);
                  return;
                }

                final projectViewModel = ref.read(projectViewModelProvider.notifier);
                projectViewModel.createProject(
                  controller.text,
                  descriptionController.text,
                  outerContext,
                );

                Navigator.pop(dialogContext);

                DelightToastBar(
                  builder: (context) => const ToastCard(
                    leading: Icon(
                      Icons.check_circle,
                      size: 28,
                      color: Colors.green,
                    ),
                    title: Text(
                      "Project created successfully",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ).show(outerContext);
              },
            ),
          ],
        );
      },
    );
  }
}
