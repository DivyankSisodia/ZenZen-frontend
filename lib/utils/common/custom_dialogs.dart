import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenzen/utils/common/custom_textfield.dart';
import 'package:zenzen/utils/theme.dart';

import '../../config/responsive.dart';
import '../../config/size_config.dart';
import '../../features/docs/model/project_model.dart';
import '../../features/docs/view-model/doc_viewmodel.dart';
import '../../features/docs/view-model/project_viewmodel.dart';
import '../../features/home/provider/select_project_provider.dart';

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
    // final authViewModel = ref.watch(authStateProvider.notifier);
    final outerContext = context;
    // authViewModel.getAllUsers();

    // Declare a local list to track selected usernames
    // final List<String> localSelectedUsernames = [];

    showDialog(
      traversalEdgeBehavior: TraversalEdgeBehavior.values[0],
      barrierDismissible: true,
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: StatefulBuilder(
            builder: (context, setStateDialog) {
              return ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: Responsive.isDesktop(context)
                      ? SizeConfig.screenWidth / 3.5
                      : SizeConfig.screenWidth / 1.5, // Adjust this value
                  minWidth: SizeConfig.screenWidth / 4.5,
                ),
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'SpaceGrotesk',
                        ),
                      ),
                      SizedBox(height: 15),
                      AutoSizeText(
                        'Project title',
                        style: AppTheme.smallBodyTheme(context),
                        maxLines: 1,
                      ),
                      SizedBox(height: 8),
                      CustomTextField(
                        controller: controller,
                        focusNode: focusNode,
                        hint: hint,
                      ),
                      SizedBox(height: 15),
                      AutoSizeText(
                        'Project Description',
                        style: AppTheme.smallBodyTheme(context),
                        maxLines: 1,
                      ),
                      SizedBox(height: 8),
                      CustomTextField(
                          controller: descriptionController,
                          focusNode: descriptionFocusNode,
                          hint: descriptionHint,
                          ),
                      SizedBox(height: 16),
                      // AutoSizeText(
                      //   'Want to add Users? 🤔',
                      //   style: AppTheme.smallBodyTheme(context),
                      //   maxLines: 1,
                      // ),
                      SizedBox(height: 8),
                      // Consumer(
                      //   builder: (context, ref, child) {
                      //     final authState = ref.watch(authStateProvider);
                      //     return authState.when(
                      //       loading: () => const Center(
                      //           child: CupertinoActivityIndicator()),
                      //       error: (err, stack) =>
                      //           Text('Error loading users: ${err.toString()}'),
                      //       data: (users) => CustomDropdown.multiSelectSearch(
                      //         searchHintText: 'Search Users',
                      //         hintBuilder: (context, hint, enabled) {
                      //           return Text(
                      //             hint,
                      //             style: TextStyle(
                      //               color: CupertinoColors.systemGrey,
                      //               fontSize: 16,
                      //               fontFamily: 'SpaceGrotesk',
                      //             ),
                      //           );
                      //         },
                      //         hintText: 'Select Users',
                      //         items: users
                      //             .map((user) => user.userName)
                      //             .whereType<String>()
                      //             .toList(),
                      //         decoration: CustomDropdownDecoration(
                      //           overlayScrollbarDecoration: ScrollbarThemeData(
                      //             mainAxisMargin: 300,
                      //             crossAxisMargin: 300,
                      //           ),
                      //           searchFieldDecoration: SearchFieldDecoration(
                      //             contentPadding:
                      //                 EdgeInsets.only(left: 16, bottom: 8),
                      //             hintStyle: TextStyle(
                      //                 color: CupertinoColors.systemGrey,
                      //                 fontFamily: 'SpaceGrotesk',
                      //                 fontSize: 16),
                      //           ),
                      //           hintStyle: TextStyle(
                      //               color: CupertinoColors.systemGrey),
                      //           listItemStyle:
                      //               TextStyle(color: CupertinoColors.black),
                      //         ),
                      //         onListChanged: (List<String> s) {
                      //           setStateDialog(() {
                      //             localSelectedUsernames.clear();
                      //             localSelectedUsernames.addAll(s);
                      //           });
                      //           final selectedUsers = users
                      //               .where((user) => s.contains(user.userName))
                      //               .toList();
                      //           final selectedUserIds = selectedUsers
                      //               .map((user) => user.id!)
                      //               .toList();
                      //           ref.read(userListProvider.notifier).state =
                      //               selectedUsers;
                      //           final dataInProvider =
                      //               ref.read(userListProvider);
                      //           print(
                      //               'Selected Users: ${dataInProvider[0].id}');
                      //           print('Selected User IDs: $selectedUserIds');
                      //         },
                      //       ),
                      //     );
                      //   },
                      // ),
                      // Display selected usernames as chips
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CupertinoButton(
                            child: Text('Cancel'),
                            onPressed: () {
                              Navigator.pop(dialogContext);
                            },
                          ),
                          CupertinoButton.filled(
                            child: Text('OK'),
                            onPressed: () {
                              // Check if fields are empty
                              if (controller.text.isEmpty ||
                                  descriptionController.text.isEmpty) {
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
                                return; // Return early without closing dialog
                              }

                              // Fields are not empty, create the project
                              final projectViewModel =
                                  ref.read(projectViewModelProvider.notifier);

                              projectViewModel.createProject(
                                controller.text,
                                descriptionController.text,
                                outerContext,
                              );

                              // Close the dialog
                              Navigator.pop(dialogContext);

                              // Show success toast
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
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
