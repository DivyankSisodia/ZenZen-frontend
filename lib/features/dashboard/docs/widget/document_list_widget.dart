import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:zenzen/config/router/constants.dart';

import '../../../../config/constants/app_colors.dart';
import '../../../../utils/theme.dart';
import '../view-model/doc_viewmodel.dart';

class DocumentListWidget extends ConsumerStatefulWidget {
  const DocumentListWidget({
    super.key,
  });

  @override
  ConsumerState<DocumentListWidget> createState() => _DocumentListWidgetState();
}

class _DocumentListWidgetState extends ConsumerState<DocumentListWidget> {
  List<Color> colors = [
    AppColors.warning,
    AppColors.info,
    AppColors.success,
    AppColors.error,
  ];

  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final documents = ref.watch(docViewmodelProvider);
        return documents.when(
          data: (data) {
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.length,
              itemBuilder: (context, index) {
                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  onEnter: (event) => setState(() => isHovered = true),
                  onExit: (event) => setState(() => isHovered = false),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      boxShadow: isHovered
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
                        Icon(
                          Icons.file_copy,
                          size: 30,
                          shadows: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 10,
                            ),
                          ],
                          color: AppColors.primary,
                        ),
                        const Gap(10),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              print(data[index].id);
                              context.goNamed(RoutesName.doc, pathParameters: {'id': data[index].id!}, extra: data[index].title);
                            },
                            child: Column(
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
                                const Gap(5),
                                Row(
                                  children: [
                                    Text(
                                      data[index].isPrivate ? 'Private' : 'Public',
                                      style: AppTheme.textSmall(context).copyWith(
                                        color: AppColors.primary.withOpacity(0.7),
                                      ),
                                    ),
                                    const Gap(5),
                                    // if private then show an icon of lock
                                    if (data[index].isPrivate)
                                      Icon(
                                        Icons.lock,
                                        size: 15,
                                        color: AppColors.primary.withOpacity(0.7),
                                      ),
                                  ],
                                ),
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
                                  height: 30, // Add fixed height
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      for (int i = 0; i < data[index].users.length; i++)
                                        Positioned(
                                          right: i * 20.0,
                                          child: Tooltip(
                                            message: data[index].users[i].userName!,
                                            mouseCursor: MouseCursor.defer,
                                            child: CircleAvatar(
                                              radius: 15,
                                              backgroundColor: colors[i % colors.length],
                                              child: Text(
                                                data[index].users[i].userName!.substring(0, 1).toUpperCase(),
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
                                  DateFormat.yMMMd().format(data[index].createdAt),
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
                              title: 'Edit',
                              onTap: () {
                                print('Edit');
                              },
                              icon: CupertinoIcons.pencil,
                            ),
                            PullDownMenuItem(
                              title: 'Delete',
                              onTap: () {
                                print('Delete');
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
                            icon: Icon(Icons.menu),
                          ),
                        ),
                      ],
                    ),
                  ),
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
