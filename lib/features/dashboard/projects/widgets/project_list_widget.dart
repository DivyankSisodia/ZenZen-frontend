import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:zenzen/features/auth/login/model/user_model.dart';
import 'package:zenzen/features/dashboard/docs/view-model/doc_viewmodel.dart';
import 'package:zenzen/features/dashboard/projects/view-model/project_viewmodel.dart';
import 'package:zenzen/utils/common/custom_dialogs.dart';

import '../../../../config/constants/app_colors.dart';
import '../../../../utils/theme.dart';
import '../../docs/widget/document_list_widget.dart';

class ProjectListWidget extends ConsumerStatefulWidget {
  const ProjectListWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProjectListWidgetState();
}

class _ProjectListWidgetState extends ConsumerState<ProjectListWidget> {
  List<Color> colors = [
    AppColors.warning,
    AppColors.info,
    AppColors.success,
    AppColors.error,
  ];

  int? hoveredIndex;
  bool isHovered = false;

  CustomDialogs customDialogs = CustomDialogs();

  int? expandedIndex;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final projects = ref.watch(projectViewModelProvider);
        return projects.when(
          data: (data) {
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final isExpanded = expandedIndex == index;
                return Column(
                  children: [
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      onEnter: (event) {
                        if (expandedIndex != index) {
                          setState(() => isHovered = true);
                          CustomDialogs.startHoverTimer(
                            context: context,
                            title: data[index].title,
                            creationDate: data[index].createdAt,
                            users: data[index].addedUser,
                            admins: data[index].addedUser,
                            description: data[index].description,
                            id: data[index].id,
                            onOpenProject: () {
                              debugPrint('TODO:');
                              // context.goNamed(RoutesName.project, pathParameters: {'id': data[index].id!}, extra: data[index].title);
                            },
                          );
                        }
                      },
                      onExit: (event) {
                        setState(() => isHovered = false);
                        CustomDialogs.cancelHover();
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          boxShadow: hoveredIndex == index
                              ? [
                                  BoxShadow(
                                    color: AppColors.black.withOpacity(0.2),
                                    blurRadius: 5,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : [
                                  BoxShadow(
                                    color: AppColors.black.withOpacity(0.1),
                                    blurRadius: 2,
                                    spreadRadius: 1,
                                  ),
                                ],
                          color: AppColors.lightGrey,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                final wasExpanded = expandedIndex == index;
                                setState(() {
                                  expandedIndex = wasExpanded ? null : index;
                                });
                                if (!wasExpanded) {
                                  ref.read(docViewmodelProvider.notifier).getProjectDocs(data[index].id!);
                                }
                              },
                              child: Icon(
                                isExpanded ? Icons.folder_open : Icons.folder,
                                size: 30,
                                shadows: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 10,
                                  ),
                                ],
                                color: AppColors.primary,
                              ),
                            ),
                            const Gap(10),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  print(data[index].id);
                                  // setState(() {
                                  //   expandedIndex = isExpanded ? null : index;
                                  // });
                                  // final projects = ref.watch(projectViewModelProvider.notifier).getProjectDocs(data[index].id!);
                                  // print(projects);
                                  // context.goNamed(RoutesName.doc, pathParameters: {'id': data[index].id!}, extra: data[index].title);
                                },
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      text: TextSpan(
                                        text: data[index].title,
                                        style: AppTheme.textMedium(context),
                                      ),
                                    ),
                                    const Gap(10),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                alignment: Alignment.centerRight,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.3,
                                      height: 30,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          for (int i = 0; i < data[index].addedUser!.length; i++)
                                            Positioned(
                                              right: i * 20.0,
                                              child: Tooltip(
                                                message: data[index].addedUser![i].userName!,
                                                mouseCursor: MouseCursor.defer,
                                                child: CircleAvatar(
                                                  radius: 15,
                                                  backgroundColor: colors[i % colors.length],
                                                  child: Text(
                                                    data[index].addedUser![i].userName!.substring(0, 1).toUpperCase(),
                                                    style: AppTheme.textSmall(context).copyWith(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      DateFormat.yMMMd().format(data[index].createdAt ?? DateTime.now()),
                                      style: AppTheme.textSmall(context).copyWith(
                                        color: AppColors.primary.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Gap(20),
                            PullDownButton(
                              itemBuilder: (context) => [
                                PullDownMenuItem(
                                  title: 'Add Users',
                                  onTap: () {
                                    print('add users');
                                    customDialogs.showMultiSelectUsersBottomSheet(data[index].id!, context, ref, (List<UserModel> selectedUsers) {
                                      print('Selected users: ${selectedUsers.length}');
                                      print(selectedUsers.map((e) => e.id).toList());
                                    });
                                  },
                                  icon: CupertinoIcons.person_add,
                                ),
                                PullDownMenuItem(
                                  title: 'Delete',
                                  onTap: () {
                                    print('Delete');
                                    ref.read(projectViewModelProvider.notifier).deleteProject(data[index].id!, context);
                                  },
                                  isDestructive: true,
                                  icon: CupertinoIcons.delete,
                                ),
                                PullDownMenuItem(
                                  title: 'Share',
                                  onTap: () {
                                    print('Share');
                                  },
                                  icon: CupertinoIcons.share,
                                ),
                              ],
                              position: PullDownMenuPosition.automatic,
                              buttonBuilder: (context, showMenu) => IconButton(
                                onPressed: showMenu,
                                icon: Icon(CupertinoIcons.ellipsis),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    isExpanded
                        ? Consumer(
                            builder: (context, ref, child) {
                              return ref.watch(docViewmodelProvider).when(
                                data: (docs) {
                                  // Introduce a delay before showing the data
                                  return docs.isEmpty
                                      ? Container(
                                          margin: const EdgeInsets.only(bottom: 15),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            color: AppColors.lightGrey,
                                          ),
                                          padding: const EdgeInsets.only(top: 4.0, bottom: 10, right: 40, left: 40),
                                          child: const Text(
                                            'No documents found',
                                            style: TextStyle(color: Colors.grey),
                                          ),
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.only(top: 4.0, bottom: 10, right: 20, left: 20),
                                          child: DocumentListWidget(documents: docs),
                                        );
                                },
                                error: (error, stackTrace) {
                                  return Center(
                                    child: Text(
                                      'Error: $error',
                                      style: AppTheme.textMedium(context),
                                    ),
                                  );
                                },
                                loading: () {
                                  // Keep showing the skeleton loader during the loading state
                                  return Skeletonizer(
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: 2,
                                      itemBuilder: (context, index) {
                                        return Card(
                                          child: ListTile(
                                            title: Text('Item number $index as title'),
                                            subtitle: const Text('Subtitle here'),
                                            trailing: const Icon(
                                              Icons.ac_unit,
                                              size: 32,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              );
                            },
                          )
                        : const SizedBox(),
                  ],
                );
              },
            );
          },
          error: (error, stackTrace) {
            return Center(
              child: Text(
                'Error: $error',
                style: AppTheme.textMedium(context),
              ),
            );
          },
          loading: () {
            return SizedBox(
              height: 500,
              child: Skeletonizer(
                enabled: true,
                enableSwitchAnimation: true,
                child: ListView.builder(
                  itemCount: 6,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        title: Text('Item number $index as title'),
                        subtitle: const Text('Subtitle here'),
                        trailing: const Icon(
                          Icons.ac_unit,
                          size: 32,
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
