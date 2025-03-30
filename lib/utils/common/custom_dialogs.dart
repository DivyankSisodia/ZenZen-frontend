// ignore_for_file: must_be_immutable

import 'dart:async';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:zenzen/data/cache/api_cache.dart';
import 'package:zenzen/data/failure.dart';
import 'package:zenzen/features/auth/login/model/user_model.dart';
import 'package:zenzen/features/auth/user/view-model/user_view_model.dart';
import 'package:zenzen/utils/common/custom_searchbar.dart';

import '../../config/constants/app_colors.dart';
import '../../config/constants/responsive.dart';
import '../../config/constants/size_config.dart';
import '../../features/dashboard/projects/model/project_model.dart';
import '../../features/dashboard/docs/view-model/doc_viewmodel.dart';
import '../../features/dashboard/projects/view-model/project_viewmodel.dart';
import '../../features/dashboard/home/provider/select_project_provider.dart';
import '../providers/select_user_provider.dart';
import '../theme.dart';

// Replace VoidCallback with void Function() if used
// typedef void Function() CallbackType;

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
                    error: (err, stack) {
                      if (err is ApiFailure) {
                        print('Error loading projects: ${err.error}');
                        return Text('Error loading projects: ${err.error}');
                      }
                      return Text('Error loading projects: ${err.toString()}');
                    },
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
                          print(projectId);
                          docViewModel.createDocument(
                            'bhele',
                            projectId,
                            outerContext,
                          );
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

    ApiCache apiCache = ApiCache();

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
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
                const SizedBox(height: 15),
                CupertinoTextField(
                  controller: descriptionController,
                  focusNode: descriptionFocusNode,
                  placeholder: descriptionHint,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                  return;
                }

                apiCache.clear();

                final projectViewModel =
                    ref.read(projectViewModelProvider.notifier);

                projectViewModel.createProject(
                  controller.text,
                  descriptionController.text,
                  outerContext,
                );

                Navigator.pop(dialogContext);

                DelightToastBar(
                  animationCurve: Curves.easeInOut,
                  animationDuration: const Duration(milliseconds: 500),
                  autoDismiss: true,
                  snackbarDuration: const Duration(seconds: 3),
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

  // timer dialogs
  static Timer? _hoverTimer;
  static bool _isHovered = false;

  // Cancel any active hover timer
  static void cancelHover() {
    _hoverTimer?.cancel();
    _isHovered = false;
  }

  static void showProjectDetailsDialog({
    required BuildContext context,
    required String? title,
    required DateTime? creationDate,
    required List? users,
    required List? admins,
    required String? description,
    required String? id,
    void Function()? onOpenProject,
  }) {
    if (!_isHovered) return;

    // Extract usernames and avatars from UserModel objects
    List<Map<String, String>> userDetails = [];
    if (users != null) {
      for (var user in users) {
        userDetails.add({
          'name': user.userName ?? "Unknown User",
          'avatar': user.avatar ?? "",
        });
      }
    }

    // Extract admin details
    List<Map<String, String>> adminDetails = [];
    if (admins != null) {
      for (var admin in admins) {
        adminDetails.add({
          'name': admin.userName ?? "Unknown Admin",
          'avatar': admin.avatar ?? "",
        });
      }
    }

    showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Padding(
          padding: const EdgeInsets.all(12),
          child: Text('Project Details', style: AppTheme.textLarge(context)),
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Project title: $title',
                style: AppTheme.textMedium(context),
              ),
              const SizedBox(height: 10),
              Text(
                'Description: $description',
                style: AppTheme.textMedium(context),
              ),
              const SizedBox(height: 10),
              Text(
                  'Created: ${DateFormat.yMMMd().format(creationDate ?? DateTime.now())}',
                  style: AppTheme.textMedium(context).copyWith(fontSize: 16)),

              // Display collaborators
              if (userDetails.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text('Collaborators:',
                    style: AppTheme.mediumBodyTheme(context)),
                const SizedBox(height: 5),
                ...userDetails.map<Widget>(
                  (user) => _buildUserRow(context, user),
                ),
              ],

              // Display admins
              if (adminDetails.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text('Admins:', style: AppTheme.mediumBodyTheme(context)),
                const SizedBox(height: 5),
                ...adminDetails.map<Widget>(
                  (admin) => _buildUserRow(context, admin),
                ),
              ],
            ],
          ),
        ),
        actions: [
          CupertinoDialogAction(
            textStyle: AppTheme.textMedium(context),
            isDefaultAction: true,
            isDestructiveAction: true,
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          CupertinoDialogAction(
            onPressed: () {
              Navigator.of(context).pop();
              if (onOpenProject != null) {
                onOpenProject();
              }
            },
            child: const Text('Open Project'),
          ),
        ],
      ),
    );
  }

  // Helper method to build user/admin row
  static Widget _buildUserRow(BuildContext context, Map<String, String> user) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, bottom: 5),
      child: Row(
        children: [
          CircleAvatar(
            radius: 15,
            backgroundImage: user['avatar']!.isNotEmpty
                ? NetworkImage(user['avatar']!)
                : null,
            child: user['avatar']!.isEmpty
                ? Text(
                    user['name']!.substring(0, 1).toUpperCase(),
                    style: AppTheme.textMedium(context).copyWith(
                      color: AppColors.lightGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Text(user['name']!,
              style: AppTheme.textMedium(context).copyWith(fontSize: 16)),
        ],
      ),
    );
  }

  static void startHoverTimer({
    required BuildContext context,
    required String? title,
    required DateTime? creationDate,
    required List? users,
    List? admins,
    required String? description,
    required String? id,
    void Function()? onOpenProject,
  }) {
    _hoverTimer?.cancel();
    _hoverTimer = Timer(const Duration(seconds: 2), () {
      _isHovered = true;
      showProjectDetailsDialog(
        context: context,
        title: title,
        creationDate: creationDate,
        users: users,
        admins: admins ?? [],
        description: description,
        id: id,
        onOpenProject: onOpenProject,
      );
    });
  }

  // Show user profile dialog
  static void showUserProfileDialog(
      {required BuildContext context,
      required String userName,
      required String email,
      required String mobile,
      required String status,
      required String avatar}) {
    if (!_isHovered) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
              child: avatar.isEmpty
                  ? Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Text(
              userName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: $email'),
            const SizedBox(height: 5),
            Text('Mobile: $mobile'),
            const SizedBox(height: 5),
            Text('Status: $status'),
            const SizedBox(height: 5),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Start hover timer
  static void startProfileHoverTimer(
      {required BuildContext context,
      required String userName,
      required String email,
      required String mobile,
      required String status,
      required String avatar}) {
    _hoverTimer?.cancel();
    _hoverTimer = Timer(const Duration(seconds: 1), () {
      _isHovered = true;
      showUserProfileDialog(
        context: context,
        userName: userName,
        email: email,
        mobile: mobile,
        status: status,
        avatar: avatar,
      );
    });
  }

  static void showAlertDialog({
    required BuildContext context,
    required String title,
    required String message,
    required String buttonText,
    void Function()? onButtonPressed,
  }) {
    showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              Navigator.of(context).pop();
              if (onButtonPressed != null) {
                onButtonPressed();
              }
            },
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  // show all users dialog
  void showMultiSelectUsersBottomSheet(String projectId, BuildContext context,
      WidgetRef ref, Function(List<UserModel>) onUsersSelected) {
    final userViewmodel = ref.read(userViewmodelProvider.notifier);
    userViewmodel.getAllUsers();

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext sheetContext) {
        return ProviderScope(
          child: Material(
            child: _MultiSelectUsersBottomSheet(
              projectId: projectId,
              onUsersSelected: onUsersSelected,
            ),
          ),
        );
      },
    );
  }
}

class _MultiSelectUsersBottomSheet extends StatelessWidget {
  String projectId;
  final Function(List<UserModel>) onUsersSelected;

  _MultiSelectUsersBottomSheet({
    required this.projectId,
    required this.onUsersSelected,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 8),
            height: 5,
            width: 40,
            alignment: Alignment.center,
            child: Container(
              height: 5,
              width: 40,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey3,
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Consumer(
                  builder: (context, ref, _) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: CupertinoColors.systemRed,
                          fontSize: 16,
                        ),
                      ),
                    );
                  },
                ),
                Text(
                  'Select Users',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'SpaceGrotesk',
                  ),
                ),
                Consumer(
                  builder: (context, ref, _) {
                    return GestureDetector(
                      onTap: () {
                        final selectedUsers = ref.read(selectedUsersProvider);

                        // Just call the callback with selected users
                        onUsersSelected(selectedUsers.cast<UserModel>());

                        // Close the bottom sheet
                        Navigator.pop(context);

                        // Clear selection state
                        ref
                            .read(selectedUsersProvider.notifier)
                            .clearSelection();
                      },
                      child: Text(
                        'Done',
                        style: TextStyle(
                          color: CupertinoColors.activeBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: VoiceSearchBar(onSearch: (value) {
              print('Search value: $value');
              // Implement filtering logic here if needed
            }),
          ),

          SizedBox(height: 8),

          // Selected count
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Consumer(
              builder: (context, ref, _) {
                final selectedUsers = ref.watch(selectedUsersProvider);
                return Text(
                  'Selected ${selectedUsers.length} users',
                  style: TextStyle(
                    color: CupertinoColors.activeBlue,
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),
          ),

          // User list
          Expanded(
            child: Container(
              margin: EdgeInsets.only(top: 8),
              child: Consumer(
                builder: (context, ref, _) {
                  final usersState = ref.watch(userViewmodelProvider);

                  return usersState.when(
                    loading: () => Center(
                      child: CupertinoActivityIndicator(),
                    ),
                    error: (err, stack) {
                      if (err is ApiFailure) {
                        return Center(
                          child: Text('Error loading users: ${err.error}'),
                        );
                      }
                      return Center(
                        child: Text('Error loading users: ${err.toString()}'),
                      );
                    },
                    data: (users) {
                      return DecoratedBox(
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemBackground,
                        ),
                        child: ListView.builder(
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final user = users[index];

                            return Consumer(
                              builder: (context, ref, _) {
                                final selectedUsers =
                                    ref.watch(selectedUsersProvider);
                                final isSelected =
                                    selectedUsers.any((u) => u.id == user.id);

                                return CupertinoListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: user.avatar != null
                                        ? NetworkImage(user.avatar!)
                                        : null,
                                    child: user.avatar == null
                                        ? Text(
                                            user.userName != null &&
                                                    user.userName!.isNotEmpty
                                                ? user.userName!
                                                    .substring(0, 1)
                                                    .toUpperCase()
                                                : '?',
                                            style: TextStyle(
                                              color: CupertinoColors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : null,
                                  ),
                                  title: Text(user.userName ?? 'Unknown User'),
                                  subtitle: Text(user.email ?? 'Unknown Email'),
                                  trailing: CupertinoCheckbox(
                                    value: isSelected,
                                    onChanged: (bool? value) {
                                      if (value == true) {
                                        ref
                                            .read(
                                                selectedUsersProvider.notifier)
                                            .addUser(user);
                                      } else {
                                        ref
                                            .read(
                                                selectedUsersProvider.notifier)
                                            .removeUser(user);
                                      }
                                    },
                                  ),
                                  onTap: () {
                                    if (isSelected) {
                                      ref
                                          .read(selectedUsersProvider.notifier)
                                          .removeUser(user);
                                    } else {
                                      ref
                                          .read(selectedUsersProvider.notifier)
                                          .addUser(user);
                                    }
                                  },
                                );
                              },
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),

          // Bottom safe area padding
          SizedBox(height: bottomPadding),
        ],
      ),
    );
  }
}
